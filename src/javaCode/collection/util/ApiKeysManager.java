/*
   ApiKeysManager.java
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

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URLConnection;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

public class ApiKeysManager {

	private static final int MIN_CALL_INTERVAL = 200;
	private static final int MAX_CALL_INTERVAL = 4000;
	private static final int CALL_INTERVAL_CHANGE_TIME_IN_MINUTES = 10;
	private static final int CALL_INTERVAL_DECREASE_STEP_IN_MILLIS = 100;
	private static final int CALL_INTERVAL_INCREASE_STEP_IN_MILLIS = 200;

	private static int callIntervalInMillis;
	private static int throttledTimes;

	private static ArrayList<ApiKey> keys;
	private static int currentKeyIndex;

	// private static Calendar nextHour;
	private static Calendar lastCallIntervalChange;

	public static void setKeys(String[] newKeys, String[] keyNames) {

		if (newKeys.length > 0) {
			keys = new ArrayList<ApiKey>();
			for (int i = 0; i < newKeys.length; i++) {
				keys.add(new ApiKey(newKeys[i], keyNames[i]));
			}
			currentKeyIndex = -1;

			lastCallIntervalChange = Calendar.getInstance();

			callIntervalInMillis = 500;

			throttledTimes = 0;
		} else {
			throw new RuntimeException("No available API Key!");
		}
	}

	public static String getKey() {
		stopForAWhile();
		changeApiKey();

		return keys.get(currentKeyIndex).getKey();
	}

	private static void stopForAWhile() {
		try {
			Thread.sleep(callIntervalInMillis);
		} catch (InterruptedException e) {
			System.out
			.println(">>> ATTENTION! The timer was interrupted before the expected time!");
			e.printStackTrace();
		}
	}

	private static void changeApiKey() {

		currentKeyIndex = (currentKeyIndex + 1) % keys.size();
		System.out.print("            " + keys.get(currentKeyIndex).getName());
		if (currentKeyIndex == 0) {
			Date now = new Date(System.currentTimeMillis());
			SimpleDateFormat f = new SimpleDateFormat("HH:mm:ss 'at' dd.MM.yy");
			System.out.print("(" + f.format(now) + ")");
		}
		System.out.print(": ");
	}

	public static boolean checkConnectionCondition(URLConnection urlConn)
			throws IOException {

		boolean result = true;

		if (urlConn instanceof HttpURLConnection) {
			int responseCode = ((HttpURLConnection) urlConn).getResponseCode();
			if (responseCode != 200) {

				System.out.println();
				System.out
				.println(">>> ATTENTION! HTTP URL Connection error code: "
						+ responseCode);

				if (responseCode == 400 || responseCode == 429) {
					// Increment the throttled counter
					throttledTimes++;

					System.out
					.println(">>> We should have been throttled! Throttling counter = "
							+ throttledTimes);

					if (callIntervalInMillis <= MAX_CALL_INTERVAL) {

						callIntervalInMillis += CALL_INTERVAL_INCREASE_STEP_IN_MILLIS
								* throttledTimes;

						callIntervalInMillis = (callIntervalInMillis > MAX_CALL_INTERVAL) ? MAX_CALL_INTERVAL
								: callIntervalInMillis;

						System.out
						.println(">>> The new interval between calls is "
								+ callIntervalInMillis + " ms");
					}
				}

				System.out.println();

				// Update the while change variable
				lastCallIntervalChange = Calendar.getInstance();

				result = false;
			} else {
				Calendar c = Calendar.getInstance();
				long diffMillis = c.getTimeInMillis()
						- lastCallIntervalChange.getTimeInMillis();

				if (diffMillis >= CALL_INTERVAL_CHANGE_TIME_IN_MINUTES
						* (60 * 1000)) {

					if (callIntervalInMillis > MIN_CALL_INTERVAL) {

						callIntervalInMillis -= CALL_INTERVAL_DECREASE_STEP_IN_MILLIS;

						callIntervalInMillis = (callIntervalInMillis < MIN_CALL_INTERVAL) ? MIN_CALL_INTERVAL
								: callIntervalInMillis;

						System.out.println();
						System.out.println();
						System.out.println(">>> Nice! No throttling in "
								+ CALL_INTERVAL_CHANGE_TIME_IN_MINUTES
								+ " minutes.");
						System.out
						.println(">>> The new interval between calls is "
								+ callIntervalInMillis + " ms");
						System.out.println();
					}

					// Update the while change variable
					lastCallIntervalChange = c;
				}
			}
		}
		return result;
	}

	static class ApiKey {
		private String key;
		private String name;

		public ApiKey(String key, String name) {
			this.key = key;
			this.name = name;
		}

		public String getKey() {
			return key;
		}

		public String getName() {
			return name;
		}

		@Override
		public String toString() {
			return "Key Name: " + getName();
		}

	}

//	public static void main(String[] args) throws MalformedURLException,
//	IOException {
//		MainCollection.readPropertiesFile();
//
//		URLConnection urlConn = new URL(URLManager.getEventsURLByMember(
//				"4c5f7a107b7624226a67794025897c", new Long(10341972), 0))
//		.openConnection();
//
//		// URLConnection urlConn = new URL(
//		// "https://api.meetup.com/ew/events?key=7f422a3a6e6d253c7e62585b722a6&sign=true&page=20")
//		// .openConnection();
//
//		System.out.println(urlConn.getHeaderFields());
//		System.out.println(((HttpURLConnection) urlConn).getResponseCode());
//
//		// BufferedReader br = new BufferedReader(new
//		// InputStreamReader(urlConn.getInputStream()));
//		// System.out.println(br.readLine());
//
//		for (int i = 0; i < 2000; i++) {
//			getKey();
//			System.out.println();
//			if (!checkConnectionCondition(urlConn))
//				continue;
//
//			System.out.println();
//		}
//	}
}
