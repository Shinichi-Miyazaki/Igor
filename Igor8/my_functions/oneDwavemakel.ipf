#pragma rtGlobals=1		// Use modern global access method.
function oneDwavemake(wv,start,finish,step,length,prefix)  
wave wv;
variable start,finish,step,length;
string prefix
variable count,i;
string wavestr;
//yNum=dimsize(wv,2)
Silent 1; PauseUpdate
count=trunc((finish-start)/step)
print count
//transform to integer
i= 0

do 
	wavestr = prefix+num2str(i)
	Duplicate/R = [i+start][0,*] wv $wavestr
	redimension/n = (length) $wavestr 
	i += 1	
while(i<=count)

end

///////////////////////////////////////////////////////




function makeInitBase_MS(wv)
wave wv;
variable a,b
a = (vcsr(B)-vcsr(A))/(xcsr(B)-xcsr(A))
b = vcsr(A) - (a * xcsr(A))

print b
print a

end


