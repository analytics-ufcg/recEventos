package javaCode.collection.util;

import java.util.List;
import javaCode.collection.MainCollection;

public class URLManager {

	public static final int PAGE_SIZE = 200;

	private static final String GROUP_ATTRIBUTES = "id,name,urlname,created,city,country,join_mode,visibility,lat,lon,members,organizer.id,category";
	private static final String MEMBER_ATTRIBUTES = "id,name,city,country,lon,lat,joined,topics.id,topics.name";
	private static final String EVENT_ATTRIBUTES = "id,rsvp_limit,maybe_rsvp_count,yes_rsvp_count,waitlist_count,visibility,status,utc_offset,time,created,name,headcount,group.id,venue.id,venue.lon,venue.lat,venue.name,venue.address_1,venue.address_2,venue.address_3,venue.city,venue.country,venue.rating,venue.rating_count";
	private static final String GROUPTOPIC_ATTRIBUTES = "id,topics.id,topics.name";
	private static final String VENUE_ATTRIBUTES = "id,lon,lat,name,address_1,address_2,address_3,city,country,rating,rating_count";
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

	public static String getEventsURLByMember(String key, Long memberId,
			int offset) {
		return ("https://api.meetup.com/2/events?key=" + key + "&member_id="
				+ memberId.toString() + "&status=upcoming,past&page="
				+ PAGE_SIZE + "&offset=" + offset + "&only=" + EVENT_ATTRIBUTES);
	}

	public static String getGroupsURLByGroupId(String key,
			List<Long> groupIds, int offset) {
		return ("https://api.meetup.com/2/groups?key="
				+ key
				+ "&group_id="
				+ groupIds.toString().replace("[", "").replace("]", "")
						.replace(" ", "") + "&page=" + PAGE_SIZE + "&offset="
				+ offset + "&only=" + GROUPTOPIC_ATTRIBUTES);
	}

	public static String getVenuesURLByGroupId(String key, Long groupId,
			int offset) {
		return ("https://api.meetup.com/2/venues?key=" + key + "&group_id="
				+ groupId.toString() + "&page=" + PAGE_SIZE + "&offset="
				+ offset + "&only=" + VENUE_ATTRIBUTES);
	}

	public static String getOpenVenuesURLByCity(String key, int cityIndex,
			int offset) {
		return ("https://api.meetup.com/2/open_venues?key=" + key + "&city="
				+ MainCollection.cities[cityIndex].replace(" ", "%20")
				+ "&country=br&radius=100&page=" + PAGE_SIZE + "&offset="
				+ offset + "&only=" + VENUE_ATTRIBUTES);
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
