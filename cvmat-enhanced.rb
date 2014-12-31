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
  def calcMSE_color(theSameSizeImage)
    a = self
    b = theSameSizeImage

    mse = 0
    for x in 1..(a.width)
      for y in 1..(a.height)
        dr = a.getRGB(x, y)[:red] - b.getRGB(x, y)[:red]
        db = a.getRGB(x, y)[:blue] - b.getRGB(x, y)[:blue]
        dg = a.getRGB(x, y)[:green] - b.getRGB(x, y)[:green]
        mse = dr ** 2 + db ** 2 + dg ** 2
      end
    end
    mse /= 3 * a.width * a.height
  end
  def isGriddable(pertitions)
    numW = pertitions[:width].to_i
    numH = pertitions[:height].to_i
    a = self

    unless a.width % numW == 0 and a.height % numH == 0
      p "grid number ... ng"
      p "a.width is #{a.width}, parseNum is #{numW}"
      p "a.height is #{a.height}, parseNum is #{numH}"
      return false
    end
    p "grid number ... ok"
    return true
  end
  def gridize(pertitions)
    numW = pertitions[:width].to_i
    numH = pertitions[:height].to_i
    a = self
    perWidth = a.width / numW
    perHeight = a.height / numH

    results = []
    for x in 0...(numW)
      for y in 0...(numH)
        posX = x * perWidth
        posY = y * perHeight
        mat = a.sub_rect posX, posY, perWidth, perHeight
        result = {
          x: posX,
          y: posY,
          mat: mat
        }
        results.push result
      end
    end
    return results
  end
end
