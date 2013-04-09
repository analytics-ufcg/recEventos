-- ==============================================================================
--   group_members.sql
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

CREATE TABLE IF NOT EXISTS group_members
(
group_id INT NOT NULL, 
member_id INT NOT NULL,
FOREIGN KEY (group_id) REFERENCES groups(id),
FOREIGN KEY (member_id) REFERENCES members(id)
);

COPY group_members FROM 'C:\group_members.csv' DELIMITERS ',' CSV HEADER;