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
		for i in range(1,6):
			f = open(os.path.join("data_output", "members_"+str(i)+".csv"), 'r')
			
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

	return render_template("index.html", venues=venues, users=users)

@app.route('/venue_events/<venue_ids>', methods=['GET'])
def venue_events(venue_ids=None):
	venue_ids = venue_ids.split("&")
	return render_template("venue_events.html", venue_ids=venue_ids)

if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
	app.run(host='0.0.0.0', port=port)

