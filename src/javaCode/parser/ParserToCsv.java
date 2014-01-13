/*
   ParserToCsv.java
   Copyright (C) 2013  Elias Paulino and Augusto Queiroz

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

package javaCode.parser;

import java.io.File;
import java.io.FileOutputStream;
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

	private static TreeSet<Long> userIds = new TreeSet<Long>();
	private static TreeSet<String> eventIds = new TreeSet<String>();
	private static TreeSet<Long> groupIds = new TreeSet<Long>();
	private static TreeSet<Long> venueIds = new TreeSet<Long>();
	private static TreeSet<Long> rsvpIds = new TreeSet<Long>();
	private static TreeSet<Long> tagIds = new TreeSet<Long>();
	private static TreeSet<Long> categoryIds = new TreeSet<Long>();

	public static void createCsvRelations(String arquivoLeitura,
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

		groupWriter.writeNext(new String[] { "group_id", "name", "urlname",
				"created", "city", "country", "join_mode", "visibility",
				"latitude", "longitude", "users", "category_id",
				"organizer_id" });

		categoryWriter.writeNext(new String[] { "category_id", "name", "shortname" });

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
					if ((new Double(group.getLat()) != null)) {
						groupData[8] = String.valueOf(group.getLat());

					}
					if ((new Double(group.getLon()) != null)) {
						groupData[9] = String.valueOf(group.getLon());

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

	public static void createCsvFromUserWithTags(File[] userJsonFiles,
			String userCsvFilename, String tagCsvFilename,
			String userTagCsvFilename) throws IOException {

		CSVWriter userWriter = null;
		CSVWriter tagWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(tagCsvFilename), CHAR_SET),
				CSV_SEPARATOR);
		CSVWriter userTagWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(userTagCsvFilename), CHAR_SET),
				CSV_SEPARATOR);

		tagWriter.writeNext(new String[] { "tag_id", "name" });
		userTagWriter.writeNext(new String[] { "user_id", "tag_id" });

		Arrays.sort(userJsonFiles, new JsonFilenameComparator());

		int i = 0;
		for (File f : userJsonFiles) {

			if (i++ % 5 == 0) {
				if (userWriter != null) {
					userWriter.close();
				}
				userWriter = new CSVWriter(new OutputStreamWriter(
						new FileOutputStream(userCsvFilename + "_"
								+ (((i - 1) / 5) + 1) + ".csv"), CHAR_SET),
						CSV_SEPARATOR);
				userWriter.writeNext(new String[] { "user_id", "name", "city",
						"country", "latitude", "longitude", "joined" });
			}

			Scanner sc = new Scanner(f, CHAR_SET);

			ObjectMapper mapper = new ObjectMapper();

			while (sc.hasNext()) {
				Member[] userArray = mapper.readValue(sc.nextLine(),
						Member[].class);
				for (Member user : userArray) {

					if (userIds.contains(user.getId()))
						continue;

					userIds.add(user.getId());

					String[] userData = new String[7];

					if ((new Long(user.getId()) != null)) {
						userData[0] = String.valueOf(user.getId());

					}
					if (user.getName() != null) {
						userData[1] = user.getName();

					}
					if (user.getCity() != null) {
						userData[2] = user.getCity();

					}
					if (user.getCountry() != null) {
						userData[3] = user.getCountry();

					}
					if ((new Double(user.getLat()) != null)) {
						userData[4] = String.valueOf(user.getLat());
						
					}
					if ((new Double(user.getLon()) != null)) {
						userData[5] = String.valueOf(user.getLon());

					}
					if ((new Long(user.getJoined()) != null)) {
						userData[6] = String.valueOf(user.getJoined());

					}
					userWriter.writeNext(userData);

					if (user.getTopics() != null) {
						for (Topic t : user.getTopics()) {

							String[] tagData = checkAttributesTag(t);

							// Add the relation: user_id -> tag_id
							userTagWriter.writeNext(new String[] {
									userData[0], tagData[0] });

							if (tagIds.contains(t.getId())) {
								continue;
							}

							tagIds.add(t.getId());
							tagWriter.writeNext(tagData);
						}

					}
				}
			}
			sc.close();
		}
		userWriter.close();
		tagWriter.close();
		userTagWriter.close();
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

		venueWriter.writeNext(new String[] { "venue_id", "latitude", "longitude", "name",
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

				eventWriter.writeNext(new String[] { "event_id", "name", "created",
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

	public static void createCsvFromGroupTags(File[] groupTagJsonFiles,
			String tagCsvFilename, String groupTagCsvFilename)
			throws IOException {

		ObjectMapper mapper = new ObjectMapper();
		CSVWriter tagWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(tagCsvFilename, true), CHAR_SET),
				CSV_SEPARATOR);
		CSVWriter groupTagWriter = new CSVWriter(new OutputStreamWriter(
				new FileOutputStream(groupTagCsvFilename), CHAR_SET),
				CSV_SEPARATOR);

		groupTagWriter.writeNext(new String[] { "group_id", "tag_id" });

		for (File arquivo : groupTagJsonFiles) {

			Scanner sc = new Scanner(arquivo, CHAR_SET);

			while (sc.hasNext()) {

				GroupTopics[] groupTagsArray = mapper.readValue(
						sc.nextLine(), GroupTopics[].class);

				for (GroupTopics gTags : groupTagsArray) {

					for (Topic tag : gTags.getTopics()) {

						String[] tagData = new String[2];

						if ((new Long(tag.getId()) != null)) {
							tagData[0] = String.valueOf(tag.getId());
						}
						if (tag.getName() != null) {
							tagData[1] = tag.getName();

						}
						groupTagWriter
								.writeNext(new String[] {
										String.valueOf(gTags.getId()),
										tagData[0] });

						if (tagIds.contains(tag.getId())) {
							continue;
						}

						tagIds.add(tag.getId());
						tagWriter.writeNext(tagData);
					}
				}
			}
			sc.close();
		}
		tagWriter.close();
		groupTagWriter.close();
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
				rsvpWriter.writeNext(new String[] { "rsvp_id", "created", "mtime",
						"response", "user_id", "event_id" });
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
		if ((new Double(v.getLat()) != null)) {
			venueArray[1] = String.valueOf(v.getLat());

		}
		if ((new Double(v.getLon()) != null)) {
			venueArray[2] = String.valueOf(v.getLon());
			
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

	private static String[] checkAttributesTag(Topic t) {

		String[] tagArray = new String[2];

		if ((new Long(t.getId()) != null)) {
			tagArray[0] = String.valueOf(t.getId());

		}
		if (t.getName() != null) {
			tagArray[1] = t.getName();

		}

		return tagArray;
	}
}
