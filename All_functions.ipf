#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function wave2Dto4DMS(wv,Numx,Numy,Numz)	//rearrange the 2D wave to 4Dwave
	wave	wv;
	variable	Numx,Numy,Numz;
	variable	SampleNum,i,j,k,l, wvNum;
	variable start, startnum, endnum

	Silent 1;
	Pauseupdate
	wvNum = dimsize(wv, 0)

	make/O/N=(wvNum,Numx,Numy,Numz)/D CARS;
	k = 0;
	j = 0;


	do
		for(j=0;j<Numy;j=j+1)
			start = k * Numx * Numy
			startnum =  start + j * Numx
			endnum = start + (j+1) * Numx
			Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
			CARS[][][j][k] = tempwv[p][q];
		endfor
		k += 1
	while(k < Numz)
end

Function/wave darkNonres(rawwv, bgwv, nrwv)
	wave rawwv, bgwv, nrwv
	variable numofwv, bgnum, nrnum

	numofwv = dimsize(rawwv, 1)
	bgnum = dimsize(bgwv, 1)
	nrnum = dimsize(nrwv, 1)

	matrixOP/free/O sumbgwv = sumRows(bgwv)
	matrixOP/free/O bgwv = sumbgwv / bgnum
	matrixOP/free/O sumnrwv = sumRows(nrwv)
	matrixOP/free/O nrwv = sumnrwv / nrnum
	matrixOP/free/o nrwv = nrwv-bgwv

	matrixop/free/o tempbg = colRepeat(bgwv, numofwv)
	matrixop/o rawwv = rawwv - tempbg
	matrixop/free/o tempnr = colRepeat(nrwv, numofwv)
	matrixOP/O rawwv = rawwv / tempnr
end


Function darkV2(wv1, wv2)	//this function gives wave of wv1 - wv2
	wave	wv1, wv2;
	variable	i;

	variable numofwv
	numofwv = dimsize(wv1, 1)

	Silent 1;
	Pauseupdate

	matrixOP/O/FREE temp = colRepeat(wv2, numofwv)
	matrixop/O wv1 = wv1-temp


end

Function nonresV2(wv3, wv4)
	wave	wv3, wv4;
	variable numofwv
	numofwv = dimsize(wv3, 1)
	matrixop/O temp = colRepeat(wv4,numofwv)
	matrixop/o wv3 = wv3/temp
end

Function/wave makeramanshift4(wv)		//making new Ramanshift wave after MEM
	wave	wv;
	variable	pixNum;
	variable	i;
	
	pixNum=DimSize(wv,0);
	print pixNum
	make/O/N=(pixNum) /D re_ramanshift2;
	for(i=0;i<pixNum;i=i+1)
		re_ramanshift2[i] = -wv[pixNum-1-i];
	endfor
	return	re_ramanshift2;
end

// WinSpec file (*.spe) loader v 1.0
//

#pragma rtGlobals=1		// Use modern global access method.

Menu "Data"
	SubMenu "Import"
		"WinSpec SPE", SpeLoader()
	End
End


Static Constant DATEMAX = 10
Static Constant TIMEMAX = 7
Static Constant COMMENTMAX = 80
Static Constant LABELMAX = 16
Static Constant FILEVERMAX = 16
Static Constant HDRNAMEMAX1 = 100 // splitted 120 to 100, 20 to deal with igor < 6.1
Static Constant HDRNAMEMAX2 = 20
Static Constant ROIMAX = 10

Static Structure ROI // region of interest
	uint16 startx
	uint16 endx
	uint16 groupx
	uint16 starty
	uint16 endy
	uint16 groupy
EndStructure

Static Structure comment
	char body[5]
EndStructure

// Igor does not accept non-2byte-aligned multi-byte menbers in a structure.
// so using "char" instead of "double" here. should re-interpret bit patterns.
Static Structure calib
//	double offset // +0
//	double factor // +8
	char offset[8] // +0
	char factor[8] // +8
	char current_unit // +16 selected scaling unit
	char reserved1    // +17
	char scaling_string[40] // +18
	char reserved2[40]  // +58
	char calib_valid // +98 flag if calib. is vaid
	char input_unit // +99
	char polynom_unit //+100
	char polynom_order //+101
	char calib_count //+102

//	double pixel_position[10] // +103
//	double calib_value[10] // +183
//	double polynom_coeff[6] // +263
//	double laser_position // +311
	char pixel_position[10*8] // +103
	char calib_value[10*8] // +183
	char polynom_coeff[6*8] // +263
	char laser_position[1*8] // +311

	char reserved3 // +319
	char new_calib_flag  // +320 (when ==200, "calib_label" field is valid)
	char calib_label[81] // +321
	char expansion[87] // +402
EndStructure

Structure SPE_Header // WinSpec SPE format ver 2.5
	int16	ControllerVersion		//	0	Hardware Version
	int16	LogicOutput		//	2	Definition of Output BNC
	uint16	AmpHiCapLowNoise		//	4	Amp Switching Mode
	uint16	xDimDet		//	6	Detector x dimension of chip.
	int16	mode		//	8	timing mode
	float	exp_sec		//	10	alternative exposure, in sec.
	int16	VChipXdim		//	14	Virtual Chip X dim
	int16	VChipYdim		//	16	Virtual Chip Y dim
	uint16	yDimDet		//	18	y dimension of CCD or detector.
	char	datestr[DATEMAX]		//	20	date
	int16	VirtualChipFlag		//	30	On/Off
	char	Spare_1[2]		//	32
	int16	noscan		//	34	Old number of scans - should always be -1
	float	DetTemperature		//	36	Detector Temperature Set
	int16	DetType		//	40	CCD/DiodeArray type
	uint16	xdim		//	42	actual # of pixels on x axis
	int16	stdiode		//	44	trigger diode
	float	DelayTime		//	46	Used with Async Mode
	uint16	ShutterControl		//	50	Normal, Disabled Open, Disabled Closed
	int16	AbsorbLive		//	52	On/Off
	uint16	AbsorbMode		//	54	Reference Strip or File
	int16	CanDoVirtualChipFlag		//	56	T/F Cont/Chip able to do Virtual Chip
	int16	ThresholdMinLive		//	58	On/Off
	float	ThresholdMinVal		//	60	Threshold Minimum Value
	int16	ThresholdMaxLive		//	64	On/Off
	float	ThresholdMaxVal		//	66	Threshold Maximum Value
	int16	SpecAutoSpectroMode		//	70	T/F Spectrograph Used
	float	SpecCenterWlNm		//	72	Center Wavelength in Nm
	int16	SpecGlueFlag		//	76	T/F File is Glued
	float	SpecGlueStartWlNm		//	78	Starting Wavelength in Nm
	float	SpecGlueEndWlNm		//	82	Starting Wavelength in Nm
	float	SpecGlueMinOvrlpNm		//	86	Minimum Overlap in Nm
	float	SpecGlueFinalResNm		//	90	Final Resolution in Nm
	int16	PulserType		//	94	0=None, PG200=1, PTG=2, DG535=3
	int16	CustomChipFlag		//	96	T/F Custom Chip Used
	int16	XPrePixels		//	98	Pre Pixels in X direction
	int16	XPostPixels		//	100	Post Pixels in X direction
	int16	YPrePixels		//	102	Pre Pixels in Y direction
	int16	YPostPixels		//	104	Post Pixels in Y direction
	int16	asynen		//	106	asynchronous enable flag 0 = off
	int16	datatype		//	108	experiment datatype 0:float, 1:int32, 2:int16, 3:uint16
	int16	PulserMode		//	110	Repetitive/Sequential
	uint16	PulserOnChipAccums		//	112	Num PTG On-Chip Accums
	uint32	PulserRepeatExp		//	114	Num Exp Repeats (Pulser SW Accum)
	float	PulseRepWidth		//	118	Width Value for Repetitive pulse (usec)
	float	PulseRepDelay		//	122	Width Value for Repetitive pulse (usec)
	float	PulseSeqStartWidth		//	126	Start Width for Sequential pulse (usec)
	float	PulseSeqEndWidth		//	130	End Width for Sequential pulse (usec)
	float	PulseSeqStartDelay		//	134	Start Delay for Sequential pulse (usec)
	float	PulseSeqEndDelay		//	138	End Delay for Sequential pulse (usec)
	int16	PulseSeqIncMode		//	142	Increments: 1=Fixed, 2=Exponential
	int16	PImaxUsed		//	144	PI-Max type controller flag
	int16	PImaxMode		//	146	PI-Max mode
	int16	PImaxGain		//	148	PI-Max Gain
	int16	BackGrndApplied		//	150	1 if background subtraction done
	int16	PImax2nsBrdUsed		//	152	T/F PI-Max 2ns Board Used
	uint16	minblk		//	154	min. # of strips per skips
	uint16	numminblk		//	156	# of min-blocks before geo skps
	int16	SpecMirrorLocation[2]		//	158	Spectro Mirror Location, 0=Not Present
	int16	SpecSlitLocation[4]		//	162	Spectro Slit Location, 0=Not Present
	int16	CustomTimingFlag		//	170	T/F Custom Timing Used
	char	ExperimentTime[TIMEMAX*2]		//	172	Experiment Local Time as hhmmss\0  (UTC follows)
	int16	ExposUnits		//	186	User Units for Exposure
	uint16	ADCoffset		//	188	ADC offset
	uint16	ADCrate		//	190	ADC rate
	uint16	ADCtype		//	192	ADC type
	uint16	ADCresolution		//	194	ADC resolution
	uint16	ADCbitAdjust		//	196	ADC bit adjust
	uint16	gain		//	198	gain
	STRUCT comment	Comments[COMMENTMAX]		//	200	File Comments
	uint16	geometric		//	600	geometric ops: rotate 0x01,reverse 0x02, flip 0x04
	char	xlabel[LABELMAX]		//	602	intensity display string
	uint16	cleans		//	618	cleans
	uint16	NumSkpPerCln		//	620	number of skips per clean.
	uint16	SpecMirrorPos[2]		//	622	Spectrograph Mirror Positions
	float	SpecSlitPos[4]		//	626	Spectrograph Slit Positions
	int16	AutoCleansActive		//	642	T/F
	int16	UseContCleansInst		//	644	T/F
	int16	AbsorbStripNum		//	646	Absorbance Strip Number
	int16	SpecSlitPosUnits		//	648	Spectrograph Slit Position Units
	float	SpecGrooves		//	650	Spectrograph Grating Grooves
	int16	srccmp		//	654	number of source comp. diodes
	uint16	ydim		//	656	y dimension of raw data.
	int16	scramble		//	658	0=scrambled, 1=unscrambled
	int16	ContinuousCleansFlag		//	660	T/F Continuous Cleans Timing Option
	int16	ExternalTriggerFlag		//	662	T/F External Trigger Timing Option
	uint32	lnoscan		//	664	Number of scans (Early WinX)
	uint32	lavgexp		//	668	Number of Accumulations
	float	ReadoutTime		//	672	Experiment readout time
	int16	TriggeredModeFlag		//	676	T/F Triggered Timing Option
	char	Spare_2[10]		//	678
	char	sw_version[FILEVERMAX]		//	688	Version of SW creating this file
	int16	type		//	704	1 = new120 (Type II) 2 = old120 (Type I ) 3 = ST130 4 = ST121 5 = ST138 6 = DC131 (PentaMax) 7 = ST133 (MicroMax/SpectroMax) 8 = ST135 (GPIB) 9 = VICCD 10 = ST116 (GPIB) 11 = OMA3 (GPIB) 12 = OMA4
	int16	flatFieldApplied		//	706	1 if flat field was applied.
	char	Spare_3[16]		//	708
	int16	kin_trig_mode		//	724	Kinetics Trigger Mode
	char	dlabel[LABELMAX]		//	726	Data label.
	char	Spare_41[100]		//	742
	char	Spare_42[100]		//
	char	Spare_43[100]		//
	char	Spare_44[100]		//
	char	Spare_45[36]		//
	char	PulseFileName1[HDRNAMEMAX1]		//	1178	Name of Pulser File with Pulse Widths/Delays (for Z-Slice)
	char	PulseFileName2[HDRNAMEMAX2]		//	1178	Name of Pulser File with Pulse Widths/Delays (for Z-Slice)
	char	AbsorbFileName1[HDRNAMEMAX1]		//	1298	Name of Absorbance File (if File Mode)
	char	AbsorbFileName2[HDRNAMEMAX2]		//	1298	Name of Absorbance File (if File Mode)
	uint32	NumExpRepeats		//	1418	Number of Times experiment repeated
	uint32	NumExpAccums		//	1422	Number of Time experiment accumulated
	int16	YT_Flag		//	1426	Set to 1 if this file contains YT data
	float	clkspd_us		//	1428	Vert Clock Speed in micro-sec
	int16	HwaccumFlag		//	1432	set to 1 if accum done by Hardware.
	int16	StoreSync		//	1434	set to 1 if store sync used
	int16	BlemishApplied		//	1436	set to 1 if blemish removal applied
	int16	CosmicApplied		//	1438	set to 1 if cosmic ray removal applied
	int16	CosmicType		//	1440	if cosmic ray applied, this is type
	float	CosmicThreshold		//	1442	Threshold of cosmic ray removal.
	uint32	NumFrames		//	1446	number of frames in file.
	float	MaxIntensity		//	1450	max intensity of data (future)
	float	MinIntensity		//	1454	min intensity of data (future)
	char	ylabel[LABELMAX]		//	1458	y axis label.
	uint16	ShutterType		//	1474	shutter type.
	float	shutterComp		//	1476	shutter compensation time.
	uint16	readoutMode		//	1480	readout mode, full, kinetics, etc.
	uint16	WindowSize		//	1482	window size for kinetics only.
	uint16	clkspd		//	1484	clock speed for kinetics & frame transfer
	uint16	interface_type		//	1486	computer interface(isa, taxi, pci, eisa, etc.)
	int16	NumROIsInExperiment		//	1488	May be more than the 10 allowed in this header (if 0, assume 1)
	char	Spare_5[16]		//	1490
	uint16	controllerNum		//	1506	if multiple controller system will have controller number data came from. This is a future item.
	uint16	SWmade		//	1508	Which software package created this file
	int16	NumROI		//	1510	number of ROIs used. if 0 assume 1.
	STRUCT ROI	ROIinfoblk[ROIMAX]		//	1512 - 1630	ROI information
	char	FlatField1[HDRNAMEMAX1]		//	1632	Flat field file name.
	char	FlatField2[HDRNAMEMAX2]		//	1632	Flat field file name.
	char	background1[HDRNAMEMAX1]		//	1752	background sub. file name.
	char	background2[HDRNAMEMAX2]		//	1752	background sub. file name.
	char	blemish1[HDRNAMEMAX1]		//	1872	blemish file name.
	char	blemish2[HDRNAMEMAX2]		//	1872	blemish file name.
	float	file_header_ver		//	1992	version of this file header
	char	YT_Info0[100]		//	1996-2996	Reserved for YT information
	char	YT_Info1[100]		//
	char	YT_Info2[100]		//
	char	YT_Info3[100]		//
	char	YT_Info4[100]		//
	char	YT_Info5[100]		//
	char	YT_Info6[100]		//
	char	YT_Info7[100]		//
	char	YT_Info8[100]		//
	char	YT_Info9[100]		//
	uint32	WinView_id		//	2996	0x01234567L if file created by WinX

	STRUCT calib	calib_X		//	3000-3488
	STRUCT calib	calib_Y		//	3489-3977

	char	Istring[40]		//	3978	special Intensity scaling string
	char	Spare_6[76]		//	4018	empty block to reach 4100 bytes
	int16	AvGainUsed		//	4094	avalanche gain was used
	int16	AvGain		//	4096	avalanche gain value
	int16	lastvalue	//	4098	Always the LAST value in the header
EndStructure

Static Constant SPE_HEADER_SIZE = 4100

Static function read_SPE_header(fd, header)
	variable fd;
    	STRUCT SPE_Header &header;
	// expect little-endian
	fSetPos fd, 0
	fBinRead /B=3 fd, header;

	// post-process
	if(header.NumROI == 0)
		header.NumROI = 1
	endif
    	return 0;
end

Static function dump_header(h)
    	STRUCT SPE_Header &h;
    	String hhmmss_local = h.ExperimentTime
    	print "datetime", h.datestr, hhmmss_local[0,1]+":"+ hhmmss_local[2,3]+":"+ hhmmss_local[4,5]
	print "detector element size (x,y)", h.xDimDet, h.yDimDet
	print "image pixels (x,y)", h.xdim, h.ydim
	print "number of frames", h.NumFrames
	print "exposure", h.exp_sec, "[s]"
	print "accum", h.lavgexp

	switch(h.datatype)
		case 0:
			print "datatype: float"
			break
		case 1:
			print "datatype: int32"
			break
		case 2:
			print "datatype: int16"
			break
		case 3:
			print "datatype: uint16"
			break
	endswitch

	Variable i;
	print "number of ROI", h.NumROI
	for(i=0;i<h.NumROI;i+=1)
		print "  ROI#", i+1, "start(x,y)", h.ROIinfoblk[i].startx ,h.ROIinfoblk[i].starty
		print "    end(x,y)", h.ROIinfoblk[i].endx, h.ROIinfoblk[i].endy
		print "    group(x,y)", h.ROIinfoblk[i].groupx, h.ROIinfoblk[i].groupy
	endfor
end


Function ImageMS(wv,pixel,Numx,Numy)    //make 2d data at particular pixel point
    wave    wv;
    variable    pixel, Numx,Numy;
    variable imagesize
    Silent 1;
    Pauseupdate
    imagesize = Numx*Numy
    make/O/N=(Numx,Numy)/D im;
    duplicate/O/R=[pixel][0, imagesize] wv im
    redimension/n=(imagesize) im
    redimension/n = (Numx, Numy) im
    newimage im
end

function SpeLoaderM([skip, frames, verbose, compact, fullpath])
	Variable skip; // number of frames to skip
	Variable frames; // number of frames to read. 0 will beinterpreted as Inf.
	Variable verbose; // when non-zero, output debug informations
	Variable compact; // when non-zero, multiple frames will be aggregated into single wave
	String fullpath;

	Variable suppress = 1;

	variable fd = -1;
	String path;
	if(ParamIsdefault(fullpath))
		open/R/T=".SPE" fd;
	else
		open/R fd as fullpath;
		//path = "bdbg.spe"
	endif
	path = S_fileName;

	if(fd < 0)
		return -1;
	endif

	Variable t = ticks // start profiling

    	STRUCT SPE_Header h;
	if(read_SPE_header(fd, h) < 0)
		close fd;
		return -1;
	endif
	close fd;

	if(skip >= h.NumFrames)
		return -1; // no more frame to read
	endif

	if(frames == 0)
		frames = h.NumFrames
	endif
	if(frames + skip > h.NumFrames) // allow to use Inf as "frames"
		frames = h.NumFrames - skip
	endif

	Variable fType;
	Variable frameSize;
	switch(h.datatype)
		case 0:
			fType = 2 // fingle-precision IEEE float
			frameSize = 4*h.xdim*h.ydim
			break
		case 1:
			fType = 32 // signed 32 bit int
			frameSize = 4*h.xdim*h.ydim
			break
		case 2:
			fType = 16 // signed 16 bit int
			frameSize = 2*h.xdim*h.ydim
			break
		case 3:
			fType = 16 + 64 // unsigned 16 bit int
			frameSize = 2*h.xdim*h.ydim
			break
	endswitch

	// ensure unique wave names
	Variable i = 0;
	String basename = StringFromList(0, path[strsearch(path, ":", Inf, 1) +1, Inf], ".");
	String wavbase;
	do
		if(skip > 0)
			wavbase = CleanUpName(basename + num2str(i)+"_from"+ num2str(skip)+ "_", 1)
		else
			wavbase = CleanUpName(basename + "_"+ num2str(i)+"_", 1)
		endif
		i += 1
	while(CheckName(wavbase + "0", 1))

	if(ParamIsdefault(fullpath))
		Prompt wavbase, "prefix for waves: "
		DoPrompt "set name prefix", wavbase
	endif
	if(V_flag == 1)
		return -1;
	endif
	if(verbose)
		print "src SPE:", path;
		print "wave base name will be:", wavbase;
		dump_header(h);
		suppress = 0; // to be used with /Q
	endif

	if(compact)
		GBLoadWave /T={(fType),2} /S=(SPE_HEADER_SIZE + (skip*frameSize)) /U=(h.xdim*h.ydim*frames) /W=1 /B /A=$wavbase /Q=(suppress) path;
	else
		// load values from file as arrays of single-float
		GBLoadWave /T={(fType),2} /S=(SPE_HEADER_SIZE + (skip*frameSize)) /U=(h.xdim*h.ydim) /W=(frames) /B /A=$wavbase /Q=(suppress) path;
	endif

	Variable num = V_flag;
	String loaded_waves = S_waveNames

	if(verbose)
		print " * Loaded", num, "frames as ", wavbase + "*"
		print " * Elapsed", (ticks-t)/60
	endif

	String wn;
	if(compact)
		wn = StringFromList(0, loaded_waves)
		if(h.ydim > 1)
			if(verbose)
				print " * redimension to a 3D wave:", h.xdim, h.ydim, frames;
			endif
			Redimension /N=( (h.xdim), (h.ydim), frames), $(wn)
		else
			if(verbose)
				print " * redimension to a 2D wave:", h.xdim, frames;
			endif
			Redimension /N=( (h.xdim), frames), $(wn)
		endif
	else
		if(h.ydim > 1)
			if(verbose)
				print " * redimension to 2D waves:", h.xdim, h.ydim;
			endif
			for(i=0;i<num;i+=1)
				// dynamically truncate loaded_waves to handle many-wave case
				wn = StringFromList(0, loaded_waves)
				loaded_waves = RemoveListItem(0, loaded_waves)
				Redimension /N=( (h.xdim), (h.ydim) ), $(wn)
			endfor
		endif
	endif
	return num;
end

Function/wave MEM_time()
	wave imchi3_data
	Variable start = dateTime
	memit()
	Variable timeElapsed = dateTime - start
	print "This procedure took " + num2str(timeElapsed) + " in seconds."
	return imchi3_data
end

function Pickup_nr(xsize, xNum1,xNum2,yNum1,yNum2, oriwv)
wave oriwv
variable xsize, xNum1,xNum2,yNum1,yNum2;
variable pts;
variable i,cts,first, last;

Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
make /o/n=(pts) tempnrwv
tempnrwv=0;
cts=0;

first = xsize * (yNum1-1) + xNum1
last = xsize*(yNum2-1) + xNum2

i=first
do	
	tempnrwv[]+=oriwv[p][i]
	cts+=1
	i+=1
while(i<last)
tempnrwv/=cts
matrixop/o tempnr = colrepeat(tempnrwv, 100)

end


//gauss functions
Function gaussoffset(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0] + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2);
	return	ans;	
end

Function Dualgaussoffset(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0] + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2);
	return	ans;
end


Function Triplegauss(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2);
	return	ans;
end

Function Quadruple_gauss(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2)+ W[11]*exp(-((X-W[12])/W[13])^2);
	return	ans;
end

Function Gauss5(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2)+ W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2);
	return	ans;
end


Function Gauss6(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2)+ W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2)+ W[17]*exp(-((X-W[18])/W[19])^2);
	return	ans;
end

Function Gauss7(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2)+ W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2)+ W[17]*exp(-((X-W[18])/W[19])^2)+W[20]*exp(-((X-W[21])/W[22])^2);
	return	ans;
end



function MakeFitImageMS(frompix, endpix, gausNum, wcoef, zNum)
variable frompix,endpix,gausNum,zNum;
wave wcoef
variable i,j, k,pts;
wave imchi3_data, re_ramanshift2
Variable V_fitOptions=4
variable xNum,yNum
String wavestr,wavestr2,wavestr3,wavestr4,wavestr5,wavestr6,wavestr7
Silent 1; PauseUpdate
print frompix,endpix, gausNum;

make /o/n=23  W_coefQrG
xNum=dimsize(imchi3_data,1);
yNum=dimsize(imchi3_data,2);
pts=dimsize(imchi3_data,0);
make /n=(pts)/o temp

//Single gauss
if (gausNum==1)
	make /O/T/N=1 T_constraint;
	T_constraint = {"K2 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,4]=wcoef[p]
				W_coefQrG[5]=0;
				W_coefQrG[8]=0;
				W_coefQrG[11]=0;
				W_coefQrG[14]=0;
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011111111111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				wave tempwv = $wavestr
				SetScale/I x 0,(xNum-1)/2,"", tempwv;
				SetScale/I y 0,(yNum-1)/2,"", tempwv;
				tempwv[j][i]=W_coefQrG[2];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
	
	//SetAxis/A/R left;
endif



//Double gauss
if (gausNum==2)
	make /O/T/N=2 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,7]=wcoef[p]
				W_coefQrG[8]=0;
				W_coefQrG[11]=0;
				W_coefQrG[14]=0;
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011111111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif


//Triple gauss
if (gausNum==3)
	make /O/T/N=3 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,10]=wcoef[p]
				W_coefQrG[11]=0;
				W_coefQrG[14]=0;
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011011111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif


//quadruple gauss
if (gausNum==4)
	make /O/T/N=4 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,13]=wcoef[p]
				W_coefQrG[14]=0;
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011011011111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				wavestr4="Fitimage4Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				make /o/n=(xNum,yNum) $wavestr4
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				wave tempwv4 = $wavestr4
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				tempwv4[j][i]=W_coefQrG[11];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr4;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr4 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif

//five gauss
if (gausNum==5)
	make /O/T/N=5 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,16]=wcoef[p]
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011011011011111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				wavestr4="Fitimage4Z"+num2str(k)
				wavestr5="Fitimage5Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				make /o/n=(xNum,yNum) $wavestr4
				make /o/n=(xNum,yNum) $wavestr5
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				wave tempwv4 = $wavestr4
				wave tempwv5 = $wavestr5
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				tempwv4[j][i]=W_coefQrG[11];
				tempwv5[j][i]=W_coefQrG[14];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr4;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr4 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr5;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr5 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif


//six gauss
if (gausNum==6)
	make /O/T/N=6 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0","K17 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,19]=wcoef[p]
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011011011011011111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				wavestr4="Fitimage4Z"+num2str(k)
				wavestr5="Fitimage5Z"+num2str(k)
				wavestr6="Fitimage6Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				make /o/n=(xNum,yNum) $wavestr4
				make /o/n=(xNum,yNum) $wavestr5
				make /o/n=(xNum,yNum) $wavestr6
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				wave tempwv4 = $wavestr4
				wave tempwv5 = $wavestr5
				wave tempwv6 = $wavestr6
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5,tempwv6;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5,tempwv6;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				tempwv4[j][i]=W_coefQrG[11];
				tempwv5[j][i]=W_coefQrG[14];
				tempwv6[j][i]=W_coefQrG[17];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr4;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr4 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr5;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr5 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr6;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr6 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif

//seven gauss
if (gausNum==7)
	make /O/T/N=7 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0","K17 > 0","K20 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,22]=wcoef[p]
				Funcfit/Q/H="00011011011011011011011"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				wavestr4="Fitimage4Z"+num2str(k)
				wavestr5="Fitimage5Z"+num2str(k)
				wavestr6="Fitimage6Z"+num2str(k)
				wavestr7="Fitimage7Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				make /o/n=(xNum,yNum) $wavestr4
				make /o/n=(xNum,yNum) $wavestr5
				make /o/n=(xNum,yNum) $wavestr6
				make /o/n=(xNum,yNum) $wavestr7
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				wave tempwv4 = $wavestr4
				wave tempwv5 = $wavestr5
				wave tempwv6 = $wavestr6
				wave tempwv7 = $wavestr7
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5,tempwv6,tempwv7;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5,tempwv6,tempwv7;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				tempwv4[j][i]=W_coefQrG[11];
				tempwv5[j][i]=W_coefQrG[14];
				tempwv6[j][i]=W_coefQrG[17];
				tempwv7[j][i]=W_coefQrG[20];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr4;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr4 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr5;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr5 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr6;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr6 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr7;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr7 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif


end

#pragma rtGlobals=1		// Use modern global access method.
macro makeInitBase()

print (temp00[pcsr(B)]-temp00[pcsr(A)])/(re_ramanshift2[pcsr(B)]-re_ramanshift2[pcsr(A)])*(-re_ramanshift2[pcsr(A)])+temp00[pcsr(A)]
print (temp00[pcsr(B)]-temp00[pcsr(A)])/(re_ramanshift2[pcsr(B)]-re_ramanshift2[pcsr(A)])

endmacro

Function region_analysis(wv, roiwv, znum)
    wave wv, roiwv;
    variable znum
    variable pts, xNum, yNum;
    variable i, j;
    //get x and y range
    pts = dimsize(wv, 0)
    xNum = dimsize(wv, 1)
    yNum = dimsize(wv, 2)

    //extract z position = znum 
    duplicate/O/R=[0,*][0,*][0,*][znum] wv tempwv

    //inverse roiwv
    matrixop/O temproi = -(roiwv-1)
    
    //make new wave 
    make/o/n=(pts, xNum, yNum) extractedwv

    // loop
    i=0
    do
        j=0
        do
            extractedwv[][i][j] = tempwv[p][i][j][0] * temproi[i][j]
            j+=1
        while(j<yNUm)
        i+=1
    while(i<xNum)
    
    matrixop/o temp = sumrows(extractedwv)
    matrixop/o roinum = sum(temproi)
    matrixop/o average_wv = sumbeams(temp)/roinum[0]
end






function SumFromImage_MS2(refwv,discri,refwv2,discri2,oriwv)
wave refwv,refwv2, oriwv;
variable discri, discri2;

wave wav;
variable pts,xNum,yNum;
variable i,j,cts;

Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
//obtain number of the spectral data (1340)
xNum=dimsize(oriwv,1)
//get x data number
yNum=dimsize(oriwv, 2)
//get y data number

make /o/n=(pts) temp00
temp00=0
cts=0;

i=0
do
	j=0
	do	
		if(refwv2[i][j]<discri2 && refwv[i][j]>discri)
		//if a data at spatial position [i][j] > threshold, execute below
			temp00[]+=oriwv[p][i][j][0] 
			//p = 0, 1, 2, 3,,,,,,
			cts+=1
		endif
		j+=1
	while(j<yNum)
	i+=1
while(i<xNum)
temp00/=cts

end


function ImageSum_MS(xNum1,xNum2,yNum1,yNum2, oriwv)
wave oriwv
variable xNum1,xNum2,yNum1,yNum2;
variable pts;
variable i,j,cts;

Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
make /o/n=(pts) temp00
temp00=0;
cts=0;

i=xNum1
do
	j=yNum1
	do	
		temp00[]+=oriwv[p][i][j][0]
		cts+=1
		j+=1
	while(j<yNum2)
	i+=1
while(i<xNum2)
temp00/=cts

end

function SumFromImage_MS(wv, discri, oriwv)
wave wv,oriwv;
variable discri;

wave imchi3_data
wave wav;
variable pts,xyNum,pixnum;
variable i,j,cts;


Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
make /o/n=(pts) temp00
temp00=0;
cts=0;

i=0
do
	j=0
	do
		if(wv[i][j]>discri)
		//if(imchi3_data[pixnum][i][j][0]>discri)
			temp00[]+=oriwv[p][i][j][0]
			cts+=1
		endif
		j+=1
	while(j<xyNum)
	i+=1
while(i<xyNum)
temp00/=cts

end


function SumfromImage_MS3(xNum1,xNum2,yNum1,yNum2,oriwv)
wave oriwv
variable xNum1,xNum2,yNum1,yNum2;
variable pts;
variable i,j,cts;

Silent 1; PauseUpdate
make /o/n=1 temp00
temp00=0;
cts=0;

i=xNum1
do
	j=yNum1
	do	
		temp00[]+=oriwv[i][j]
		cts+=1
		j+=1
	while(j<yNum2)
	i+=1
while(i<xNum2)
temp00/=cts
variable ans = temp00[0][0]
return ans

end




function DropSaturatedPixel(wv,image, threshold)  
//wv = imchi3(raw data, four-dimensional), image = image(the image you wanted to delete pixels, two-dimensional)
// This function delete the pixels of which singnal in raw data is saturated.  
wave wv;
wave image;
variable threshold
variable pts,xNum,yNum,pixnum;
variable i,j,k,cts, count;


Silent 1; PauseUpdate
pts=dimsize(wv,0)
xNum=dimsize(wv,1)
yNum=dimsize(wv,2)
make /o/n=(xNum, yNum) temp00
temp00=0
count = 0
cts=0;

i=0
do
	j=0
	do
		k=0
		do
			if(wv[k][i][j][0]<threshold)
				cts+=1
			else
				count+=1
				cts+=1
			endif
			k+=1
		while(k<pts)
		
		if(count>0)
			temp00[i][j]=0
		else
			temp00[i][j]=image[i][j]
		endif
		count=0
		j+=1
	while(j<yNum)
	i+=1
while(i<xNum)
temp00/=cts


end

function ratiometric_image(image1, image2)
	wave image1, image2
	variable xNum, yNum
	variable i, j

	// get x, y range
	xNum = dimsize(image1,0)
	yNum = dimsize(image1,1)
	make/o/n=(xNum, yNum) ratioimage
	
	i=0
    do
        j=0
        do
            ratioimage[i][j] = image1[i][j] / image2[i][j]
            j+=1
        while(j<yNUm)
        i+=1
    while(i<xNum)
    NewImage ratioimage

end
	