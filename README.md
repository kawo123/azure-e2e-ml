# Azure End-to-end Machine Learning

This repository contains end-to-end example solution based on the [Computer Hardware dataset](http://archive.ics.uci.edu/ml/datasets/Computer+Hardware) built from Azure Data Factory, Azure Data Lake Gen 2, and Azure Machine Learning Python SDK to ingest data from multiple data sources, build machine learning models, and serve machine learning models as HTTP endpoints.

## Architecture

![Azure End-to-end Machine Learning Deployment Architecture](./doc/architecture.png "Azure End-to-end Machine Learning Deployment Architecture")

1. User has data sources from [Azure SQL Database](https://azure.microsoft.com/en-us/services/sql-database/) and [Azure Cosmos Database](https://azure.microsoft.com/en-us/services/cosmos-db/)
2. User ingests data from data sources with [Azure Data Factory](https://azure.microsoft.com/en-us/services/data-factory/) to [Azure Data Lake Gen 2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction)
3. User performs data preparation using [Azure Data Factory Wrangling Data Flow](https://docs.microsoft.com/en-us/azure/data-factory/wrangling-data-flow-overview)
4. User trains machine learning model using [Azure Machine Learning Service](https://azure.microsoft.com/en-us/services/machine-learning/)
5. User deploys machine learning model to [Azure Container Instance](https://azure.microsoft.com/en-us/services/container-instances/) using [Azure Machine Learning Python SDK](https://docs.microsoft.com/en-us/python/api/overview/azure/ml/intro?view=azure-ml-py)

## Pre-requisite

- [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Azure CLI extension: ML](https://docs.microsoft.com/en-us/azure/machine-learning/service/reference-azure-machine-learning-cli)
- [jq](https://stedolan.github.io/jq/download/)

## Getting Started

- Environment preparation
  - Run `AZ_SUBSCRIPTION_ID='{subscription-id}' AZ_BASE_NAME='{unique-base-name}' AZ_REGION='{azure-region}' ./build_environment.sh`to provision the Azure environment
  - Through [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/), upload data files from `./data/*` to ADLSG2 "demo-prep" container
  - Through ADF portal, execute pipeline "PL_E2E_Demo_Prep" (under "Demp-Prep" folder) to hydrate Azure Cosmos DB and Azure SQL Database

- Through ADF portal, execute pipeline "PL_E2E_MachineData" to hydrate Azure Data Lake Gen 2 and curate the raw data into curated zone
- Through [Azure Machine Learning studio [preview]](https://ml.azure.com),
  - Upgrade AML workspace to Enterprise edition. This is required for the advanced AutoML features which this solution will use.
  - Create notebook VMs (NBVM) with unique VM name and VM size "STANDARD_DS3_V2"
  - **Note:** make sure that AML studio is scoped to the appropriate AML workspace that is created by the build automation
- Create service principal using the following command and note the output (the output is needed later for AML notebook):

```bash
az ad sp create-for-rbac \
-n "{unique-sp-name}" \
--role 'Storage Blob Data Reader' \
--scopes /subscriptions/{subscriptions-id}/resourceGroups/{rg-name}/providers/Microsoft.Storage/storageAccounts/{adlsg2-name}
```

- Through AML NBVM Jupyter:
  - Create a new terminal and clone this repository (Note: `git` is pre-installed on AML NBVM)
  - Open and walkthrough `azure-e2e-ml/aml/configuration.ipynb` to configure local environment with AML configurations
    - **Note:** you have to replace the default values of `SUBSCRIPTION_ID`, `RESOURCE_GROUP`, `WORKSPACE_NAME`, `WORKSPACE_REGION` with appropriate values in this notebook
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
