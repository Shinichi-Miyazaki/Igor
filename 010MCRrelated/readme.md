## MCR-ALS

0. 用意するもの
MEM後のデータ(4次元) (baselineを引いたものでもOK)
対応する軸  


1. 以下のコードを実行
```Igor
SVD_MCRALS(indata, xaxis, componentNum, startwvNum, endwvNum, maxiter)
```

引数は以下です。
indata: 解析対象のデータ (4次元)
xaxis: 対応する軸 (1次元)
componentNum: データを幾つのコンポーネントに分けるか (数値)
StartWvNum: 解析対象の波数範囲開始地点 (数値)
EndWvNum: 解析対象の波数範囲終了地点 (数値) 
MaxIter: 繰り返しの回数 (数値)

(例)
SVD_MCRALS(data, re_ramanshift2, 7, 800, 1800, 20)
dataを7つのコンポーネントに分けます。解析対象の波数範囲は800-1800 cm<sup>-1</sup>、計算の繰り返しは20回です。

データのS/N比にもよりますが、コンポーネントの数は5-10程度がおすすめです。
それ以上はあまり意味がない気がします。

繰り返し回数もデータによりますが、基本的には20回以上はあまり意味がないと思います。
以下のように、進んでいって、終わると次の画像のように画像とスペクトルがでます。
この例ではいくつかの画像がほぼ同じになっているので、コンポーネント数が多すぎる感じです。
<img width="587" alt="Screen Shot 2022-09-25 at 20 45 26" src="https://user-images.githubusercontent.com/59829168/192141981-2c4d83bc-fc83-40a8-8266-cf8496c554c5.png">
<img width="1418" alt="Screen Shot 2022-09-25 at 20 49 29" src="https://user-images.githubusercontent.com/59829168/192141986-158a1579-67be-4b0c-9b37-4c6d4220be58.png">


今までの経験上、ベースラインを引いて、fitでノーマライズするとよりよく分かれる印象です。
