# 🛒 Zepto Sales Analysis - MySQL Project  

This project analyzes the **sales dataset of Zepto products** using **MySQL**. The workflow includes **data inspection, data cleansing, feature engineering, and exploratory data analysis (EDA)** to gain insights into product performance, pricing, inventory management, and revenue contribution.  

---

## 📁 Dataset Information  

The dataset consists of **10 columns**. Below is a brief description of each column:  

| Column                 | Description                                 | Data Type     |
|-------------------------|---------------------------------------------|---------------|
| sku_id                 | Unique product ID                           | SERIAL (PK)   |
| category               | Product category                            | VARCHAR(120)  |
| name                   | Product name                                | VARCHAR(150)  |
| mrp                    | Original price before discount              | NUMERIC(8,2)  |
| discountpercent        | Discount percentage                         | NUMERIC(5,2)  |
| availablequantity      | Available stock                             | INTEGER       |
| discountedsellingprice | Selling price after discount                | NUMERIC(8,2)  |
| weightingms            | Product weight (in grams)                   | INTEGER       |
| outofstock             | Stock status (TRUE/FALSE)                   | BOOLEAN       |
| quantity               | Quantity sold                               | INTEGER       |

---

## 🔧 Data Inspection  

- **Row Count** → Total number of rows in the dataset.  
- **Unique Values** → Distinct product categories and product names.  
- **Descriptive Statistics** → Min, Max, and Avg for `mrp`, `discountpercent`, `availablequantity`, `discountedsellingprice`, `weightingms`, and `quantity`.  
- **Data Anomalies Check**:  
  - Products with `mrp = 0` or `discountedsellingprice = 0`.  
  - Duplicate entries based on product details.  
  - Stock inconsistency (`outofstock = TRUE` but `availablequantity > 0`).  
  - Selling price higher than MRP.  
  - Discount percentage outside the 0–100% range.  
  - Unreasonable product weight (`<1 gram` or `>50 kg`).  
  - Products appearing in multiple categories.  

---

## 🧹 Data Cleansing  

1. Removed invalid rows where `mrp = 0` or `discountedsellingprice = 0`.  
2. Converted `mrp` and `discountedsellingprice` from **paise to rupees**.  
3. Applied **one product = one category rule** using `ROW_NUMBER()` to assign each product to a primary category.  

---

## ⚙️ Feature Engineering  

- **Price per Gram** → `(discountedsellingprice / weightingms)` to compare unit prices.  
- **Weight Category Classification**:  
  - `Low` (< 1kg)  
  - `Medium` (1–5kg)  
  - `Bulk` (> 5kg)  

---

## 📊 Exploratory Data Analysis (EDA)  

### 🌍 General Information  
- Count of unique categories and products.  
- Detection of products belonging to multiple categories.  

### 🧾 Product & Pricing Analysis  
- Top 10 products by discount percentage.  
- High-MRP products that are out of stock.  
- Products with **MRP > 500 Rupee & discount < 10%**.  
- Top 5 categories with highest average discount percentage.  
- Price-per-gram analysis to identify most cost-effective products.  

### 📦 Inventory Insights  
- Total inventory weight per category.  
- Product segmentation into `Low`, `Medium`, and `Bulk` weight groups.  

### 💰 Revenue Analysis  
- Revenue contribution per category.  
- **Revenue Potential Gap**:  
  - Compare realized revenue vs. potential revenue.  
  - Calculate **lost revenue** and **gap percentage** due to stockouts.  

### 🎯 Discount Effectiveness  
- Compare revenue from **High Discount (≥30%)** vs **Low Discount (<30%)** product groups.  

---

## ✅ Key Findings  

- Some products had invalid data such as **MRP = 0, selling price > MRP, and inconsistent stock status**, which required cleaning.  
- **High discounts do not always lead to higher revenue** — products with ≥30% discount did not dominate total sales.  
- Certain categories contribute disproportionately to overall revenue, making them priority areas for marketing and inventory focus.  
- **Stockouts cause significant lost revenue**, emphasizing the importance of inventory management.  
- **Weight classification** helps understand which product sizes (Low, Medium, Bulk) drive sales most effectively.  

---

## 🛠️ Tools Used  

- **MySQL 8.0.42.0**  
- SQL Features:  
  - DDL & DML  
  - CTE & Window Functions (`ROW_NUMBER()`)  
  - Aggregations & CASE expressions  

---

## 📌 Project Structure  

- `zepto` → raw dataset.  
- `zepto_final1` → after anomaly removal & price conversion.  
- `zepto_final2` → one product = one category (final table for analysis).  

---

## 📅 Author  

**Data Analyst**: Naufal Nur Fanani  
**Project**: Zepto Sales EDA  
**Tools**: SQL (MySQL)  

---
