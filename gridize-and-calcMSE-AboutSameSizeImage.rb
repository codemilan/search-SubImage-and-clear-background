require "opencv"
require "./cvmat-enhanced.rb"

# 同じ大きさの２つの画像を、グリッド化する。
# グリッド化された画像同士を比較して、MSE value を算出する。

# -------------------------------------
#  Configuration
# -------------------------------------

a_image = "paintLittle.jpg"
b_image = "result.png"
numberOfPertitions = {
  width: 1,
  height: 2
}
# -------------------------------------
# メイン処理
# -------------------------------------

a_Mat = OpenCV::CvMat.load a_image
b_Mat = OpenCV::CvMat.load b_image
unless a_Mat.isTheSameSizeOf b_Mat
  p "同じ画像を指定してください。"
  return false
end
if a_Mat.isGriddable numberOfPertitions
  gridedImagesA = a_Mat.gridize numberOfPertitions
  gridedImagesB = b_Mat.gridize numberOfPertitions
  results = []
  for i in 0...(gridedImagesA.length)
    gridA = gridedImagesA[i][:mat]
    gridB = gridedImagesB[i][:mat]
    mse = gridA.calcMSE_color gridB
    results.push result = {
      x: gridedImagesA[i][:x],
      y: gridedImagesA[i][:y],
      width: gridA.width,
      height: gridB.height,
      mse: mse
    }
  end
  puts results
end

