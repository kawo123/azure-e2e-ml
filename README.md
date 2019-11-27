# Azure End-to-end Machine Learning

This repository contains end-to-end example solution based on the [Computer Hardware dataset](http://archive.ics.uci.edu/ml/datasets/Computer+Hardware) built from Azure Data Factory, Azure Data Lake Gen 2, and Azure Machine Learning Python SDK to ingest data from multiple data sources, build machine learning models, and serve machine learning models as HTTP endpoints.

## Pre-requisite

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Azure CLI: ML](https://docs.microsoft.com/en-us/azure/machine-learning/service/reference-azure-machine-learning-cli)
- [jq](https://stedolan.github.io/jq/download/)

## Getting Started

- Environment preparation
  - Run `AZ_SUBSCRIPTION_ID='{subscription-id}' AZ_BASE_NAME='{unique-base-name}' AZ_REGION='{azure-region}' ./build_environment.sh`to provision the Azure environment
  - Through Azure Storage Explorer, copy data files from `./data/*` to ADLSG2 "demo-prep" container
  - Through ADF portal, execute pipeline "PL_E2E_Demo_Prep" to hydrate Azure Cosmos DB and Azure SQL Database

- Through ADF portal, execute pipeline "PL_E2E_MachineData" to hydrate Azure Data Lake Gen 2 and curate the raw data into curated zone
- Through Azure Machine Learning studio [preview], create notebook VMs (NBVM) with unique name and VM size "STANDARD_DS3_V2"
- Create service principal using the following command and note the output (the output is needed for later AML notebook):

```bash
az ad sp create-for-rbac \
-n "{unique-sp-name}" \
--role 'Storage Blob Data Reader' \
--scopes /subscriptions/{subscriptions-id}/resourceGroups/{rg-name}/providers/Microsoft.Storage/storageAccounts/{adlsg2-name}
```
- Through AML NBVM JupyterLab:
  - Open a terminal
  - Clone this repository (Note: `git` is pre-installed on AML NBVM)

- Through AML NBVM Jupyter:
  - Open and walkthrough `azure-e2e-ml/aml/configuration.ipynb` to configure local environment with AML configurations
  - Open and walkthrough `azure-e2e-ml/aml/auto-ml-regression-hardware-performance-explanation-and-featurization.ipynb` to build and deploy model
  - Note: Currently, mini-widget is not support in JupyterLab. Thus, we are using Jupyter for executing the notebook. There is a [GitHub issue](https://github.com/Azure/MachineLearningNotebooks/issues/666) opened to track the issue.

## Todos

- Architecture diagram
- Automation: build script

---

### PLEASE NOTE FOR THE ENTIRETY OF THIS REPOSITORY AND ALL ASSETS

1. No warranties or guarantees are made or implied.
2. All assets here are provided by me "as is". Use at your own risk. Validate before use.
3. I am not representing my employer with these assets, and my employer assumes no liability whatsoever, and will not provide support, for any use of these assets.
4. Use of the assets in this repo in your Azure environment may or will incur Azure usage and charges. You are completely responsible for monitoring and managing your Azure usage.

---

Unless otherwise noted, all assets here are authored by me. Feel free to examine, learn from, comment, and re-use (subject to the above) as needed and without intellectual property restrictions.

If anything here helps you, attribution and/or a quick note is much appreciated.
