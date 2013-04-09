/*
   IOManager.java
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

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;
import java.util.TreeSet;
import javaCode.collection.MainCollection;

import org.codehaus.jackson.map.ObjectMapper;

public class IOManager {

	public static final String LINE_SEPARATOR = System
			.getProperty("line.separator");
	public static final String FIELD_SEPARATOR = ":";
	public static final String CHAR_SET = "UTF-8";
	public static final String DATA_DIR = "data";
	private static final long MAX_JSON_FILE_SIZE = 4194304; // equals to 4MB

	/*
	 * FILENAME METHODS
	 */

	/**
	 * Create the name of the next JSON file of the given object type
	 * 
	 * @param objectType
	 * @param quantity
	 * @return
	 */
	private static String getNextJsonFilename(String objectType) {
		File dataDir = new File(DATA_DIR);
		File objectDir = new File(DATA_DIR + "/" + objectType + "s");

		if (!dataDir.exists()) {
			dataDir.mkdir();
		}
		if (!objectDir.exists()) {
			objectDir.mkdir();
		}

		// Select only the files from this sourceCity
		JsonFilenameFilter filenameFilter = new JsonFilenameFilter(objectType);
		File[] filteredFiles = objectDir.listFiles(filenameFilter);

		if (filteredFiles.length > 0) {
			// If there is any filename, iterate over them and select the one
			// with the highest index
			Arrays.sort(filteredFiles, new JsonFilenameComparator());

			File lastFile = filteredFiles[filteredFiles.length - 1];

			if (lastFile.length() > MAX_JSON_FILE_SIZE) {
				// If this one is bigger than 4096 Bytes increment the index to
				// create a new one objectDir.length();
				return objectDir.getAbsolutePath() + "/" + objectType + "s_"
						+ (filteredFiles.length + 1) + ".json";

			} else {
				// Return the filename with the last index
				return lastFile.getAbsolutePath();
			}
		} else {
			// Return the first filename (index 1)
			return (objectDir.getAbsolutePath() + "/" + objectType + "s_1.json");
		}
	}

	/**
	 * Create the ALL IDS filename, based on the objectType
	 * 
	 * @param objectType
	 * @return
	 */
	private static String getObjectAllIdsFilename(String objectType) {
		File dataDir = new File(DATA_DIR);
		File idDir = new File(DATA_DIR + "/" + objectType + "s");

		if (!dataDir.exists()) {
			dataDir.mkdir();
		}
		if (!idDir.exists()) {
			idDir.mkdir();
		}

		// The filename contains the quantity of json objects and the
		// index of the file
		return (idDir.getAbsoluteFile() + "/" + objectType + "_ids.txt");
	}

	/**
	 * Create the IDS PER CITY filename, based on the objectType
	 * 
	 * @param sourceCity
	 * @param objectType
	 * @return
	 */
	private static String getObjectIdsPerCityFilename(int cityIndex,
			String objectType) {
		return getObjectAllIdsFilename(objectType).replace(
				".txt",
				"_"
						+ MainCollection.cities[cityIndex].toLowerCase()
								.replace(" ", "-") + ".txt");
	}

	/*
	 * READ AND WRITE METHODS
	 */

	/**
	 * Read the file with all ids of the given object
	 * 
	 * @param objectType
	 * @return
	 * @throws IOException
	 */
	public static TreeSet<Long> readObjectAllIds(String objectType)
			throws IOException {

		Scanner in = new Scanner(new File(getObjectAllIdsFilename(objectType)),
				CHAR_SET);

		TreeSet<Long> objectIds = new TreeSet<Long>();

		while (in.hasNext()) {
			objectIds.add(Long.valueOf(in.nextLine()));
		}
		in.close();

		return objectIds;
	}

	/**
	 * Write the file of all ids, with new ids of the given object
	 * 
	 * @param objectType
	 * @param objectIds
	 * @throws IOException
	 */
	public static void writeObjectAllIds(String objectType,
			TreeSet<Long> objectIds) throws IOException {

		OutputStreamWriter outAllIds = new OutputStreamWriter(
				new FileOutputStream(new File(
						getObjectAllIdsFilename(objectType))), CHAR_SET);

		// Clean the file
		outAllIds.write("");
		for (Long id : objectIds) {
			outAllIds.append(id + LINE_SEPARATOR);
		}
		outAllIds.close();
	}

	/**
	 * Reads the file with the ids per city of the given object
	 * 
	 * @param sourceCity
	 * @param objectType
	 * @return
	 * @throws IOException
	 */
	public static TreeSet<Long> readObjectIdsPerCity(int cityIndex,
			String objectType) throws IOException {

		Scanner in = new Scanner(new File(getObjectIdsPerCityFilename(
				cityIndex, objectType)), CHAR_SET);

		TreeSet<Long> objectIds = new TreeSet<Long>();
		while (in.hasNext()) {
			objectIds.add(Long.valueOf(in.nextLine()));
		}
		in.close();

		return objectIds;
	}

	public static ArrayList<Long> readObjectIdsPerCityList(int cityIndex,
			String objectType) throws IOException {

		Scanner in = new Scanner(new File(getObjectIdsPerCityFilename(
				cityIndex, objectType)), CHAR_SET);

		ArrayList<Long> objectIds = new ArrayList<Long>();
		while (in.hasNext()) {
			objectIds.add(Long.valueOf(in.nextLine()));
		}
		in.close();

		return objectIds;
	}

	/**
	 * Write the file of the ids per city with new ids of the given object
	 * 
	 * @param sourceCity
	 * @param objectType
	 * @param objectIds
	 * @throws IOException
	 */
	public static void writeObjectIdsPerCity(int cityIndex, String objectType,
			TreeSet<Long> objectIds) throws IOException {

		OutputStreamWriter outPerCity = new OutputStreamWriter(
				new FileOutputStream(new File(getObjectIdsPerCityFilename(
						cityIndex, objectType))), CHAR_SET);

		// Clean the file
		outPerCity.write("");
		for (Long id : objectIds) {
			outPerCity.append(id + LINE_SEPARATOR);
		}
		outPerCity.close();
	}

	public static void appendJsonObjects(String objectType, Object[] array)
			throws IOException {

		OutputStreamWriter outJsonPerCity = new OutputStreamWriter(
				new FileOutputStream(new File(getNextJsonFilename(objectType)),
						true), CHAR_SET);

		// Append a new line to the city file
		ObjectMapper mapper = new ObjectMapper();
		outJsonPerCity
				.append(mapper.writeValueAsString(array) + LINE_SEPARATOR);

		outJsonPerCity.close();
	}

	public static void appendJsonRelations(String objectType, Long id,
			TreeSet<Long> idList) throws IOException {
		OutputStreamWriter outJsonPerCity = new OutputStreamWriter(
				new FileOutputStream(new File(
						getObjectAllIdsFilename(objectType)), true), CHAR_SET);

		// Append a new line to the city file
		outJsonPerCity.append(id + FIELD_SEPARATOR
				+ idList.toString().replace(" ", "") + LINE_SEPARATOR);

		outJsonPerCity.close();
	}

	/*
	 * EVENT ID METHODS, STRING PROBLEM
	 */

	/**
	 * Read the file with all ids of the given object
	 * 
	 * @param objectType
	 * @return
	 * @throws IOException
	 */
	public static TreeSet<String> readEventAllIds(String objectType)
			throws IOException {

		Scanner in = new Scanner(new File(getObjectAllIdsFilename(objectType)),
				CHAR_SET);
		TreeSet<String> objectIds = new TreeSet<String>();

		while (in.hasNext()) {
			objectIds.add(in.nextLine());
		}
		in.close();

		return objectIds;
	}

	public static ArrayList<String> readEventAllIdsList(String objectType)
			throws IOException {

		Scanner in = new Scanner(new File(getObjectAllIdsFilename(objectType)),
				CHAR_SET);
		ArrayList<String> objectIds = new ArrayList<String>();

		while (in.hasNext()) {
			objectIds.add(in.nextLine());
		}
		in.close();

		return objectIds;
	}

	/**
	 * Write the file of all ids, with new ids of the given object
	 * 
	 * @param objectType
	 * @param objectIds
	 * @throws IOException
	 */
	public static void writeEventAllIds(String objectType,
			TreeSet<String> objectIds) throws IOException {

		OutputStreamWriter outAllIds = new OutputStreamWriter(
				new FileOutputStream(new File(
						getObjectAllIdsFilename(objectType))), CHAR_SET);

		// Clean the file
		outAllIds.write("");
		for (String id : objectIds) {
			outAllIds.append(id + LINE_SEPARATOR);
		}
		outAllIds.close();
	}

}
