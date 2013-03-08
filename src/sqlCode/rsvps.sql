CREATE TABLE IF NOT EXISTS rsvps
(
id integer NOT NULL, 
created bigint NOT NULL, 
mtime bigint NOT NULL, 
response VARCHAR(255) NOT NULL, 
member_id INT NOT NULL, 
event_id VARCHAR(255) NOT NULL
);

COPY rsvps FROM 'C:\rsvps_1.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_2.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_3.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_4.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_5.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_6.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_7.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_8.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_9.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_10.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_11.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_12.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_13.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_14.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_15.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_16.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_17.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_18.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_19.csv' DELIMITERS ',' CSV HEADER;
COPY rsvps FROM 'C:\rsvps_20.csv' DELIMITERS ',' CSV HEADER;