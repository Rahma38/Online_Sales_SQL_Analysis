use online_sales


select * from Details
select * from Orders

Alter table Details
add constraint fk_Details_orders
foreign key (Order_ID)
references Orders(Order_ID)
/*purpose:

Summarizes monthly revenue and number of unique orders.

Insights:

Identifies sales trends by month — helps spot peak or slow seasons.

Could be extended by including YEAR(Order_Date) to handle multiple years properly*/


select MONTH(Order_Date)as Order_Month,
       sum(amount)as Total_Revenue,
	   count(distinct Orders.Order_ID)as Total_orders
from Orders
inner join Details
on Orders.Order_ID=Details.Order_ID
group by MONTh(Order_Date)
order by MONTH(Order_Date)



/*Purpose:

Shows number of orders per product category.

Insights:

Reveals which product categories drive demand.

You could add SUM(Amount) to also see total revenue by category for deeper insight*/


select Details.Category,
	   count(distinct Orders.Order_ID)as Total_orders
from Orders
inner join Details
on Orders.Order_ID=Details.Order_ID
group by Details.Category
order by Details.Category desc

/*Purpose:

Lists top 5 most popular subcategories based on order count.

Insights:

Highlights best-performing product niches — useful for inventory and marketing focus.

Pairing this with profit margins can identify high-performing and high-margin products.*/


select top 5 Details.Sub_Category,Details.Category,
	   count(distinct Orders.Order_ID)as Total_orders
from Orders
inner join Details
on Orders.Order_ID=Details.Order_ID
group by Details.Sub_Category,Details.Category
order by Total_orders desc



/*Purpose:

Calculates revenue and order volume for Q2 2018 (April–June).

Insights:

Focused time-frame analysis — useful for quarterly sales reporting.

You can compare with other quarters for growth tracking.*/


select MONTH(Order_Date)as Order_Month,
       sum(amount)as Total_Revenue,
	   count(distinct Orders.Order_ID)as Total_orders
from Orders
inner join Details
on Orders.Order_ID=Details.Order_ID 
where Order_Date between '2018-04-01' and '2018-06-01'
group by MONTh(Order_Date)
order by MONTH(Order_Date)


/*Purpose:

Finds top 5 revenue-generating customers.

Insights:

Identifies high-value clients (VIPs) for loyalty programs or targeted marketing.

Could also calculate their contribution % of total revenue for Pareto analysis (80/20 rule).*/


select top 5 CustomerName,
	   sum(Amount)as Total_revenue
from Orders
inner join Details
on Orders.Order_ID=Details.Order_ID
group by CustomerName
order by Total_revenue desc
/*Purpose:

Uses a CTE (Common Table Expression) to find, for each month, which subcategory generated the highest revenue.

Insights:

Helps identify monthly product leaders — shows shifts in customer preference.

Excellent for merchandising and demand planning.*/

WITH MonthlySales AS (
    SELECT
        MONTH(o.Order_Date) AS Order_Month,
        d.Sub_Category,
        SUM(d.amount) AS Total_Revenue,
        COUNT(DISTINCT o.Order_ID) AS Total_orders
    FROM Orders o
    INNER JOIN Details d
        ON o.Order_ID = d.Order_ID
    GROUP BY MONTH(o.Order_Date), d.Sub_Category
)
SELECT
    Order_Month,
    Sub_Category,
    Total_Revenue,
    Total_orders
FROM MonthlySales ms
WHERE Total_Revenue = (
    SELECT MAX(Total_Revenue)
    FROM MonthlySales
    WHERE Order_Month = ms.Order_Month
)
ORDER BY Order_Month;
/*Purpose:

Finds the single highest revenue day for each month.

Insights:

Useful for detecting spikes — e.g., promotional events, holidays, or new product launches.

Can guide campaign timing and stock preparation.*/

SELECT
    YEAR(Sale_Date) AS Order_Year,
    MONTH(Sale_Date) AS Order_Month,
    Sale_Date,
    Total_Revenue
FROM (
    SELECT 
        CAST(o.Order_Date AS DATE) AS Sale_Date,
        SUM(d.amount) AS Total_Revenue
    FROM Orders o
    JOIN Details d ON o.Order_ID = d.Order_ID
    GROUP BY CAST(o.Order_Date AS DATE)
) AS DailyTotals
WHERE Total_Revenue = (
    SELECT MAX(Total_Revenue)
    FROM (
        SELECT 
            CAST(o2.Order_Date AS DATE) AS Sale_Date,
            SUM(d2.amount) AS Total_Revenue
        FROM Orders o2
        JOIN Details d2 ON o2.Order_ID = d2.Order_ID
        WHERE YEAR(o2.Order_Date) = YEAR(DailyTotals.Sale_Date)
          AND MONTH(o2.Order_Date) = MONTH(DailyTotals.Sale_Date)
        GROUP BY CAST(o2.Order_Date AS DATE)
    ) AS MonthTotals
)
ORDER BY Order_Year, Order_Month;






