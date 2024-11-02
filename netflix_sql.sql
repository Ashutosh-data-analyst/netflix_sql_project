                                            /* Netflix Data-Set-Project */  

/* Schema */

	create table netflix 
	(
		show_id varchar(7),
		type varchar(10),
		title varchar( 150),  
		director varchar(210),
		casts varchar(1000),  
		country varchar(150),
		date_added varchar(50),
		release_year INT,
		rating varchar(10),
		duration varchar(20),
		listed_in varchar(100),
		description varchar(250)
	);



	Select count(*) as total_count from netflix; 
	
	select distinct type from netflix;

/* Q1. Count the Number of Moves vs Tv shows? */ 

	select type, count(type) as sum_types from netflix group by type;

/* Q2 Find most common rating of movies and Tv Shows? */  
	
	create view common_rating                 /* Instead of using Sub-Query I have created the view */
	as
	select type, rating,                         /* rating is in Text Max funx not work */
	
	count(*), rank() over(partition by type order by count(*) desc) as Ranking from netflix 
	group by type, rating;
	
	select type, rating from common_rating where ranking = 1; 


/* Q3 List of all the movies release in specific Year? */
	
	select * from netflix where release_year = 2020 and type like 'Movie';

/* Q4. Find the Top 5 Countries which is on Netflix? */

/* Issue in country column in certain row multiple country was written like USA, CANADA
 convert String to Array, unnest to put values of array in seperate column
 update netflix set country = Trim(country) */

	select new_country, count(show_id) from
	(
	
		select show_id, unnest(string_to_array(country, ',')) as new_country from netflix
	) 
	group by new_country order by 2 desc limit 5;


/* Q5. Find the Longest Movies? */
	
	select * from netflix
	where type = 'Movie' and duration = (select max(duration) from netflix);


/* Q6. Find the content that is added in the last 5 years from now? */

/*  select type, title, cast(right(date_added,4) as int) as years from netflix 
where cast(right(date_added,4) as int) IS NOT NULL order by years desc; */
	
	select * from netflix
	where to_date(date_added,'Month DD, YYYY') >= current_date - interval '5 years'
	order by date_added;

/* Q7 Find all movies and tv shows directed by Rajiv Chilaka? */
	
	
	select type, title, director from netflix     
	where director Ilike '%Rajiv Chilaka%';       
                                                  
 /* Q8.List all tv show which is more than 5 seasons? */

	
	select type, title, duration from netflix 
	where type = 'TV Show' and 
	cast(left(trim(duration), 1) as int) > 5;

/* Q9 count the number of content items in each genre? */
	
	select genre , count(show_id) as total_content from 
	(
	select *, trim( unnest (string_to_array(listed_in, ', '))) as genre from netflix
	)
	group by genre;


/* Q10 Find each year and avg % of content release by INDIA on netflix? */

	select extract (year from to_date(date_added, 'month dd yyyy')) as years , 
	count(*) as cnt,
	round(count(*) :: numeric / (select count(*) from netflix where country Ilike '%India%') :: numeric * 100, 2)
	as average
	from
	netflix where country Ilike '%India%' group by years order by cnt desc;


/* Q11 List of all the movies that are documentaries? */
	
	select type, title , listed_in from netflix where listed_in Ilike '%documentaries%';


/* Q12Find all the content with out director? */

	select * from netflix where director is null;

/* Q13 Find the movies actor 'Salman Khan' appeared in last 10 years (released)? */
	
	select * from  netflix where casts Ilike '%Salman Khan%' 
	AND 
	release_year > Extract( year from current_date) - 10;    -- current yera - 10 = 2014

/* Q14 Find the top 10 actors who had appear in the highest number of movies produced in India? */
	
	select actors, count(show_id) as cnt from (
	select *, trim(unnest( string_to_array(casts , ', '))) as actors from netflix
	) where type ilike 'movie' and country ilike '%india%' group by actors order by cnt desc limit 10;

/* Q15 Categorize the content based on the presence of the keyword 'Kill' and 'Violence' in the description field.
 Label content containing these keywords as 'BAD' and all other content as 'GOOD' . count how many items fall eacg category? */

	with new_table
	as
	(
	select TYPE, title,
	
	case
	
	When description ilike '%kill%' OR description ilike '%violence%'
	then  'Bad_Content'
	else 'Good_Content'
	
	end  as category , description
	from netflix
	)
	select category, count(*) from new_table group by category;