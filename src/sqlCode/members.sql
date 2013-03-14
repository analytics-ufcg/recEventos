CREATE TABLE IF NOT EXISTS members
(
id integer NOT NULL, 
name VARCHAR(255) DEFAULT NULL, 
city VARCHAR(255) DEFAULT NULL, 
country VARCHAR(255) DEFAULT NULL, 
lon VARCHAR(255) NOT NULL, 
lat VARCHAR(255) NOT NULL, 
joined bigint NOT NULL
, PRIMARY KEY (id)
);

COPY members FROM 'C:\members_1.csv' DELIMITERS ',' CSV HEADER;
COPY members FROM 'C:\members_2.csv' DELIMITERS ',' CSV HEADER;
COPY members FROM 'C:\members_3.csv' DELIMITERS ',' CSV HEADER;
COPY members FROM 'C:\members_4.csv' DELIMITERS ',' CSV HEADER;
COPY members FROM 'C:\members_5.csv' DELIMITERS ',' CSV HEADER;
COPY members FROM 'C:\members_6.csv' DELIMITERS ',' CSV HEADER;
COPY members FROM 'C:\members_7.csv' DELIMITERS ',' CSV HEADER;
COPY members FROM 'C:\members_8.csv' DELIMITERS ',' CSV HEADER;
COPY members FROM 'C:\members_9.csv' DELIMITERS ',' CSV HEADER;
COPY members FROM 'C:\members_10.csv' DELIMITERS ',' CSV HEADER;