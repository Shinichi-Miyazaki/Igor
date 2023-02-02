#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
Function/wave GetSubDirNames()
	String SubDirName
	Variable index = 0
	Variable NumOfSubDirs = countobjects(":", 4)
	make/T/o/n=(NumOfSubDirs) SubDirNames
	do
		SubDirName = GetIndexedObjName(":", 4, index)
		SubDirNames[index] = SubDirName
		if (strlen(subDirName) == 0)
			break
		endif
		index += 1
	while(index<NumOfSubDirs)
	return subDirnames
End

Function GetFilePaths()
	wave/t SubDirNames
	String FileName
	Variable index = 0
	variable i=0
	variable j=0
	variable cnt=0
	
	make/T/o tempFilePaths = ""
	wave/t SubDirNames = GetSubDirNames()
	variable NumOfSubDirs = dimsize(SubDirNames, 0)
	do
		String currentDir = ":"+ SubDirNames[j] 
		i=0
		do
			Variable NumOfFiles = countobjects(currentDir, 1)
			FileName = GetIndexedObjName(CurrentDir, 1, i)
			if (strlen(FileName) == 0)
				break
			endif
			tempFilepaths[cnt] = CurrentDir + ":" +  FileName
			cnt+=1
			i+=1
		while(i<NumOfFiles)
		j+=1
	while(j<NumofSubDirs)
	duplicate/t/o/R=[0,cnt-1] tempfilePaths Filepaths
	killwaves tempfilepaths, SubdirNames
End