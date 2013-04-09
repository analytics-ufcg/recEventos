/*
   RSVP.java
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

public class RSVP {

	private long rsvp_id;
	private long created;
	private long mtime;
	private RSVPMember member;
	private String response;
	private RSVPEvent event;

	public long getRsvp_id() {
		return rsvp_id;
	}

	public void setRsvp_id(long rsvp_id) {
		this.rsvp_id = rsvp_id;
	}

	public long getCreated() {
		return created;
	}

	public void setCreated(long created) {
		this.created = created;
	}

	public long getMtime() {
		return mtime;
	}

	public void setMtime(long mtime) {
		this.mtime = mtime;
	}

	public RSVPMember getMember() {
		return member;
	}

	public void setMember(RSVPMember member) {
		this.member = member;
	}

	public String getResponse() {
		return response;
	}

	public void setResponse(String response) {
		this.response = response;
	}

	public RSVPEvent getEvent() {
		return event;
	}

	public void setEvent(RSVPEvent event) {
		this.event = event;
	}

}
