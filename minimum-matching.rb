require "opencv"

# 目的
#   ２つの画像 a, b (a < b) において、b 内に a に近い画像が含まれているとき、どの位置にあるのか探索する。位置を c とする。
#   imagemagick を用いて、黒で塗りつぶした画像 d を用意する。
#   b に上で求めた c 位置 で a サイズ分切り取り、c で和をとることで、b の背景はすべて白になる。


# -------------------------------------
#  拡張
# -------------------------------------


class OpenCV::CvMat
  # ピクセルを入力すると、その位置の rgb をハッシュで返すメソッド
  def getRGB(x, y)
    blue, green, red = self.at(y - 1, x - 1).to_a
    return {
      blue: blue,
      green: green,
      red: red
    }
  end
  # ピクセルを入力すると、その位置が 白 かどうか判定するメソッド
  def isWhite(x, y)
    blue, green, red = self.at(y - 1, x - 1).to_a
    [blue, green, red] == [255.0, 255.0, 255.0]
  end
  # isValidAndSmallerThan かどうか判定するメソッド
  def isValidAndSmallerThan(b)
    reWidth = self.width
    reHeight = self.height
    roWidth = b.width
    roHeight = b.height
    unless reHeight or roHeight or reWidth or roWidth
      p "まともな画像じゃないんでだめ。"
      return false
    end
    if reHeight > roHeight and reWidth > roWidth
      p "なんでターゲットが小さいんだよ！"
      return false
    end
    if (reWidth - roWidth) * (reHeight - roHeight) < 0
      p "ターゲットを十分に大きな画像にしてください。"
      return false
    end
    return true
  end
  # 対象画像において、ある位置からピクセル単位で探索し、誤差の和と開始位置を含めたハッシュを返すメソッド
  def evaluateDegreeOfSimilarity(bigImage, x, y)
    a = self
    b = bigImage

    error = 0
    counter = 0

    for dx in 1..(a.width)
      for dy in 1..(a.height)
        error += (a.getRGB(dx, dy)[:blue] - b.getRGB(x + dx, y + dy)[:blue]).abs
        counter += 1
      end
    end

    result = {
      x: x,
      y: y,
      diff: error / counter
    }
  end
  # 画像がどの位置に存在していそうかを計算するメソッド
  def placesAt(bigImage)

    a = self
    b = bigImage

    searchWidth = b.width - a.width + 1
    searchHeight = b.height - a.height + 1

    results = []
    for x in 0...searchWidth
      for y in 0...searchHeight
        results.push a.evaluateDegreeOfSimilarity(b, x, y)
      end
    end
    results.min_by do |result|
      result[:diff]
    end
  end
end

# -------------------------------------
# メイン処理
# -------------------------------------

# read constructed image
reconstructer = OpenCV::CvMat.load("paintLittle.jpg")
# read target image
rough = OpenCV::CvMat.load("paintBig.jpg")
# main
if reconstructer.isValidAndSmallerThan rough
  # 場所を探索
  place = reconstructer.placesAt rough
  # 物体を黒で塗りつぶした画像を求める。
  preboundary = OpenCV::CvMat.load("paintLittle-th.jpg")
  # 探索結果を用いて切り取る。
  clipped = rough.sub_rect place[:x], place[:y], reconstructer.width, reconstructer.height
  # 探索結果 + 黒塗り画像
  view = preboundary.add clipped
  # 保存
  view.save_image("result.png")
end

# -------------------------------------
# 他に使えそうなコマンド
# -------------------------------------
# CvMat#BGRTOGRAY
# -------------------------------------
# 以下は駄文
# -------------------------------------

# bin = reconstructer.threshold(0, 255, OpenCV::CV_THRESH_BINARY | OpenCV::CV_THRESH_OTSU)

# 近似対象の輪郭線を取得
# contours = bin.find_contours(:mode => OpenCV::CV_RETR_EXTERNAL)
# CvContour#approx_poly(approx_poly_option)
# 引数：
#   approx_poly_option (Hash)…近似オプション
#     :method - 近似手法。Douglas-Peuckerアルゴリズム(:dp)のみ。[cvApproxPolyの引数methodに対応]
#     :accuracy - Douglas-Peuckerアルゴリズムの近似精度[cvApproxPolyの引数parameterに対応]
#     :recursive - trueなら全部近似、falseなら1つのシーケンスのみ近似[cvApproxPolyの引数parameter2に対応]
# 戻り値：
#   近似された折れ線(CvContour)
# poly = contours.approx_poly(
#   :method => :dp,
#   :accuracy => 2.0,
#   :recursive => true
# )
# # (4)描画して表示
# begin
#   reconstructer.draw_contours!(
#     poly,
#     OpenCV::CvColor::Blue,
#     OpenCV::CvColor::Black,
#     2,
#     :thickness => 1,
#     :line_type => :aa
#   )
# end while (poly = poly.h_next)
# window = OpenCV::GUI::Window.new('approx_poly')
# window.show reconstructer
# OpenCV::GUI::wait_key




# 参考
# cvmat = cvmat.BGR2GRAY
# #.threshold(200, 255, CV_ADAPTIVE_THRESH_MEAN_C)

# canny = cvmat.canny(160, 200)
# contour = canny.find_contours(
#   :mode => OpenCV::CV_RETR_LIST,
#   :method => OpenCV::CV_CHAIN_APPROX_SIMPLE
# )
# while contour
#   unless contour.hole?
#     box = contour.bounding_rect
#     if(box.top_right.x-box.top_left.x > cvmat.width*0.8 &&
#          box.bottom_right.y-box.top_right.y > cvmat.height*0.8)
#       cvmat.rectangle! box.top_left, box.bottom_right, :color => OpenCV::CvColor::Gray, :thickness => 2
#       crop_box= box;
#       p "detect"
#     end
#   end
#   contour = contour.h_next
# end
# cvmat.save_image("detect.jpg")