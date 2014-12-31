require "opencv"
require "./cvmat-enhanced.rb"

# 目的
#   ２つの画像 a, b (a < b) において、b 内に a に近い画像が含まれているとき、どの位置にあるのか探索する。位置を c とする。
#   imagemagick を用いて、a を黒で塗りつぶした画像 d を用意する。
#   b に求めた c 位置 で a のサイズ分切り取り、d と和をとることで、b の背景はすべて白になったものを得られる。それを出力する。

# -------------------------------------
#  Configuration
# -------------------------------------

a_image = "paintLittle.jpg"
b_image = "paintBig.jpg"
d_image = "paintLittle-th.jpg"
result_image = "result.png"

# -------------------------------------
# メイン処理
# -------------------------------------

# read constructed image
reconstructer = OpenCV::CvMat.load(a_image)
# read target image
rough = OpenCV::CvMat.load(b_image)
# main
if reconstructer.isValidAndSmallerThan rough
  # search b-coodinates
  place = reconstructer.placesAt rough
  # read black constructed image
  preboundary = OpenCV::CvMat.load(d_image)
  if preboundary.isTheSameSizeOf reconstructer
    # b から a に相当する部分を切り取る。
    clipped = rough.sub_rect place[:x], place[:y], reconstructer.width, reconstructer.height
    # 画像足し算をする。
    view = preboundary + clipped
    # 保存
    view.save_image result_image
    puts "This result image has been saved at #{result_image}"
  end
end