/*
   MainParser.java
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

import java.io.IOException;
import javaCode.collection.MainCollection;
import javaCode.collection.util.JsonFilenameFilter;

public class MainParser {

	public static void main(String[] args) throws IOException {

		String dataDir = "data/";
		String dataCsvDir = "data_csv/";

		if (!new File(dataCsvDir).exists()) {
			new File(dataCsvDir).mkdir();
		}

		/*
		 * CSV for RELATIONS
		 */
		System.out.println("Parsing Relations only...");
		String[] relations = { MainCollection.GROUP_MEMBER };

		for (String relation : relations) {
			System.out.println("    " + relation + "...");

			String[] headers = relation.split("_");
			if (new File(dataDir + relation + "s").exists())
				ParserToCsv.createCsvRelations(dataDir + relation + "s/"
						+ relation + "_ids.txt", dataCsvDir + relation
						+ "s.csv", headers[0] + "_id", headers[1] + "_id");
		}

		/*
		 * CSV for OBJECTS
		 */
		System.out.println("Parsing Objects and its relations...");

		System.out.println("    Groups and Categories...");
		ParserToCsv.createCsvFromGroupWithCategories(new File(dataDir
				+ MainCollection.GROUP + "s").listFiles(new JsonFilenameFilter(
				MainCollection.GROUP)), dataCsvDir + MainCollection.GROUP
				+ "s.csv", dataCsvDir + "categories.csv");

		System.out
				.println("    Members, Topics and relation: Member -> Topics...");
		ParserToCsv.createCsvFromMemberWithTopics(new File(dataDir
				+ MainCollection.MEMBER + "s")
				.listFiles(new JsonFilenameFilter(MainCollection.MEMBER)),
				dataCsvDir + MainCollection.MEMBER + "s", dataCsvDir
						+ MainCollection.TOPIC + "s.csv", dataCsvDir
						+ "member_topics.csv");

		System.out.println("    Event, Venues and relation: Group -> Event...");
		ParserToCsv.createCsvFromEventWithVenueByGroup(new File(dataDir
				+ MainCollection.EVENT + "s").listFiles(new JsonFilenameFilter(
				MainCollection.EVENT)),
				dataCsvDir + MainCollection.EVENT + "s", dataCsvDir
						+ "venues.csv", dataCsvDir + "group_events.csv");

		System.out
				.println("    Topics (again) and relation: Group -> Topics...");
		ParserToCsv.createCsvFromGroupTopics(new File(dataDir
				+ MainCollection.GROUP_TOPIC + "s")
				.listFiles(new JsonFilenameFilter(MainCollection.GROUP_TOPIC)),
				dataCsvDir + MainCollection.TOPIC + "s.csv", dataCsvDir
						+ "group_topics.csv");

		System.out.println("    RSVPs...");
		ParserToCsv.createCsvFromRSVP(new File(dataDir + MainCollection.RSVP
				+ "s").listFiles(new JsonFilenameFilter(MainCollection.RSVP)),
				dataCsvDir + MainCollection.RSVP + "s");

		System.out.println("Finished!");
	}
}
