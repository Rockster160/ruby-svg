# frozen_string_literal: true

require_relative "svg/version"

class SVG
  class Error < StandardError; end

  attr_accessor(
    :filename, :tag, :attrs,
    :minx, :miny, :width, :height,
    :items, :stroke, :fill
  )

  def self.open(tag=:svg, opts={}, &block)
    new(tag, opts, &block).open
  end

  def self.write(tag=:svg, opts={}, &block)
    new(tag, opts, &block).write
  end

  def self.register(method_name, &block)
    define_method(method_name) do |*attrs|
      block.call(self, *attrs)
    end
  end

  # Allows setting any attrs directly from the instance
  def method_missing(method, *args, &block)
    super unless method.to_s.end_with?("=")

    @attrs[method.to_s[0..-2].to_sym] = args.first
  end

  def initialize(tag, opts={}, &block)
    @attrs = opts[:attrs] || {}
    if tag == :svg
      # Use `self.` since it will auto set the `attr` as an ivar
      self.fill = :transparent
      self.stroke = :black
    end
    @tag = tag
    @filename = (opts[:filename] || :svg).to_s.gsub(/\.svg$/, "")
    @content = opts[:content]
    @minx, @miny, @width, @height = opts[:minx] || 0, opts[:miny] || 0, opts[:width] || 100, opts[:height] || 100
    @items = []

    block&.call(self)
  end

  def g(**attrs, &block)
    @items << SVG.new(:g, attrs: attrs, &block)
  end
  def path(d, **attrs, &block)
    @items << SVG.new(:path, attrs: attrs.merge(d: d), &block)
  end
  def text(str, x, y, **attrs, &block) # https://developer.mozilla.org/en-US/docs/Web/SVG/Element/text
    escaped = str.to_s.gsub("<", "&lt;").gsub(">", "&gt;")
    @items << SVG.new(:text, attrs: attrs.merge(x: x, y: y), content: escaped, &block)
  end
  def rect(x, y, width, height, **attrs, &block)
    @items << SVG.new(:rect, attrs: attrs.merge(x: x, y: y, width: width, height: height), &block)
  end
  def circle(x, y, r, **attrs, &block)
    @items << SVG.new(:circle, attrs: attrs.merge(cx: x, cy: y, r: r), &block)
  end
  def line(x1, y1, x2, y2, **attrs, &block)
    @items << SVG.new(:line, attrs: attrs.merge(x1: x1, y1: y1, x2: x2, y2: y2), &block)
  end
  def ellipse(cx, cy, rx, ry, **attrs, &block)
    @items << SVG.new(:ellipse, attrs: attrs.merge(cx: cx, cy: cy, rx: rx, ry: ry), &block)
  end
  def polyline(*points, **attrs, &block)
    block_called = false
    points = points.presence || block.call.then { |block_points|
      next block_points if block_points.is_a?(String)
      next unless block_points.is_a?(Array)

      block_points.filter_map { |block_point|
        case block_point
        when String then block_point
        when Array then block_point.join(",")
        when Hash then "#{block_point[:x]},#{block_point[:y]}"
        end
      }.join(" ")
    }&.tap { block_called = true }
    block = nil if block_called
    @items << SVG.new(:polyline, attrs: attrs.merge(points: points), &block)
  end
  def polygon(*points, **attrs, &block)
    @items << SVG.new(:polygon, attrs: attrs.merge(points: points), &block)
  end
  def item(tag, **attrs, &block)
    @items << SVG.new(tag, attrs: attr, &block)
  end
  # <animate attributeName="|" attributeType="" begin="0" end="" from="" to="" dur="" repeatCount="" fill=""/>

  def html_tag(tag, n, **attrs, &block)
    # TODO: Need to escape attr vals, in case they have quotes in them
    attr_str = attrs.map { |k,v| "#{k}=\"#{v}\"" }.join(" ")
    content = block&.call
    no_content = content.gsub(/\s/, "").length == 0
    # content.gsub(/\s/, "").length == 0 ? "" : "\n  #{content}\n"
    if no_content
      "<#{tag} #{attr_str} />"
    else
      "<#{tag} #{attr_str}>\n#{content}\n#{"  "*n}</#{tag}>"
    end
  end

  def to_svg(n=0)
    if @tag == :svg
      @attrs = {
        xmlns: "http://www.w3.org/2000/svg",
        viewBox: [@minx, @miny, @width, @height].join(" "),
      }.merge(@attrs)
    end
    @attrs = @attrs.transform_keys { |sym| sym.to_s.split("_").join("-") }

    html_tag(@tag, n, **@attrs) {
      [@content, *items.map { |i| i.to_svg(n+1) }].filter_map { |i|
        next if i.to_s.gsub(/\s/, "").length == 0
        "#{"  "*(n+1)}#{i}"
      }.join("\n")
    }
  end

  def save_as(filename)
    write(filename)
  end

  def write(filename=@filename)
    File.open("#{@filename}.svg", "w") { |file| file.write(to_svg) }
  end

  def open
    write
    default_browser = `defaults read com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers | sed -n -e "/LSHandlerURLScheme = https;/{x;p;d;}" -e 's/.*=[^"]"\\(.*\\)";/\\1/g' -e x`.strip
    `open -b #{default_browser} '#{@filename}.svg' && sleep 2 && rm '#{@filename}.svg'`
  end
end

# SVG.open(:svg) do |svg| - alternative syntax. Automatically opens the SVG after creation.
# SVG.new(:svg) do |svg|
#   svg.minx = -5
#   svg.miny = -105
#   svg.width = 110
#   svg.height = 110
#
#   svg.circle(5, -5, 5)
#   svg.grid(svg.minx, svg.miny, svg.width, svg.height)
# end

# SVG.new(:svg, filename: "my svg") do |svg|
#   svg.stroke = "black"
#   svg.fill = "transparent"
#   svg.g(id: "sup") do |g|
#     g.rect(5, 5, 90, 90)
#     g.text("Words", 10, 5)
#     g.rect(0, 0, 50, 50)
#     g.g do |g|
#       g.text("More Words", 5, 20)
#     end
#   end
# end

# SVG.register(:point) do |svg, attrs|
#   attrs[:fill] ||= svg.stroke || :black
#   attrs[:stroke] ||= svg.fill || :none
#
#   svg.circle(**attrs.merge(cx: x, cy: y, r: r))
# end
#
# SVG.register(:bezier) do |svg, attrs|
#   p1, b1, b2, p2 = attrs.slice(:p1, :b1, :b2, :p2).values
#   path = [:M, p1.join(","), :C, *[b1, b2, p2].map { |c| c.join(",") }]
#   puts "\e[36m#{path.join(" ")}\e[0m"
#   svg.path(path.join(" "), **attrs)
#
#   svg.line(*p1, *b1, stroke: :cyan,  opacity: 0.6)
#   svg.point(*b1,     fill:   :cyan,  opacity: 0.4)
#   svg.point(*p1,     fill:   :blue,  opacity: 0.4)
#
#   svg.line(*b2, *p2, stroke: :lime,  opacity: 0.6)
#   svg.point(*b2,     fill:   :lime,  opacity: 0.4)
#   svg.point(*p2,     fill:   :green, opacity: 0.4)
# end
# SVG.register(:spiral) do |svg, attrs|
#   center_x = svg.width/2
#   center_y = svg.height/2
#   max_rev = attrs.delete(:max_rev) || 10
#   progress = attrs.delete(:progress) || 1
#   outer_radius = attrs.delete(:size) || [center_x, center_y].min
#
#   # line_width = (max_radius/(max_rev+1).to_f)-1
#   # padding = max_line_width
#   # outer_radius = max_radius - padding
#   # line_width = (outer_radius/max_rev.to_f)-1
#
#   path = ["M#{center_x},#{center_y-outer_radius}"] # Starting at top-center
#   (0..max_rev * 360).step(1).each do |angle|
#     rotation = 90
#     radians = (angle - rotation) * (Math::PI / 180)
#     radius = outer_radius * (1 - (angle.to_f / (max_rev*360)))
#
#     x = center_x + radius * Math.cos(radians)
#     y = center_y + radius * Math.sin(radians)
#     path << "L#{x},#{y} "
#
#     break if angle.to_f > (progress*360)
#   end
#   path.join(" ")
#
#   svg.path(path.join(" "), **attrs)
# end
