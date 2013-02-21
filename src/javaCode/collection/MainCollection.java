package javaCode.collection;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.TreeSet;
import javaCode.collection.util.ApiKeysManager;
import javaCode.collection.util.IOManager;
import javaCode.collection.util.Tracer;
import javaCode.collection.util.URLManager;
import javaCode.pojo.Event;
import javaCode.pojo.Group;
import javaCode.pojo.GroupTopics;
import javaCode.pojo.Member;
import javaCode.pojo.RSVP;
import javaCode.pojo.Results;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

public class MainCollection {

	/*
	 * List of OBJECT types
	 */
	public static final String GROUP = "group", EVENT = "event",
			MEMBER = "member", TOPIC = "topic", VENUE = "venue", RSVP = "rsvp";

	/*
	 * List of RELATION between OBJECTs
	 */
	public static final String GROUP_TOPIC = "group_topic",
			GROUP_MEMBER = "group_member";

	/*
	 * PROPERTIES file variables
	 */
	public static String[] cities;

	public static URLConnection urlConn;

	private static void findGroupsByCity(int cityIndex) throws IOException {

		// Set the initial offset
		int offset = Tracer.getOffset();

		ObjectMapper mapper = new ObjectMapper();

		/*
		 * Get all groups
		 */
		boolean keepFetching = true;

		// Read the group id's already stored
		TreeSet<Long> allGroupIds;
		try {
			allGroupIds = IOManager.readObjectAllIds(GROUP);
		} catch (IOException e) {
			// There is no id yet...
			allGroupIds = new TreeSet<Long>();
		}

		// Read the group id's per city already stored
		TreeSet<Long> groupIdsPerCity;
		try {
			groupIdsPerCity = IOManager.readObjectIdsPerCity(cityIndex, GROUP);
		} catch (IOException e) {
			// There is no id yet...
			groupIdsPerCity = new TreeSet<Long>();
		}

		do {
			// Check and stop for 1 hour, if needed
			ApiKeysManager.checkApiCallLimit(urlConn);

			// Parse the JSON object directly from the URL
			println("        Fetching URL...");

			urlConn = new URL(URLManager.getFindGroupsURLByCity(
					ApiKeysManager.getKey(), cityIndex, offset))
					.openConnection();

			Group[] groupArray = mapper.readValue(
					new InputStreamReader(urlConn.getInputStream(),
							IOManager.CHAR_SET), Group[].class);

			ArrayList<Group> newGroups = new ArrayList<Group>();

			print("        Processing data (" + groupArray.length
					+ " group(s)):");
			for (int i = 0; i < groupArray.length; i++) {
				Long groupId = groupArray[i].getId();
				if (!allGroupIds.contains(groupId)) {
					allGroupIds.add(groupId);
					groupIdsPerCity.add(groupId);
					newGroups.add(groupArray[i]);
				}// else clause {Removes the object}
			}
			println(" DONE");

			// Rewrite the all group ids file
			IOManager.writeObjectAllIds(GROUP, allGroupIds);

			// Rewrite the group ids file per city
			IOManager.writeObjectIdsPerCity(cityIndex, GROUP, groupIdsPerCity);

			// Persist the new json objects, if there is any
			if (!newGroups.isEmpty()) {
				IOManager.appendJsonObjects(GROUP, newGroups.toArray());
			}

			// Rewrite the trace file
			Tracer.writeTraceFile(cityIndex, Tracer.FINDGROUPS_INDEX, 0, 0, 0,
					offset);

			// Checks if there is any more data to fetch
			if (groupArray.length > 200) {
				offset++;
			} else {
				keepFetching = false;
			}

			System.gc();

		} while (keepFetching);
	}

	private static void getMembersByGroup(int cityIndex) throws IOException {

		// Read the group id's per city already stored
		TreeSet<Long> groupIdsPerCity;
		try {
			groupIdsPerCity = IOManager.readObjectIdsPerCity(cityIndex, GROUP);
		} catch (IOException e) {
			// There is no id. So, there is nothing to do.
			return;
		}

		// Set the initial groupIndex
		int groupIndex = Tracer.getGroupIndex();

		// Set the initial offset
		int offset = Tracer.getOffset();

		ObjectMapper mapper = new ObjectMapper();

		// Read the member id's already stored
		TreeSet<Long> allMemberIds;
		try {
			allMemberIds = IOManager.readObjectAllIds(MEMBER);
		} catch (IOException e) {
			// There is no id yet...
			allMemberIds = new TreeSet<Long>();
		}

		// Read the member id's per city already stored
		TreeSet<Long> memberIdsPerCity;
		try {
			memberIdsPerCity = IOManager
					.readObjectIdsPerCity(cityIndex, MEMBER);
		} catch (IOException e) {
			// There is no id yet...
			memberIdsPerCity = new TreeSet<Long>();
		}

		// Foreach groupId of the given city do...
		int i = 0;
		for (Long groupId : groupIdsPerCity) {

			if (i++ < groupIndex)
				continue;

			println("        Group " + groupId + " (" + (groupIndex + 1) + "/"
					+ groupIdsPerCity.size() + ")");

			boolean hasMoreData = true;

			do {
				// Check and stop for 1 hour, if needed
				ApiKeysManager.checkApiCallLimit(urlConn);

				print("            Fetching URL...");

				urlConn = new URL(URLManager.getMembersURLByGroup(
						ApiKeysManager.getKey(), groupId, offset))
						.openConnection();
				Results<Member> memberResults = mapper.readValue(
						new InputStreamReader(urlConn.getInputStream(),
								IOManager.CHAR_SET),
						new TypeReference<Results<Member>>() {
						});

				int totalObjects = memberResults.getMeta().getTotal_count();
				println("("
						+ ((totalObjects <= 0) ? 0 : (offset + 1))
						+ "/"
						+ (int) Math.ceil(totalObjects
								/ (double) URLManager.PAGE_SIZE) + ")");

				ArrayList<Member> newMembers = new ArrayList<Member>();
				TreeSet<Long> groupMemberIds = new TreeSet<Long>();

				print("            Processing data ("
						+ memberResults.getResults().size() + " member(s)):");
				for (Member member : memberResults.getResults()) {

					groupMemberIds.add(member.getId());
					if (!allMemberIds.contains(member.getId())) {

						allMemberIds.add(member.getId());
						memberIdsPerCity.add(member.getId());
						newMembers.add(member);
					}// else clause {Ignores the repeated object}
				}
				println(" DONE");

				// Rewrite the all member ids file
				IOManager.writeObjectAllIds(MEMBER, allMemberIds);

				// Rewrite the member ids file per city
				IOManager.writeObjectIdsPerCity(cityIndex, MEMBER,
						memberIdsPerCity);

				// Persist the new json objects, if there is any
				if (!newMembers.isEmpty()) {
					IOManager.appendJsonObjects(MEMBER, newMembers.toArray());
				}

				// Persist the json relation between group and members
				IOManager.appendJsonRelations(GROUP_MEMBER, groupId,
						groupMemberIds);

				// Rewrite the trace file
				Tracer.writeTraceFile(cityIndex, Tracer.MEMBERS_BYGROUP_INDEX,
						groupIndex, 0, 0, offset);

				if (memberResults.getMeta().getTotal_count() > (URLManager.PAGE_SIZE * (offset + 1))) {
					offset++;
				} else {
					hasMoreData = false;
				}

				System.gc();

			} while (hasMoreData);

			// Reset the offset
			offset = 0;

			// Increment the groupIndex
			groupIndex++;
		}
	}

	private static void getEventsByGroup(int cityIndex) throws IOException {

		// Read the group id's per city already stored
		ArrayList<Long> groupIdsPerCity;
		try {
			groupIdsPerCity = IOManager.readObjectIdsPerCityList(cityIndex,
					GROUP);
		} catch (IOException e) {
			// There is no id. So, there is nothing to do.
			return;
		}

		// Set the initial groupIndex
		int groupIndex = Tracer.getGroupIndex();

		// Set the initial offset
		int offset = Tracer.getOffset();

		ObjectMapper mapper = new ObjectMapper();

		// Read the member id's already stored
		TreeSet<String> allEventIds;
		try {
			allEventIds = IOManager.readEventAllIds(EVENT);

		} catch (IOException e) {
			// There is no id yet...
			allEventIds = new TreeSet<String>();
		}

		final int groupsPerCall = 10;

		// Foreach group do...
		for (; groupIndex < groupIdsPerCity.size();) {
			int lastIndex = Math.min(groupIndex + groupsPerCall,
					groupIdsPerCity.size() - 1);
			List<Long> groupIds = groupIdsPerCity.subList(groupIndex,
					(groupIndex == lastIndex) ? lastIndex + 1 : lastIndex);

			println("        Groups (" + (groupIndex + 1) + " to "
					+ (lastIndex + 1) + "/" + groupIdsPerCity.size() + ")");

			boolean hasMoreData = true;
			do {
				// Check and stop for 1 hour, if needed
				ApiKeysManager.checkApiCallLimit(urlConn);

				print("            Fetching URL...");
				// Parse the JSON object directly from the URL
				urlConn = new URL(URLManager.getEventsURLByGroup(
						ApiKeysManager.getKey(), groupIds, offset))
						.openConnection();
				Results<Event> eventResults = mapper.readValue(
						new InputStreamReader(urlConn.getInputStream(),
								IOManager.CHAR_SET),
						new TypeReference<Results<Event>>() {
						});

				int totalObjects = eventResults.getMeta().getTotal_count();
				println("("
						+ ((totalObjects <= 0) ? 0 : (offset + 1))
						+ "/"
						+ (int) Math.ceil(totalObjects
								/ (double) URLManager.PAGE_SIZE) + ")");

				ArrayList<Event> newEvents = new ArrayList<Event>();

				print("            Processing data ("
						+ eventResults.getResults().size() + " event(s)):");
				for (Event e : eventResults.getResults()) {
					if (!allEventIds.contains(e.getId())) {
						allEventIds.add(e.getId());
						newEvents.add(e);
					}
				}
				println(" DONE");

				// Rewrite the all member ids file
				IOManager.writeEventAllIds(EVENT, allEventIds);

				// Persist the new json objects, if there is any
				if (!newEvents.isEmpty()) {
					IOManager.appendJsonObjects(EVENT, newEvents.toArray());
				}

				// Rewrite the trace file
				Tracer.writeTraceFile(cityIndex, Tracer.EVENTS_BYGROUP_INDEX,
						groupIndex, 0, 0, offset);

				// Checks if there is more data to fetch
				if (eventResults.getMeta().getTotal_count() > (URLManager.PAGE_SIZE * (offset + 1))) {
					offset++;
				} else {
					hasMoreData = false;
				}

				System.gc();

			} while (hasMoreData);

			// Reset the offset
			offset = 0;

			// Increment the groupIndex
			groupIndex = lastIndex + 1;
		}
	}

	/**
	 * It get the topics of all groups in a JSON object, this object is stored
	 * in a JSON file with a prefix like groupTopic and updates the JSON file
	 * with topics of the given city and the topic id's file.
	 * 
	 * @param cityIndex
	 * @throws JsonParseException
	 * @throws JsonMappingException
	 * @throws IOException
	 */
	private static void getGroupTopicsByGroup(int cityIndex) throws IOException {

		// Read the group id's per city already stored
		ArrayList<Long> groupIdsPerCity;
		try {
			groupIdsPerCity = IOManager.readObjectIdsPerCityList(cityIndex,
					GROUP);
		} catch (IOException e) {
			// There is no id. So, there is nothing to do.
			return;
		}

		// Set the initial groupIndex
		int groupIndex = Tracer.getGroupIndex();

		// Set the initial offset
		int offset = Tracer.getOffset();

		ObjectMapper mapper = new ObjectMapper();

		final int groupsPerCall = 25;

		// Foreach group do...
		for (; groupIndex < groupIdsPerCity.size();) {
			int lastIndex = Math.min(groupIndex + groupsPerCall,
					groupIdsPerCity.size() - 1);
			List<Long> groupIds = groupIdsPerCity.subList(groupIndex,
					(groupIndex == lastIndex) ? lastIndex + 1 : lastIndex);

			println("        Groups (" + (groupIndex + 1) + " to "
					+ (lastIndex + 1) + "/" + groupIdsPerCity.size() + ")");

			boolean hasMoreData = true;
			do {
				// Check and stop for 1 hour, if needed
				ApiKeysManager.checkApiCallLimit(urlConn);

				// Read all the members of the group
				print("            Fetching URL...");

				urlConn = new URL(URLManager.getGroupsURLByGroupId(
						ApiKeysManager.getKey(), groupIds, offset))
						.openConnection();
				Results<GroupTopics> groupTopicsResults = mapper.readValue(
						new InputStreamReader(urlConn.getInputStream(),
								IOManager.CHAR_SET),
						new TypeReference<Results<GroupTopics>>() {
						});

				int totalObjects = groupTopicsResults.getMeta()
						.getTotal_count();
				println("("
						+ ((totalObjects <= 0) ? 0 : (offset + 1))
						+ "/"
						+ (int) Math.ceil(totalObjects
								/ (double) URLManager.PAGE_SIZE) + ")");

				// Persist the new Topics (if it isn't empty)
				if (!groupTopicsResults.getResults().get(0).getTopics()
						.isEmpty()) {
					IOManager.appendJsonObjects(GROUP_TOPIC, groupTopicsResults
							.getResults().toArray());
				}// else clause {Ignores the repeated object}

				// Rewrite the trace file
				Tracer.writeTraceFile(cityIndex,
						Tracer.GROUPTOPICS_BYGROUP_INDEX, groupIndex, 0, 0,
						offset);

				// Checks if there is more data to fetch
				if (groupTopicsResults.getMeta().getTotal_count() > (URLManager.PAGE_SIZE * (offset + 1))) {
					offset++;
				} else {
					hasMoreData = false;
				}

				System.gc();

			} while (hasMoreData);

			// Reset the offset
			offset = 0;

			// Increment the groupIndex
			groupIndex = lastIndex + 1;
		}
	}

	private static void getRSVPsByEvents(int cityIndex) throws IOException {

		// Read all event id's
		ArrayList<String> allEventsIds;
		try {
			allEventsIds = IOManager.readEventAllIdsList(EVENT);
		} catch (IOException e) {
			// There is no id yet...
			allEventsIds = new ArrayList<String>();
		}

		// Set the initial members
		int eventIndex = Tracer.getEventIndex();

		// Set the initial offset
		int offset = Tracer.getOffset();

		ObjectMapper mapper = new ObjectMapper();

		final int eventsPerCall = 24;

		// Foreach member do...
		for (; eventIndex < allEventsIds.size();) {
			int lastIndex = Math.min(eventIndex + eventsPerCall,
					(allEventsIds.size() - 1));

			List<String> eventIds = allEventsIds.subList(eventIndex,
					(eventIndex == lastIndex) ? lastIndex + 1 : lastIndex);

			println("        RSVPs (" + (eventIndex + 1) + " to "
					+ (lastIndex + 1) + "/" + allEventsIds.size() + ")");

			boolean hasMoreData = true;
			do {
				// Check and stop for 1 hour at most, if needed
				ApiKeysManager.checkApiCallLimit(urlConn);

				print("            Fetching URL...");
				urlConn = new URL(URLManager.getRSVPsURLByEvents(
						ApiKeysManager.getKey(), eventIds, offset))
						.openConnection();
				Results<RSVP> rsvpResults = mapper.readValue(
						new InputStreamReader(urlConn.getInputStream(),
								IOManager.CHAR_SET),
						new TypeReference<Results<RSVP>>() {
						});

				int totalObjects = rsvpResults.getMeta().getTotal_count();
				println("("
						+ ((totalObjects <= 0) ? 0 : (offset + 1))
						+ "/"
						+ (int) Math.ceil(totalObjects
								/ (double) URLManager.PAGE_SIZE) + ")");

				print("            Processing data ("
						+ rsvpResults.getResults().size() + " rsvp(s)):");
				println(" DONE");

				// Persist the new json objects, if there is any
				if (!rsvpResults.getResults().isEmpty()) {
					IOManager.appendJsonObjects(RSVP, rsvpResults.getResults()
							.toArray());
				}

				// Rewrite the trace file
				Tracer.writeTraceFile(cityIndex, Tracer.RSVPS_BYEVENT_INDEX, 0,
						0, eventIndex, offset);

				// Checks if there is more data to fetch
				if (rsvpResults.getMeta().getTotal_count() > (URLManager.PAGE_SIZE * (offset + 1))) {
					offset++;
				} else {
					hasMoreData = false;
				}

				System.gc();

			} while (hasMoreData);

			// Reset the offset
			offset = 0;

			// Increment the eventIndex
			eventIndex = lastIndex + 1;
		}
	}

	/*
	 * PRINT METHODS
	 */

	private static void print(String s) {
		System.out.print(s);
	}

	private static void println(String s) {
		System.out.println(s);
	}

	/*
	 * READ PROPERTIES
	 */
	private static void readPropertiesFile() throws FileNotFoundException {
		Scanner sc = new Scanner(new File("properties.txt"));
		String[] entries = null, newKeys = null, keyNames = null;
		while (sc.hasNext()) {
			entries = sc.nextLine().split("=");
			if (entries[0].equals("API_KEYS")) {
				newKeys = entries[1].split(",");
			} else if (entries[0].equals("API_KEYS_NAMES")) {
				keyNames = entries[1].split(",");
			} else if (entries[0].equals("CITIES")) {
				cities = entries[1].split(",");
			}
		}
		sc.close();

		ApiKeysManager.setKeys(newKeys, keyNames);
	}

	public static void main(String[] args) throws IOException {

		// Set the API_KEY and CITIES from the properties.txt file
		readPropertiesFile();

		// Read the trace.txt file
		Tracer.readTraceFile();

		// Set the initial cityIndex
		int cityIndex = Tracer.getCityIndex();

		// Set the initial method index
		int methodIndex = Tracer.getMethodIndex();
		boolean reset = false;
		for (; cityIndex < cities.length; cityIndex++) {

			println("CITY: " + cities[cityIndex]);

			if (methodIndex <= Tracer.FINDGROUPS_INDEX) {
				if (reset) {
					Tracer.resetTraceData(cityIndex, Tracer.FINDGROUPS_INDEX,
							0, 0, 0, 0);
				}
				println("    Find Groups by City...");
				findGroupsByCity(cityIndex);
				reset = true;
			}
			if (methodIndex <= Tracer.MEMBERS_BYGROUP_INDEX) {
				if (reset) {
					Tracer.resetTraceData(cityIndex,
							Tracer.MEMBERS_BYGROUP_INDEX, 0, 0, 0, 0);
				}
				println("    Get Members by Group...");
				getMembersByGroup(cityIndex);
				reset = true;
			}
			if (methodIndex <= Tracer.EVENTS_BYGROUP_INDEX) {
				if (reset) {
					Tracer.resetTraceData(cityIndex,
							Tracer.EVENTS_BYGROUP_INDEX, 0, 0, 0, 0);
				}
				println("    Get Events by Group...");
				getEventsByGroup(cityIndex);
				reset = true;
			}
			if (methodIndex <= Tracer.GROUPTOPICS_BYGROUP_INDEX) {
				if (reset) {
					Tracer.resetTraceData(cityIndex,
							Tracer.GROUPTOPICS_BYGROUP_INDEX, 0, 0, 0, 0);
				}
				println("    Get GroupTopics by Group...");
				getGroupTopicsByGroup(cityIndex);
				reset = true;
			}

			// Reset the method index
			methodIndex = Tracer.FINDGROUPS_INDEX;
		}

		// Get the RSVPs for all events (independent from city)
		if (methodIndex <= Tracer.RSVPS_BYEVENT_INDEX) {
			println("All Cities:");
			if (reset) {
				// The cityIndex should be equals to the city list length
				// (avoiding the for loop)
				Tracer.resetTraceData(cityIndex, Tracer.RSVPS_BYEVENT_INDEX, 0,
						0, 0, 0);
			}
			println("    Get RSVPs by Events...");
			getRSVPsByEvents(cityIndex);
			reset = true;
		}

		println("FINISHED! =D");
	}
}
