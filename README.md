目的
--------
+ matching-removing.rb
	+ 欠損画像を、三次元再構成された画像と比較することで、背景の除去を行う。
+ lattice-worker.rb
	+ ２つの画像を格子化した後に、MSE 値を算出して一覧表示する。

matching-removing
----------
1. a_image, b_image, d_image を用意して、matching-removing.rb  内にパスを指定してください。
	+ 以下のようにして、a_image から d_image を生成してください。

	~~~
convert -threshold 65000 a.jpg d.jpg
	~~~

2. $ ruby matching-removing.rb で結果が出力されます。

lattice-worker
----------
1. a_image, result_image を用意して、lattice-worker.rb 内にパスを指定してください。
2. $ ruby lattice-worker.rb で結果が出力されます。
