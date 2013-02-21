package javaCode.collection.util;

import java.io.File;
import java.io.FilenameFilter;

public class JsonFilenameFilter implements FilenameFilter {

	private String objectType;

	public JsonFilenameFilter(String objectType) {
		this.objectType = objectType;
	}

	@Override
	public boolean accept(File dir, String name) {
		return name.startsWith(objectType + "s_") && name.endsWith(".json");
	}
}