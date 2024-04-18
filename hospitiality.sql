-- REVENUE
-- Total Revenue Generated
select sum(revenue_realized)/1000000 as Revenue_Millions
from fact_bookings;


-- by booking_platform
select booking_platform,
	round(sum(revenue_realized)/1000000,2) as Revenue_Millions
from fact_bookings
group by booking_platform;


-- booking % by platform
select 
    fb.booking_platform,
    (count(fb.booking_id) / total.total_bookings) * 100 as booking_pct
from
    fact_bookings fb
cross join (
    select count(booking_id) as total_bookings
    from fact_bookings
) as total
group by 
    fb.booking_platform, total.total_bookings;


-- booiking % by romm class
select 
	r.room_class,
    round((count(booking_id)/total.total_booking)*100,2) as booking_pct
    from fact_bookings b
    join dim_rooms r
    on b.room_category=r.room_id
cross join(
	select count(booking_id) as total_booking
    from fact_bookings) as total
group by r.room_class,total.total_booking;



-- by room class
select r.room_id ,r.room_class,
	round(sum(revenue_realized)/1000000,2) as Revenue_Millions
from fact_bookings b
	join dim_rooms r
    on b.room_category=r.room_id
group by r.room_class,r.room_id;


-- by luxury or business
select h.category,
	round(sum(revenue_realized)/1000000,2) as Revenue_Millions
from fact_bookings b
	join dim_hotels h
    on b.property_id=h.property_id
group by h.category;

-- booking status
select booking_status,
	round(sum(revenue_realized)/1000000,2) as Revenue_Millions
from fact_bookings
group by booking_status;


-- by month
select mmm_yy,
	round(sum(revenue_realized)/1000000,2) as Revenue_Millions
from fact_bookings b
	join dim_date d
    on b.check_in_date=d.date
group by mmm_yy;

-- by day type
select day_type,
	round(sum(revenue_realized)/1000000,2) as Revenue_Millions
	from fact_bookings b
    join dim_date d
    on b.check_in_date=d.date
group by day_type;


-- revenue by property_name ,city 
select h.property_id,h.property_name,h.city,
	round(sum(revenue_realized)/1000000,2) as revenue
from fact_bookings b
	join dim_hotels h
    on b.property_id=h.property_id
group by h.property_id,h.property_name,h.city;

-- by weekno
select mmm_yy ,week_no, round(sum(revenue_realized)/1000000,2)
from fact_bookings b 
join dim_date d
on b.check_in_date=d.date
group by mmm_yy,week_no;



-- TOTAL CAPACITY
select sum(capacity) as total_capacity
from fact_aggregated_bookings;
    
    
-- total successful booking
select sum(successful_bookings) as total_successful_booking
from fact_aggregated_bookings;

-- average rating
select round(avg(ratings_given),2) as avg_rating
from fact_bookings;

select h.city ,
	round(avg(ratings_given),2) as avg_rating
from fact_bookings b
	join dim_hotels h
	on b.property_id=h.property_id
group by h.city;


-- occupancy % 
select  round(sum(successful_bookings)/sum(capacity)*100,2) as occupancy_pct
from fact_aggregated_bookings;

-- total booking
select count(booking_id) 
from fact_bookings;

-- cancellation %    
SELECT 
    round((cancelled_booking / total_booking)*100,2) AS cancellation_pct
FROM (
    SELECT 
        (SELECT COUNT(booking_id) 
		FROM fact_bookings 	
		WHERE booking_status = 'Cancelled') AS cancelled_booking,
        
        (SELECT COUNT(booking_id) 	
        FROM fact_bookings) AS total_booking
) AS x;

-- no show %
SELECT 
    round((No_show_booking / total_booking)*100,2) AS no_show_pct
FROM (
    SELECT 
        (SELECT COUNT(booking_id) 
		FROM fact_bookings 	
		WHERE booking_status = 'No Show') AS No_show_booking,
        
        (SELECT COUNT(booking_id) 	
        FROM fact_bookings) AS total_booking
) AS x;

-- count by booking status
select booking_status,count(booking_id) as count
from fact_bookings
group by booking_status;

-- Revpar
select revenue/total_capacity as RevPAR
from (
	select 
		(select sum(revenue_realized)  
        from fact_bookings) as revenue,
        
        (select sum(capacity) 
        from fact_aggregated_bookings) as total_capacity
) as x;


-- ADR
select 
	round(sum(revenue_realized)/count(booking_id),2) as ADR
from fact_bookings;

-- no of day
select datediff(max(check_in_date),min(check_in_date))+1 as no_of_days
from fact_bookings;

-- DSRN
select total_capacity/no_of_days as DSRN
from (
	select 
		(select 
			datediff(max(check_in_date),min(check_in_date))+1
		from fact_bookings) as no_of_days,
        
        (select sum(capacity) 
        from fact_aggregated_bookings) as total_capacity
) as x;


-- DBRN
select total_bookings/no_of_days as DSRN
from (
	select 
		(select 
			datediff(max(check_in_date),min(check_in_date))+1
		from fact_bookings) as no_of_days,
        
        (select count(booking_id) 
        from fact_bookings) as total_bookings
) as x;


-- DURN
select total_checkout/no_of_days as DSRN
from (
	select 
		(select 
			datediff(max(check_in_date),min(check_in_date))+1
		from fact_bookings) as no_of_days,
        
        (select count(booking_id) as count 
        from fact_bookings
        where booking_status="Checked Out") as total_checkout
) as x;

-- relisaiton %
select 
    round((1 - ((cancelled_booking / total_booking) + (no_show_booking / total_booking))) * 100, 2) as realization_pct
from (
    select 
        (select count(booking_id) 
        from fact_bookings 
        where booking_status = 'Cancelled') as cancelled_booking,
        
        (select count(booking_id) 
        from fact_bookings 
        where booking_status = 'No Show') as no_show_booking,
        
        (select COUNT(booking_id) 
        from fact_bookings) as total_booking
) as x;
 
