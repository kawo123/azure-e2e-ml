# Azure End-to-end Machine Learning

This repository contains end-to-end example solution based on the [Computer Hardware dataset](http://archive.ics.uci.edu/ml/datasets/Computer+Hardware) built from Azure Data Factory, Azure Data Lake Gen 2, and Azure Machine Learning Python SDK to ingest data from multiple data sources, build machine learning models, and serve machine learning models as HTTP endpoints.

## Pre-requisite

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Azure CLI: ML](https://docs.microsoft.com/en-us/azure/machine-learning/service/reference-azure-machine-learning-cli)
- [jq](https://stedolan.github.io/jq/download/)

## Getting Started

- Environment preparation
  - Run `./build_environment.sh`to provision the Azure environment
  - Through Azure Storage Explorer, copy data files from `./data/*` to ADLSG2 "demo-prep" container
  - Through ADF portal, execute pipeline "PL_E2E_Demo_Prep" to hydrate Azure Cosmos DB and Azure SQL Database

- Through ADF portal, execute pipeline "PL_E2E_MachineData" to hydrate Azure Data Lake Gen 2 and curate the raw data into curated zone
- Through Azure Machine Learning studio [preview], create notebook VMs with unique name and VM size "STANDARD_DS3_V2"

## Todos

- AML
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