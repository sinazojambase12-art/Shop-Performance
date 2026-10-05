# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "6"
# ///
# MAGIC %md
# MAGIC ### Import Libraries

# COMMAND ----------

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# COMMAND ----------

# MAGIC %md
# MAGIC ### Data Ingestions

# COMMAND ----------

# MAGIC %md
# MAGIC #### 1.Loading the tables

# COMMAND ----------

# DBTITLE 1,Customers
customers = spark.table("brightlearn.shop_performance.customers")
customers=customers.toPandas()

# COMMAND ----------

# DBTITLE 1,Orders
orders = spark.table("brightlearn.shop_performance.orders")
orders=orders.toPandas()

# COMMAND ----------

# DBTITLE 1,Payments
payments = spark.table("brightlearn.shop_performance.payments")
payments=payments.toPandas()

# COMMAND ----------

# DBTITLE 1,Products
products = spark.table("brightlearn.shop_performance.products")
products=products.toPandas()

# COMMAND ----------

# MAGIC %md
# MAGIC ### Exploratory Data Analysis

# COMMAND ----------

# MAGIC %md
# MAGIC #### 1.Customers EDA

# COMMAND ----------

# Show how the customers table look like
display(customers)

# COMMAND ----------

# Showing the size of the table
customers.shape

# COMMAND ----------

# Previewing the top 5 dataset
customers.head()

# COMMAND ----------

# Checking the data types
customers.dtypes

# COMMAND ----------

# Shows the summary of the table
customers.info()

# COMMAND ----------

# Showing the statistical summary of the numerical column in the dataset
customers.describe()

# COMMAND ----------

# Shows columns summary in the dataset
print(customers.describe(include="all"))

# COMMAND ----------

# Checking for duplicates
customers.duplicated().sum()

# COMMAND ----------

# MAGIC %md
# MAGIC Customers table has no duplicates

# COMMAND ----------

print(customers["Age"].min())
print(customers["Age"].max())
print(customers["Age"].mean())
print(customers["Age"].count())

# COMMAND ----------

# Checking for nulls in the columns
customers.isnull().sum()

# COMMAND ----------

# Coverting columns to datetime
customers["SignupDate"] = pd.to_datetime(
    customers["SignupDate"],
    errors = "coerce"
    )

# COMMAND ----------

customers.dtypes

# COMMAND ----------

# Calculating the average age in customers
average_age = customers["Age"].mean()
print("Average customer age", average_age)

# COMMAND ----------

# Filling in the null values in age using mean
customers["Age"] = customers["Age"].fillna(average_age)

print(customers["Age"].isnull().sum())

# COMMAND ----------

# Inspeting the cities
print(customers["City"].value_counts(dropna=False))


# COMMAND ----------

# Cleaning the missing cities
customers["City"] = customers["City"].fillna("Unknown")

# COMMAND ----------

print(customers["City"].isnull().sum())

# COMMAND ----------

# unique shows the distinct values in a column
customers["City"].unique()

# COMMAND ----------

# Fixing the naming errors
customers["City"] = customers["City"].replace({
    "tehran": "Tehran",
    "Mashad": "Mashhad"
})

# COMMAND ----------

customers["City"].value_counts()

# COMMAND ----------

# MAGIC %md
# MAGIC City names were standardised to avoid treating different spellings or capitalisations of the same location as separate cities. For example, tehran was changed to Tehran, and Mashad was standardised to Mashhad.

# COMMAND ----------

# MAGIC %md
# MAGIC #### 2.Orders EDA

# COMMAND ----------

# Show how the orders table look like
display(orders)

# COMMAND ----------

# Check the dataset size
orders.shape

# COMMAND ----------

# Previewing the top 5 of the dataset
orders.head()

# COMMAND ----------

# Checking the data types
orders.dtypes

# COMMAND ----------

# Shows the summary of the table
orders.info()

# COMMAND ----------

# Showing statistical summary of numerical columns
orders.describe()

# COMMAND ----------

# Summarize all the columns in the dataset
print(orders.describe(include="all"))

# COMMAND ----------

# Checking for duplicates
orders.duplicated().sum()

# COMMAND ----------

# MAGIC %md
# MAGIC There are 120 duplicated OrderIDs

# COMMAND ----------

# displaying all duplicated rows sorted by orderId
do = orders[orders.duplicated(keep=False)].sort_values("OrderID")

display(do.head(10))

# COMMAND ----------

# Check duplicate OrderID
orders[orders.duplicated(subset = "OrderID", keep=False)].sort_values("OrderID")

# COMMAND ----------

# MAGIC %md
# MAGIC

# COMMAND ----------

# Removing duplicates
orders = orders.drop_duplicates()

# COMMAND ----------

# checking if the duplicates were removed
print("Remaining duplicates:", orders.duplicated().sum())
print("New order shape:", orders.shape)

# COMMAND ----------

# MAGIC %md
# MAGIC 120 duplicate order records were identified and removed before handling missing values. 
# MAGIC This reduced the orders dataset from 50120 rows to 50000 unique orders and prevents duplicated transactions from overstating revenue, units sold and order counts.

# COMMAND ----------

# Checking for nulls
orders.isnull().sum()

# COMMAND ----------

# Converting the orderDate to datetime
orders["OrderDate"] = pd.to_datetime(
    orders["OrderDate"],
    errors = "coerce"
)

# COMMAND ----------

orders.dtypes

# COMMAND ----------

# Statistical analysis of the dataset
print(orders["Discount"].min())
print(orders["Discount"].max())
print(orders["Discount"].mean())
print(orders["Discount"].std())
print(orders["Discount"].count())

# COMMAND ----------

# unique shows the distinct values in a column
orders["PaymentMethod"].unique()

# COMMAND ----------

# Calculating the median orders date
median_order_date = orders["OrderDate"].dropna().median()

print("Median Order Date:", median_order_date)

# COMMAND ----------

# Filling the null dates with the median date
orders["OrderDate"] = orders["OrderDate"].fillna(
    median_order_date
)

print(orders["OrderDate"].isnull().sum())

# COMMAND ----------

# Investigating quantity
orders["Quantity"].value_counts(dropna=False).sort_index()

# COMMAND ----------

# MAGIC %md
# MAGIC A quantity can never be a negative value, and an order line with quantity zero does not represent an actual sale.

# COMMAND ----------

# Inspecting invalid quantities
invalid_quantity = orders[
    orders["Quantity"] <= 0
]

display(invalid_quantity)

# COMMAND ----------

# Convert the invalid quantities to nulls
orders.loc[
    orders["Quantity"] <= 0,
    "Quantity"
] = np.nan

# COMMAND ----------

# Calculating the median valid quantity
median_quantity = orders["Quantity"].median()

print("Median quantity:", median_quantity)

# COMMAND ----------

# Replacing the missing quantities
orders["Quantity"] = orders["Quantity"].fillna(
    median_quantity
)

# COMMAND ----------

# Showing quantities as an integer
orders["Quantity"] = orders["Quantity"].astype(int)

orders["Quantity"].value_counts().sort_index()

# COMMAND ----------

# MAGIC %md
# MAGIC Quantity values of 0, -1 and -2 were considered invalid because sales quantities should be positive. These values were converted to missing values and, together with the existing missing quantities, replaced using the median valid quantity of 2 units

# COMMAND ----------

# Checking the distribution in the discount missing values
orders["Discount"].value_counts(dropna=False).sort_index()

# COMMAND ----------

# Assume that for missing discounts there was zero discount
orders["Discount"] = orders["Discount"].fillna(0)

orders["Discount"].isnull().sum()

# COMMAND ----------

# MAGIC %md
# MAGIC Missing discount values were replaced with 0, treating an unrecorded discount as no discount.

# COMMAND ----------

# Handling the missing payment methods
orders["PaymentMethod"].value_counts(dropna=False)

# COMMAND ----------

# Labelling the missing values
orders["PaymentMethod"] = orders["PaymentMethod"].fillna(
    "Unknown"
)

# COMMAND ----------

# MAGIC %md
# MAGIC #### 3.Payments EDA

# COMMAND ----------

# Show how the payments table look like
display(payments)

# COMMAND ----------

# Check the size of the dataset
payments.shape

# COMMAND ----------

# Check the top 5 rows in the dataset
payments.head()

# COMMAND ----------

# Checking the data type
payments.dtypes

# COMMAND ----------

# Shows the summary of the table
payments.info()

# COMMAND ----------

# checking the statistical summary of the numeric column in the dataset
payments.describe()

# COMMAND ----------

# comprehensive summary of the dataset
print(payments.describe(include = "all"))

# COMMAND ----------

# Checking for duplicates
payments.duplicated().sum()

# COMMAND ----------

# MAGIC %md
# MAGIC The payments table has no duplicates

# COMMAND ----------

# Checking for nulls
payments.isnull().sum()

# COMMAND ----------

# Converting paymentdate to datetime
payments["PaymentDate"] = pd.to_datetime(
    payments["PaymentDate"],
    errors = "coerce"
)

# COMMAND ----------

payments.dtypes

# COMMAND ----------

# Calculating the median payment date
median_payment_date= payments["PaymentDate"].dropna().median()

print("Median Payment Date:", median_payment_date)

# COMMAND ----------

# filling the null dates with the median payment date
payments["PaymentDate"] = payments["PaymentDate"].fillna(
    median_payment_date
)

print(payments["PaymentDate"].isnull().sum())

# COMMAND ----------

# MAGIC %md
# MAGIC Missing order and payment dates were replaced with their respective median dates. The median was used because it provides a central date without being overly influenced by the distribution of dates.

# COMMAND ----------

# MAGIC %md
# MAGIC #### 4.Products EDA

# COMMAND ----------

# Show how the products table look like
display(products)

# COMMAND ----------

# Check the dataset size
products.shape

# COMMAND ----------

# Checking the top 5 rows in the dataset
products.head()

# COMMAND ----------

# Showing the data types
products.dtypes

# COMMAND ----------

# Checking the dataset summary
products.info()

# COMMAND ----------

# checking the statistical summary of the numeric columns
products.describe()

# COMMAND ----------

# The comprehensive summary of the dataset
print(products.describe(include = "all"))

# COMMAND ----------

# Checking for duplicates
products.duplicated().sum()

# COMMAND ----------

# MAGIC %md
# MAGIC Products table has no duplicates

# COMMAND ----------

# unique shows the distinct values in a column
products["ProductName"].unique()

# COMMAND ----------

# Shows distinct values in a column and number of times it appears
products["ProductName"].value_counts()

# COMMAND ----------

# Checking number of categories
products["Category"].value_counts()

# COMMAND ----------

# gives you statistical summary of the numeric columns
products["UnitPrice"].describe()

# COMMAND ----------

# Statistical summary of the columns
print(products["UnitPrice"].min())
print(products["UnitPrice"].max())
print(products["UnitPrice"].mean())
print(products["UnitPrice"].std())
print(products["UnitPrice"].count())

# COMMAND ----------

# Checking the nulls
products.isnull().sum()

# COMMAND ----------

# MAGIC %md
# MAGIC There are no nulls in the products table

# COMMAND ----------

# Checking the product prices
products[["ProductName", "UnitPrice"]].sort_values(
    "UnitPrice"
)

# COMMAND ----------

# MAGIC %md
# MAGIC Product prices were inspected for unusual values. 
# MAGIC The Monitor price of 21 appears low relative to other electronics, but it was retained because the case-study data does not provide a verified replacement price.
# MAGIC It cannot not be changed due to that contrasting with the assumption.

# COMMAND ----------

# Comprehensive summary of the unitprice statistics
products["UnitPrice"].describe()

# COMMAND ----------

# Check broken links for customer IDs
broken_customer_links = orders[
    ~orders["CustomerID"].isin(customers["CustomerID"])
]

print("Broken customer links:", len(broken_customer_links))

display(broken_customer_links.head())

# COMMAND ----------

# Check broken links for product IDs
broken_product_links = orders[
    ~orders["ProductID"].isin(products["ProductID"])
]

print(
    "Broken product links:",
    len(broken_product_links)
)

# COMMAND ----------

# Check broken links for OrderIDs
broken_payment_links = orders[
    ~orders["OrderID"].isin(payments["OrderID"])
]

print(
    "Orders without matching payment:",
    len(broken_payment_links)
)

# COMMAND ----------

# Final check of nulls in the four tables
print("CUSTOMERS")
print(customers.isnull().sum())

print("\nORDERS")
print(orders.isnull().sum())

print("\nPRODUCTS")
print(products.isnull().sum())

print("\nPAYMENTS")
print(payments.isnull().sum())

# COMMAND ----------

# Saving the cleaned tables individually
customers.to_csv(
    "customers_cleaned.csv",
    index=False
)

orders.to_csv(
    "orders_cleaned.csv",
    index=False
)

products.to_csv(
    "products_cleaned.csv",
    index=False
)

payments.to_csv(
    "payments_cleaned.csv",
    index=False
)

# COMMAND ----------

# checking if the number of rows is maintained
starting_rows = len(orders)

print("Starting order rows:", starting_rows)

# COMMAND ----------

# MAGIC %md
# MAGIC ### 3.Connecting the tables

# COMMAND ----------

# MAGIC %md
# MAGIC #### 3.1.Joining Products to Orders

# COMMAND ----------

# Use left join to join products to orders
orders_products = orders.merge(products, on="ProductID", how="left")

# COMMAND ----------

# # checking if the number of rows is maintained
print("Before product join:", starting_rows)
print("After product join:", len(orders_products))

# COMMAND ----------

# Verifying product join
assert len(orders_products) == starting_rows

# COMMAND ----------

display(orders_products)

# COMMAND ----------

orders_products.shape

# COMMAND ----------

# MAGIC %md
# MAGIC #### 3.2.Joining customers to orders_products

# COMMAND ----------

# checking if the rows are maintained
rows_before_customer_join = len(orders_products)

orders_products_customers = orders_products.merge(
    customers,
    on="CustomerID",
    how="left",
    )

rows_after_customer_join = len(orders_products_customers)

print(
    "Before customer join:",
    rows_before_customer_join
)

print(
    "After customer join:",
    rows_after_customer_join
)

# COMMAND ----------

#
assert rows_before_customer_join == rows_after_customer_join

# COMMAND ----------

orders_products_customers.shape

# COMMAND ----------

# Labelling unmatched columns in age and categorical customer information
orders_products_customers["City"] = orders_products_customers["City"].fillna(
    "Unknown"
)

orders_products_customers["CustomerSegment"] = orders_products_customers[
    "CustomerSegment"
].fillna("Unknown")

orders_products_customers["Age"] = orders_products_customers["Age"].fillna(
    average_age
)

# COMMAND ----------

display(orders_products_customers)

# COMMAND ----------

orders_products_customers.shape

# COMMAND ----------

# MAGIC %md
# MAGIC #### 3.3.Joining Payments

# COMMAND ----------

# Joning the payments to the combined table
rows_before_payment_join = len(orders_products_customers)

opcp = orders_products_customers.merge(
    payments,
    on="OrderID",
    how="left"
)

rows_after_payment_join = len(opcp)

print(
    "Before payment join:",
    rows_before_payment_join
)

print(
    "After payment join:",
    rows_after_payment_join
)

# COMMAND ----------

# verify the join
assert rows_before_payment_join == rows_after_payment_join

# COMMAND ----------

# Checking the size of the big table
opcp.shape

# COMMAND ----------

# MAGIC %md
# MAGIC Left joins were used with the cleaned orders table as the base table. The row count remained at 50,000 after joining products, customers and payments. This confirms that the joins did not unintentionally duplicate or remove order records.

# COMMAND ----------

# Dispalying the big table
display(opcp)

# COMMAND ----------

# MAGIC %md
# MAGIC ### 4.Creating New Columns

# COMMAND ----------

# Calculating the Revenue
opcp["Revenue"] = (
    opcp["Quantity"]
    * opcp["UnitPrice"]
    * (1 - opcp["Discount"])
)

# COMMAND ----------

# Displaying the new columns
display(
    opcp[
        [
            "Quantity",
            "UnitPrice",
            "Discount",
            "Revenue"
        ]
    ].head()
)

# COMMAND ----------

# counting only revenue where the status was paid and completed
opcp["ValidSale"] = (
    (opcp["Status"] == "Completed")
    &
    (opcp["PaymentStatus"] == "Paid")
)

# COMMAND ----------

# Calculating the net revenue
opcp["NetRevenue"] = np.where(
    opcp["ValidSale"],
    opcp["Revenue"],
    0
)

# COMMAND ----------

display(opcp)

# COMMAND ----------

# Creating the year
opcp["Year"] = opcp[
    "OrderDate"
].dt.year

# COMMAND ----------

# Creating the month
opcp["Month"] = opcp[
    "OrderDate"
].dt.month_name()

# COMMAND ----------

# Creating Year-Month for trend analysis
opcp["YearMonth"] = opcp[
    "OrderDate"
].dt.to_period("M")

# COMMAND ----------

# Creating the discount percentage
opcp["DiscountPercent"] = (
    opcp["Discount"] * 100
)

# COMMAND ----------

# Checking the size of the final combined dataset
opcp.shape

# COMMAND ----------

# Displaying the finalcombined dataset
display(opcp)
