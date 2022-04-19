## Wave2Dto4D(wv,Numx,Numy,Numz,[DataType,SlidePxNum])	
DataLoad_Preprocessing.ipf内
2次元 (波数*空間点) を 4次元 (波数\*x\*y\*z)に変更

### 引数
#### wv: wave
2次元から4次元にしたいwave

#### Numx, Numy, Numz: variable
作成したい4次元waveのx, y, z

<p class="warn">
警告
z方向に1枚の際にはNumz=1とする必要あり, Numz=0だと出力が3次元？
</p>


#### Datatype: variable, optional
デフォルト (何も入力しなかった場合)
xyz撮影, z方向はz=0, z=1, z=2と撮影

Datatype = 1
xZy撮影, z方向はz=0, z=-1, z=1とジグザグ撮影

Datatype = 2 
xyZ撮影, z方向はz=0, z=-1, z=1とジグザグ撮影

Datatype = 3 
Oneway scan をxy平面で
ピエゾではなく, マイクロドライブでの撮影
IIIS用

#### SlidePxNum: variable, optional
マイクロドライブで撮影した場合の画像でピクセルがずれる際の解決用
入れた数字の分だけピクセルをずらした4次元waveを作成する

### 返り値
なし
**【注意】**
**加納研の関数は大半がそうだが, グローバル変数に代入している.具体的には関数内でCARSという名前のグローバル変数が上書きされている. 後に修正したほうがよさそう (何もエラーは出ないので急ぎではない)**


## darknonres(rawwv, bgwv, nrwv)
DataLoad_Preprocessing.ipf内
rawデータの前処理
rawからbgを引いて, nr (あらかじめbgを引いたもの) で割る

### 引数
#### rawwv: wave (2次元)
前処理をしたいwave

#### bgwv: wave (1 or 2次元)
background, レーザー閉じて測ったスペクトル
1ポイントでもいいですし, 100回測定でもOK 
1次元wave (1回測定)　にも対応済み

#### nrwv: wave (1 or 2次元)
nonresonant, フォーカスずらしたりして測ったスペクトル
1ポイントでもいいですし, 100回測定でもOK 
1次元wave (1回測定)　にも対応済み
pickup_nrを使用した場合にはtempnr入れる

### 返り値
なし
**【注意】
rawwvに入れたwvが上書きされるので注意
2回同じ解析をしようとすると, bg nrでの処理が2回入る**

## darkV2(wv1, wv2)
**[注意]
旧型の関数であり, 保守していない**
DataLoad_Preprocessing.ipf内
rawデータの前処理用
rawデータからbgを引く

### 引数
#### wv1: wave (2次元)
rawデータ

#### wv2: wave (1次元)
background, おそらく2次元非対応 (未確認)

###　返り値
なし


## nonresV2(wv3, wv4)
**[注意]
旧型の関数であり, 保守していない**
DataLoad_Preprocessing.ipf内

rawデータの前処理用
rawデータをnrで割る

### 引数

#### wv3: wave (2次元)
rawデータ

#### wv4: wave (1次元)
bgを引いたnonresonant, おそらく2次元非対応 (未確認)
**【注意】
nonresとして使用するwv4はあらかじめbgを引いていないといけない**

### 返り値
なし


## makeramanshift4(wv)
DataLoad_Preprocessing.ipf内
MEM後の横軸の作成
未検証 (みんな使っていたのでたぶん正しい)

### 引数
#### wv: wave (1次元)
m_ramanshift1という名前で生成されるwave

### 返り値
#### re_ramanshift2: wave 
MEM後の横軸

## ImageCreate(wv, pixel, Numx, Numy, Numz)
DataLoad_Preprocessing.ipf内
データから画像の作成
rawdata, MEM後のimchi3_dataでもなんでも画像化できる
(便利だと思って僕は使っていますが, 意外と使用率低い？)

### 引数
#### wv: (2 or 4次元)
画像化したいデータ, 何次元でも大丈夫
**[警告]
と思ったが, 4次元ではないといけないみたいです
近日中に直します**

#### pixel: variable 
画像化したい波数のピクセル位置

#### Numx, NUmy, Numz
画像のピクセル数

### 返り値
なし
imageは自動生成

