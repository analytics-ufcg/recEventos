from flask import Flask, render_template
import os, json, string


DEBUG = True
SECRET_KEY = 'dev_key'

app = Flask(__name__)
app.config.from_object(__name__)

@app.route('/')
def index():

	f = None
	try:
		f = open(os.path.join("data_output", "venues.csv"), 'r')
	except IOError:
		render_template("index.html", venues=[], users=[])

	venues = []
	try:
		first = True
		for venue in f.readlines():
			if first:
				first = False
				continue
			venue = venue.replace("\"", "")
			venue = venue.split(",")


			#venue[0] - id; venue[1] - longitude; venue[2] - latitude; venue[3] - name
			if venue[1].strip() == "" or venue[2].strip() == "":
				continue
			if venue[1].isspace() or venue[2].isspace():
				continue
			elif venue[1].isalpha() or venue[2].isalpha():
				continue
			venues.append( { 'id' : venue[0], 'name' : filter(lambda x: x in string.printable, venue[3]), 'lon' : venue[1], 'lat' : venue[2] } )			
	except:
		print "Error parsing venues CSV occured"
	finally:
		f.close()

	users = []
	try:
		i = 1
		while True:
			f = open(os.path.join("data_output", "members_"+str(i)+".csv"), 'r')
			i += 1
			
			first = True
			for user in f.readlines():
				if first:
					first = False
					continue
				user = user.replace("\"", "")
				user = user.split(",")


				#user[0] - id; user[1] - name; user[4] - longitude; user[5] - latitude
				if user[4].strip() == "" or user[5].strip() == "":
					continue
				if user[4].isspace() or user[5].isspace():
					continue
				elif user[4].isalpha() or user[5].isalpha():
					continue
				users.append( { 'id' : user[0], 'name' : filter(lambda x: x in string.printable, user[1]), 'lon' : user[4], 'lat' : user[5] } )
	except IOError:
		pass
	finally:
		f.close()

	print "user: ", len(users), " users loaded"
	return render_template("index.html", venues=venues, users=users)

@app.route('/venue_events/<venue_ids>', methods=['GET'])
@app.route('/venue_events/<venue_ids>/user_id/<user_id>', methods=['GET'])
def venue_events(venue_ids=None, user_id=None):
	venue_ids = venue_ids.split("&")

	venues_events = {}


	f = None
	try:
		f = open(os.path.join("data_output", "venue_events.csv"), 'r')

		first = True
		for venue_event in f.readlines():
			if first:
				first = False
				continue

			venue_event = venue_event.replace("\"", "")
			venue_event = venue_event.split(",")

			venue = venue_event[1]
			event = venue_event[2]

			if venue in venue_ids:

				#query event info
				event_info = None
				j = 1
				found = False
				f2 = None
				try:
					while not found:
						f2 = open(os.path.join("data_output", "events_"+str(j)+".csv"), 'r')
						j += 1

						first = True
						for event_entry in f2.readlines():
							if first:
								first = False
								continue
							event_entry = event_entry.replace("\"", "")
							event_entry = event_entry.split(",")

							#event_entry[0] - id; event_entry[1] - name;

							if ( event_entry[0] == event ):
								event_info = { 'id' : event, 'name' : event_entry[1] }
								found = True
								break
				except IOError:
					pass
				finally:
					f2.close()

				if event_info == None:
					event_info = { 'id' : event, 'name' : 'not_found' }

				#if user_id is specified, see if user has this event

				if user_id != None:

					ok = False
					i = 1
					while True:
						f = open(os.path.join("data_output", "member_events_"+str(i)+".csv"), 'r')
						i += 1

						first = True
						for user_event in f.readlines():
							if first:
								first = False
								continue
							user_event = user_event.replace("\"", "")
							user_event = user_event.split(",")

							user = user_event[0]
							event = user_event[1]

							if user == user_id and event == event_info["id"]:
								ok = True
								break

					if not ok:
						continue


				if not venue in venues_events:
					venues_events[venue] = []
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
		i = 1
		while True:
			f = open(os.path.join("data_output", "member_events_"+str(i)+".csv"), 'r')
			i += 1

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
					j = 1
					found = False
					f2 = None
					try:
						while not found:
							f2 = open(os.path.join("data_output", "events_"+str(j)+".csv"), 'r')
							j += 1
	
							first = True
							for event_entry in f2.readlines():
								if first:
									first = False
									continue
								event_entry = event_entry.replace("\"", "")
								event_entry = event_entry.split(",")

								#event_entry[0] - id; event_entry[1] - name;
	
								if ( event_entry[0] == event ):
									event_info = { 'id' : event, 'name' : event_entry[1] }
									found = True
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

							event_info['lat'] = venue[2]
							event_info['lon'] = venue[1]
							event_info['venue_id'] = venue[0]
							event_info['venue_name'] = venue[3]
							break
					except IOError:
						continue
					finally:
						f2.close()

					user_events.append(event_info)
			f.close()
	except IOError:
		pass

	return json.dumps(user_events)

if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
	app.run(host='0.0.0.0', port=port, debug=False)
	

