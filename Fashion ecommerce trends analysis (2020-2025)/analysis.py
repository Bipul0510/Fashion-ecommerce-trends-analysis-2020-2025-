"""
analysis.py - Fashion ecommerce trends analysis (2020-2025)
Produces KPI summaries and example plots.
"""
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

DATA = Path(__file__).resolve().parents[0] / "fashion_ecom_2020_2025.csv"
OUT = Path(__file__).resolve().parents[0] / "analysis_outputs"
OUT.mkdir(parents=True, exist_ok=True)

df = pd.read_csv(DATA, parse_dates=['order_date'])

# KPIs
total_revenue = df['revenue'].sum()
total_orders = df['order_id'].nunique()
avg_order_value = total_revenue / total_orders if total_orders else 0
avg_items_per_order = df['quantity'].sum() / total_orders if total_orders else 0

kpis = pd.DataFrame([{
    'total_revenue': total_revenue,
    'total_orders': total_orders,
    'avg_order_value': avg_order_value,
    'avg_items_per_order': avg_items_per_order
}])
kpis.to_csv(OUT / 'kpis_summary.csv', index=False)

# Monthly revenue
monthly = df.set_index('order_date').resample('M')['revenue'].sum().reset_index()
monthly.to_csv(OUT / 'monthly_revenue.csv', index=False)
plt.figure()
monthly.plot(x='order_date', y='revenue')
plt.title('Monthly Revenue')
plt.xlabel('Month')
plt.ylabel('Revenue')
plt.tight_layout()
plt.savefig(OUT / 'monthly_revenue.png')

# Category yearly trends
cat_trends = df.groupby([pd.Grouper(key='order_date', freq='Y'), 'category'])['revenue'].sum().reset_index()
cat_trends.to_csv(OUT / 'category_trends_yearly.csv', index=False)

print('Analysis complete. Outputs saved to', OUT)
