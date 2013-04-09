-- ==============================================================================
--   group_events.sql
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

CREATE TABLE IF NOT EXISTS group_events 
(
group_id INT NOT NULL, 
event_id VARCHAR(255) NOT NULL,
FOREIGN KEY (group_id) REFERENCES groups(id)
);

COPY group_events FROM 'C:\group_events.csv' DELIMITERS ',' CSV HEADER;

