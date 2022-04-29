#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function MakePanel()
	NewPanel
	Button button0 title="LoadRawData",size={80,20}
	ShowTools/A arrow
	Button button0 size={100,20},proc=ButtonProc_2
end

Function ButtonProc_2(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			SpeloaderM(Compact=1)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End