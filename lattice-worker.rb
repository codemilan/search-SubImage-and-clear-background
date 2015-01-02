#!/usr/bin/env ruby
# coding: utf-8

require "opencv"
require "optparse"
require "./cvmat-enhanced.rb"

# 同じ大きさの２つの画像を、グリッド化する。
# グリッド化された画像同士を比較して、MSE value を算出する。

# -------------------------------------
#  Configuration
# -------------------------------------

a_image = "./samples/paintLittle.jpg"
b_image = "./samples/result.png"
pertition = {
  width: 7,
  height: 7
}
# 強制実行
forceful = true

# -------------------------------------
# メイン処理
# -------------------------------------

a_Mat = OpenCV::CvMat.load a_image
b_Mat = OpenCV::CvMat.load b_image

if forceful
  p "forceful execute ..."
  a_Mat = a_Mat.idealize(pertition)
  b_Mat = b_Mat.idealize(pertition)
end

unless a_Mat.has_identical_size? b_Mat
  p "同じ画像を指定してください。"
  return false
end



if a_Mat.griddable? pertition
  a_grids = a_Mat.gridize pertition
  b_grids = b_Mat.gridize pertition
  results = []

  (0...(a_grids.length)).each do |i|
    grid_a = a_grids[i][:mat]
    grid_b = b_grids[i][:mat]
    mse = grid_a.calculate_MSE grid_b

    results.push result = {
      x: a_grids[i][:x],
      y: a_grids[i][:y],
      width: grid_a.width,
      height: grid_b.height,
      mse: mse
    }
  end
  puts results.sort_by {|result| result[:mse]}
end

