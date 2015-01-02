#!/usr/bin/env ruby
# coding: utf-8

require "opencv"
require "./cvmat-enhanced.rb"

# 目的
#   ２つの画像 a, b (a < b) において、b 内に a に近い画像が含まれているとき、どの位置にあるのか探索する。位置を c とする。
#   imagemagick を用いて、a を黒で塗りつぶした画像 d を用意する。
#   b に求めた c 位置 で a のサイズ分切り取り、d と和をとることで、b の背景はすべて白になったものを得られる。それを出力する。

# -------------------------------------
#  Configuration
# -------------------------------------

a_image = "./samples/paintLittle.jpg"
b_image = "./samples/paintBig.jpg"
d_image = "./samples/paintLittle-th.jpg"
result_image = "./samples/result.png"

# -------------------------------------
# メイン処理
# -------------------------------------

reconstructed = OpenCV::CvMat.load(a_image)
rough = OpenCV::CvMat.load(b_image)

if reconstructed.smallerThan? rough
  place = reconstructed.placesAt rough
  black_shadow = OpenCV::CvMat.load(d_image)
  if black_shadow.has_identical_size? reconstructed
    clipped = rough.sub_rect place[:x], place[:y], reconstructed.width, reconstructed.height
    view = black_shadow + clipped
    view.save_image result_image
    puts "This result image has been saved at #{result_image}"
  end
end