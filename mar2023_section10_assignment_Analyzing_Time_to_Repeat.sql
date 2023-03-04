-- Step 1: Identify the relevant new sessions
-- Step 2: use the user_id values from step 1 to find any repeat sessions those users had
-- Step 3: Find the created_at times for first and second sessions
-- Step 4: Find the differences between first and second sessions at a user level
-- Step 5: Aggregate the user level data to find the average, min, max

create temporary table if not exists sessions_w_repeats_for_time_diff
select 
	new_sessions.user_id,
    new_sessions.website_session_id as new_session_id,
    new_sessions.created_at as new_session_created_at,
    ws.website_session_id as repeat_session_id,
    ws.created_at as repeat_session_created_at
from(
	select 
		user_id,
		website_session_id,
        created_at
	from website_sessions
	where created_at between '2014-01-01' and '2014-11-03'
		and is_repeat_session = 0
) as new_sessions
	left join website_sessions ws
		on new_sessions.user_id = ws.user_id
        and ws.is_repeat_session = 1	-- was a repeat session
        and ws.website_session_id > new_sessions.website_session_id	-- session was later than new session
        and ws.created_at between '2014-01-01' and '2014-11-03';
        
select * from sessions_w_repeats_for_time_diff;

create temporary table users_first_to_second
select 
	user_id,
    datediff(second_session_created_at,new_session_created_at) as days_first_to_second_session
from (
	select 
		user_id,
		new_session_id,
		new_session_created_at,
		MIN(repeat_session_id) as second_session_id,
		min(repeat_session_created_at) as second_session_created_at
	from sessions_w_repeats_for_time_diff
	where repeat_session_id IS NOT NULL
	group by 1,2,3
)as first_second;

select * from users_first_to_second;


select 
	avg(days_first_to_second_session) as avg_days_first_to_second,
    min(days_first_to_second_session) as min_days_first_to_second,
    max(days_first_to_second_session) as max_days_first_to_second
from users_first_to_second;
