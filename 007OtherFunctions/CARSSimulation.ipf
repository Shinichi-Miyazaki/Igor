#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later


function CARSSiumulation(ResA, NonresA, GammaConst)
	Variable ResA, NonresA, GammaConst
	make/o/n=1280 xaxis = 500+2.5*x
	make/o/n=1280 Omega = 1650
	make/o/N=1280 OmegaDif = omega-xaxis
	make/o/n=1280 impart = -GammaConst
	make/o/c/n=1280 ResDenomi =0
	ResDenomi = cmplx(omegadif, impart)
	make/c/o/n=1280 Res = ResA/ResDenomi
	make/o/n=1280 nonres = NonresA
	matrixop/c/o signal = (Nonres+Res)*conj(Nonres+Res)
	matrixop/o signalReal = real(signal)
end
