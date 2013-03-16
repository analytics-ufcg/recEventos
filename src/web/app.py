from flask import Flask, render_template
import os, json, string


DEBUG = True
SECRET_KEY = 'dev_key'

app = Flask(__name__)
app.config.from_object(__name__)

@app.route('/')
def index():

	f = None
	venues = []
	try:
		f = open(os.path.join("data_output", "venues.csv"), 'r')
		first = True
		for venue in f.readlines():
			if first:
				first = False
				continue
			venue = venue.replace("\"", "")
			venue = venue.split(",")


			#venue[0] - id; venue[1] - lat; venue[2] - lon; venue[3] - name; venue[4] - city
			venues.append( { 'id' : venue[0], 'name' : filter(lambda x: x in string.printable, venue[3]), 'lon' : venue[2], 'lat' : venue[1], 'city' : venue[4] } )			
	except:
		print "Error parsing venues CSV occured"
	finally:
		f.close()

	users = []
	try:
		f = open(os.path.join("data_output", "members.csv"), 'r')
		i += 1
			
		first = True
		for user in f.readlines():
			if first:
				first = False
				continue
			user = user.replace("\"", "")
			user = user.split(",")

			#user[0] - id; user[3] - name; user[2] - longitude; user[1] - latitude
			users.append( { 'id' : user[0], 'name' : filter(lambda x: x in string.printable, user[3]), 'lon' : user[2], 'lat' : user[1] } )
	except IOError:
		pass
	finally:
		f.close()

	return render_template("index.html", venues=venues, users=users)

@app.route('/venue_events/<venue_ids>', methods=['GET'])
@app.route('/venue_events/<venue_ids>/user_id/<user_id>', methods=['GET'])
@app.route('/venue_events/<venue_ids>/user_id/<user_id>/<events_user_have>', methods=['GET'])
def venue_events(venue_ids=None, user_id=None, events_user_have=None):
	venue_ids = venue_ids.split("&")
	venues_events = {}

	if ( events_user_have != None ):
		events_user_have = events_user_have.split("&")

	f = None
	try:
		f = open(os.path.join("data_output", "events.csv"), 'r')

		first = True
		for event in f.readlines():
			if first:
				first = False
				continue
			event = event.replace("\"", "")
			event = event.split(",")

			#event[0] - id; event[1] - name; event[2] - venue_id; event[3] - time
			venue = event[2]
			event_info = { 'id' : event[0], 'name' : event[1], 'time' : event[3] }
			if ( venue in venue_ids ):
				if not venue in venues_events:
					venues_events[venue] = []
				#if user_id is specified, see if user has this event and then add it to found events, otherwise just add it to found events
				if user_id == None:
					venues_events[venue].append(event_info)
				else:
					if ( event_info["id"] in events_user_have ):
						venues_events[venue].append(event_info)
	except IOError:
		pass
	finally:
		f.close()
	return render_template("venue_events.html", venue_ids=venue_ids, venues_events=venues_events)

@app.route("/user_events/<user_id>", methods=["GET"])
def user_events(user_id=None):

	user_events = []
	f = None
	try:
		f = open(os.path.join("data_output", "member_events.csv"), 'r')

		first = True
		for user_event in f.readlines():
			if first:
				first = False
				continue
			user_event = user_event.replace("\"", "")
			user_event = user_event.split(",")

			user = user_event[0]
			event = user_event[1]

			if user == user_id:

				#query event info
				event_info = None
				f2 = None
				try:
					f2 = open(os.path.join("data_output", "events.csv"), 'r')
	
					first = True
					for event_entry in f2.readlines():
						if first:
							first = False
							continue
						event_entry = event_entry.replace("\"", "")
						event_entry = event_entry.split(",")

						#event_entry[0] - id; event_entry[1] - name;
	
						if ( event_entry[0] == event ):
							event_info = { 'id' : event, 'name' : event_entry[1], 'venue_id' : event_entry[2], 'time' : event_entry[3] }
							break
				except IOError:
					pass
				finally:
					f2.close()

				if event_info == None:
					continue

				#query event venue info (lat, lon)

				try:
					f2 = open(os.path.join("data_output", "venues.csv"), 'r')

					first = True
					for venue in f2.readlines():
						if first:
							first = False
							continue
						venue = venue.replace("\"", "")
						venue = venue.split(",")

						#venue[0] - id; venue[1] - longitude; venue[2] - latitude; venue[3] - name

						if ( venue[0] == event_info["venue_id"] ):
							event_info['lat'] = venue[2]
							event_info['lon'] = venue[1]
							event_info['venue_name'] = venue[3]
							break
				except IOError:
					continue
				finally:
					f2.close()

				user_events.append(event_info)
	except IOError:
		pass
	finally:
		f.close()

	return json.dumps(user_events)

if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
	app.run(host='0.0.0.0', port=port, debug=False)
	

