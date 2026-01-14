import streamlit as st
import pandas as pd
import plotly.express as px

# Set page config
st.set_page_config(page_title="📊 Sales Performance Dashboard", layout="wide")

# Load cleaned data
@st.cache_data
def load_data():
    df = pd.read_csv("cleaned_superstore_data.csv", parse_dates=["Order Date", "Ship Date"])
    df["MonthYear"] = df["Order Date"].dt.to_period("M").astype(str)
    return df

df = load_data()

# Title
st.title("📈 Sales Performance Analysis Dashboard")
st.markdown("Built with **Python**, **Power BI**, and **SQL**")

# Section: KPIs
st.header("🔢 Key Metrics")
col1, col2 = st.columns(2)

with col1:
    total_profit = df["Profit"].sum()
    st.metric("Total Profit", f"${total_profit:,.2f}")

with col2:
    avg_margin = df["Profit Margin"].mean()
    st.metric("Average Profit Margin", f"{avg_margin:.2%}")

# Section: Python Chart (Monthly Sales Trend)
st.header("📅 Monthly Sales Trend")
monthly = df.groupby("MonthYear")["Sales"].sum().reset_index()
fig = px.line(monthly, x="MonthYear", y="Sales", title="Monthly Sales Over Time")
fig.update_layout(xaxis_tickangle=45)
st.plotly_chart(fig, use_container_width=True)

# Section: Power BI Dashboard Image
st.header("📊 Power BI Dashboard (Static View)")
st.image("Screenshot 2025-06-28 154725.png", caption="Power BI Dashboard Overview", use_container_width=True)

# Optional: Download Power BI Template or PDF
st.download_button(
    label="📥 Download Power BI Report (.pbix)",
    data=open("visualize.pbix", "rb"),
    file_name="visualize.pbix"
)

# Section: SQL Analysis (Example Queries)
st.header("🧠 SQL Insights")
st.markdown("""
Here are some SQL queries you can run on your `sales_data` table:

- **Top 5 Profitable States:**
```sql
SELECT State, SUM(Profit) AS TotalProfit
FROM sales_data
GROUP BY State
ORDER BY TotalProfit DESC
LIMIT 5;
            


            
""")