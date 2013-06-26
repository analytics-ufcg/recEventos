/*
   URLManager.java
   Copyright (C) 2013  Augusto Queiroz

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

package javaCode.collection.util;

import java.util.List;
import javaCode.collection.MainCollection;

public class URLManager {

	public static final int PAGE_SIZE = 200;
	public static final int MAX_OFFSET = 200;

	private static final String GROUP_ATTRIBUTES = "id,name,urlname,created,city,country,join_mode,visibility,lat,lon,members,organizer.id,category";
	private static final String MEMBER_ATTRIBUTES = "id,name,city,country,lon,lat,joined,topics.id,topics.name";
	private static final String EVENT_ATTRIBUTES = "id,rsvp_limit,visibility,status,utc_offset,time,created,name,headcount,group.id,venue.id,venue.lon,venue.lat,venue.name,venue.address_1,venue.address_2,venue.address_3,venue.city,venue.country,venue.rating,venue.rating_count";
	private static final String GROUPTOPIC_ATTRIBUTES = "id,topics.id,topics.name";
	private static final String RSVP_ATTRIBUTES = "rsvp_id,created,mtime,member.member_id,response,event.id";

	public static String getFindGroupsURLByCity(String key, int cityIndex,
			int offset) {
		return ("https://api.meetup.com/find/groups?key=" + key + "&location="
				+ MainCollection.cities[cityIndex].replace(" ", "%20")
				+ "&order=newest&page=" + PAGE_SIZE + "&offset=" + offset
				+ "&only=" + GROUP_ATTRIBUTES);
	}

	public static String getMembersURLByGroup(String key, Long groupId,
			int offset) {
		return ("https://api.meetup.com/2/members?key=" + key + "&group_id="
				+ groupId.toString() + "&page=" + PAGE_SIZE + "&offset="
				+ offset + "&only=" + MEMBER_ATTRIBUTES);
	}

	public static String getEventsURLByGroup(String key, List<Long> groupIds,
			int offset) {
		return ("https://api.meetup.com/2/events?key="
				+ key
				+ "&status=upcoming,past&group_id="
				+ groupIds.toString().replace("[", "").replace("]", "")
						.replace(" ", "") + "&page=" + PAGE_SIZE + "&offset="
				+ offset + "&only=" + EVENT_ATTRIBUTES);
	}

	public static String getGroupsURLByGroupId(String key, List<Long> groupIds,
			int offset) {
		return ("https://api.meetup.com/2/groups?key="
				+ key
				+ "&group_id="
				+ groupIds.toString().replace("[", "").replace("]", "")
						.replace(" ", "") + "&page=" + PAGE_SIZE + "&offset="
				+ offset + "&only=" + GROUPTOPIC_ATTRIBUTES);
	}

	public static String getRSVPsURLByEvents(String key, List<String> eventIds,
			int offset) {
		return ("https://api.meetup.com/2/rsvps?key="
				+ key
				+ "&event_id="
				+ eventIds.toString().replace("[", "").replace("]", "")
						.replace(" ", "") + "&order=event&page=" + PAGE_SIZE
				+ "&offset=" + offset + "&only=" + RSVP_ATTRIBUTES);
	}
	
}
