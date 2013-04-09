-- ==============================================================================
--   member_topics.sql
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

CREATE TABLE IF NOT EXISTS member_topics
(
member_id INT NOT NULL, 
topic_id INT NOT NULL,
FOREIGN KEY (member_id) REFERENCES members(id)
);

COPY member_topics FROM 'C:\member_topics.csv' DELIMITERS ',' CSV HEADER;