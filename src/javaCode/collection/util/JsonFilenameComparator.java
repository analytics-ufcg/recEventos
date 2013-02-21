package javaCode.collection.util;

import java.io.File;
import java.util.Comparator;

public class JsonFilenameComparator implements Comparator<File> {

	@Override
	public int compare(File f0, File f1) {
		return (Integer
				.parseInt(f0.getName().replace(".json", "").split("_")[1]) - Integer
				.parseInt(f1.getName().replace(".json", "").split("_")[1]));
	}

}