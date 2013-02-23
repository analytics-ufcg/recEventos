package javaCode.collection.util;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.TimeUnit;

public class ApiKeysManager {

	private static final int WHILE_IN_MILLIS = 1500;
	private static final int MIN_REMAINING_CALLS = 5;
	private static final int MAX_REMAINING_CALLS = 200;

	private static Calendar nextHour;
	private static ArrayList<ApiKey> keys;
	private static int currentKeyIndex;

	public static void setKeys(String[] newKeys, String[] keyNames) {

		if (newKeys.length > 0) {
			keys = new ArrayList<ApiKey>();
			for (int i = 0; i < newKeys.length; i++) {
				keys.add(new ApiKey(newKeys[i], keyNames[i]));
			}
			currentKeyIndex = -1;
			nextHour = Calendar.getInstance();
			updateNextHour();
		} else {
			throw new RuntimeException("No available API Key!");
		}
	}

	public static String getKey() {
		stopForAWhile();

		resetCallLimits();

		if (!changeApiKey()) {
			stopExecutionUntilNextHour();
		}

		// And, to finish, decrement the remaining calls of the current key
		keys.get(currentKeyIndex).decrementCalls();

		return keys.get(currentKeyIndex).getKey();
	}

	private static void stopForAWhile() {
		try {
			Thread.sleep(WHILE_IN_MILLIS);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	private static void resetCallLimits() {
		if (new Date(System.currentTimeMillis()).compareTo(nextHour.getTime()) >= 0) {
			for (ApiKey k : keys) {
				k.setRemainingCalls(MAX_REMAINING_CALLS);
			}
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
						+ keys.get(currentKeyIndex).getName() + ": ");
				break;
			} else {
				System.out.println(">>>  API Key "
						+ keys.get(currentKeyIndex).getName()
						+ ": Call Limit Exceeded");
			}

			if ((keys.get(tmpIndex).getRemainingCalls() - MIN_REMAINING_CALLS) % 50 == 0) {
				System.out.println(">>>  "
						+ keys.get(currentKeyIndex).getName() + " reached "
						+ keys.get(tmpIndex).getRemainingCalls()
						+ " remaining calls!");
			}
		}
		return result;
	}

	private static void stopExecutionUntilNextHour() {

		long millisToWait = nextHour.getTimeInMillis()
				- System.currentTimeMillis();

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

}
