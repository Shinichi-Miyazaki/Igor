#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function MEM_Igor7(rawwv,xNum,yNum,axiswv,M)
	wave rawwv, axiswv
	variable M, xNum, yNum

	variable waveNum, xyzNum
	variable i, j, startx, endx
	Variable start = dateTime
	waveNum = numpnts(axiswv)
	xyzNum = dimsize(rawwv, 1)
	
	Make/O/N=(waveNum, xyzNum) exp_wv=0
	i=0
	do 
		MatrixOp/O/FREE tempwv = abs(col(rawwv, i)) 
		wave mem_wave = MEM(tempwv,axiswv,M)
		exp_wv[][i] = mem_wave[p]
		i+=1
	while(i<xyzNum)
	
	make/O/N=(waveNum,xNum,yNum) imchi3=0
	j = 0;
	do
		startx = 0 + j *xNum
		endx = xNum + j * xNUm -1
		Duplicate/O/R = [0,*][startx, endx] exp_wv, tempx
		imchi3[][][j] = tempx[p][q]
		j += 1
	while(j<yNum)
	Variable timeElapsed = dateTime - start
	print "This procedure took " + num2str(timeElapsed) + " in seconds."
end


Function/wave MEM(pow_spectrum,ramanshift,M)
	wave pow_spectrum,ramanshift
	variable M
	
	variable N
	variable k,l,count
	variable mem_beta
	variable/C mem_beta_2
	
	N = numpnts(pow_spectrum)
	
	Make/O/D/C/N=(M+1) C_wave
	Make/O/D/C/N=(N) mem_cmp_sp
	Make/O/D/C/N=(M,M) toeplitz_mat
	Make/O/D/C/N=(M,1) b_mat
	Make/O/D/C/N=(N) mem_sp_deno
	Make/O/D/N=(N) mem_sp_real,mem_sp_imag,mem_sp_ps,mem_phase,mem_amp
	Make/O/D/N=1 M_B
	
	b_mat = 0

	FFT/DEST=C_wave pow_spectrum
	C_wave/=N
	
	for(l=0;l<M;l+=1)
		count = 0
		for(k=l;k<M;k+=1)
			toeplitz_mat[k][l] = C_wave[count]
			count +=1
		endfor
	endfor
	
	for(l=1;l<M;l+=1)
		count = l
		for(k=0;k<l;k+=1)
			toeplitz_mat[k][l] = conj(C_wave[count])
			count -=1
		endfor
	endfor

	for(l=0;l<M;l+=1)
			b_mat[l][0] = -C_wave[l+1]
	endfor

	MatrixLinearSolve/M=8 toeplitz_mat b_mat
	mem_beta_2 = C_wave[0]
	for(l=1;l<M+1;l+=1)
		mem_beta_2 += C_wave[l]*M_B[l-1]
	endfor
	mem_beta = sqrt(cabs(mem_beta_2))
	
	mem_sp_deno = 0
	mem_sp_deno[0] = 1
	for(l=0;l<M;l+=1)
		mem_sp_deno[l+1] = M_B[l]
	endfor
	mem_sp_deno*=N
	IFFT/C mem_sp_deno
	for(l=0;l<N;l+=1)
		mem_sp_deno[l] *= exp(pi*(l)*cmplx(0,1))
	endfor
	
	mem_phase =imag(r2polar(mem_sp_deno))
	if(ramanshift[N-1]-ramanshift[0]<0)
		mem_phase*=-1
	endif
	mem_amp = mem_beta/real(r2polar(mem_sp_deno))
	mem_sp_ps =mem_amp^2
	
	mem_cmp_sp = mem_amp*exp(cmplx(0,1)*mem_phase)
	mem_sp_real = real(mem_cmp_sp)
	mem_sp_imag = imag(mem_cmp_sp)
	
	return mem_sp_imag
end


Function even_interval(CARS_spectrum_wv_name,ramanshift_wv_name)
	string CARS_spectrum_wv_name,ramanshift_wv_name

	string output_wv_name
	
	duplicate/O $CARS_spectrum_wv_name, temp_data
	duplicate/O $ramanshift_wv_name, temp_rs
	duplicate/O $ramanshift_wv_name, temp_rs_ei
	duplicate/O $CARS_spectrum_wv_name, temp_data_ei

	variable N
	variable k,l
	variable tilt
	N= numpnts(temp_rs)
	
	temp_rs_ei = (p)*(temp_rs[N-1]-temp_rs[0])/(N-1)+temp_rs[0]
	

	for(k=0;k<N;k+=1)
		if(k==0||k==N-1)
			temp_data_ei[k] =temp_data[k] 
		else
			l= 0
			do		
				l+=1
			while (temp_rs[l]<temp_rs_ei[k])
			tilt = (temp_data[l]-temp_data[l-1]  )/(temp_rs[l]-temp_rs[l-1])
			temp_data_ei[k] = tilt*(temp_rs_ei[k] - temp_rs[l-1])+temp_data[l-1]
		endif
	endfor
	
	output_wv_name = CARS_spectrum_wv_name + "_ei"
	duplicate/O temp_data_ei $output_wv_name
	output_wv_name = ramanshift_wv_name + "_ei"
	duplicate/O temp_rs_ei $output_wv_name
	
end

Function darkV2(wv1, wv2,n)	//this function gives wave of wv1 - wv2
	wave	wv1, wv2;
	variable	n;
	variable	i;
	
	Silent 1;
	Pauseupdate 

	matrixOP/O/FREE temp = colRepeat(wv2, n)
	matrixop/O wv1 = wv1-temp

	
end

Function nonresV2(wv3, wv4, n)
	wave	wv3, wv4;
	variable n;

	matrixop/O temp = colRepeat(wv4,n)
	matrixop/o wv3 = wv3/temp
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


Function makeav_ms(inwv)
	wave inwv
	variable wavenum
	wavenum = dimsize(inwv, 1)
	matrixop/O sumwv = sumRows(inwv)
	matrixop/O inwv = sumwv/wavenum
end

