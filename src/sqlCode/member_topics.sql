CREATE TABLE IF NOT EXISTS member_topics
(
member_id INT NOT NULL, 
topic_id INT NOT NULL 
);

COPY member_topics FROM 'C:\member_topics.csv' DELIMITERS ',' CSV HEADER;