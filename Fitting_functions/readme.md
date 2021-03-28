## フィットと画像の作成  

0. 用意するもの  
領域平均スペクトル  
imchi3_data  
re_ramanshift2  
MakeFitImageMS.ipf  
MakeInitBase.ipf  

1. フィット領域の定義のため, グラフを表示  
まずは, 領域平均スペクトルを表示して, どの波数をフィットするかを考えます.  
平均スペクトルを読み込んだら, 以下のコードで適当に図を出します.  
```Igor
display waveav vs re_ramanshift2
```
以下のような図が出るはずなので, フィットしたい領域を拡大しましょう.  
<img width="852" alt="im1" src="https://user-images.githubusercontent.com/59829168/112760635-ba1a9180-9032-11eb-9599-b76f88b09e4c.png">  
拡大は適当なところを四角で囲って, 右クリック expandです.   
<img width="852" alt="im2" src="https://user-images.githubusercontent.com/59829168/112760652-c30b6300-9032-11eb-910d-7e5827c970c6.png">  

2. baselineの取得  
次に, fitする範囲を決めて, baselineを取得します.  
カーソル (ctrl + i) でfitしたい領域の高波数側と低波数側に置きます.  
<img width="852" alt="im3" src="https://user-images.githubusercontent.com/59829168/112760653-c3a3f980-9032-11eb-88be-84798bdabd93.png">  
この状態で, コマンド (ctrl + j)から MakeinitBaseを実行します.  
```Igor
rename waveav temp00
	//makeinitbase()はtemp00というwaveに対してしか働きません. のちに直しておきます. 
Makeinitbase()
```
これ実行すると, 2つの数字が手に入ると思います. この数字は, カーソル間を直線で結んだ時の傾きと切片です.  
この値をベースとしてフィッティングを行います.  

3. Fit   
加納研で行っているガウスフィットは, あらかじめ与えたbaselineと大まかなガウス関数の形 (振幅, 位置, 幅) でフィットをします. そのため, まずはフィットのための初期値を与える必要があります.  
baselineは先ほどのmakeinitbase()で得ているので, 残りを適当に定義します. 解析虎の巻などで, 便利な定数が書いてあったりします.  
例えば, ここではCHを6つのガウスでフィットします. この場合の定数の数は, 2 (baseline) + 3 (gauss) * 6 = 20個となります.  
```Igor
make/O/N = 20 wcoef
	//適当にwcoefという名前にしています. 
wcoef = {-2.6, 0.001,0.5, 2850, 10, 0.9 2870, 10, 0.5,2930, 10, 0.3, 2950, 10, 0.5. 2910, 10, 0.2, 3000, 10}  
	//適当に, ピークを見ながら値を代入します
FuncFit gauss6 wcoef20 temp00[pcsr(A),pcsr(B)]/X=re_ramanshift2/D fit_temp00= gauss6(wcoef,x)
	//gauss 6つなので, gauss6という名前を使います. 
```
fitがうまくいくと, このようになります.  
(わかりやすいように, fitした曲線を青色に変えています. やり方はグラフをダブルクリックして色変更です. )
<img width="852" alt="im4" src="https://user-images.githubusercontent.com/59829168/112760654-c3a3f980-9032-11eb-8fe6-4fd138678481.png">  

4. Fit Imageの作成
Fitがある程度うまくいったら, Fit imageを作成します.  
```Igor
MakeFitImageMS(V_startRow,V_endRow, 6, wcoef, 0)
	//最初の2引数 V_startrow, V_endrowはそのままコピペ
	//3つ目の引数はガウスの数
	//4つ目はwcoef (上記で自作したときの名前)
	//5つ目はz方向の数, ここではz stackしないで1平面のみを想定して0にしています. 
	//z stackした場合の処理は後述
```
これはすなわち, 先ほどの例では, CHの部分を6つのガウスでフィットしましたが, そのガウス一つ一つの強度で画像を作るということです.  
2850でフィットすれば, それは画像内の脂質のイメージになるでしょうし, 1003のフィット画像はタンパク質になるというような感じです.  
うまくいけば以下のように, いくつかの画像が表示されます.  
<img width="960" alt="im5" src="https://user-images.githubusercontent.com/59829168/112760646-c1da3600-9032-11eb-94ff-dce8ed03ea5e.png">  

----

## z stack時のfitと画像表示について  
z stackで何枚かとった場合, そのままmemをかけることができます.  
そのままfitも3次元でかけることができます.  
やり方は上記と同じですが, 最後のmakefitimage_msで5つ目の引数をz stackの枚数-1とします (5枚撮った時は4としてください.)  
出力される画像はFitImage1Z0のような名前になります.  
最初の数字はいくつ目のガウスでフィットしたかを示し, Zの後の数字はz stack何枚目かを示します. 　
