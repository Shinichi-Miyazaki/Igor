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
