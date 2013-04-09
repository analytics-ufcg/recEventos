/*
   Event.java
   Copyright (C) 2013  Elias Paulino

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package javaCode.pojo;

public class Event {

	private String id;
	private long rsvp_limit;
	private String visibility;
	private String status;
	private long utc_offset;
	private long time;
	private long created;
	private String name;
	private long headcount;
	private EventGroup group;
	private Venue venue;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public long getRsvp_limit() {
		return rsvp_limit;
	}

	public void setRsvp_limit(long rsvp_limit) {
		this.rsvp_limit = rsvp_limit;
	}

	public String getVisibility() {
		return visibility;
	}

	public void setVisibility(String visibility) {
		this.visibility = visibility;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public long getUtc_offset() {
		return utc_offset;
	}

	public void setUtc_offset(long utc_offset) {
		this.utc_offset = utc_offset;
	}

	public long getTime() {
		return time;
	}

	public void setTime(long time) {
		this.time = time;
	}

	public long getCreated() {
		return created;
	}

	public void setCreated(long created) {
		this.created = created;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public long getHeadcount() {
		return headcount;
	}

	public void setHeadcount(long headcount) {
		this.headcount = headcount;
	}

	public Venue getVenue() {
		return venue;
	}

	public void setVenue(Venue venue) {
		this.venue = venue;
	}

	public EventGroup getGroup() {
		return group;
	}

	public void setGroup(EventGroup group) {
		this.group = group;
	}
}
