MEM_Igor7使い方　　　最終更新日 2020/6/3

用意するもの
・解析用データ (資料測定したもの、型通りの方法で取得したbackground, ノンレゾ
・軸 (Xwavelength)


1, データの読み込み
↓Igor Pro 7.08 64bit の立ち上げ
↓軸のインポート (ドラッグアンドドロップ)
↓Procedureのインポート (ドラッグアンドドロップ)
(以降で使う関数はすべて入れてあるのでこれのみコンパイルでOKです。)
↓コンパイル (ウィンドウ下のほう)
↓コマンドウィンドウ (ctrl+J) でSpeLoaderM(compact=1)と打ち込みエンター
↓ファイル選択画面が開くのでbackgroundデータを選択
↓名前の入力ができるので適当に名前付け 
(この時つけた名前に0がついた名前で読み込まれる, 例bg→bg0)
↓同じくノンレゾも読み込み名前付け (例 nr→nr0)
↓同じくデータも読み込み (例raw→raw0)

2, バックグラウンド、ノンレゾの平均化
(以前使用していたmakeav_oonoはIgor7では動かなそうでした)
↓コマンドウィンドウで makeav_miyazaki(bg0) などと入力
↓bg0が平均化　
(以前のmakeav_oonoでは別のwaveとして作成していましたが、今回はbg0を上書きするようになっています。
↓同じく makeav_miyazaki(nr0)

3, バックグラウンド、ノンレゾの処理
ここは昔と同じ
↓darkV2(raw0, bg0, 101*301)　でバックグラウンド処理(101*301点の場合)
↓nonresV2(raw0, nr0, 101*301) でノンレゾ処理(101*301点の場合)

4,　データの等間隔化
データが等間隔でないと出力がおかしくなる (注意　現時点ではエラーは出ません)ので等間隔化
↓even_interval("raw0", "ramanshift") などと入力　ダブルクオーテーションを入れないとエラー、文字列として読み込みますので
出力として raw0ならraw0_ei、ramanshiftなら ramanshift_eiというwaveが出てきます。

5, MEMの実行
↓MEM_Igor7(raw0_ei, 21, 21, ramanshift_ei, 500)などと入力
現状、私のノートPC corei5-8265 1.60GHz 1.80GHz, RAM 8GB で30000点解析に40分程度かかります。
出力はimchi3 (wavenum, xNum, yNumの3次元)です。
display imchi3[][5][5] vs ramanshift_ei　などでグラフ化してください。

•SpeLoaderM(compact=1)
•SpeLoaderM(compact=1)
•SpeLoaderM(compact=1)
•makeav_miyazaki(bg0)
•makeav_miyazaki(nr0)
•darkV2(raw0, bg0, 101*301)
•nonresV2(raw0, nr0, 101*301)
•even_interval("raw0", "ramanshiftMS")
•MEM_Igor7(raw0_ei, 21, 21, ramanshift_ei, 500)


Notes
注意点を書いていきます

・バックグラウンド処理をして、waveに負の値があるとエラーが起こりそうです。
おそらく線型方程式を解くアルゴリズムが行列の正定値性を仮定しているためと思われますが、
詳細は不明です。(すみません高校以降、線形代数をやらなかったせいです。勉強します。)
いずれにしてもバックグラウンドを引いて0以下になるのは引きすぎなので、
負の値を0にするなりの処理があったほうがいいかもしれません。
僕が普通に測定したものでは負になることはなかったので、対策していませんが、
このエラーが頻発するようなら報告をお願いします。

・現時点で空間点は2次元のものを想定しています。3次元は少々お待ちください。