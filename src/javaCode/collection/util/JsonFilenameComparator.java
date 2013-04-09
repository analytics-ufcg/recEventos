/*
   JsonFilenameComparator.java
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
import java.util.Comparator;

public class JsonFilenameComparator implements Comparator<File> {

	@Override
	public int compare(File f0, File f1) {
		return (Integer
				.parseInt(f0.getName().replace(".json", "").split("_")[1]) - Integer
				.parseInt(f1.getName().replace(".json", "").split("_")[1]));
	}

}