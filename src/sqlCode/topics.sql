CREATE TABLE IF NOT EXISTS topics
(
id integer NOT NULL, 
name VARCHAR(255) NOT NULL
);

COPY topics FROM 'C:\topics.csv' DELIMITERS ',' CSV HEADER;