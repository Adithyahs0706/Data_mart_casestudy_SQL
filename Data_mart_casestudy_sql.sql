use case1
# Add a week_number as the second column for each week_date value, for example any value 
  #from the 1st of January to 7th of January will be 1, 8th to 14th will be 2, etc. 
# Add a month_number with the calendar month for each week_date value as the 3rd column
# Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
# Add a new column called age_band after the original segment column using the following
  # mapping on the number inside the segment value
# Add a new demographic column using the following mapping for the first letter in the segment values
# Ensure all null string values with an "unknown" string value in the original segment column as well 
  #as the new age_band and demographic columns
# Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal 
  #places for each record
create table clean_weekly_sales as select week_date, week(week_date) as week_no,
month(week_date) as month_no, year(week_date) as calender_year,region,platform,
case 
	when segment=null then 'Unknown'
else segment
end as segment,
case
    when right(segment,1)='1' then 'Young audlts'
    when right(segment,1)='2' then 'Middle aged'
    when right(segment,1) in ('3','4') then 'Retirees'
    else 'Unknown'
    end as age_band,
case
when left(segment,1)='C' then 'Couples'
when left(segment,1)='F' then 'Families'
else 'Unknown'
end as demographic,customer_type,transactions,sales,
round(sales/transactions,2) as 'avg_transaction' 
from weekly_sales
select * from clean_weekly_sales

# Which week numbers are missing from the dataset?
create table seq52(x int auto_increment primary key)
insert into seq52 values (),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),
(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),(),()
select distinct x as week_day from seq52 where x not in (select distinct week_no from clean_weekly_sales)

select distinct week_no from clean_weekly_sales

# How many total transactions were there for each year in the dataset?
select calender_year,sum(transactions) as total_transactions from clean_weekly_sales group by calender_year

# What are the total sales for each region for each month?
select region,month_no,sum(sales) as total_sales from clean_weekly_sales group by month_no,region

# What is the total count of transactions for each platform
select platform,sum(transactions) as total_transaction from clean_weekly_sales group by platform

# What is the percentage of sales for Retail vs Shopify for each month?
with cte_monthly_platform_sales as
(select month_no,calender_year,platform,sum(sales) as monthly_sales from clean_weekly_sales group by 
month_no,calender_year,platform)     #Monthly sales=Retail+Shopify sales
select month_no,calender_year,round(100*max(case when platform='Retail' then monthly_sales else null end)/
sum(monthly_sales),2) as retail_percentage,   #Retail%=(Retail sales/Monthly sales)*100
# Here when we give platform=Retail it will take sales of retail from Monthly sales
round(100*max(case when platform='Shopify' then monthly_sales else null end)/
sum(monthly_sales),2) as shopify_percentage    #Shopify%=(Shopify sales/Monthly sales)*100
from cte_monthly_platform_sales
group by month_no,calender_year

# What is the percentage of sales by demographic for each year in the dataset?
select calender_year,demographic,sum(sales) as yearly_sales, round(100*sum(sales)/sum(sum(sales))
over(partition by demographic),2) as percentage from clean_weekly_sales group by calender_year,demographic

# Which age_band and demographic values contribute the most to Retail sales?
select age_band,demographic,sum(sales) as total_sales from clean_weekly_sales where platform='Retail'
group by age_band,demographic order by total_sales desc

