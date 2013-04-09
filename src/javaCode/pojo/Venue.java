/*
   Venue.java
   Copyright (C) 2013  Elias Paulino

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

package javaCode.pojo;

public class Venue {

	private long id;
	private double lon;
	private double lat;
	private String name;
	private String address_1;
	private String address_2;
	private String address_3;
	private String city;
	private String country;	
	private long rating_count;
	private long rating;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public double getLon() {
		return lon;
	}

	public void setLon(double lon) {
		this.lon = lon;
	}

	public double getLat() {
		return lat;
	}

	public void setLat(double lat) {
		this.lat = lat;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getAddress_1() {
		return address_1;
	}

	public void setAddress_1(String address_1) {
		this.address_1 = address_1;
	}

	public String getAddress_2() {
		return address_2;
	}

	public void setAddress_2(String address_2) {
		this.address_2 = address_2;
	}

	public String getAddress_3() {
		return address_3;
	}

	public void setAddress_3(String address_3) {
		this.address_3 = address_3;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public long getRating_count() {
		return rating_count;
	}

	public void setRating_count(long rating_count) {
		this.rating_count = rating_count;
	}

	public long getRating() {
		return rating;
	}

	public void setRating(long rating) {
		this.rating = rating;
	}
	
	
}
