package javaCode.collection.util;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URLConnection;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.TimeUnit;

public class ApiKeysManager {

	private static final int MIN_REMAINING_CALLS = 5;
	private static final int MAX_REMAINING_CALLS = 200;

	private static final int MIN_CALL_INTERVAL = 400;
	private static final int MAX_CALL_INTERVAL = 4000;
	private static final int CALL_INTERVAL_CHANGE_TIME_IN_MINUTES = 10;
	private static final int CALL_INTERVAL_DECREASE_STEP_IN_MILLIS = 100;
	private static final int CALL_INTERVAL_INCREASE_STEP_IN_MILLIS = 200;

	private static int callIntervalInMillis;
	private static int throttledTimes;

	private static ArrayList<ApiKey> keys;
	private static int currentKeyIndex;

	private static Calendar nextHour;
	private static Calendar lastCallIntervalChange;

	public static void setKeys(String[] newKeys, String[] keyNames) {

		if (newKeys.length > 0) {
			keys = new ArrayList<ApiKey>();
			for (int i = 0; i < newKeys.length; i++) {
				keys.add(new ApiKey(newKeys[i], keyNames[i]));
			}
			currentKeyIndex = -1;

			nextHour = Calendar.getInstance();
			updateNextHour();

			lastCallIntervalChange = Calendar.getInstance();

			callIntervalInMillis = 1500;

			throttledTimes = 0;
		} else {
			throw new RuntimeException("No available API Key!");
		}
	}

	public static String getKey() {
		stopForAWhile();

		checkAndResetCallLimits();

		if (!changeApiKey()) {
			stopExecutionUntilNextHour();
		}

		// And, to finish, decrement the remaining calls of the new key,
		// returning it
		keys.get(currentKeyIndex).decrementCalls();

		return keys.get(currentKeyIndex).getKey();
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

					if (callIntervalInMillis >= MIN_CALL_INTERVAL) {

						callIntervalInMillis -= CALL_INTERVAL_DECREASE_STEP_IN_MILLIS;

						callIntervalInMillis = (callIntervalInMillis < MIN_CALL_INTERVAL) ? MIN_CALL_INTERVAL
								: callIntervalInMillis;

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

	private static void stopForAWhile() {
		try {
			Thread.sleep(callIntervalInMillis);
		} catch (InterruptedException e) {
			System.out
					.println(">>> ATTENTION! The timer was interrupted before the expected time!");
			e.printStackTrace();
		}
	}

	private static void checkAndResetCallLimits() {
		if (new Date(System.currentTimeMillis()).compareTo(nextHour.getTime()) >= 0) {
			for (ApiKey k : keys) {
				k.setRemainingCalls(MAX_REMAINING_CALLS);
			}

			updateNextHour();
		}
	}

	private static boolean changeApiKey() {

		int tmpIndex;
		boolean result = false;
		for (int i = 1; i < keys.size(); i++) {
			tmpIndex = (currentKeyIndex + i) % keys.size();

			if (keys.get(tmpIndex).getRemainingCalls() > MIN_REMAINING_CALLS) {
				currentKeyIndex = tmpIndex;
				result = true;

				System.out.print("            "
						+ keys.get(currentKeyIndex).getName());
				if (currentKeyIndex == 0) {
					Date now = new Date(System.currentTimeMillis());
					SimpleDateFormat f = new SimpleDateFormat(
							"HH:mm:ss 'at' dd.MM.yy");
					System.out.print("("
							+ keys.get(currentKeyIndex).getRemainingCalls()
							+ " calls - " + f.format(now) + ")");
				}
				System.out.print(": ");

				break;
			} else {
				System.out.println(">>>  " + keys.get(tmpIndex).getName()
						+ " key: Call Limit Exceeded");
			}
		}
		return result;
	}

	private static void stopExecutionUntilNextHour() {

		long millisToWait = nextHour.getTimeInMillis()
				- System.currentTimeMillis();

		System.out.println();
		System.out.println(">>>  Script stopped during: "
				+ String.format(
						"%d min, %d sec",
						TimeUnit.MILLISECONDS.toMinutes(millisToWait),
						TimeUnit.MILLISECONDS.toSeconds(millisToWait)
								- TimeUnit.MINUTES
										.toSeconds(TimeUnit.MILLISECONDS
												.toMinutes(millisToWait))));
		System.out.println(">>>  Script stopped until: " + nextHour.getTime());
		try {
			Thread.sleep(millisToWait + 1);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		System.out.println(">>>  We're back at: "
				+ new Date(System.currentTimeMillis()));
		System.out.println();
	}

	private static void updateNextHour() {
		Calendar calendar = Calendar.getInstance();
		calendar.add(Calendar.HOUR, 1);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);
		nextHour = calendar;
	}

	static class ApiKey {
		private String key;
		private String name;
		private int remainingCalls;

		public ApiKey(String key, String name) {
			this.key = key;
			this.name = name;
			this.remainingCalls = 200;
		}

		public void decrementCalls() {
			remainingCalls--;
		}

		public int getRemainingCalls() {
			return remainingCalls;
		}

		public void setRemainingCalls(int remainingCalls) {
			this.remainingCalls = remainingCalls;
		}

		public String getKey() {
			return key;
		}

		public String getName() {
			return name;
		}

		@Override
		public String toString() {
			return "Key Name: " + getName() + "\nRemainingCalls: "
					+ getRemainingCalls();
		}

	}

	// public static void main(String[] args) throws MalformedURLException,
	// IOException {
	// MainCollection.readPropertiesFile();
	//
	// // URLConnection urlConn = new URL(URLManager.getEventsURLByMember(
	// // "4c5f7a107b7624226a67794025897c", new Long(10341972), 0))
	// // .openConnection();
	//
	// URLConnection urlConn = new URL(
	// "https://api.meetup.com/ew/events?key=7f422a3a6e6d253c7e62585b722a6&sign=true&page=20")
	// .openConnection();
	//
	// System.out.println(urlConn.getHeaderFields());
	// System.out.println(((HttpURLConnection) urlConn).getResponseCode());
	//
	// // BufferedReader br = new BufferedReader(new
	// // InputStreamReader(urlConn.getInputStream()));
	// // System.out.println(br.readLine());
	//
	// for (int i = 0; i < 2000; i++) {
	// getKey();
	// System.out.println();
	// if (!checkConnectionCondition(urlConn))
	// continue;
	//
	// System.out.println();
	// }
	// }
}
