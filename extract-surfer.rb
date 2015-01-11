#!/usr/bin/env ruby
# coding: utf-8

require "opencv"
include OpenCV
# require "./cvmat-enhanced.rb"

#######################################
# configuration
#######################################

USE_EXTENDED_DESCRIPTOR = true
THRESHOLD = 1500
DESCRIPTOR_SIZE = USE_EXTENDED_DESCRIPTOR ? 128 : 64
# a画像
img1 = CvMat.load('./samples/lenna.jpg', CV_LOAD_IMAGE_GRAYSCALE)
# b画像
img2 = CvMat.load('./samples/lenna-rotated.jpg', CV_LOAD_IMAGE_GRAYSCALE)

#######################################
# 特徴点の抽出
#######################################

puts 'Extracting features from img1 using SURF...'
# 特徴点オプション 1500, true
param = CvSURFParams.new(THRESHOLD, USE_EXTENDED_DESCRIPTOR)
# 特徴点、特徴量
kp1, desc1 = img1.extract_surf(param)
puts "found #{kp1.size} keypoints from img1" # => 299

puts 'Extracting features from img2 using SURF...'
kp2, desc2 = img2.extract_surf(param)
puts "found #{kp2.size} keypoints from img2" # => 117

#######################################
# 特徴点の一致
#######################################

puts 'Matching keypoints...'
# a画像の特徴点, kp1.size は特徴点の数
desc1mat = CvMat.new(kp1.size, DESCRIPTOR_SIZE, :cv32f, 1)
desc2mat = CvMat.new(kp2.size, DESCRIPTOR_SIZE, :cv32f, 1)
# (i, j) = 行・列
desc1.each_with_index { |desc, i|
  desc.each_with_index { |d, j|
    # 特徴量を行列化したものを作る。
    desc1mat[i, j] = CvScalar.new(d)
  }
}
desc2.each_with_index { |desc, i|
  desc.each_with_index { |d, j|
    desc2mat[i, j] = CvScalar.new(d)
  }
}
# 探索木作成
feature_tree = CvFeatureTree.new(desc1mat)
# 特徴量行列で一致結果を得る。
# results = 1 * 117
# distances = 1 * 117
results, distances = feature_tree.find_features(desc2mat, 1, 250)

reverse_lookup = []
reverse_lookup_dist = []
kp1.size.times { |i|
  reverse_lookup << -1
  reverse_lookup_dist << Float::MAX
}

match_count = 0
kp2.size.times { |j|
  i = results[j][0].to_i # kp1 の対応番号が格納されているかも。
  d = distances[j][0]
  # Float型の最大値より小さい値のときのみ処理
  if (d < reverse_lookup_dist[i])
    match_count += 1 if reverse_lookup_dist[i] == Float::MAX
    # この時点で i が kp1 の値の点番号
    # p "なんか #{d}"
    reverse_lookup[i] = j
    reverse_lookup_dist[i] = d
  end
}
puts "found #{match_count} putative correspondences"
# my log
logger = []

points1 = []
points2 = []
kp2.size.times { |j|
  i = results[j][0].to_i
  if (j == reverse_lookup[i])
    points1 << kp1[i].pt
    points2 << kp2[j].pt
    mylog = {
      ax: kp1[i].pt.x,
      ay: kp1[i].pt.y,
      bx: kp2[j].pt.x,
      by: kp2[j].pt.y,
    }
    logger.push mylog
  end
}

width = img1.cols + img2.cols
height = (img1.rows > img2.rows) ? img1.rows : img2.rows
correspond = IplImage.new(width, height, :cv8u, 1);
correspond.set_roi(CvRect.new(0, 0, img1.cols, img1.rows))
img1.copy(correspond)
correspond.set_roi(CvRect.new(img1.cols, 0, img1.cols + img2.cols, img2.rows))
img2.copy(correspond)
correspond.reset_roi

points1.zip(points2) { |pt1, pt2|
  pt2.x += img1.cols
  correspond.line!(pt1, pt2, :color => CvColor::White)
}

#######################################
#######################################

# puts logger
scales = []

(1..1000).each do
  log1, log2 = logger.sample(2)
  da22 = (log1[:ax] - log2[:ax]) ** 2 + (log1[:ay] - log2[:ay]) ** 2
  db22 = (log1[:bx] - log2[:bx]) ** 2 + (log1[:by] - log2[:by]) ** 2
  len_a = Math.sqrt(da22)
  len_b = Math.sqrt(db22)
  # p "倍率 #{len_b / len_a * 100} ％"
  scale = len_b / len_a * 100
  scales.push scale
end

percentage = scales.inject(0.0){ |r,i| r += i } / scales.size
p "倍率は 約#{percentage}％の比率です。"

#######################################
#######################################

GUI::Window.new('Object Correspond').show correspond
GUI::wait_key
