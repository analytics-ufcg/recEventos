CREATE TABLE IF NOT EXISTS group_events 
(
group_id INT NOT NULL, 
event_id VARCHAR(255) NOT NULL,
FOREIGN KEY (group_id) REFERENCES groups(id)
);

COPY group_events FROM 'C:\group_events.csv' DELIMITERS ',' CSV HEADER;

