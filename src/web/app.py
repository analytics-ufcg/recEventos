from flask import Flask, render_template
import os, json


DEBUG = True
SECRET_KEY = 'dev_key'

app = Flask(__name__)
app.config.from_object(__name__)

@app.route('/')
def index():

	f = open('venues.csv', 'r')
	events = []
	try:
		for event in f.readlines():
			event = event.replace("\"", "")
			event = event.split(",")
			events.append( { 'lat' : event[1], 'lon' : event[2] } )
	except:
		print "Error parsing CSV occured"
	finally:
		f.close()
	return render_template("index.html", events=events)

if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
	app.run(host='0.0.0.0', port=port)

