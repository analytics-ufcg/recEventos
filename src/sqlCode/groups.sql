CREATE TABLE IF NOT EXISTS groups
(
id integer NOT NULL, 
name VARCHAR(255) NOT NULL, 
urlname VARCHAR(255) NOT NULL, 
created bigint NOT NULL, 
city VARCHAR(255) NOT NULL, 
country VARCHAR(255) NOT NULL, 
join_mode VARCHAR(255) NOT NULL, 
visibility VARCHAR(255) NOT NULL, 
lon VARCHAR(255) NOT NULL, 
lat VARCHAR(255) NOT NULL, 
members integer NOT NULL, 
category_id integer DEFAULT NULL, 
organizer_id integer DEFAULT NULL,
PRIMARY KEY (id)
);

COPY groups FROM 'C:\groups.csv' DELIMITERS ',' CSV HEADER;