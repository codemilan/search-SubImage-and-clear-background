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

  def smallerThan?(image)
    a = self
    b = image

    return false unless a.valid? or b.valid?
    if a.height < b.height and a.width < b.width
      return true
    else
      return false
    end
  end

  def valid?
    a = self
    if a.height * a.width > 0
      return true
    else
      return false
    end
  end

  def calculate_degree_of_diff(same_size_image)
    a = self
    b = same_size_image
    c = a.abs_diff b
    ########################################
    # 緑単色
    ########################################
    blue, green, red = c.split
    multipled = green.mul green
    error = multipled.sum.to_ary[0]
    ########################################
    # 全色
    ########################################
    # error = c.split.inject(0) do |sum, c_parsed|
    #   multipled = c_parsed.mul c_parsed
    #   sum + multipled.sum.to_ary[0]
    # end

    return error
  end

  def placesAt(bigImage)
    a = self
    b = bigImage

    search_width = b.width - a.width + 1
    search_height = b.height - a.height + 1
    num_try = (search_height) * (search_width)
    sub_rect_width = a.width
    sub_rect_height = a.height

    results = []
    counts = 0
    (0...search_width).each do |x|
      (0...search_height).each do |y|
        target = b.sub_rect x, y, sub_rect_width, sub_rect_height
        diff = a.calculate_degree_of_diff target
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

  def has_identical_size?(image)
    a = self
    d = image

    if a.width == d.width and a.height == d.height
      return true
    else
      p "a 画像と同じ大きさの d 画像を指定してください。"
      return false
    end
  end

  def calculate_MSE(same_size_image)
    a = self
    b = same_size_image
    c = a.abs_diff b

    mse = c.split.inject(0) do |sum, c_parsed|
      multipled = c_parsed.mul c_parsed
      sum + multipled.sum.to_ary[0]
    end

    mse /= 3 * a.width * a.height
  end

  def griddable?(pertitions)
    num_w = pertitions[:width].to_i
    num_h = pertitions[:height].to_i
    a = self

    unless a.width % num_w == 0 and a.height % num_h == 0
      p "grid number ... ng"
      p "a.width is #{a.width}, parseNum is #{num_w}"
      p "a.height is #{a.height}, parseNum is #{num_h}"
      return false
    end
    p "grid number ... ok"
    return true
  end

  def gridize(pertition)
    num_w = pertition[:width].to_i
    num_h = pertition[:height].to_i
    a = self
    per_width = a.width / num_w
    per_height = a.height / num_h

    results = []
    (0...(num_w)).each do |x|
      (0...(num_h)).each do |y|
        pos_x = x * per_width
        pos_y = y * per_height
        mat = a.sub_rect pos_x, pos_y, per_width, per_height
        result = {
          x: pos_x,
          y: pos_y,
          mat: mat
        }
        results.push result
      end
    end
    return results
  end
end
