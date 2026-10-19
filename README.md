

# E-Commerce Sales, Customer Behavior & Operations Analytics (T-SQL)

[![Database: SQL Server](https://img.shields.io/badge/Database-Microsoft%20SQL%20Server-CC292B?logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/sql-server)
[![Language: T-SQL](https://img.shields.io/badge/Language-T--SQL-blue)](https://docs.microsoft.com/sql/t-sql/)
[![Tool: SSMS](https://img.shields.io/badge/IDE-SSMS-orange)](https://docs.microsoft.com/sql/ssms/)
[![Project Status: Complete](https://img.shields.io/badge/Status-Complete-brightgreen)](#)

An end-to-end database engineering and advanced analytics project querying **138,116+ transactions** spanning 2021–2025 across a 4-table relational architecture. Built entirely in Microsoft SQL Server and SSMS, this project demonstrates production data hygiene, referential integrity enforcement, query optimization (resolving TempDB spools), and progressive business intelligence using **Multi-Table Joins, Comparative Subqueries, Window Functions, Multi-Stage CTEs, and a Flagship Capstone Synthesis**.

---

##  Table of Contents
1. [Executive Summary & Core Discoveries](#1-executive-summary--core-discoveries)
2. [Database Architecture & Entity Relationships](#2-database-architecture--entity-relationships)
3. [Data Ingestion, Schema Auditing & Integrity Pre-Checks](#3-data-ingestion-schema-auditing--integrity-pre-checks)
4. [Progressive Analytical Query Suite](#4-progressive-analytical-query-suite)
   * [Stage 1: Multi-Table Relational JOINs (Question 23)](#stage-1-multi-table-relational-joins)
   * [Stage 2: Comparative Subqueries (Question 5)](#stage-2-comparative-subqueries)
   * [Stage 3: Window Functions (Questions 1 & 3)](#stage-3-window-functions)
   * [Stage 4: Multi-Stage CTEs (Question 19)](#stage-4-multi-stage-ctes)
   * [Stage 5: Flagship Capstone Synthesis (Question 25)](#stage-5-flagship-capstone-synthesis)
5. [Query Performance & TempDB Optimization](#5-query-performance--tempdb-optimization)
6. [Repository Structure & How to Run](#6-repository-structure--how-to-run)

---

## 1. Executive Summary & Core Discoveries

Rather than building basic descriptive charts, this analysis addresses commercial e-commerce questions: regional margins, customer purchase velocity, and identifying hidden profit leakages caused by habitual returners.

###  Key Business Findings
* **Regional Profit Concentration (Q23):** The **South region** is the company's primary profit driver, sweeping the top 3 highest-earning spots company-wide: **Electronics (\$14.28M sales / \$4.27M profit)**, **Jewelry (\$8.98M sales / \$3.26M profit)**, and **Home Appliances (\$8.59M sales / \$3.17M profit)**. Electronics ranks as the #1 profit generator across all 5 geographic regions.
* **Granular Spend Benchmarking (Q5):** Differentiating individual transaction price averages (~\$519) from total customer lifetime spend identified VIP accounts contributing upwards of **\$30,000 to \$39,000+** in gross sales.
* **Product Revenue Skew (Q1 & Q3):** In Electronics, individual flagship items (OnePlus Gaming Consoles at \$1.03M, Xiaomi Gaming Consoles at \$1.02M, and Asus TVs at \$1.01M) each exceeded **\$1,000,000+** in gross revenue, while category leaders in Automotive peaked at ~\$456K and Baby & Kids at ~\$276K.
* **The 10-Month Repurchase Window (Q19):** Across 24,387 repeat customers, the average lag between order #1 and order #2 is **~308 to ~321 days (~10 months)** across all segments (Consumer, Premium, Business, VIP). This provides the marketing team with a defined re-engagement window before churn risk escalates.
* **The "High-Spend Margin Trap" (Q25 Capstone):** Filtering spend quintiles against company return benchmarks revealed that several top-tier spenders (spending \$12K–\$15K+) exhibit **return rates between 66% and 68.42%**—nearly **10x higher than the company baseline (~6.85%)**. These accounts severely erode operating margin through reverse logistics and restocking overhead.

---

## 2. Database Architecture & Entity Relationships

The relational schema connects 4 core tables enforcing primary keys (`PK`) and foreign keys (`FK`):

<img width="975" height="874" alt="image" src="https://github.com/user-attachments/assets/2bd62945-75f0-47e0-8f04-652b923aa03d" />

*Figure 1: SSMS Database Diagram displaying enforced 1-to-many relationships and foreign key bindings across the 4 relational tables.*

---

## 3. Data Ingestion, Schema Auditing & Integrity Pre-Checks

### A. Defensive Data Type Corrections
During staging ingestion via the SSMS Import Flat File Wizard, column configurations were manually audited:
* **Postal Code Truncation Defense:** Overrode default `INT` inference to `NVARCHAR(50)` on `customer_postal_code` to preserve leading zeros (e.g., `04028`, `06357`) and accommodate international alphanumeric postal formats.
* **String Truncation Defense:** Expanded descriptive attributes to `NVARCHAR(250)` to prevent runtime truncation errors on long text values.
* **Primary Key Enforcement:** Formally designated `order_id`, `customer_id`, and `product_id` as primary keys with `NOT NULL` enforced on master tables.

<img width="638" height="574" alt="image" src="https://github.com/user-attachments/assets/6216eb7c-d94c-417f-a59d-7a77424347d0" />

*Figure 2: SSMS Flat File Import Wizard showing explicit data typing, character capacity expansion, and PK enforcement.*

### B. Defensive Referential Integrity Audit (0 Orphan Records)
Before applying DDL constraints, defensive verification queries checked for unlinked records across child-parent relationships:
<img width="728" height="393" alt="image" src="https://github.com/user-attachments/assets/08ee19c5-0037-4e0d-a001-29f4c376d7de" />

### C. Constraint Enforcement (DDL)
With referential integrity confirmed, foreign key constraints were bound to the database engine:
<img width="975" height="167" alt="image" src="https://github.com/user-attachments/assets/2be19986-b3c5-4bf4-a50b-3c6b6c3246ed" />

### 4. Progressive Analytical Query Suite
### Stage 1: Multi-Table Relational JOINs
Business Question Answered : "Does purchasing behavior differ by region? Which product categories drive the highest sales and margins across different geographic regions?"

Connects all 4 relational tables to analyze regional sales and net profit margins by category.

<img width="975" height="514" alt="image" src="https://github.com/user-attachments/assets/68e02eca-158d-4258-b1c7-071be55f235f" />

### Stage 2: Comparative Subqueries
Business Question Answered: "Which individual customers spent more money in total than the average customer did?"

Uses a nested scalar subquery in the HAVING clause to compute the true average lifetime spend per user account across the entire store before filtering individual customer totals.

<img width="882" height="473" alt="image" src="https://github.com/user-attachments/assets/50b5398d-5b2c-4996-8474-cfc715288b71" />

### Stage 3: Window Functions
Business Questions Answered : "Which products generate the highest revenue within each category, and what are the top 3 best-selling products per category?"

Uses dense_rank()  within a derived table to identify the top 3 products per category without collapsing product row grain.

<img width="975" height="487" alt="image" src="https://github.com/user-attachments/assets/e01d1e2e-3253-49c9-ab24-4c840ead2097" />

### Stage 4: Multi-Stage CTEs
Business Question Answered: "How does customer behavior change over time? (Repurchase Velocity — For repeat customers, how many days elapsed between their 1st order and their 2nd order?)"

A 2 stage CTE pipeline tracking sequential order dates via row_number() and computing elapsed days to order 2 via datediff() and lag().

<img width="975" height="381" alt="image" src="https://github.com/user-attachments/assets/2f1e18ee-7e0d-4830-9e59-b0ef4b291737" />

### Stage 5: Flagship Capstone Synthesis
Business Question Answered: "What hidden relationships exist between customers, products, sales, and operations?"

Combines a 3-table join, 2-stage CTE pipeline, window functions (ntile(5) spend tiers, dense_rank() profit rank), and subquery filtering against storewide averages to identify high-spending customers whose return behavior creates hidden operational friction.

<img width="975" height="364" alt="image" src="https://github.com/user-attachments/assets/10afec59-72d1-42b4-afaa-a9dc48c0c0f2" />

<img width="975" height="503" alt="image" src="https://github.com/user-attachments/assets/2dab963b-8342-4e32-a946-518bcf49df9c" />

### 6. Repository Structure & How to Run

├── sql/
│   └── ecommerce_analytics_suite.sql # The master SQL script containing all stages
└── README.md                         # Master GitHub case study









