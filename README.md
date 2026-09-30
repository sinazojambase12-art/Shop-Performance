# 🛒 Shop Performance Case Study — Python Data Analysis

## 📌 Project Overview

This project analyses the performance of an online shop that sells electronics, accessories, wearables, home office items, stationery, and gaming products.

The objective is to transform four raw datasets into meaningful business insights that help answer the question:

> **How is the shop performing?**

The analysis covers the period from **January 2024 to June 2026** and was completed using **Python and Jupyter Notebook**.

The project focuses on data cleaning, data integration, exploratory data analysis, business metrics, visualisation, and actionable recommendations.

---

## 🎯 Business Objectives

The analysis aims to answer the following business questions:

* How much revenue did the shop generate?
* How many orders were placed?
* What was the average order value?
* Is revenue growing, declining, or remaining stable over time?
* Are there noticeable seasonal peaks?
* Which products and categories generate the most revenue?
* Which products sell the most units?
* Which cities and customer segments are the most valuable?
* What percentage of orders are cancelled or returned?
* What percentage of payments fail?
* Do some payment methods have higher failure rates?
* Do larger discounts result in larger orders or lower revenue?

These questions follow the requirements of the case study.

---

## 📂 Dataset

The project uses four CSV files.

| File            | Description            | Key Columns                                                                          |
| --------------- | ---------------------- | ------------------------------------------------------------------------------------ |
| `customers.csv` | Customer information   | CustomerID, Age, City, SignupDate, CustomerSegment                                   |
| `orders.csv`    | Order-line information | OrderID, CustomerID, OrderDate, ProductID, Quantity, Discount, PaymentMethod, Status |
| `payments.csv`  | Payment attempts       | PaymentID, OrderID, PaymentDate, PaymentStatus                                       |
| `products.csv`  | Product catalogue      | ProductID, ProductName, Category, UnitPrice                                          |

The datasets are connected through:

```text
Customers
    │
    │ CustomerID
    ▼
  Orders ────────── ProductID ──────────► Products
    │
    │ OrderID
    ▼
 Payments
```

The relationships between the four datasets are defined in the case study.

---

## 🛠️ Technologies Used

* **Python**
* **Jupyter Notebook**
* **Pandas** — data manipulation and analysis
* **NumPy** — numerical calculations
* **Matplotlib** — data visualisation
* **Seaborn** — statistical visualisation
* **Git & GitHub** — version control and project sharing

---

## 🔍 Project Workflow

### 1. Data Loading

The four CSV datasets were imported into Python using Pandas.

```python
import pandas as pd

customers = pd.read_csv("customers.csv")
orders = pd.read_csv("orders.csv")
payments = pd.read_csv("payments.csv")
products = pd.read_csv("products.csv")
```

The datasets were then inspected to understand their structure, number of rows and columns, data types and contents.

---

### 2. Data Cleaning

Before performing calculations, the datasets were checked for common data-quality problems.

The following were investigated:

* Missing values
* Duplicate order records
* Invalid numerical values
* Product price ranges
* Inconsistent city names
* Broken customer links
* Broken product links

The case study specifically requires these data-quality checks before analysis.

### Cleaning Decisions

The analysis identified **120 duplicate order rows**. These were removed to prevent duplicate records from artificially increasing sales and revenue calculations.

There were also **30 orders whose `CustomerID` did not match a customer in the customer dataset**. These records were retained for appropriate order-level analysis but were excluded from customer-level analysis where customer information was required.

Product links were checked to ensure that orders referenced valid products.

Missing values were assessed according to their purpose rather than automatically deleting every row containing a null value.

---

## 🔗 3. Combining the Data

The `orders` table was used as the main analytical table.

The tables were joined using:

* `ProductID` → Products
* `CustomerID` → Customers
* `OrderID` → Payments

Left joins were used to preserve the order records while adding available information from the other datasets.

```python
orders_products = orders.merge(
    products,
    on="ProductID",
    how="left"
)

orders_customers = orders_products.merge(
    customers,
    on="CustomerID",
    how="left"
)

final_data = orders_customers.merge(
    payments,
    on="OrderID",
    how="left"
)
```

The row count was checked after each join to ensure that the merging process did not unexpectedly duplicate or remove records.

---

## 🧮 4. Feature Engineering

New analytical columns were created from the existing data.

### Revenue

Revenue was calculated using the formula specified in the case study:

```text
Revenue = Quantity × UnitPrice × (1 − Discount)
```

Python implementation:

```python
final_data["Revenue"] = (
    final_data["Quantity"]
    * final_data["UnitPrice"]
    * (1 - final_data["Discount"])
)
```

### Date Features

The `OrderDate` column was converted to a datetime format and used to create:

* Year
* Month
* Month Name
* Year-Month

These columns allow revenue and order trends to be analysed over time.

The case study specifically requires Revenue, Year and Month to be created.

---

## 📊 5. Exploratory Data Analysis

The analysis calculates key business performance indicators including:

### Sales Performance

* Total revenue
* Total orders
* Average order value
* Total units sold

### Time Trends

* Monthly revenue
* Monthly order volume
* Yearly performance
* Seasonal patterns

### Product Performance

* Revenue by product
* Units sold by product
* Revenue by category
* Units sold by category

### Customer Analysis

* Revenue by city
* Revenue by customer segment
* Order volume by customer segment
* Average order value by customer segment

### Order & Payment Analysis

* Cancelled orders
* Returned orders
* Payment failures
* Payment failure rate by payment method

### Discount Analysis

The project also investigates whether larger discounts are associated with:

* Larger order quantities
* Higher order values
* Lower revenue

---

## 📈 6. Data Visualisation

The project uses charts to communicate the findings clearly to a non-technical business audience.

The main visualisations include:

* 📈 Monthly revenue trend line chart
* 📊 Revenue by product
* 📊 Revenue by category
* 📊 Revenue by customer segment
* 📊 Revenue by city
* 📊 Payment failure rates
* 📊 Discount versus order/revenue analysis
* 🔢 KPI summary metrics

The visualisation approach follows the case study recommendation of using line charts for trends, bar charts for comparisons, and KPI cards for headline figures.

---

## 💡 Key Findings

The notebook presents the calculated findings from the cleaned dataset, including:

1. Overall shop revenue and order performance.
2. Monthly revenue patterns and potential seasonal trends.
3. The products and categories contributing the most revenue.
4. The products and categories selling the most units.
5. The most valuable customer segments and locations.
6. Order cancellation and return rates.
7. Payment failure rates and differences between payment methods.
8. The relationship between discounts, order size and revenue.

All numerical findings are calculated directly from the project datasets.

---

## 🚀 Business Recommendations

The final section of the project provides **three practical recommendations** for the Head of Operations.

The recommendations are based on the results of the analysis and focus on areas such as:

### 1. Product & Category Strategy

Focus attention on products and categories that demonstrate strong revenue and/or unit performance.

### 2. Customer Strategy

Use customer segment and city-level performance to identify where customer retention and sales activity can be strengthened.

### 3. Payment & Discount Optimisation

Investigate payment methods with higher failure rates and evaluate discount strategies to ensure that promotions generate additional sales without unnecessarily reducing revenue.

The recommendations are linked directly to the numerical findings rather than being based on assumptions.

---

## 📁 Project Structure

```text
shop-performance-case-study/
│
├── data/
│   ├── customers.csv
│   ├── orders.csv
│   ├── payments.csv
│   └── products.csv
│
├── notebooks/
│   └── Shop_Performance_Case_Study.ipynb
│
├── outputs/
│   ├── cleaned_data.csv
│   └── charts/
│
├── README.md
└── requirements.txt
```

---

## ▶️ How to Run the Project

### 1. Clone the repository

```bash
git clone https://github.com/YOUR-USERNAME/shop-performance-case-study.git
```

### 2. Navigate to the project

```bash
cd shop-performance-case-study
```

### 3. Install the required libraries

```bash
pip install pandas numpy matplotlib seaborn jupyter
```

### 4. Launch Jupyter Notebook

```bash
jupyter notebook
```

### 5. Open the notebook

Open:

```text
notebooks/Shop_Performance_Case_Study.ipynb
```

Run the notebook cells from top to bottom.

---

## 🧹 Data Quality Notes

The project does not simply delete all records containing missing values.

Instead, each data-quality issue is assessed according to its impact on the relevant analysis.

Key cleaning decisions include:

* Exact duplicate order records were removed.
* Missing customer relationships were identified.
* Orders with valid product and transaction information were retained where appropriate.
* Customer-level analysis excludes records where the customer cannot be reliably identified.
* Product links were checked for validity.
* Numerical values were inspected for implausible ranges.
* City names were checked for inconsistent formatting.

This approach helps maintain the integrity of the analysis while avoiding unnecessary loss of information.

---

## 📌 Deliverables

The project produces:

* A cleaned analytical dataset
* A complete Jupyter Notebook
* Exploratory data analysis
* Business KPIs
* Data visualisations
* Data-quality documentation
* Three actionable business recommendations

The final deliverable is designed for a non-technical Head of Operations and therefore focuses on **simple numbers, clear charts and plain-language explanations**, as requested in the case study.

---

## 👤 Author

**Sinazo**

Data Analysis Project
Python | Pandas | Matplotlib | Seaborn | Jupyter Notebook

---

## 📚 Case Study

This project was completed as a beginner-level data analysis case study focused on understanding the performance of an online shop using four interconnected datasets.

The analysis follows the required workflow:

**Understand → Clean → Combine → Create → Analyse → Visualise → Recommend**

