#!/usr/bin/env bash
#
#  - Environment build script for end-to-end machine learning environment
#
# Usage:
#
#  AZ_SUBSCRIPTION_ID=1234 AZ_BASE_NAME='random-123' ./build_environment.sh
#
# Based on a template by BASH3 Boilerplate v2.3.0
# http://bash3boilerplate.sh/#authors
#
# The MIT License (MIT)
# Copyright (c) 2013 Kevin van Zonneveld and contributors
# You are not obligated to bundle the LICENSE file with your b3bp projects as long
# as you leave these references intact in the header comments of your source files.

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace


# Environment variables (and their defaults) that this script depends on
AZ_SUBSCRIPTION_ID="${AZ_SUBSCRIPTION_ID:-1234}"                        # Azure subscription id
ARM_TEMPLATE_PATH="${ARM_TEMPLATE_PATH:-./arm/azure_environment.json}"  # File path to Azure environment ARM template
ADF_TEMPLATE_PATH="${ADF_TEMPLATE_PATH:-./adf/adf_environment.json}"    # File path to Azure Data Factory environment ARM template
AZ_REGION="${AZ_REGION:-eastus}"                                        # Azure region
AZ_BASE_NAME="${AZ_BASE_NAME:-GEN-UNIQUE}"                              # Base name for Azure resources


### Functions
##############################################################################

function __b3bp_log () {
  local log_level="${1}"
  shift

  # shellcheck disable=SC2034
  local color_info="\x1b[32m"
  local color_warning="\x1b[33m"
  # shellcheck disable=SC2034
  local color_error="\x1b[31m"

  local colorvar="color_${log_level}"

  local color="${!colorvar:-${color_error}}"
  local color_reset="\x1b[0m"

  if [[ "${NO_COLOR:-}" = "true" ]] || [[ "${TERM:-}" != "xterm"* ]] || [[ ! -t 2 ]]; then
    if [[ "${NO_COLOR:-}" != "false" ]]; then
      # Don't use colors on pipes or non-recognized terminals
      color=""; color_reset=""
    fi
  fi

  # all remaining arguments are to be printed
  local log_line=""

  while IFS=$'\n' read -r log_line; do
    echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" "${log_level}")${color_reset} ${log_line}" 1>&2
  done <<< "${@:-}"
}

function error ()     { __b3bp_log error "${@}"; true; }
function warning ()   { __b3bp_log warning "${@}"; true; }
function info ()      { __b3bp_log info "${@}"; true; }


### Runtime
##############################################################################

if ! [ -x "$(command -v az)" ]; then
  error "command not found: az. Please install Azure CLI before executing this setup script. See https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest to install Azure CLI."
  exit 1
fi

# if ! [ -x "$(command -v azcopy)" ]; then
#   error "command not found: azcopy. Please install jq before executing this setup script. See https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10#download-azcopy to install AzCopy."
#   exit 1
# fi

if ! [ -x "$(command -v jq)" ]; then
  error "command not found: jq. Please install jq before executing this setup script."
  exit 1
fi

if ! az ml -h > /dev/null ; then
  info "Az extension 'ml' is not installed. Intalling now"
  az extension add -y -n azure-cli-ml
  info "Az extension 'ml' is installed now"
fi

az_aml_rg_name="${AZ_BASE_NAME}-rg"

info "Initiating login to Azure"
az login > /dev/null
info "Successfully login to Azure"

info "Setting Az CLI subscription context to '${AZ_SUBSCRIPTION_ID}'"
az account set \
--subscription "${AZ_SUBSCRIPTION_ID}"

info "Creating resource group '${az_aml_rg_name}' in region '${AZ_REGION}'"
az group create \
--subscription "${AZ_SUBSCRIPTION_ID}" \
--location "${AZ_REGION}" \
--name "${az_aml_rg_name}" 1> /dev/null

info "Validating ARM template '${ARM_TEMPLATE_PATH}' deployment to resource group '${az_aml_rg_name}'"
az group deployment validate \
--resource-group "${az_aml_rg_name}" \
--template-file "${ARM_TEMPLATE_PATH}" \
--parameters location="${AZ_REGION}" baseName="${AZ_BASE_NAME}" > /dev/null

if [ $? -eq 0 ]; then
  info "ARM template validation passes"
else
  error "ARM template validation fails. Exiting.."
  exit 1
fi

info "Deploying ARM template '${ARM_TEMPLATE_PATH}' deployment to resource group '${az_aml_rg_name}'"
arm_template_output=$(az group deployment create \
--resource-group "${az_aml_rg_name}" \
--template-file "${ARM_TEMPLATE_PATH}" \
--parameters location="${AZ_REGION}" baseName="${AZ_BASE_NAME}" | jq ".properties.outputs")
echo $arm_template_output | jq
info "ARM template deployment finishes"

azure_cosmos_db_conn_str=$(echo $arm_template_output | jq -r '.azureCosmosDbConnectionString.value' )
# echo $azure_cosmos_db_conn_str
azure_sql_db_conn_str=$(echo $arm_template_output | jq -r '.azureSqlDatabaseConnectionString.value' )
# echo $azure_sql_db_conn_str
adlsg2_account_key=$(echo $arm_template_output | jq -r '.azureDataLakeGen2AccountKey.value' )
# echo $adlsg2_account_key
adlsg2_url=$(echo $arm_template_output | jq -r '.azureDataLakeGen2PropertiesUrl.value' )
# echo $adlsg2_url

info "Validating ADF ARM template '${ADF_TEMPLATE_PATH}' deployment to resource group '${az_aml_rg_name}'"
az group deployment validate \
--resource-group "${az_aml_rg_name}" \
--template-file "${ADF_TEMPLATE_PATH}" \
--parameters location="${AZ_REGION}" \
baseName="${AZ_BASE_NAME}" \
AzureDataLakeGen2_accountKey="${adlsg2_account_key}" \
AzureSqlDatabaseServerless_connectionString="${azure_sql_db_conn_str}" \
AzureCosmosDBSQL_connectionString="${azure_cosmos_db_conn_str}" \
AzureDataLakeGen2_properties_typeProperties_url="${adlsg2_url}" > /dev/null

if [ $? -eq 0 ]; then
  info "ADF ARM template validation passes"
else
  error "ADF ARM template validation fails. Exiting.."
  exit 1
fi

info "Deploying ADF ARM template '${ADF_TEMPLATE_PATH}' deployment to resource group '${az_aml_rg_name}'"
az group deployment create \
--resource-group "${az_aml_rg_name}" \
--template-file "${ADF_TEMPLATE_PATH}" \
--parameters location="${AZ_REGION}" \
baseName="${AZ_BASE_NAME}" \
AzureDataLakeGen2_accountKey="${adlsg2_account_key}" \
AzureSqlDatabaseServerless_connectionString="${azure_sql_db_conn_str}" \
AzureCosmosDBSQL_connectionString="${azure_cosmos_db_conn_str}" \
AzureDataLakeGen2_properties_typeProperties_url="${adlsg2_url}" > /dev/null
info "ADF ARM template deployment finishes"

# TODO: upload data to ADLSG2, azcopy
# azcopy login --tenant-id "72f988bf-86f1-41af-91ab-2d7cd011db47"
# Error: failed to perform login command, failed to get keyring during saving token, function not implemented
# https://github.com/Azure/azure-storage-azcopy/issues/193
# azcopy copy './data/*.csv' 'https://e2emlkwfadlsg2.dfs.core.windows.net/demo-prep/'

# TODO: obtain token from AAD
# https://docs.microsoft.com/en-us/rest/api/azure/#register-your-client-application-with-azure-ad
# TODO: execute ADF demo prep pipeline using REST API
# curl -v \
# -X POST \
# -H "Content-Type: application/json" \
# -H "Content-Length: 0" \
# -H "Authorization: {token}" \
# https://management.azure.com/subscriptions/{azure-subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.DataFactory/factories/{adf-name}/pipelines/{adf-pipeline-name}/createRun?api-version=2017-03-01-preview
