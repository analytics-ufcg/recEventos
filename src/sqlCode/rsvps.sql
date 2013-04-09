-- ==============================================================================
--   rsvps.sql
--   Copyright (C) 2013  Rodolfo Martins
-- 
--   This program is free software: you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation, either version 3 of the License, or
--   (at your option) any later version.
-- 
--   This program is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details.
-- 
--   You should have received a copy of the GNU General Public License
--   along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- ==============================================================================

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