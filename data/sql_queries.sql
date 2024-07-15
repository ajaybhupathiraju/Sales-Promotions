		/** Below is a list of questions asked by the business team (senior sales executive). **/


1.Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free). This information will help us identify high-value products that are currently being heavily discounted, which can be useful for evaluating our pricing and promotion strategies.

Query:
-------------
SELECT DISTINCT
    product_name
FROM
    dim_products p
        JOIN
    fact_events events ON p.product_code = events.product_code
        AND events.promo_type = 'BOGOF'
        AND events.base_price > 500;

output:

product_name
-------------------------------
Atliq_Double_Bedsheet_set
Atliq_waterproof_Immersion_Rod	

2.Generate a report that provides an overview of the number of stores in each city. The results will be sorted in descending order of store counts, allowing us to identify the cities with the highest store presence.The report includes two essential fields: city and store count, which will assist in optimizing our retail operations.

Query:
-------------
SELECT 
    city, COUNT(store_id) "No of stores"
FROM
    dim_stores
GROUP BY city
ORDER BY COUNT(store_id) DESC;

output:

product_name   No of stores
------------  --------------
Bengaluru	10
Chennai		8
Hyderabad	7
Coimbatore	5
Visakhapatnam	5
Madurai		4
Mysuru		4
Mangalore	3
Trivandrum	2
Vijayawada	2	

3.Generate a report that displays each campaign along with the total revenue generated before and after the campaign? The report includes three key fields: campaign_name, totaI_revenue(before_promotion), totaI_revenue(after_promotion). This report should help in evaluating the financial impact of our promotional campaigns. (Display the values in millions)

Query:
-------------
SELECT 
    camp.campaign_name,
    SUM(events.base_price * events.`quantity_sold(before_promo)`) 'total revenue before promotions',
    SUM(events.base_price * events.`quantity_sold(after_promo)`) 'total revenue after promotions'
FROM
    dim_campaigns camp
        JOIN
    fact_events events ON camp.campaign_id = events.campaign_id
GROUP BY camp.campaign_name
ORDER BY camp.campaign_name ASC;

output:

campaign_name   total revenue before promotions      total revenue before promotions
------------    --------------------------------     --------------------------------
Diwali	                82573759	                     207456209
Sankranti	        58127429	                     140403941


4.Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. Additionally, provide rankings for the categories based on their ISU%. The report will include three key fields: category, isu%, and rank order. This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.

Note: ISU% (Incremental Sold Quantity Percentage) is calculated as the percentage increase/decrease in qu	) compared to quantity sold (before promo)

Query:
------------- 
select s.category,s.ISU,ROW_NUMBER() OVER (ORDER BY s.ISU DESC)"Rank" from 
(
SELECT 
    product.category,
    ROUND((SUM(events.`quantity_sold(after_promo)`) - SUM(events.`quantity_sold(before_promo)`)) / SUM(events.`quantity_sold(after_promo)`) * 100,
            2) 'ISU'
FROM
    fact_events events
        JOIN
    dim_campaigns camp ON camp.campaign_id = events.campaign_id
        AND camp.campaign_name = 'Diwali'
        JOIN
    dim_products product ON product.product_code = events.product_code
GROUP BY product.category
ORDER BY ROUND((SUM(events.`quantity_sold(after_promo)`) - SUM(events.`quantity_sold(before_promo)`)) / SUM(events.`quantity_sold(after_promo)`) * 100,
        2) DESC
)s;

output:

category           ISU%       Rank
------------      ------     -------
Home Appliances	   70.95        1
Combo1	           66.93        2
Home Care	   44.33        3
Personal Care	   23.70        4
Grocery & Staples  15.29	5
 
5.Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. The report will provide essential information including product name, category, and ir%. This analysis helps identify the most successful products in terms of incremental revenue across our campaigns, assisting in product optimization.

Query:
-------------
SELECT 
    product.category,
    product.product_name,
    (SUM(base_price * events.`quantity_sold(after_promo)`) - SUM(base_price * events.`quantity_sold(before_promo)`)) / (SUM(base_price * events.`quantity_sold(before_promo)`)) * 100 'IR%'
FROM
    fact_events events
        JOIN
    dim_products product ON product.product_code = events.product_code
GROUP BY product.category , product.product_name
ORDER BY (SUM(base_price * events.`quantity_sold(after_promo)`) - SUM(base_price * events.`quantity_sold(before_promo)`)) / (SUM(base_price * events.`quantity_sold(before_promo)`)) * 100 DESC
LIMIT 5

output:

category        product_name       			Rank
------------    ----------------------------------	-------
Home Appliances	Atliq_waterproof_Immersion_Rod		266.1874
Home Appliances	Atliq_High_Glo_15W_LED_Bulb		262.9836
Home Care	Atliq_Double_Bedsheet_set		258.2679
Home Care	Atliq_Curtains				255.3354
Combo1	        Atliq_Home_Essential_8_Product_Combo	183.3311
