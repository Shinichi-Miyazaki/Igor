#pragma rtGlobals=1		// Use modern global access method.
function fitbase(wavedata)
wave wavedata
wave temp00
variable pix
variable k

pix=dimsize(wavedata,0)
print pix
make /o/n=(pix) temp11
temp11=0
for(k=0;k<pix;k+=1)
	if((k>30&&k<131)||(k>225&&k<233)||(k>387&&k<398)||(k>466&&k<578))
		temp11[k]=wavedata[k]
	else
		temp11[k]=nan
	endif
endfor
end

function fitbase2D(wavedata)
wave wavedata
wave temp00,re_ramanshift2
variable pix
variable i,j,pts,k,l;
variable xNum,yNum
Variable V_fitOptions=4

Silent 1; PauseUpdate
xNum=dimsize(wavedata,1);
yNum=dimsize(wavedata,2);
pix=dimsize(wavedata,0)

make /o/n=(pix,xNum,yNum,0) imchi3_dataSUB
make /o/n=(pix) temp11
make /o/n=(pix) fitresult

i=0;
do
	j=0;
	do
		temp11=0
		fitresult=0
		for(k=0;k<pix;k+=1)
			if((k>30&&k<131)||(k>225&&k<233)||(k>387&&k<398)||(k>466&&k<578))
			temp11[k]=wavedata[k][i][j][0]
		else
			temp11[k]=nan
			endif
		endfor
		CurveFit/Q/NTHR=0 poly 6,  temp11 /X=re_ramanshift2 /D 
		fitresult= poly(W_coef,re_ramanshift2)
		imchi3_dataSUB[][i][j][0]=wavedata[p][i][j][0]-fitresult[p]
	j+=1;
	while(j<yNum)
	i+=1;
while(i<xNum)
end