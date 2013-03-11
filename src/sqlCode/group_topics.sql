CREATE TABLE IF NOT EXISTS group_topics
(
group_id INT NOT NULL, 
topic_id INT NOT NULL
);

COPY group_topics FROM 'C:\group_topics.csv' DELIMITERS ',' CSV HEADER;