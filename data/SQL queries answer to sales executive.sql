									/** Below is a list of questions asked by the business team (senior sales executive). **/


1.	Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free). This information will help us identify high-value products that are currently being heavily discounted, which can be useful for evaluating our pricing and promotion strategies.

Result Query:
-------------
select distinct product_name from dim_products p join fact_events events
	  on p.product_code = events.product_code and events.promo_type = "BOGOF" and events.base_price > 500;


2.	Generate a report that provides an overview of the number of stores in each city. The results will be sorted in descending order of store counts, allowing us to identify the cities with the highest store presence.The report includes two essential fields: city and store count, which will assist in optimizing our retail operations.

Result Query:
-------------
select city,count(store_id) from dim_stores group by city
	  order by count(store_id) desc;


3.	Generate a report that displays each campaign along with the total revenue generated before and after the campaign? The report includes three key fields: campaign_name, totaI_revenue(before_promotion), totaI_revenue(after_promotion). This report should help in evaluating the financial impact of our promotional campaigns. (Display the values in millions)

Result Query:
-------------
select camp.campaign_name,SUM(events.base_price*events.`quantity_sold(before_promo)`)"total revenue before promotions",
SUM(events.base_price*events.`quantity_sold(after_promo)`)"total revenue after promotions"
from dim_campaigns camp join fact_events events on camp.campaign_id = events.campaign_id
GROUP BY camp.campaign_name order by camp.campaign_name ASC;


4.	Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. Additionally, provide rankings for the categories based on their ISU%. The report will include three key fields: category, isu%, and rank order. This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.

Note: ISU% (Incremental Sold Quantity Percentage) is calculated as the percentage increase/decrease in qu	) compared to quantity sold (before promo)

Result Query:
------------- 
select s.category,s.ISU,ROW_NUMBER() OVER (ORDER BY s.ISU DESC)"Rank" from 
(
select product.category,
ROUND((SUM(events.`quantity_sold(after_promo)`)-SUM(events.`quantity_sold(before_promo)`))/SUM(events.`quantity_sold(after_promo)`)*100,2)"ISU" from fact_events events join dim_campaigns camp on camp.campaign_id = events.campaign_id and camp.campaign_name = "Diwali"
join dim_products product on product.product_code = events.product_code
group by product.category
order by ROUND((SUM(events.`quantity_sold(after_promo)`)-SUM(events.`quantity_sold(before_promo)`))/SUM(events.`quantity_sold(after_promo)`)*100,2) DESC
)s;

 
5.	Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. The report will provide essential information including product name, category, and ir%. This analysis helps identify the most successful products in terms of incremental revenue across our campaigns, assisting in product optimization.

Result Query:
-------------
select product.category,
product.product_name,
(SUM(base_price*events.`quantity_sold(after_promo)`)-SUM(base_price*events.`quantity_sold(before_promo)`))/(SUM(base_price*events.`quantity_sold(before_promo)`))*100 "IR%" 
from fact_events events join dim_products product on product.product_code = events.product_code
group by product.category,product.product_name
order by (SUM(base_price*events.`quantity_sold(after_promo)`)-SUM(base_price*events.`quantity_sold(before_promo)`))/(SUM(base_price*events.`quantity_sold(before_promo)`))*100 DESC
LIMIT 5
