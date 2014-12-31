require "opencv"

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
#  拡張
# -------------------------------------


class OpenCV::CvMat
  # ピクセルを入力すると、その位置の rgb をハッシュで返す。
  def getRGB(x, y)
    blue, green, red = self.at(y - 1, x - 1).to_a
    return {
      blue: blue,
      green: green,
      red: red
    }
  end
  # ピクセルを入力すると、その位置が 白 かどうか判定する。
  def isWhite(x, y)
    blue, green, red = self.at(y - 1, x - 1).to_a
    [blue, green, red] == [255.0, 255.0, 255.0]
  end
  # isValidAndSmallerThan かどうか判定する。
  def isValidAndSmallerThan(image)
    a = self
    b = image

    unless a.height or b.height or a.width or b.width
      p "a, b に妥当な画像を指定してください。"
      return false
    end
    if a.height > b.height and a.width > b.width
      p "大きな b 画像を指定してください。"
      return false
    end
    if (a.width - b.width) * (a.height - b.height) < 0
      p "十分に大きな b 画像を指定してください。"
      return false
    end
    return true
  end
  def getDegreeOfDiff(image)
    a = self
    b = image

    error = 0

    for x in 1..(a.width)
      for y in 1..(a.height)
        error += (a.getRGB(x, y)[:green] - b.getRGB(x, y)[:green]).abs ** 2
      end
    end

    return error
  end
  # 画像がどの位置に存在していそうかを計算する。
  def placesAt(bigImage)
    a = self
    b = bigImage

    searchWidth = b.width - a.width + 1
    searchHeight = b.height - a.height + 1

    results = []
    for x in 0...searchWidth
      for y in 0...searchHeight
        target = b.sub_rect x, y, a.width, a.height
        diff = a.getDegreeOfDiff target
        results.push result = {
          x: x,
          y: y,
          diff: diff
        }
      end
    end
    results.min_by do |result|
      result[:diff]
    end
  end
  def isTheSameSizeOf(image)
    a = self
    d = image

    if a.width == d.width and a.height == d.height
      return true
    else
      p "a 画像と同じ大きさの d 画像を指定してください。"
      return false
    end
  end
end

# -------------------------------------
# メイン処理
# -------------------------------------

# read constructed image
reconstructer = OpenCV::CvMat.load(a_image)
# read target image
rough = OpenCV::CvMat.load(b_image)
# main
if reconstructer.isValidAndSmallerThan rough
  # 場所を探索
  place = reconstructer.placesAt rough
  # read black constructed image
  preboundary = OpenCV::CvMat.load(d_image)

  if preboundary.isTheSameSizeOf reconstructer
    clipped = rough.sub_rect place[:x], place[:y], reconstructer.width, reconstructer.height
    view = preboundary.add clipped
    view.save_image result_image
    puts "result image has been saved at #{result_image}"
  end
end