CREATE TABLE IF NOT EXISTS categories 
(
id integer NOT NULL,
name VARCHAR(255) NOT NULL,
shortname VARCHAR(255) NOT NULL, 
PRIMARY KEY (id)
);

COPY categories FROM 'C:\categories.csv' DELIMITERS ',' CSV HEADER;