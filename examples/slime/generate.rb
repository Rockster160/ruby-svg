require "ruby-svg"

# You can include helpers externally!
require_relative "../helpers/point"

# Or build them inline
SVG.register(:bezier_helper, :p1, :b1, :b2, :p2) do |svg, p1, b1, b2, p2, **attrs|
  path_cmd = [:M, p1.join(","), :C, *[b1, b2, p2].map { |c| c.join(",") }]
  # puts "\e[36m#{path.join(" ")}\e[0m"
  svg.path(path_cmd.join(" "), **attrs)

  svg.line(*p1, *b1, stroke: :cyan,  opacity: 0.6)
  svg.point(*b1,     fill:   :cyan,  opacity: 0.4)
  svg.point(*p1,     fill:   :blue,  opacity: 0.4)

  svg.line(*b2, *p2, stroke: :lime,  opacity: 0.6)
  svg.point(*b2,     fill:   :lime,  opacity: 0.4)
  svg.point(*p2,     fill:   :green, opacity: 0.4)
end

# And use them right away!
SVG.write(:svg, filename: :slime) do |svg|
  svg.width = 100
  svg.height = 100

  svg.path(
    "M 5 65
      C  0,110 100,110 95,65
      C 90,40   60,45  55,15
      C 53,5    47,5   45,15
      C 40,45   10,40   5,65
    Z",
    id: :slimeBody,
    stroke: "#0160FF",
    fill: "#0160FFAA",
  )
  # The bezier helpers draw the bezier lines/points so you can visually see the curve
  # svg.bezier_helper([55,15], [53,5], [47,5], [45,15])
  svg.bezier_helper([95,65], [90,40], [60,45], [55,15])
  # svg.bezier_helper([45,15], [40,45], [10,40], [5,65])

  svg.path(
    "M 25,75 C 30,90 70,90 75,75",
    id: :smile,
    stroke: :red,
    stroke_width: 7,
    stroke_linecap: :round,
  )
  # svg.bezier_helper([25,75], [30,90], [70,90], [75,75], stroke: :red, stroke_width: 7, stroke_linecap: :round)

  # eyes
  eye = ->(x) {
    svg.circle(x, 60, 8, stroke: :transparent, fill: :white)
    svg.circle(x, 60, 2.5, stroke: :transparent, fill: :black)
  }
  eye[37]
  eye[63]
end
