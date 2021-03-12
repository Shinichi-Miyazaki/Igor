#pragma rtGlobals=1		// Use modern global access method.
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
