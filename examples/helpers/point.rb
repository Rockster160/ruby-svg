SVG.register(:point, :x, :y) do |svg, x, y, **attrs|
  attrs[:fill] ||= svg.stroke || :black
  attrs[:stroke] ||= svg.fill || :none
  r ||= attrs.delete(:r) || 1

  svg.circle(x, y, r, **attrs)
end
