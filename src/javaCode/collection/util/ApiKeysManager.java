package javaCode.collection.util;

import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Date;
import java.util.concurrent.TimeUnit;

public class ApiKeysManager {

	private static final int MIN_REMAINING_CALLS = 5;

	private static ArrayList<ApiKey> keys;
	private static int currentKeyIndex;

	public static String getKey() {
		return keys.get(currentKeyIndex).getKey();
	}

	public static void setKeys(String[] newKeys, String[] keyNames) {

		if (newKeys.length > 0) {
			keys = new ArrayList<ApiKey>();
			for (int i = 0; i < newKeys.length; i++) {
				keys.add(new ApiKey(newKeys[i], keyNames[i]));
			}
			currentKeyIndex = 0;
		} else {
			throw new RuntimeException("No available API Key!");
		}
	}

	public static void checkApiCallLimit(URLConnection urlConn) {
		if (urlConn != null) {
			// Update the remaining calls
			keys.get(currentKeyIndex).setRemainingCalls(
					Long.valueOf(urlConn
							.getHeaderField("X-Ratelimit-Remaining")));

			if (keys.get(currentKeyIndex).getRemainingCalls() <= MIN_REMAINING_CALLS) {

				keys.get(currentKeyIndex)
						.setResetTime(
								new Date(
										Long.valueOf(urlConn
												.getHeaderField("X-Ratelimit-Reset")) * 1000 + 1));

				System.out.println();
				System.out.println(">>>  API Key "
						+ keys.get(currentKeyIndex).getName()
						+ ": Call Limit Exceeded");

				if (!changeApiKey()) {
					forceChangeApiKey();
					stopExecution();
				}
			}
		}
	}

	private static boolean changeApiKey() {

		int tmpIndex;
		boolean result = false;
		for (int i = 1; i < keys.size(); i++) {
			tmpIndex = (currentKeyIndex + i) % keys.size();

			if (new Date(System.currentTimeMillis()).compareTo(keys.get(
					tmpIndex).getResetTime()) >= 0) {
				currentKeyIndex = tmpIndex;
				result = true;

				System.out.println(">>>  New API Key: "
						+ keys.get(currentKeyIndex).getName());
				System.out.println();

				break;
			}
		}
		return result;
	}

	private static void forceChangeApiKey() {
		currentKeyIndex = (currentKeyIndex + 1) % keys.size();

		System.out.println(">>>  Next API Key: "
				+ keys.get(currentKeyIndex).getName());
		System.out.println();

	}

	private static void stopExecution() {
		long millisToReset = keys.get(currentKeyIndex).getResetTime().getTime();
		long millisToWait = millisToReset - System.currentTimeMillis();

		System.out.println(">>>  Script stopped during: "
				+ String.format(
						"%d min, %d sec",
						TimeUnit.MILLISECONDS.toMinutes(millisToWait),
						TimeUnit.MILLISECONDS.toSeconds(millisToWait)
								- TimeUnit.MINUTES
										.toSeconds(TimeUnit.MILLISECONDS
												.toMinutes(millisToWait))));
		System.out.println(">>>  Script stopped until: "
				+ new Date(millisToReset));
		try {
			Thread.sleep(millisToWait + 1);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		System.out.println(">>>  We're back at: "
				+ new Date(System.currentTimeMillis()));
		System.out.println();

	}

	static class ApiKey {
		private String key;
		private String name;
		private Date resetTime;
		private Long remainingCalls;

		public ApiKey(String key, String name) {
			this.key = key;
			this.name = name;
			this.resetTime = new Date(System.currentTimeMillis() - 1);
			this.remainingCalls = new Long(-1);
		}

		public Date getResetTime() {
			return resetTime;
		}

		public void setResetTime(Date resetTime) {
			this.resetTime = resetTime;
		}

		public Long getRemainingCalls() {
			return remainingCalls;
		}

		public void setRemainingCalls(Long remainingCalls) {
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
					+ getRemainingCalls() + "\nResetTime: " + getResetTime()
					+ "\n";
		}

	}

}
