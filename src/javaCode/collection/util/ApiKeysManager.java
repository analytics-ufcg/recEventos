package javaCode.collection.util;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.TimeUnit;

public class ApiKeysManager {

	private static final int MIN_REMAINING_CALLS = 5;
	private static final int REQUEST_INTERTIME_IN_MILLIS = 1000;

	private static Calendar nextHour;
	private static ArrayList<ApiKey> keys;
	private static int currentKeyIndex;

	public static String getKey() {
		stopForAWhile();
		updateApiKey();
		return keys.get(currentKeyIndex).getKey();
	}

	private static void stopForAWhile() {
		try {
			System.out.print("            (Waiting... ");
			Thread.sleep(REQUEST_INTERTIME_IN_MILLIS);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}		
	}

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

	private static void updateApiKey() {
		resetCallLimits();
		if (!changeApiKey()) {
			stopExecutionUntilNextHour();
		}

		// And to finish decrement the remaining calls of the current key
		keys.get(currentKeyIndex).decrementCalls();
	}

	private static void resetCallLimits() {
		if (new Date(System.currentTimeMillis()).compareTo(nextHour.getTime()) >= 0) {
			for (ApiKey k : keys) {
				k.setRemainingCalls(200);
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

				System.out.println(" Key: "
						+ keys.get(currentKeyIndex).getName() + ")");

				break;
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

	// private static boolean changeApiKey() {
	//
	// int tmpIndex;
	// boolean result = false;
	// for (int i = 1; i < keys.size(); i++) {
	// tmpIndex = (currentKeyIndex + i) % keys.size();
	//
	// if (new Date(System.currentTimeMillis()).compareTo(keys.get(
	// tmpIndex).getResetTime()) >= 0) {
	// currentKeyIndex = tmpIndex;
	// result = true;
	//
	// System.out.println(">>>  New API Key: "
	// + keys.get(currentKeyIndex).getName());
	// System.out.println();
	//
	// break;
	// }
	// }
	// return result;
	// }
	//
	// private static void forceChangeApiKey() {
	// currentKeyIndex = (currentKeyIndex + 1) % keys.size();
	//
	// System.out.println(">>>  Next API Key: "
	// + keys.get(currentKeyIndex).getName());
	// System.out.println();
	//
	// }
	//
	// private static void stopExecution() {
	// long millisToReset = keys.get(currentKeyIndex).getResetTime().getTime();
	// long millisToWait = millisToReset - System.currentTimeMillis();
	//
	// System.out.println(">>>  Script stopped during: "
	// + String.format(
	// "%d min, %d sec",
	// TimeUnit.MILLISECONDS.toMinutes(millisToWait),
	// TimeUnit.MILLISECONDS.toSeconds(millisToWait)
	// - TimeUnit.MINUTES
	// .toSeconds(TimeUnit.MILLISECONDS
	// .toMinutes(millisToWait))));
	// System.out.println(">>>  Script stopped until: "
	// + new Date(millisToReset));
	// try {
	// Thread.sleep(millisToWait + 1);
	// } catch (InterruptedException e) {
	// e.printStackTrace();
	// }
	// System.out.println(">>>  We're back at: "
	// + new Date(System.currentTimeMillis()));
	// System.out.println();
	//
	// }

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
					+ getRemainingCalls() + "\n";
		}

	}

//	public static void main(String[] args) throws MalformedURLException,
//			IOException {
//		// Set the API_KEY and CITIES from the properties.txt file
//		MainCollection.readPropertiesFile();
//
//		URLConnection urlConn = new URL(URLManager.getMembersURLByGroup(
//				ApiKeysManager.getKey(), new Long(6922872), 0))
//				.openConnection();
//
//		System.out.println(urlConn.getHeaderFields());
//
//		System.out.println("REMAINING: "
//				+ urlConn.getHeaderField("X-Ratelimit-Remaining"));
//		System.out.println("RESET: "
//				+ urlConn.getHeaderField("X-Ratelimit-Reset"));
//		System.out.println();
//
//	}

}
