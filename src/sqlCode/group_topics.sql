CREATE TABLE IF NOT EXISTS group_topics
(
group_id INT NOT NULL, 
topic_id INT NOT NULL,
FOREIGN KEY (group_id) REFERENCES groups(id)
);

COPY group_topics FROM 'C:\group_topics.csv' DELIMITERS ',' CSV HEADER;
