#pragma rtGlobals=1		// Use modern global access method.
macro makeInitBase()

print (temp00[pcsr(B)]-temp00[pcsr(A)])/(re_ramanshift2[pcsr(B)]-re_ramanshift2[pcsr(A)])*(-re_ramanshift2[pcsr(A)])+temp00[pcsr(A)]
print (temp00[pcsr(B)]-temp00[pcsr(A)])/(re_ramanshift2[pcsr(B)]-re_ramanshift2[pcsr(A)])

endmacro