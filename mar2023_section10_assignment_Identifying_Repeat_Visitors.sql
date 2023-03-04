-- Step 1: Identify the relevant new sessions
-- Step 2: Use the user_id values from step 1 to find any repeat sessions those users had
-- Step 3: Analyze the data at the user level (how many sessions did each user have?)
-- Step 4: Aggregate the user-level analysis to generate your behavioral analysis

select * from website_sessions limit 10;

create temporary table if not exists sessions_w_repeats
select 
	new_sessions.user_id,
    new_sessions.website_session_id as new_session_id,
    ws.website_session_id as repeat_session_id
from(
	select 
		user_id,
		website_session_id
	from website_sessions
	where created_at between '2014-01-01' and '2014-11-01'
		and is_repeat_session = 0 -- new sessions only
) as new_sessions
	left join website_sessions ws
		on new_sessions.user_id = ws.user_id
			and ws.is_repeat_session = 1 -- was a repeat session 
            and ws.website_session_id > new_sessions.website_session_id -- sessions later than new session
            and ws.created_at between '2014-01-01' and '2014-11-01';
            

select 
	repeat_sessions,
    count(distinct user_id) as users
from
(
select 
	user_id,
    count(distinct new_session_id) as new_sessions,
    count(distinct repeat_session_id) as repeat_sessions
from sessions_w_repeats
group by 1
order by 3 desc
) as user_level
group by 1;
