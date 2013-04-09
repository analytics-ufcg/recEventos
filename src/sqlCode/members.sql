-- ==============================================================================
--   members.sql
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