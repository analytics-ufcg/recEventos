-- ==============================================================================
--   gruops.sql
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

CREATE TABLE IF NOT EXISTS groups
(
id integer NOT NULL, 
name VARCHAR(255) NOT NULL, 
urlname VARCHAR(255) NOT NULL, 
created bigint NOT NULL, 
city VARCHAR(255) NOT NULL, 
country VARCHAR(255) NOT NULL, 
join_mode VARCHAR(255) NOT NULL, 
visibility VARCHAR(255) NOT NULL, 
lon VARCHAR(255) NOT NULL, 
lat VARCHAR(255) NOT NULL, 
members integer NOT NULL, 
category_id integer DEFAULT NULL, 
organizer_id integer DEFAULT NULL,
PRIMARY KEY (id),
FOREIGN KEY (category_id) REFERENCES categories(id)
);

COPY groups FROM 'C:\groups.csv' DELIMITERS ',' CSV HEADER;