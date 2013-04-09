-- ==============================================================================
--   categories.sql
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

