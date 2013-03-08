import sys, re, json


DATA_PATH = "../../data/"

OUTPUT = "../../"

if sys.argv[1] == "events":
	
	path = DATA_PATH + "events/"

	i = 1

	lats = []
	longs = []

	while True:
		try:
			f = open(path+"/events_"+str(i)+".json", 'r')
			i += 1

			js = f.read(-1)
			print "JSON before: ", js, js.count("["), js.count("]")
			js = re.sub("/\]\s*\[/gm", ",", js)
			print "JSON later:",  js, js.count("["), js.count("]")

			f.close()

			events = json.loads(js)
			for event in events:
				if event['venue'] != None:
					print "that's true"
					lats.append(event['venue']['lat'])
					longs.append(event['venue']['lon'])

		except:
			break

	if len(lats) <= 0:
		print "Wasn't useful... =("
		exit(0)

	o = open("events_data", 'w')
	o.write("[{'lat' : "+lats[0]+", 'lon' : "+longs[0]+"}")
	for i in range(1,len(lats)):
		o.write(",{'lat' : "+lats[i]+", 'lon' : "+longs[i]+"}")
	o.write("]")
	o.close()

else:
	print "Nothing to do"
	pass
