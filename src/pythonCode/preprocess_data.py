import sys


DATA_PATH = "../../data/"

if sys.argv[1] == "events":
	
	path = DATA_PATH + "events/"

	i = 1

	while True:
		try:
			f = open(path+"/events_"+str(i)+".json")
			i += 1

		except:
			break

else:
	print "Nothing to do"
	pass
