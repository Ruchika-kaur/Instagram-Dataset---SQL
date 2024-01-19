-- How many times does the average user post?

SELECT (SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users) as average;

-- Find the top 5 most used hashtags.

select tag_Id, count(*) as count_tags from photo_tags
 group by tag_id
 order by count_tags desc
 limit 5;
 
 
 select pt.tag_Id, t.tag_name, count(*) as tag_count from tags t
 inner join photo_tags pt 
 on t.id = pt.tag_Id
 group by pt.tag_Id
 order by tag_count desc
 limit 5;
 
 -- Find users who have liked every single photo on the site.
 
SELECT user_id,username FROM likes
INNER JOIN users
ON likes.user_id = users.id
GROUP BY user_id
HAVING COUNT(*) = (SELECT COUNT(*) FROM photos);

-- Retrieve a list of users along with their usernames and the rank of their account creation, ordered by the creation date in ascending order.
 
 select id, username,
DENSE_RANK () OVER(ORDER BY created_at) as ranking
from users;

-- List the comments made on photos with their comment texts, photo URLs, and usernames of users who posted the comments. Include the comment count for each photo

select c.id, c.comment_text, p.image_url, u.username from comments c 
inner join photos p 
on p.id = c.photo_id
inner join users u 
on u.id = c.user_id
;

-- For each tag, show the tag name and the number of photos associated with that tag. Rank the tags by the number of photos in descending order.

with tag as (select pt.tag_id, t.tag_name,  count(photo_id) as number_of_photos from photo_tags pt 
inner join tags t on t.id = pt.tag_id
group by tag_id order by number_of_photos)
select * ,
dense_rank () over(order by number_of_photos desc) as ranking
from tag;

-- List the usernames of users who have posted photos along with the count of photos they have posted. Rank them by the number of photos in descending order.

with user_photos as (select p.user_id, u.username, count(p.user_id) as count_of_photos from users u
inner join photos p 
on p.user_id = u.id
group by p.user_id)
select *,
dense_rank() over(order by count_of_photos desc) ranking
from user_photos;

-- Display the username of each user along with the creation date of their first posted photo and the creation date of their next posted photo.

with users_photo as 
(select u.id, u.username, min(p.created_at) as first_photo from users u 
inner join photos p on p.user_id = u.id
group by u.username)
select *,
Lead (first_photo) over(order by first_photo) as next_photo
from users_photo;

-- For each comment, show the comment text, the username of the commenter, and the comment text of the previous comment made on the same photo

with comment_details as
(select c.id, c.comment_text, u.username from comments c
inner join users u 
on u.id=c.user_id)
select *,
Lag (comment_text) over(order by username) as previous_comment
from comment_details;


-- Show the username of each user along with the number of photos they have posted and the number of photos posted by the user before them and after them, based on the creation date

with photos_count as 
(select p.user_id, u.username, count(*) as count, p.created_at from photos p
inner join users u on u.id = p.user_id
group by user_id order by user_id)
select *,
Lag(count) over (order by created_at) as photos_posted_before,
Lead(count) over(order by created_at) as photos_posted_after
from photos_count;
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));