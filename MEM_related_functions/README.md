
## データの読み込みからMEMのやり方

0. 用意するもの  
   Igor8  
   測定データ (.spe)  
   バックグラウンドデータ (.spe)  
   ノンレゾナントバックグラウンド(.spe)  
   DataLoad_Preprocessing.ipf  
   x軸 (.itx)  

1. Igor8の起動  

2. 関数をドラッグアンドドロップしてcompile (下のほうに小さくcompileとあるのでクリック)  
![1](https://user-images.githubusercontent.com/59829168/121983212-e93bd600-cdcb-11eb-948c-b44269385f91.png)  

3. コマンドラインを呼び出して(ctrl+j), 以下のコード実行  
```Igor
SpeloaderM(compact=1) 
	//Igorでは大文字小文字の区別をしていないので, 全部小文字でも動きます
```
上記でファイル選択画面が開くので, 解析したい測定データを選択する  

4. 読み込みの際に名前を付けられるので, 適当に名前を付ける (rawなどとすると, "raw0"という名前になる. データブラウザ(ctrl+b)で確認可能)  

5. 3を2回繰り返して, bg, nrを読みこむ (bg, nrと名付けるとbg0, nr0みたいな名前になる)  
![2](https://user-images.githubusercontent.com/59829168/121981675-163ab980-cdc9-11eb-9d2c-c07f827cde26.png)  

6. x軸を読み込むため, .itxデータをドラッグアンドドロップ  

7. x軸は勝手に"xwavelength"という名前で読み込まれるので, これを以下のコードで名前を変える.   
```Igor
rename xwavelength ramanshift
```

__これ以降のコードで, x軸がramanshiftという名前でないと動かないコードもあるので, この手順は必ず行うこと__  

8. データの前処理のため, 以下のコード実行  
```Igor
darknonres(raw0, bg0, nr0)
	//ここは, 読み込みの際にraw, bg, nrという名前にしなかったなら, 
	//自分でつけた名前で実行すること
	//コードの中身をみてもらえばわかるかと思いますが, 
	//rawとnrからbgを引いて, bgを引いたrawをnrで割っています
```

9. 2次元データから4次元データへの変換  
測定データ (.spe) は2次元 (波数,xyz) です. これを, 4次元(波数, x, y, z)に直します.   
例) 波数1340点, x41点, y41点, z5点測定した場合, speloaderで読み込んだデータの形は
(1340, 8405)となっています. これを(1340, 41, 41, 5)に変更します. 以下のコードです
```Igor
wave2Dto4DMS(raw0,41,41,5)
	//最新の関数を使っていただいている場合には問題ありませんが, 
	//昔私が作った関数では, z方向にwaveがコピーされてしまう間違いがありました.
    //念のためデータブラウザでの確認をおすすめします
```

10. データの確認 上記コードを実行すると, データがCARSという名前に変換されています. 試しにデータの形を見てみます  
```Igor
Display cars[][20][20][0] vs ramanshift
	//CARS[][20][20][0] はcARSという4次元waveのうち, 
	//1次元目(波数)はすべてのデータ点, 
	//空間点を示す2次元目以降はx=20, y=20, z=0の点を参照しています. 
```  
![4](https://user-images.githubusercontent.com/59829168/121981766-39fdff80-cdc9-11eb-8706-832ef731aade.png)  

11. MEMをかける波数範囲の指定  
以下のコードで波数の範囲を指定します  
```Igor
MEMprep(-3500,-500)
	//ここはお好みで, 解析したい範囲を入れてください. 
	//ただし, MEMでは原理的に, 波数の端はデータの質が担保できないので, 
	//500まで解析したいときは450か400まで入れたほうが良いです. 
```

12. MEMの実行  
```Igor
MEMit()
	//もしくは, mem_time.ipfを読み込んでからmem_time()で実行すると実行時間を出してくれます. 
	//(自分で作っといてなんですが, ほかの方法もある気がします)
	//数分以上かかります
```  
![5](https://user-images.githubusercontent.com/59829168/121981786-441ffe00-cdc9-11eb-820d-1ed8d821f09d.png)  


13. 横軸の取得  
```Igor
makeramanshift4(m_ramanshift1) 
	//MEMが終わるとm_ramanshift1という名前の軸ができているので, ここは上記をそのままコピペで大丈夫です. 
```

14. データセーブ  
```Igor
save/C re_ramanshift2
save/C imchi3_data
	//すべて終わっていれば, 軸の名前がre_ramanshift2,
    //データの名前がimchi3_dataになっているはずです. 
    //これらを希望の位置に保存しましょう
```


---
### 以下は特定の状況下での技法です (常に使う必要はないです)

16. MEMした後に, 特定の波数で画像を作りたい  
MEMした後, 特定の波数 (2850など)でとりあえず画像を見たい場合には, まずは2850の位置を調べましょう.   
```Igor
display imchi3_data
	//これで, 横軸ramanshiftではなく, 点数のグラフが出ます. 
	//見たいピークにカーソル(ctrl+i)を合わせたら, ピークの波数位置がでます
	//これを記憶しておきます
```
![6](https://user-images.githubusercontent.com/59829168/121981955-96611f00-cdc9-11eb-8739-af1569d5c572.png)

```Igor
ImageMS(imchi3_data,230,41,41)
	//2つ目の引数, 230は可視化したいピークの波数位置です. 
```
![7](https://user-images.githubusercontent.com/59829168/121982202-0c658600-cdca-11eb-9002-fd207bd97eec.png)

17. nonresonant backgroundを測定データから作りたい  
nonresonant backgroudを, カバーガラスではなく, 細胞の横の培地からとりたい時などに  
僕はあまり, 必要としたことがありませんが, 培地からnonres取るには以下です  
最初に適当な波数でイメージ作成して, どこからnonresを作るかを決めましょう  
適当にImageMSでも, loadからイメージ出しても大丈夫です. カーソル (ctrl+i) で位置決めして, x, y座標を書き留めておきましょう.  
```Igor
pickup_nr(xsize, xnum1, xnum2, ynum1, ynum2, oriwv)
	//xsizeは画像のx幅です. 41点41点の画像なら41
	//xnum1~yNum2はnonresをとりたい領域のxy座標です. 順番に注意
	//oriwvは測定データです. .speをspeloaderで読み込めばそのデータでOK
```
