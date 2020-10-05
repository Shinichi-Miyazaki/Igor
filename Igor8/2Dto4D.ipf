#pragma rtGlobals=1		// Use modern global access method.
Function wave2Dto4DV3(wv,Numx,Numy,Numz)	//rearrange the 2D wave to 4Dwave
	wave	wv;
	variable	Numx,Numy,Numz;
	variable	SampleNum,i,j,k,l, wvNum;

	Silent 1;
	Pauseupdate
	wvNum = dimsize(wv, 1)

	make/O/N=(wvNum,Numx,Numy,Numz)/D CARS;
	k = 0;
	j = 0;


//なんとなくの開発方針
//入力 (1340, xyz)
//出力 (1340, x, y, z)
//matrixopのredimensionを使えば何とかなりそう
//そのためには入力を転置して2, 3次元目を追加して
//redimensionを行う？？
//イメージとしては(xyz, 0, 0, 1340)→(x, y, z, 1340)
//最後に次元を並び替え


	do
		for(i=0;i<Numx;i=i+1)
			for(l=0;l<1340;l=l+1)
				CARS[l][i][j][0] = wv[l][k];
			endfor
			k = k+1;
		endfor
		j = j+1;
		if(j == Numy)
			break

		endif
	while(j <Numy)
end
