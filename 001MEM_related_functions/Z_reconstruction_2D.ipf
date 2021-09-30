#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

/// @params input_wv: the wave, which you want to change
/// @params z_range: the range which you want to remake
/// @output reconstructed_wave
/// this script reconstruct the wave along z direction 
/// the z direction is below
/// input wave: z = 0, +1, -1, +2, -2...
/// output wave: z = -a, -a+1, ... , -1, 0, 1, ..., a-1, a

function Z_reconstruction(input_wv, z_range)
wave input_wv
variable z_range
variable x_Num, z_num, z_limit
variable i,j, inv_i

x_Num=dimsize(input_wv,0)
z_Num=dimsize(input_wv, 1)
// check the length, if the input length is too large (larger than input wave), return error
z_limit=(z_range-1)/2
if(z_range>z_num)
	print("z_range is too large")
else
	make/o/n=(x_Num,z_range) reconstructed_wave=0
	i=0
	j=0
	do
		if(i==0)
			reconstructed_wave[][z_limit+i] = input_wv[p][i]
			i+=1
			j+=1
		else
			reconstructed_wave[][z_limit+i] = input_wv[p][j]
			inv_i = -i
			reconstructed_wave[][z_limit+inv_i] = input_wv[p][j+1]
			i+=1
			j+=2
		endif
	while(i<=z_limit)

endif
end