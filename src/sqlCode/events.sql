CREATE TABLE IF NOT EXISTS events
(
id VARCHAR(255) NOT NULL,
name VARCHAR(255) NOT NULL,
created bigint NOT NULL,
time bigint NOT NULL, 
utc_offset integer NOT NULL, 
status VARCHAR(255) NOT NULL, 
visibility VARCHAR(255) NOT NULL, 
headcount integer NOT NULL, 
rsvp_limit integer NOT NULL, 
venue_id integer DEFAULT NULL, 
group_id integer NOT NULL,
FOREIGN KEY (venue_id) REFERENCES venues(id),
FOREIGN KEY (group_id) REFERENCES groups(id)
);

COPY events FROM 'C:\events_1.csv' DELIMITERS ',' CSV HEADER;
COPY events FROM 'C:\events_2.csv' DELIMITERS ',' CSV HEADER;
COPY events FROM 'C:\events_3.csv' DELIMITERS ',' CSV HEADER;
COPY events FROM 'C:\events_4.csv' DELIMITERS ',' CSV HEADER;
COPY events FROM 'C:\events_5.csv' DELIMITERS ',' CSV HEADER;
COPY events FROM 'C:\events_6.csv' DELIMITERS ',' CSV HEADER;
COPY events FROM 'C:\events_7.csv' DELIMITERS ',' CSV HEADER;
COPY events FROM 'C:\events_8.csv' DELIMITERS ',' CSV HEADER;
COPY events FROM 'C:\events_9.csv' DELIMITERS ',' CSV HEADER;
COPY events FROM 'C:\events_10.csv' DELIMITERS ',' CSV HEADER;

