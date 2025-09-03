# 🛒 Global Store SQL Analysis

## 📌 Project Overview
This project aims to answer a key business question:

> **“Why do we see a high number of transactions, but revenue and profit keep dropping?”**

Using **SQL**, this analysis explores transactional data step by step to uncover the root cause. The main focus of this analysis is the **high return rate**, which represents canceled or returned transactions.

---

## 🗂 Dataset
1. **Transaction Table**  
   Contains customer order data:
   - `order_id`, `customer_name`, `product_category`, `product_name`
   - `order_date`, `quantity`, `unit_price`
   - `status` (Completed / Returned)
   - `country`, `payment_method`

2. **Product Cost Table**  
   Contains product cost data:
   - `product_number`, `product_name`, `cost_percentage`

---

## 🔄 Analysis Workflow

### 1. Data Inspection
Checking the structure and quality of data:
- Number of transactions & unique customers  
- Distribution of product categories & payment methods  
- Date range of transactions  
- Min, max, average for quantity & unit price  
- Detect NULL, blank, and duplicate values  

**Why important?**  
To understand the initial state of the data before diving deeper.

---

### 2. Data Cleansing
Cleaning the data for accuracy:
- Removing duplicates  
- Removing NULL or invalid values (e.g., quantity ≤ 0)  

**Why important?**  
Dirty data can lead to misleading results.

---

### 3. Feature Engineering
Adding new fields for deeper analysis:
- Extracting `year` & `month` from `order_date`  
- Joining with product cost table (`cost_percentage`)  
- Price segmentation (`Low`, `Mid`, `High`)  
- Calculated metrics:
  - `revenue = quantity * unit_price`  
  - `total_cost = quantity * (cost_percentage * unit_price)`  
  - `total_profit = revenue - total_cost`  

**Why important?**  
This step transforms raw data into business metrics that drive insights.

---

### 4. Exploratory Data Analysis (EDA)
Exploring the data to identify patterns:
- **General Metrics**: total transactions, unique customers, revenue, profit, AOV, margin ratio  
- **Time Analysis**: revenue & profit by year and month  
- **Price Segmentation**: revenue and profit contribution by price group  
- **Product & Category**: top categories and products by performance  
- **Payment & Country**: transaction distribution by payment method & country  

**Why important?**  
EDA highlights trends and anomalies worth investigating further.

---

### 5. Case Study: Return Rate Analysis
Focused analysis to measure the impact of returned transactions:
- **Return Rate by Transaction**: % of returned transactions  
- **Return Rate by Revenue & Profit**: financial impact of returns  
- **Segmentation of Return Rate**:
  - By product category  
  - By country  
  - By price segment  
  - By month (time trend)  

**Why important?**  
Even with high sales volume, a high return rate can cause revenue and profit to drop significantly.

---

## 📊 Case Studies Implemented
1. **General Business Metrics** → overall business performance  
2. **Time-based Analysis** → yearly & monthly trends  
3. **Price Segmentation** → revenue & profit by price group  
4. **Product & Category Performance** → category & product contributions  
5. **Payment Method & Country Analysis** → distribution of transactions  
6. **Return Rate Analysis (main focus)** → measuring return rate impact on revenue & profit  

---

## 💡 Key Insights
- A **high return rate** (both by transaction count and by revenue) is the main reason for declining profitability, even though the transaction count is high.  
- Across categories, countries, and price segments, the return rate is consistently high. This indicates a **structural issue**, not just a localized problem.  

---

## 🚀 Tools
- **SQL** (all analysis performed using SQL queries only)

---

## 📁 Repository Structure
