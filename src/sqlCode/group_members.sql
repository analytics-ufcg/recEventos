CREATE TABLE IF NOT EXISTS group_members
(
group_id INT NOT NULL, 
member_id INT NOT NULL
);

COPY group_members FROM 'C:\group_members.csv' DELIMITERS ',' CSV HEADER;