from flask import Flask, render_template
import os, json


DEBUG = True
SECRET_KEY = 'dev_key'

app = Flask(__name__)
app.config.from_object(__name__)

@app.route('/')
def index():

	f = None
	try:
		f = open(os.path.join(os.path.join("src", "web"), "venues.csv"), 'r')
	except IOError:
		render_template("index.html", venues=[])

	venues = []
	try:
		first = True
		for venue in f.readlines():
			if first:
				first = False
				continue
			venue = venue.replace("\"", "")
			venue = venue.split(",")


			#venue[0] - id; venue[1] - longitude; venue[2] - latitude
			if venue[1].strip() == "" or venue[2].strip() == "":
				continue
			if venue[1].isspace() or venue[2].isspace():
				continue
			elif venue[1].isalpha() or venue[2].isalpha():
				continue
			venues.append( { 'id' : venue[0], 'lon' : venue[1], 'lat' : venue[2] } )
	except:
		print "Error parsing CSV occured"
	finally:
		f.close()
	return render_template("index.html", venues=venues)

@app.route('/venue_events/<venue_ids>', methods=['GET'])
def venue_events(venue_ids=None):
	venue_ids = venue_ids.split("&")
	return render_template("venue_events.html", venue_ids=venue_ids)

if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
	app.run(host='0.0.0.0', port=port)

