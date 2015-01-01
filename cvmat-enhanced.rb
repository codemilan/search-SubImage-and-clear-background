require "opencv"

def progress_bar(i, max = 100)
  i = i.to_f
  max = max.to_f
  i = max if i > max
  percent = i / max * 100.0
  rest_size = 1 + 5 + 1 # space + progress_num + %
  bar_size = 79 - rest_size # (width - 1) - rest_size
  bar_str = '%-*s' % [bar_size, ('#' * (percent * bar_size / 100).to_i)]
  progress_num = '%3.1f' % percent
  print "\r#{bar_str} #{'%5s' % progress_num}%"
end

class OpenCV::CvMat
  def get_rgb(x, y)
    blue, green, red = self.at(y - 1, x - 1).to_a
    return {
      blue: blue,
      green: green,
      red: red
    }
  end

  def white?(x, y)
    blue, green, red = self.at(y - 1, x - 1).to_a
    [blue, green, red] == [255.0, 255.0, 255.0]
  end

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
    c = a.abs_diff b
    ########################################
    # new method
    ########################################
    error = 0
    error = c.split.inject(0) do |sum, c_parsed|
      multipled = c_parsed.mul c_parsed
      sum + multipled.sum.to_ary[0]
    end
    ########################################
    # old method
    ########################################
    # error = 0
    # try_x = a.width.to_i
    # try_y = a.height.to_i
    # (1..try_x).each do |x|
    #   (1..try_y).each do |y|
    #     error += (c.get_rgb(x, y)[:green]).abs ** 2
    #   end
    # end

    return error
  end

  def placesAt(bigImage)
    a = self
    b = bigImage

    searchWidth = b.width - a.width + 1
    searchHeight = b.height - a.height + 1
    num_try = (searchHeight) * (searchWidth)
    sub_rect_width = a.width
    sub_rect_height = a.height

    results = []
    counts = 0
    (0...searchWidth).each do |x|
      (0...searchHeight).each do |y|
        target = b.sub_rect x, y, sub_rect_width, sub_rect_height
        diff = a.getDegreeOfDiff target
        results.push result = {
          x: x,
          y: y,
          diff: diff
        }
        counts += 1
        progress_bar counts, num_try
      end
    end
    print "\n"
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
        dr = a.get_rgb(x, y)[:red] - b.get_rgb(x, y)[:red]
        db = a.get_rgb(x, y)[:blue] - b.get_rgb(x, y)[:blue]
        dg = a.get_rgb(x, y)[:green] - b.get_rgb(x, y)[:green]
        mse = dr ** 2 + db ** 2 + dg ** 2
      end
    end
    mse /= 3 * a.width * a.height
  end

  def griddable?(pertitions)
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
