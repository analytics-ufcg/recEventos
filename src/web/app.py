from flask import Flask, render_template
import os, json, string, time, csv


DEBUG = True
SECRET_KEY = 'dev_key'

app = Flask(__name__)
app.config.from_object(__name__)

def read_venues_and_members(city):

	venues = []
	with open(os.path.join(os.path.join(os.path.join("src", "web"), city), "venues.csv"), 'r') as source:
		csv_reader = csv.reader(source)
		csv_reader.next()
		for venue in csv_reader:
			#venue[0] - id; venue[1] - lat; venue[2] - lon; venue[3] - name; venue[4] - city
			venues.append( { 'id' : venue[0].strip(), 'name' : filter(lambda x: x in string.printable, venue[3]).strip().encode('utf8'), 'lon' : venue[2].strip(), 'lat' : venue[1].strip(), 'city' : filter(lambda x: x in string.printable, venue[4]).strip().encode('utf8') } )

	print "Loaded "+str(len(venues))+" venues from ", city

	users = []
	with open(os.path.join(os.path.join(os.path.join("src", "web"), city), "members.csv"), 'r') as source:
		csv_reader = csv.reader(source)
		csv_reader.next()
		for user in csv_reader:
			#user[0] - id; user[3] - name; user[2] - longitude; user[1] - latitude
			users.append( { 'id' : user[0].strip(), 'name' : filter(lambda x: x in string.printable, user[3]).strip().encode('utf8'), 'lon' : user[2].strip(), 'lat' : user[1].strip() } )
	print "Loaded "+str(len(users))+" users from ", city

	return ( venues, users )

def read_events():

	events = {}
	with open(os.path.join(os.path.join("src", "web"), "events.csv"), 'r') as source:
		csv_reader = csv.reader(source)
		csv_reader.next()
		for event in csv_reader:
			#event[0] - id; event[1] - name; event[2] - venue_id; event[3] - time
			eid = event[0].strip()
			events[eid] = { 'id' : eid, 'name' : filter(lambda x: x in string.printable, event[1]).strip().encode('utf8'), 'venue_id' : event[2].strip(), 'time' : time.asctime(time.localtime(float(event[3].strip())/1000)).encode('utf8') }
	return events

@app.route('/')
def index():

	r = read_venues_and_members("san_diego")
	venues = r[0]
	users = r[1]

	events = read_events()

	return render_template("index.html", venues=venues, users=users, events=events)

@app.route('/load_city/<city>')
def load_city(city=None):

	r = read_venues_and_members(city)
	venues = r[0]
	users = r[1]
	
	return json.dumps({ 'venues' : venues, 'users' : users })

@app.route('/venue_events/<venue_ids>', methods=['GET'])
@app.route('/venue_events/<venue_ids>/user_id/<user_id>', methods=['GET'])
@app.route('/venue_events/<venue_ids>/user_id/<user_id>/<events_user_have>', methods=['GET'])
def venue_events(venue_ids=None, user_id=None, events_user_have=None):
	venue_ids = venue_ids.split("&")
	venues_events = {}

	if ( events_user_have != None ):
		events_user_have = events_user_have.split("&")

	with open(os.path.join(os.path.join("src", "web"), "events.csv"), 'r') as source:
		csv_reader = csv.reader(source)
		csv_reader.next()
		for event in csv_reader:

			#event[0] - id; event[1] - name; event[2] - venue_id; event[3] - time
			venue = event[2].strip()
			event_info = { 'id' : event[0].strip(), 'name' : filter(lambda x: x in string.printable, event[1]).strip().encode('utf8'), 'time' : time.asctime(time.localtime(float(event[3].strip())/1000)).encode('utf8') }
			if ( venue in venue_ids ):
				if not venue in venues_events:
					venues_events[venue] = []
				#if user_id is specified, see if user has this event and then add it to found events, otherwise just add it to found events
				if user_id == None:
					venues_events[venue].append(event_info)
				else:
					if ( event_info["id"] in events_user_have ):
						venues_events[venue].append(event_info)
	return render_template("venue_events.html", venue_ids=venue_ids, venues_events=venues_events)

if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
	app.run(host='0.0.0.0', port=port, debug=True)
