﻿#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Following function fit the data with gauss function
// CUrrently, upper limit for the number of funciton is 7 (=coef23)
// Written by Shinichi Miyazaki, 2021/11/03

//preprocessing the coefs
Function CoefProcess(WCoef)
// WCoef: coef wave
wave WCoef
variable CoefNum = dimsize(WCoef,0)
make/o/n=23 ProcessedWCoef = 0 
ProcessedWCoef[0,CoefNum-1]= WCoef[p]
end

//Define Gauss Function
Function GaussFunc(W,X)
	// CoefW: coef wave, the parameters for gauss fit
	// CoefW does not have to possess 23 values
	// X: X axis
	// Amp: variable return
	// W: coef wave padded with 0, if the coefw had 14 values (4 gauss), value15~23 is 0. 
	wave w;
	variable	X;
	variable Amp;
	Amp=W[0]+W[1]*X+W[2]*exp(-((X-W[3])/W[4])^2)+W[5]*exp(-((X-W[6])/W[7])^2)//+W[8]*exp(-((X-W[9])/W[10])^2)+W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2)+W[17]*exp(-((X-W[18])/W[19])^2)+W[20]*exp(-((X-W[21])/W[22])^2);
	return	Amp;
end

// Initial fitting function
function InitialFit()
// arguments
// wave wcoef
wave temp00, re_ramanshift2, Wcoef, processedWcoef
variable NumOfGauss = (dimsize(processedWcoef,0)-2)/3

// make initial flag and constraints wave for 7 gauss
string InitHFlag="00011011"//011011011011011" 
Make/O/T/N=2 InitConstraints={"K2 > 0", "K5 > 0"}//,"K8 > 0","K11 > 0","K14 > 0","K17 > 0","K20 > 0"}

//delete unessesary gauss 

//011を必要な回数 (numofgauss) 繰り返して配列生成
//生成された配列で後ろから削除
//HFlag = removeending(InitHFlag, 
//text waveのスライスがわからない
//make/o/n=(NumofGauss-1) Constraints = InitConstraints[0,NumOfGauss-1]

Funcfit/Q/H=InitHFlag gaussfunc wcoef temp00 /X=re_ramanshift2/D /C=InitConstraints;
end


// to do (problems)
// T_constraintsを入れているのに, 値をH flagで固定しようとするとエラー
// constrainと固定は同時にはできない. 何かうまい方法を考える. 
// 可能なら, w_coefが何であれ, 問題なくfitしたいが
// /H flagに関しては removeEndingで後ろから削って必要なもののみ残す
// T_constraintsに関しては, removefromListで削除しておく
// amp0のガウスは残ってしまうが, amp0で固定されているはずなので問題ないか？


function MakeFitImages(frompix, endpix, wcoef, zNum)
// arguments
variable frompix,endpix,zNum;
wave wcoef
// defined waves and variables
variable i,j, k,pts;
wave imchi3_data, re_ramanshift2, temp00, W
Variable V_fitOptions=4
variable xNum,yNum
String wavestr,wavestr2,wavestr3,wavestr4,wavestr5,wavestr6,wavestr7

xNum=dimsize(imchi3_data,1);
yNum=dimsize(imchi3_data,2);
pts=dimsize(imchi3_data,0);

//GaussFit
// the amplitude constraints, the amplitude must be greater than 0
Make/O/T/N=7 T_Constraints={"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0","K17 > 0","K20 > 0"}
// Q: silent, just for speedup
// H: which cofficient should be static, 1 = static (can not change)
// (old) NTHR: it is no longer necessary (from Igor pro7)

Funcfit/Q/H="00011011011011011011111" Gaussfunc W temp00 /X=re_ramanshift2/D /C=T_constraints;


end