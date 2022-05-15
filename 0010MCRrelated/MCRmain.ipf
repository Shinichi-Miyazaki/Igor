#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function/wave NNLS(A, b, maxiter)
	//Author: Shinichi Miyazaki
	//this function solve Ax = b about x 
	//under constraints all x >= 0
	//This is a wrapper for a FORTRAN NNLS
	//@ params A: wave 
	//@ params b: wave right-hand side vector
	//@ params maxiter: variable 
	//@ return NNLSans: wave solution vector
	
	wave A, b
	variable maxiter
	
	//todo if A is not 2dim array, alert
	
	variable n_num = dimsize(A, 0)
	variable m_num = dimsize(A, 1)
	
	make/o/n = n_num NNLSans=0

	return NNLSans
end
