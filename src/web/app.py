from flask import Flask, render_template
import os, json, string, time, csv


DEBUG = True
SECRET_KEY = 'dev_key'

app = Flask(__name__)
app.config.from_object(__name__)

def read_venues_and_members(city):

	venues = []
	with open(os.path.join("src", "web", "files", city, "venues.csv"), 'r') as source:
		csv_reader = csv.reader(source)
		csv_reader.next()
		for venue in csv_reader:
			#venue[0] - id; venue[1] - lat; venue[2] - lon; venue[3] - name; venue[4] - city
			venue_info = { 'id' : venue[0].strip(), 'name' : filter(lambda x: x in string.printable, venue[3]).strip().encode('utf8').replace("\\", ""), 'lon' : venue[2].strip(), 'lat' : venue[1].strip(), 'city' : filter(lambda x: x in string.printable, venue[4]).strip().encode('utf8').replace("\\", "") }
			
			venue_info["events"] = venue[5]
			venues.append( venue_info  )

	print "Loaded "+str(len(venues))+" venues from ", city

	users = []
	with open(os.path.join("src", "web", "files", city, "members.csv"), 'r') as source:
		csv_reader = csv.reader(source)
		csv_reader.next()
		for user in csv_reader:
			#user[0] - id; user[3] - name; user[2] - longitude; user[1] - latitude
			user_info = { 'id' : user[0].strip(), 'name' : filter(lambda x: x in string.printable, user[3]).strip().encode('utf8').replace("\\", ""), 'lon' : user[2].strip(), 'lat' : user[1].strip(), 'city' : filter(lambda x: x in string.printable, user[4]).strip().encode('utf8').replace("\\", "")  }

			user_info["events"] = user[5]
			users.append( user_info )
			
	print "Loaded "+str(len(users))+" users from ", city

	return ( venues, users )

def read_events():

	events = []
	with open(os.path.join("src", "web", "files", "events.csv"), 'r') as source:
		csv_reader = csv.reader(source)
		csv_reader.next()
		for event in csv_reader:
			#event[0] - event_id; event[1] - event_name; event[2] - event_time; event[3] - venue_id
			eid = event[0].strip()
			events.append({ 'id' : eid, 'name' : filter(lambda x: x in string.printable, event[1]).strip().encode('utf8').replace("\\", ""), 'venue_id' : event[3].strip(), 'time' : time.asctime(time.localtime(float(event[3].strip())/1000)).encode('utf8') })
	return events

@app.route('/')
def index():

	r = read_venues_and_members("Menlo Park")
	venues = r[0]
	users = r[1]

	events = read_events()

	cities = [ "Addison",
		"Union City",
		"Sunnyvale",
		"Stanford",
		"Saratoga",
		"Santa Cruz",
		"Santa Clara",
		"San Ramon",
		"San Mateo",
		"San Jose",
		"San Francisco",
		"San Diego",
		"San Bruno",
		"Redwood City",
		"Palo Alto",
		"Mountain View",
		"Morgan Hill",
		"Milpitas",
		"Menlo Park",
		"Los Gatos",
		"Los Angeles",
		"Los Altos",
		"Livermore",
		"Fremont",
		"Cupertino",
		"Castro Valley",
		"Campbell",
		"Boulder Creek",
		"Boston" ]


	return render_template("index.html", venues=venues, users=users, events=events, cities=cities)

@app.route('/load_city/<city>')
def load_city(city=None):

	r = read_venues_and_members(city.replace("_", " "))
	venues = r[0]
	users = r[1]
	
	return json.dumps({ 'venues' : venues, 'users' : users })

if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
	app.run(host='0.0.0.0', port=port, debug=True)
