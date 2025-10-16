# Online Casino Data Analysis Dashboard

## 📊 Project Overview
This project analyzes online casino performance data to provide insights into revenue, wagers, payouts, promotional efficiency, and tax burden. It demonstrates advanced SQL analysis in PostgreSQL and interactive dashboards in Power BI.

The dataset includes monthly reports per licensee with the following columns:

- Licensee  
- Fiscal Year  
- Month Ending  
- Wagers  
- Patron Winnings  
- Cancelled Wagers  
- Online Casino Gaming Win/(Loss)  
- Promotional Coupons or Credits Wagered  
- Promotional Deduction  
- Total Gross Gaming Revenue  
- Payment  

---

## 💻 Technologies Used
- **PostgreSQL** – data exploration, aggregation, and advanced queries  
- **Power BI** – interactive dashboards and visualizations  
- **DAX** – measures and calculations for KPIs  

---

## 📝 Business Questions
1. Which licensee has the highest net revenue per fiscal year?  
2. What is the year-over-year growth in net revenue for each licensee?  
3. How effective are promotional credits in driving wagers and revenue?  
4. What is the payout ratio (Patron Winnings / Wagers) per licensee and month?  
5. What is the effective tax burden across licensees?  
6. Which months or licensees experienced unusual spikes in cancelled wagers?  
7. How does cumulative revenue evolve month over month per licensee?  
8. How does the promotional deduction impact net revenue over time?  

---

## 🗄 Database Structure
The main table `online_casino` includes:

| Column                         | Data Type | Description |
|--------------------------------|-----------|-------------|
| Licensee                        | Text      | Casino operator |
| Fiscal Year                     | Text      | Fiscal year of report |
| Month Ending                     | Date      | Month ending date |
| Wagers                           | Number    | Total wagers placed |
| Patron Winnings                  | Number    | Amount won by patrons |
| Cancelled Wagers                 | Number    | Number of cancelled wagers |
| Online Casino Gaming Win/(Loss)  | Number    | Net win or loss for casino |
| Promotional Coupons or Credits   | Number    | Promotional bets placed |
| Promotional Deduction            | Number    | Deductions due to promotions |
| Total Gross Gaming Revenue       | Number    | Total gross gaming revenue |
| Payment                          | Number    | Tax or payment to authority |

---

## 🛠 PostgreSQL Analysis
- Created table `online_casino` with proper data types.  
- Used `DATE_TRUNC` for monthly aggregation.  
- Calculated **net revenue**, **year-over-year growth**, **promo efficiency**, **payout ratio**, **tax ratios**, and **cumulative revenue**.  
- Applied window functions (`RANK()`, `LAG()`, `SUM() OVER`) for ranking and trend analysis.

---



### **Interactive Features**
- Slicers for Fiscal Year, Licensee, and Month Ending  
- Tooltips with detailed measures: Promo Deduction %, Win Margin, Effective Tax Rate  
- Conditional formatting for highlighting anomalies  

---

