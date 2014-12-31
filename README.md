目的
--------
欠損画像を、三次元再構成された画像と比較することで、背景の除去を行う。

使い方
----------
1. a_image, b_image, d_image を用意して、minimum-matching.rb 内にパスを指定してください。
2. $ ruby minimum-matching.rb で結果が出力されます。

定義
-----------
a_image =「小さな画像」:= 三次元撮影にて再現した１視点画像 = レオさんのもってる snap 画像

b_image = 「大きな画像」:= 実際に撮影した画像 = レオさんのもってる kesson 画像

d_image = 「小さな画像を塗りつぶした画像」:= a_image から以下のコマンドで作れるもの。

~~~
convert -threshold 65000 a.jpg d.jpg
~~~