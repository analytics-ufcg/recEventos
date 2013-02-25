package javaCode.collection.util;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;

public class TraceManager {

	private final static String TRACE_FILENAME = "data/trace.txt";
	private final static String VAR_SEPARATOR = ",";
	private final static String ASSIGNMENT_SEPARATOR = "=";

	/*
	 * METHOD INDEX to be used by the Tracer
	 */
	public static final int FINDGROUPS_INDEX = 0, MEMBERS_BYGROUP_INDEX = 1,
			EVENTS_BYGROUP_INDEX = 2, GROUPTOPICS_BYGROUP_INDEX = 3,
			RSVPS_BYEVENT_INDEX = 4;

	/*
	 * TRACE file variables
	 */
	private static int cityIndex;
	private static int methodIndex;
	private static int groupIndex;
	private static int memberIndex;
	private static int eventIndex;
	private static int offset;

	public static void readTraceFile() {
		try {
			Scanner sc = new Scanner(new File(TRACE_FILENAME));

			String[] vars = sc.nextLine().split(VAR_SEPARATOR);
			sc.close();

			cityIndex = Integer
					.parseInt(vars[0].split(ASSIGNMENT_SEPARATOR)[1]);
			methodIndex = Integer
					.parseInt(vars[1].split(ASSIGNMENT_SEPARATOR)[1]);
			groupIndex = Integer
					.parseInt(vars[2].split(ASSIGNMENT_SEPARATOR)[1]);
			memberIndex = Integer
					.parseInt(vars[3].split(ASSIGNMENT_SEPARATOR)[1]);
			eventIndex = Integer
					.parseInt(vars[4].split(ASSIGNMENT_SEPARATOR)[1]);
			offset = Integer.parseInt(vars[5].split(ASSIGNMENT_SEPARATOR)[1]);

		} catch (FileNotFoundException e) {
			cityIndex = 0;
			methodIndex = 0;
			groupIndex = 0;
			memberIndex = 0;
			eventIndex = 0;
			offset = 0;
		}
	}

	public static void writeTraceFile(int cityIndex, int methodIndex,
			int groupIndex, int memberIndex, int eventIndex, int offset)
			throws IOException {
		FileWriter fw = new FileWriter(new File(TRACE_FILENAME));
		fw.write("CITY_INDEX=" + cityIndex + ",METHOD_INDEX=" + methodIndex
				+ ",GROUP_INDEX=" + groupIndex + ",MEMBER_INDEX=" + memberIndex
				+ ",EVENT_INDEX=" + eventIndex + ",OFFSET=" + offset);
		fw.close();
	}

	public static void resetTraceData(int cityIndex, int methodIndex,
			int groupIndex, int memberIndex, int eventIndex, int offset)
			throws IOException {
		writeTraceFile(cityIndex, methodIndex, groupIndex, memberIndex,
				eventIndex, offset);
		readTraceFile();
	}

	public static int getCityIndex() {
		return cityIndex;
	}

	public static int getMethodIndex() {
		return methodIndex;
	}

	public static int getGroupIndex() {
		return groupIndex;
	}

	public static int getMemberIndex() {
		return memberIndex;
	}

	public static int getOffset() {
		return offset;
	}

	public static int getEventIndex() {
		return eventIndex;
	}

	public static void setEventIndex(int eventIndex) {
		TraceManager.eventIndex = eventIndex;
	}
}
