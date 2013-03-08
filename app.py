from flask import Flask, render_template
import os, json


DEBUG = True
SECRET_KEY = 'dev_key'

app = Flask(__name__)
app.config.from_object(__name__)

@app.route('/')
def index():

	f = open('events_data', 'r')
	events = f.read(-1)
	print "Read events from data"
	try:
		events = json.loads(events)
		print "Parsed JSON"
	except:
		print "Error parsing JSON occured"
	finally:
		f.close()
	return render_template("index.html", events=events)

if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
	app.run(host='0.0.0.0', port=port)

