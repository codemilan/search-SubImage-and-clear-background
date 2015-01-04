#!/usr/bin/env ruby
# coding: utf-8

require "opencv"
require "optparse"
require "./cvmat-enhanced.rb"

# 同じ大きさの２つの画像を、グリッド化する。
# グリッド化された画像同士を比較して、MSE value を算出する。
# todo
#   grid 画像の生成
    # + mse 表示

# -------------------------------------
#  Configuration
# -------------------------------------

a_image = "./samples/paintLittle.jpg"
b_image = "./samples/result.png"
# 結果保存先
error_result_image = "./samples/error_result.png"
config = {
  pertition: {
    width: 2,
    height: 2,
    regular_square: false,
    square_px: 3,
  },
  # 厳密な pertition を指定せずに強制実行
  idealization: true,
  idealization_config: {
    # 右詰め
    right_fill: false,
    # 左詰め
    bottom_fill: false,
    },
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

if config[:idealization]
  p "forceful execute ..."
  a_Mat = a_Mat.idealize config
  b_Mat = b_Mat.idealize config
end


if a_Mat.griddable? config
  a_grids = a_Mat.gridize config
  b_grids = b_Mat.gridize config
  results = []

  (0...(a_grids.length)).each do |i|
    grid_a = a_grids[i][:mat]
    grid_b = b_grids[i][:mat]
    mse = grid_a.calculate_MSE grid_b

    result = {
      x: a_grids[i][:x],
      y: a_grids[i][:y],
      width: grid_a.width,
      height: grid_b.height,
      mse: mse
    }
    results.push result
  end
  puts results.sort_by {|result| result[:mse]}
  error_field = results[-1]
  p0 = OpenCV::CvPoint.new(error_field[:x], error_field[:y])
  p1 = OpenCV::CvPoint.new(error_field[:x] + error_field[:width] - 1, error_field[:y] + error_field[:height] - 1)
  error_result = b_Mat.rectangle p0, p1
  error_result.save error_result_image
end

