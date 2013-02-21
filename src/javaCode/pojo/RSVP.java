package javaCode.pojo;

public class RSVP {

	private long rsvp_id;
	private long created;
	private long mtime;
	private RSVPMember member;
	private String response;
	private RSVPEvent event;

	public long getRsvp_id() {
		return rsvp_id;
	}

	public void setRsvp_id(long rsvp_id) {
		this.rsvp_id = rsvp_id;
	}

	public long getCreated() {
		return created;
	}

	public void setCreated(long created) {
		this.created = created;
	}

	public long getMtime() {
		return mtime;
	}

	public void setMtime(long mtime) {
		this.mtime = mtime;
	}

	public RSVPMember getMember() {
		return member;
	}

	public void setMember(RSVPMember member) {
		this.member = member;
	}

	public String getResponse() {
		return response;
	}

	public void setResponse(String response) {
		this.response = response;
	}

	public RSVPEvent getEvent() {
		return event;
	}

	public void setEvent(RSVPEvent event) {
		this.event = event;
	}

}
