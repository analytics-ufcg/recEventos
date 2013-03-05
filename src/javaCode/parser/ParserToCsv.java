package javaCode.parser;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.Arrays;
import java.util.Scanner;
import java.util.TreeSet;
import javaCode.collection.util.JsonFilenameComparator;
import javaCode.pojo.Category;
import javaCode.pojo.Event;
import javaCode.pojo.Group;
import javaCode.pojo.GroupTopics;
import javaCode.pojo.Member;
import javaCode.pojo.RSVP;
import javaCode.pojo.Topic;
import javaCode.pojo.Venue;

import org.codehaus.jackson.map.ObjectMapper;

import au.com.bytecode.opencsv.CSVWriter;

public class ParserToCsv {

	private static final char CSV_SEPARATOR = ',';
	private static final String CHAR_SET = "UTF-8";

	private static TreeSet<Long> memberIds = new TreeSet<Long>();
	private static TreeSet<String> eventIds = new TreeSet<String>();
	private static TreeSet<Long> groupIds = new TreeSet<Long>();
	private static TreeSet<Long> venueIds = new TreeSet<Long>();
	private static TreeSet<Long> rsvpIds = new TreeSet<Long>();
	private static TreeSet<Long> topicIds = new TreeSet<Long>();
	private static TreeSet<Long> categoryIds = new TreeSet<Long>();

	public static void geraCsvRelacoes(String arquivoLeitura,
			String arquivoEscrita, String header1, String header2)
			throws IOException {

		CSVWriter writer = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(arquivoEscrita), CHAR_SET), CSV_SEPARATOR);
		Scanner sc = new Scanner(new File(arquivoLeitura));

		// Create header
		writer.writeNext(new String[] { header1, header2 });
		while (sc.hasNext()) {

			String[] entries = sc.nextLine().split(":");

			// Cria uma array dos id's
			String[] arrayIds = entries[1].replace("[", "").replace("]", "")
					.split(",");

			if (!arrayIds[0].equals("")) {
				for (String id : arrayIds) {
					writer.writeNext(new String[] { entries[0], id });
				}
			}
		}
		writer.close();
		sc.close();
	}

	public static void createCsvFromGroupWithCategories(File[] groupJsonFiles,
			String groupCsvFilename, String categoryCsvFilename)
			throws IOException {

		CSVWriter groupWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(groupCsvFilename), CHAR_SET),
				CSV_SEPARATOR);
		CSVWriter categoryWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(categoryCsvFilename), CHAR_SET),
				CSV_SEPARATOR);

		groupWriter.writeNext(new String[] { "id", "name", "urlname",
				"created", "city", "country", "join_mode", "visibility", "lon",
				"lat", "members", "category_id", "organizer_id" });

		categoryWriter.writeNext(new String[] { "id", "name", "shortname" });

		for (File arquivo : groupJsonFiles) {

			Scanner sc = new Scanner(arquivo, CHAR_SET);

			while (sc.hasNext()) {

				ObjectMapper mapper = new ObjectMapper();
				Group[] groupArray = mapper.readValue(sc.nextLine(),
						Group[].class);

				for (Group group : groupArray) {

					if (groupIds.contains(group.getId()))
						continue;

					groupIds.add(group.getId());

					String[] groupData = new String[13];

					if ((new Long(group.getId()) != null)) {
						groupData[0] = String.valueOf(group.getId());

					}
					if (group.getName() != null) {
						groupData[1] = group.getName();

					}
					if (group.getUrlname() != null) {
						groupData[2] = group.getUrlname();

					}
					if ((new Long(group.getCreated()) != null)) {
						groupData[3] = String.valueOf(group.getCreated());

					}
					if (group.getCity() != null) {
						groupData[4] = group.getCity();

					}
					if (group.getCountry() != null) {
						groupData[5] = group.getCountry();

					}
					if (group.getJoin_mode() != null) {
						groupData[6] = group.getJoin_mode();

					}
					if (group.getVisibility() != null) {
						groupData[7] = group.getVisibility();

					}
					if ((new Double(group.getLon()) != null)) {
						groupData[8] = String.valueOf(group.getLon());

					}
					if ((new Double(group.getLat()) != null)) {
						groupData[9] = String.valueOf(group.getLat());

					}
					if (group.getMembers() != null) {
						groupData[10] = group.getMembers();

					}
					if (group.getCategory() != null) {
						String[] categoryArray = checkAttributesCategory(group
								.getCategory());

						groupData[11] = categoryArray[0];

						if (!categoryIds.contains(group.getCategory().getId())) {

							categoryWriter.writeNext(categoryArray);
							categoryIds.add(group.getCategory().getId());
						}
					}

					if (group.getOrganizer() != null) {
						groupData[12] = String.valueOf(group.getOrganizer()
								.getId());

					}

					groupWriter.writeNext(groupData);
				}
			}
			sc.close();
		}
		groupWriter.close();
		categoryWriter.close();
	}

	public static void createCsvFromMemberWithTopics(File[] memberJsonFiles,
			String memberCsvFilename, String topicCsvFilename,
			String memberTopicCsvFilename) throws IOException {

		CSVWriter memberWriter = null;
		CSVWriter topicWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(topicCsvFilename), CHAR_SET),
				CSV_SEPARATOR);
		CSVWriter memberTopicWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(memberTopicCsvFilename), CHAR_SET),
				CSV_SEPARATOR);

		topicWriter.writeNext(new String[] { "id", "name" });
		memberTopicWriter.writeNext(new String[] { "member_id", "topic_id" });

		Arrays.sort(memberJsonFiles, new JsonFilenameComparator());

		int i = 0;
		for (File f : memberJsonFiles) {

			if (i++ % 5 == 0) {
				if (memberWriter != null) {
					memberWriter.close();
				}
				memberWriter = new CSVWriter(new OutputStreamWriter(
						new FileOutputStream(memberCsvFilename + "_"
								+ (((i - 1) / 5) + 1) + ".csv"), CHAR_SET),
						CSV_SEPARATOR);
				memberWriter.writeNext(new String[] { "id", "name", "city",
						"country", "lon", "lat", "joined" });
			}

			Scanner sc = new Scanner(f, CHAR_SET);

			ObjectMapper mapper = new ObjectMapper();

			while (sc.hasNext()) {
				Member[] memberArray = mapper.readValue(sc.nextLine(),
						Member[].class);
				for (Member member : memberArray) {

					if (memberIds.contains(member.getId()))
						continue;

					memberIds.add(member.getId());

					String[] memberData = new String[7];

					if ((new Long(member.getId()) != null)) {
						memberData[0] = String.valueOf(member.getId());

					}
					if (member.getName() != null) {
						memberData[1] = member.getName();

					}
					if (member.getCity() != null) {
						memberData[2] = member.getCity();

					}
					if (member.getCountry() != null) {
						memberData[3] = member.getCountry();

					}
					if ((new Double(member.getLon()) != null)) {
						memberData[4] = String.valueOf(member.getLon());

					}
					if ((new Double(member.getLat()) != null)) {
						memberData[5] = String.valueOf(member.getLat());

					}
					if ((new Long(member.getJoined()) != null)) {
						memberData[6] = String.valueOf(member.getJoined());

					}
					memberWriter.writeNext(memberData);

					if (member.getTopics() != null) {
						for (Topic t : member.getTopics()) {

							String[] topicData = checkAttributesTopic(t);

							// Add the relation: member_id -> topic_id
							memberTopicWriter.writeNext(new String[] {
									memberData[0], topicData[0] });

							// If the topic wasn't added in the object file, do
							// it
							if (!topicIds.contains(t.getId())) {
								topicWriter.writeNext(topicData);
								topicIds.add(t.getId());
							}
						}

					}
				}
			}
			sc.close();
		}
		memberWriter.close();
		topicWriter.close();
		memberTopicWriter.close();
	}

	public static void createCsvFromEventWithVenueByGroup(
			File[] eventJsonFiles, String eventCsvFilename,
			String venueCsvFilename, String groupEventCsvFilename)
			throws IOException {

		CSVWriter eventWriter = null;
		CSVWriter venueWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(venueCsvFilename), CHAR_SET),
				CSV_SEPARATOR);
		CSVWriter groupEventWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(groupEventCsvFilename), CHAR_SET),
				CSV_SEPARATOR);

		venueWriter.writeNext(new String[] { "id", "lon", "lat", "name",
				"address_1", "address_2", "address_3", "city", "country",
				"rating_count", "rating" });
		groupEventWriter.writeNext(new String[] { "group_id", "event_id" });

		Arrays.sort(eventJsonFiles, new JsonFilenameComparator());

		int i = 0;
		for (File file : eventJsonFiles) {

			if (i++ % 5 == 0) {
				if (eventWriter != null) {
					eventWriter.close();
				}
				eventWriter = new CSVWriter(new OutputStreamWriter(
						new FileOutputStream(eventCsvFilename + "_"
								+ (((i - 1) / 5) + 1) + ".csv"), CHAR_SET),
						CSV_SEPARATOR);

				eventWriter.writeNext(new String[] { "id", "name", "created",
						"time", "utc_offset", "status", "visibility",
						"headCount", "rsvp_limit", "venue_id", "group_id" });
			}

			Scanner sc = new Scanner(file, CHAR_SET);

			while (sc.hasNext()) {

				ObjectMapper mapper = new ObjectMapper();
				Event[] eventArray = mapper.readValue(sc.nextLine(),
						Event[].class);

				for (Event event : eventArray) {

					if (eventIds.contains(event.getId()))
						continue;

					eventIds.add(event.getId());

					String[] eventData = new String[11];

					if (event.getId() != null) {
						eventData[0] = event.getId();
					}
					if (event.getName() != null) {
						eventData[1] = event.getName();
					}
					if (new Long(event.getCreated()) != null) {
						eventData[2] = String.valueOf(event.getCreated());
					}
					if (new Long(event.getTime()) != null) {
						eventData[3] = String.valueOf(event.getTime());
					}
					if (new Long(event.getUtc_offset()) != null) {
						eventData[4] = String.valueOf(event.getUtc_offset());
					}
					if (event.getStatus() != null) {
						eventData[5] = event.getStatus();
					}
					if (event.getVisibility() != null) {
						eventData[6] = event.getVisibility();
					}
					if (new Long(event.getHeadcount()) != null) {
						eventData[7] = String.valueOf(event.getHeadcount());
					}
					if ((new Long(event.getRsvp_limit()) != null)) {
						eventData[8] = String.valueOf(event.getRsvp_limit());
					}
					if (event.getVenue() != null) {
						String[] venueArray = checkAttributesVenue(event
								.getVenue());
						eventData[9] = venueArray[0];

						// Adiciona venues do event no arquivo .csv
						if (!venueIds.contains(event.getVenue().getId())) {
							venueWriter.writeNext(venueArray);
							venueIds.add(event.getVenue().getId());
						}
					}
					if (new Long(event.getGroup().getId()) != null) {
						eventData[10] = String
								.valueOf(event.getGroup().getId());

						groupEventWriter.writeNext(new String[] {
								String.valueOf(event.getGroup().getId()),
								eventData[0] });

					}
					eventWriter.writeNext(eventData);
				}

			}
			sc.close();
		}
		eventWriter.close();
		venueWriter.close();
		groupEventWriter.close();
	}

	public static void createCsvFromGroupTopics(File[] groupTopicJsonFiles,
			String topicCsvFilename, String groupTopicCsvFilename)
			throws IOException {

		ObjectMapper mapper = new ObjectMapper();
		CSVWriter topicWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(topicCsvFilename), CHAR_SET),
				CSV_SEPARATOR);
		CSVWriter groupTopicWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(groupTopicCsvFilename), CHAR_SET),
				CSV_SEPARATOR);

		groupTopicWriter.writeNext(new String[] { "group_id", "topic_id" });

		for (File arquivo : groupTopicJsonFiles) {

			Scanner sc = new Scanner(arquivo, CHAR_SET);

			while (sc.hasNext()) {

				GroupTopics[] groupTopicsArray = mapper.readValue(
						sc.nextLine(), GroupTopics[].class);

				for (GroupTopics gTopics : groupTopicsArray) {

					for (Topic topic : gTopics.getTopics()) {

						if (topicIds.contains(gTopics.getId()))
							continue;

						topicIds.add(topic.getId());

						String[] topicData = new String[2];

						if ((new Long(topic.getId()) != null)) {
							topicData[0] = String.valueOf(topic.getId());
						}
						if (topic.getName() != null) {
							topicData[1] = topic.getName();

						}
						topicWriter.writeNext(topicData);
						groupTopicWriter
								.writeNext(new String[] {
										String.valueOf(gTopics.getId()),
										topicData[0] });
					}

				}
			}
			sc.close();
		}
		topicWriter.close();
		groupTopicWriter.close();
	}

	public static void createCsvFromRSVP(File[] rsvpJsonFiles,
			String rsvpCsvFilename) throws IOException {

		ObjectMapper mapper = new ObjectMapper();
		CSVWriter rsvpWriter = null;
		Arrays.sort(rsvpJsonFiles, new JsonFilenameComparator());

		int i = 0;
		for (File file : rsvpJsonFiles) {

			if (i++ % 5 == 0) {
				if (rsvpWriter != null) {
					rsvpWriter.close();
				}
				rsvpWriter = new CSVWriter(new OutputStreamWriter(
						new FileOutputStream(rsvpCsvFilename + "_"
								+ (((i - 1) / 5) + 1) + ".csv"), CHAR_SET),
						CSV_SEPARATOR);
				rsvpWriter.writeNext(new String[] { "id", "created", "mtime",
						"response", "member_id", "event_id" });
			}

			Scanner sc = new Scanner(file, CHAR_SET);

			while (sc.hasNext()) {

				RSVP[] rsvpArray = mapper
						.readValue(sc.nextLine(), RSVP[].class);

				for (RSVP rsvp : rsvpArray) {

					if (rsvpIds.contains(rsvp.getRsvp_id()))
						continue;

					rsvpIds.add(rsvp.getRsvp_id());

					String[] rsvpData = new String[6];

					if ((new Long(rsvp.getRsvp_id()) != null)) {
						rsvpData[0] = String.valueOf(rsvp.getRsvp_id());

					}
					if ((new Long(rsvp.getCreated()) != null)) {
						rsvpData[1] = String.valueOf(rsvp.getCreated());

					}
					if ((new Long(rsvp.getMtime()) != null)) {
						rsvpData[2] = String.valueOf(rsvp.getMtime());

					}
					if (rsvp.getResponse() != null) {
						rsvpData[3] = rsvp.getResponse();

					}
					if (rsvp.getMember() != null
							&& new Long(rsvp.getMember().getMember_id()) != null) {
						rsvpData[4] = String.valueOf(rsvp.getMember()
								.getMember_id());
					}

					if (rsvp.getEvent() != null
							&& rsvp.getEvent().getId() != null) {
						rsvpData[5] = rsvp.getEvent().getId();
					}

					rsvpWriter.writeNext(rsvpData);
				}
			}
			sc.close();
		}
		rsvpWriter.close();
	}

	private static String[] checkAttributesCategory(Category category) {
		String[] categoryData = new String[3];

		if ((new Long(category.getId()) != null)) {
			categoryData[0] = String.valueOf(category.getId());

		}
		if (category.getName() != null) {
			categoryData[1] = category.getName();

		}
		if (category.getShortname() != null) {
			categoryData[2] = category.getShortname();

		}
		return categoryData;
	}

	private static String[] checkAttributesVenue(Venue v) {

		String[] venueArray = new String[11];

		if ((new Long(v.getId()) != null)) {
			venueArray[0] = String.valueOf(v.getId());

		}
		if ((new Double(v.getLon()) != null)) {
			venueArray[1] = String.valueOf(v.getLon());

		}
		if ((new Double(v.getLat()) != null)) {
			venueArray[2] = String.valueOf(v.getLat());

		}
		if ((v.getName()) != null) {
			venueArray[3] = v.getName();

		}
		if (v.getAddress_1() != null) {
			venueArray[4] = v.getAddress_1();

		}
		if (v.getAddress_2() != null) {
			venueArray[5] = v.getAddress_2();

		}
		if (v.getAddress_3() != null) {
			venueArray[6] = v.getAddress_3();

		}
		if (v.getCity() != null) {
			venueArray[7] = v.getCity();

		}
		if ((v.getCountry() != null)) {
			venueArray[8] = v.getCountry();

		}
		if ((new Long(v.getRating_count()) != null)) {
			venueArray[9] = String.valueOf(v.getRating_count());

		}
		if ((new Long(v.getRating()) != null)) {
			venueArray[10] = String.valueOf(v.getRating());

		}

		return venueArray;

	}

	private static String[] checkAttributesTopic(Topic t) {

		String[] topicArray = new String[2];

		if ((new Long(t.getId()) != null)) {
			topicArray[0] = String.valueOf(t.getId());

		}
		if (t.getName() != null) {
			topicArray[1] = t.getName();

		}

		return topicArray;
	}
}
