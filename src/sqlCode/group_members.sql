CREATE TABLE IF NOT EXISTS group_members
(
group_id INT NOT NULL, 
member_id INT NOT NULL,
FOREIGN KEY (group_id) REFERENCES groups(id),
FOREIGN KEY (member_id) REFERENCES members(id)
);

COPY group_members FROM 'C:\group_members.csv' DELIMITERS ',' CSV HEADER;