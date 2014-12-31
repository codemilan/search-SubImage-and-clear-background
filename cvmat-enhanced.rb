require "opencv"

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
