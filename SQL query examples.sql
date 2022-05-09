--1. Premium vs Freemium (Multiple JOINS and CASE statement)

--Find the total number of downloads for paying and non-paying users by date. 
--Include only records where non-paying customers have more downloads than paying customers. 
--The output should be sorted by earliest date first and contain 3 columns date, non-paying downloads, paying downloads.

SELECT 
    date_,
    sum(CASE WHEN a.paying_customer = 'no' 
				THEN facts.downloads ELSE 0 END) AS non_paying,
    sum(CASE WHEN a.paying_customer = 'yes' 
				THEN facts.downloads ELSE 0 END) AS paying
FROM ms_download_facts as facts
LEFT JOIN ms_user_dimension as u on u.user_id = facts.user_id
LEFT JOIN ms_acc_dimension as a on a.acc_id = u.acc_id
GROUP BY date_
HAVING  
	sum(CASE WHEN a.paying_customer = 'no' THEN facts.downloads ELSE 0 END) >
  sum(CASE WHEN a.paying_customer = 'yes' THEN facts.downloads ELSE 0 END)
ORDER BY date_ asc




--2. Marketing Campaign Success (Window Function)

--You have a table of in-app purchases by user. 
--Users that make their first in-app purchase are placed in a marketing campaign where they see call-to-actions for more in-app purchases. 
--Find the number of users that made additional in-app purchases due to the success of the marketing campaign.

--The marketing campaign doesn't start until one day after the initial in-app purchase so users that make multiple purchases on the same day do not count, 
--nor do we count users that make only the same purchases over time.

SELECT
    count(distinct user_id)
FROM(
    SELECT
        user_id,
        CASE WHEN min(created_at) over(partition by user_id) <> 
					min(created_at) over(partition by user_id, product_id) 
					THEN 1 ELSE 0 end as campaign_sale
    FROM marketing_campaign
    ) as camp
WHERE 
    campaign_sale = 1