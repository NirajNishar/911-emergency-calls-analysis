# 🚨 911 Emergency Calls Analysis (PostgreSQL)

## 📌 Project Overview

This project analyzes real-world **911 emergency call data** using PostgreSQL.

The goal is to identify patterns in emergency calls based on:

* Type of emergency
* Time of day
* Day of the week
* Monthly trends
* Weekend vs weekday behavior

---

## 🎯 Problem Statement

Emergency services generate large volumes of data.
Analyzing this data helps understand:

* When emergencies peak
* What types of emergencies are most common
* How patterns change over time

---

## 📂 Dataset Information

* **File:** `911.csv`
* Contains emergency call records including:

  * Location (lat, lng, zip)
  * Description
  * Title (contains emergency type)
  * Timestamp
  * Township

---

## 🛠 Tools Used

* PostgreSQL
* SQL
* Git & GitHub

---

## 🧠 Key SQL Concepts Used

* Data Import using `COPY`
* String Functions: `SPLIT_PART`, `TRIM`
* Date Functions: `EXTRACT`
* Conditional Logic: `CASE`
* Aggregations: `COUNT`, `GROUP BY`
* Sorting: `ORDER BY`
* Window Functions:

  * `RANK() OVER()`
  * `SUM() OVER()` (Running Total)

---

## ⚙️ Data Processing Steps

1. Created table for raw data
2. Imported CSV using `COPY`
3. Extracted emergency reason from `title`
4. Created time-based columns:

   * Hour
   * Month
   * Day of week
5. Identified weekend vs weekday calls

---

## 📊 Analysis Performed

### 🔹 Most Common Emergency Types

Identified which emergency category occurs the most.

### 🔹 Peak Call Hours

Analyzed busiest hours of the day.

### 🔹 Calls by Day of Week

Compared call volumes across weekdays.

### 🔹 Weekend vs Weekday

Checked whether weekends have more emergencies.

### 🔹 Monthly Trends

Analyzed how calls change month-by-month.

### 🔹 Busiest Hour per Emergency Type

Used window functions to find peak hour per category.

### 🔹 Running Total of Calls

Calculated cumulative monthly call trends.

---

## 📈 Key Insights

* Certain emergency types dominate call volume.
* Specific hours show peak emergency activity.
* Clear patterns exist across weekdays and weekends.
* Monthly trends indicate variation in emergency frequency.

---

## 📁 Project Structure

```
911-emergency-calls-analysis/
│── data/
│   └── 911.csv
│── sql/
│   └── 911_emergency_calls_analysis.sql
│── README.md
```

---

## ▶️ How to Run This Project

1. Open PostgreSQL
2. Create the table using SQL script
3. Update file path in this command:

```sql
COPY emergency_calls
FROM 'your_local_path/911.csv'
DELIMITER ','
CSV HEADER;
```

⚠️ Replace `'your_local_path/911.csv'` with your actual file location

4. Run the SQL queries step-by-step

---

## 🚀 Future Improvements

* Add data visualization (Power BI / Tableau)
* Convert into dashboard project
* Add more advanced SQL queries

---

## 👨‍💻 Author

**Niraj Nishar**

---

## ⭐ If you like this project

Give it a star on GitHub ⭐
