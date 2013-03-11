from flask import Flask, render_template
import os, json


DEBUG = True
SECRET_KEY = 'dev_key'

app = Flask(__name__)
app.config.from_object(__name__)

@app.route('/')
def index():

	try:
		f = open("venues.csv", 'r')
	except IOError:
		try:
			f = open("../venues.csv", 'r')
		except:
			print "Nothing worked...")

	events = []
	try:
		first = True
		for event in f.readlines():
			if first:
				first = False
				continue
			event = event.replace("\"", "")
			event = event.split(",")

			if event[1].strip() == "" or event[2].strip() == "":
				continue
			if event[1].isspace() or event[2].isspace():
				continue
			elif event[1].isalpha() or event[2].isalpha():
				continue
			events.append( { 'lon' : event[1], 'lat' : event[2] } )
	except:
		print "Error parsing CSV occured"
	finally:
		f.close()
	return render_template("index.html", events=events)

if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
	app.run(host='0.0.0.0', port=port)

