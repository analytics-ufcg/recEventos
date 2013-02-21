package javaCode.pojo;

public class Event {

	private String id;
	private long rsvp_limit;
	private long maybe_rsvp_count;
	private long yes_rsvp_count;
	private String visibility;
	private String status;
	private long utc_offset;
	private long time;
	private long waitlist_count;
	private long created;
	private String name;
	private long headcount;
	private EventGroup group;
	private Venue venue;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public long getRsvp_limit() {
		return rsvp_limit;
	}

	public void setRsvp_limit(long rsvp_limit) {
		this.rsvp_limit = rsvp_limit;
	}

	public long getMaybe_rsvp_count() {
		return maybe_rsvp_count;
	}

	public void setMaybe_rsvp_count(long maybe_rsvp_count) {
		this.maybe_rsvp_count = maybe_rsvp_count;
	}

	public long getYes_rsvp_count() {
		return yes_rsvp_count;
	}

	public void setYes_rsvp_count(long yes_rsvp_count) {
		this.yes_rsvp_count = yes_rsvp_count;
	}

	public String getVisibility() {
		return visibility;
	}

	public void setVisibility(String visibility) {
		this.visibility = visibility;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public long getUtc_offset() {
		return utc_offset;
	}

	public void setUtc_offset(long utc_offset) {
		this.utc_offset = utc_offset;
	}

	public long getTime() {
		return time;
	}

	public void setTime(long time) {
		this.time = time;
	}

	public long getWaitlist_count() {
		return waitlist_count;
	}

	public void setWaitlist_count(long waitlist_count) {
		this.waitlist_count = waitlist_count;
	}

	public long getCreated() {
		return created;
	}

	public void setCreated(long created) {
		this.created = created;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public long getHeadcount() {
		return headcount;
	}

	public void setHeadcount(long headcount) {
		this.headcount = headcount;
	}

	public Venue getVenue() {
		return venue;
	}

	public void setVenue(Venue venue) {
		this.venue = venue;
	}

	public EventGroup getGroup() {
		return group;
	}

	public void setGroup(EventGroup group) {
		this.group = group;
	}
}

