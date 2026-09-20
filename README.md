# Azure-transit-data-platform
An end-to-end Azure data engineering pipeline that ingests, stores, and loads Karachi public bus route data into a queryable relational store, enabling analysis such as identifying routes most prone to delays.

## Architecture

![Architecture Diagram](Architecture%20Diagram.PNG)

## Tech Stack

| Layer | Service |
|---|---|
| Storage | Azure Data Lake Storage Gen2 (bronze / silver zones) |
| Orchestration | Azure Data Factory |
| Database | Azure SQL Database |
| Secrets Management | Azure Key Vault |
| Identity & Access | Azure RBAC + Managed Identity |

## Pipeline Design

**Pipeline 1 — `pl_bronze_to_silver`**
Copies all raw CSV files from the bronze container to silver in a single Copy Activity using a wildcard path (`*.csv`), since no schema specific transformation is needed at this stage just a raw landing-zone move.

**Pipeline 2 — `p2_silver_to_azuresql`**
Loads each silver file into its corresponding Azure SQL table using three parallel Copy Activities (`routes`, `stops`, `stop_times`), each with its own schema mapping necessary because each file has a distinct column structure.

## Security

- No hardcoded credentials anywhere in the pipeline.
- ADF connects to ADLS Gen2 via **System-Assigned Managed Identity**.
- The Azure SQL Database password is stored in **Azure Key Vault** and referenced by ADF's Linked Service at runtime.
- Access to both Storage and Key Vault is granted via least-privilege **RBAC roles** (`Storage Blob Data Contributor`, `Key Vault Secrets User`).

## Dataset
The dataset used in this project is published on Kaggle: [Karachi Public Transit Routes and Stops](https://www.kaggle.com/datasets/arooba21/karachi-public-transit-routes-and-stops)

## Screenshots


**Pipeline 2 (3 parallel Copy Activities succeeded)**

![Pipeline Run](Screenshots/p2%20silver%20to%20azure%20sql.PNG)

**Detailed activity run (Succeeded status)**
![Successful Debug Run](Screenshots/successful%20debug%20run.PNG)

**Provisioned resources in the resource group**
![Resource Group](Screenshots/resource%20groups.PNG)

**Sample Analysis Result (Average delay per route)**
![Analysis Result](Screenshots/Analysis%20result.PNG)

## Sample Analysis

```sql
SELECT
    r.route_name,
    AVG(CAST(st.delay_minutes AS FLOAT)) AS avg_delay_minutes,
    COUNT(st.stop_id) AS total_stops
FROM stop_times st
JOIN routes r ON st.route_id = r.route_id
GROUP BY r.route_name
ORDER BY avg_delay_minutes DESC;
```

This identifies which routes have the highest average delay.

## Repository Contents

```text
├── README.md
├── Architecture Diagram.PNG
├── sql/
│   ├── create_tables.sql        # Table definitions for Azure SQL Database
│   └── analysis_queries.sql     # Sample analytical query
├── adf_templates/
│   └── (exported ARM templates from azure)
└── Screenshots/
    └── (pipeline runs, query results, resource group)
```

## Key Learnings

- Designing wildcard-based Copy Activities for raw, schema-agnostic file movement vs. schema-specific loads for structured targets.
- Managing service-to-service authentication in Azure purely through RBAC and Managed Identity, with zero hardcoded secrets.
- Structuring a multi-file ingestion pipeline (parallel Copy Activities) rather than a single monolithic one.
