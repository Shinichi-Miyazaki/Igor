#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
Function/wave MEM_time()
	wave imchi3_data
	Variable start = dateTime
	memit()
	Variable timeElapsed = dateTime - start
	print "This procedure took " + num2str(timeElapsed) + " in seconds."
	return imchi3_data
end