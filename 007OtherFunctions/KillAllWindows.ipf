#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

Function KillAllWindows()
	// kill all graphs
	String graphNames = winlist("*", ";", "WIN:1")
	variable numberOfGraphs = itemsinlist(graphNames)
	variable i=0
	do 
		String graphName = StringFromList(i, graphNames)
		Killwindow $graphName
		i+=1
	while(i<numberOfGraphs)
	
	// kill all tables
	String tableNames = winlist("*", ";", "WIN:2")
	variable numberOfTables = itemsinlist(tableNames)
	i=0
	do 
		String tableName = StringFromList(i, tableNames)
		killwindow $tableName
		i+=1
	while(i<numberOfTables)
end