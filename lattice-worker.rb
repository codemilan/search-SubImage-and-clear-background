#!/usr/bin/env ruby
# coding: utf-8

require "opencv"
require "./cvmat-enhanced.rb"

# 同じ大きさの２つの画像を、グリッド化する。
# グリッド化された画像同士を比較して、MSE value を算出する。

# -------------------------------------
#  Configuration
# -------------------------------------

a_image = "./samples/paintLittle.jpg"
b_image = "./samples/result.png"
pertition = {
  width: 1,
  height: 2
}

# -------------------------------------
# メイン処理
# -------------------------------------

a_Mat = OpenCV::CvMat.load a_image
b_Mat = OpenCV::CvMat.load b_image
unless a_Mat.has_identical_size? b_Mat
  p "同じ画像を指定してください。"
  return false
end
if a_Mat.griddable? pertition
  a_grids = a_Mat.gridize pertition
  b_grids = b_Mat.gridize pertition
  results = []
  (0...(a_grids.length)).each do |i|
    gridA = a_grids[i][:mat]
    gridB = b_grids[i][:mat]
    mse = gridA.calculate_MSE gridB
    results.push result = {
      x: a_grids[i][:x],
      y: a_grids[i][:y],
      width: gridA.width,
      height: gridB.height,
      mse: mse
    }
  end
  puts results
end

