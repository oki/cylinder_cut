#!/usr/bin/env ruby

# bundle install
# ./test_it.rb

require "rubygems"
require "bundler/setup"
require "pp"

Bundler.require

require "prawn/measurement_extensions"
Prawn::Font::AFM.hide_m17n_warning = true

pdf = Prawn::Document.new(
  page_layout: :landscape,
  page_size: "A4",
  margin: 0.6.cm
)

pdf.stroke_axis(step_length: 5.cm.to_i)

cylinder_r = 4.5
cylinder_h = 9.5
circumference = 2 * Math::PI * cylinder_r
parts_n = 24
section_len = (circumference / parts_n)
angle = 30
partial_angle = 360 / parts_n.to_f
partial_angle2 = (180 - partial_angle) / 2.0

up_h = Math.tan((angle * Math::PI) / 180.0) * (2 * cylinder_r)
down_h = cylinder_h - up_h

puts "circumference: #{circumference}"
puts "parts_n: #{parts_n}"
puts "section_len: #{section_len}"
puts "up_h: #{up_h}"
puts "down_h: #{down_h}"
puts "partial_angle: #{partial_angle}"
puts "partial_angle2: #{partial_angle2}"

tmp_angle = 180
x = Math.cos((((180 - tmp_angle) / 2.0) * Math::PI) / 180.0) * Math.sqrt(( (2 * cylinder_r ** 2)) * (1 - Math.cos((tmp_angle * Math::PI) / 180.0)))

puts "x: #{x}"

# exit 0

pdf.stroke do
  pdf.stroke_color "ff0000"

  # pdf.horizontal_line 0, cylinder_r.send(:cm), at: 0
  # pdf.horizontal_line 0, cylinder_h.send(:cm), at: 10
  pdf.horizontal_line 0, circumference.send(:cm), at: 0

  puts "lines:"
  h_points_prev, x_points_prev = nil

  pdf.stroke_color "000000"
  0.upto(parts_n) do |n|
    tmp_angle = partial_angle * n

    x = Math.cos((((180 - tmp_angle) / 2.0) * Math::PI) / 180.0) * Math.sqrt(( (2 * cylinder_r ** 2)) * (1 - Math.cos((tmp_angle * Math::PI) / 180.0)))
    h = cylinder_h - Math.tan((angle * Math::PI) / 180.0) * x

    h_points = h.send(:cm)
    x_points = (n * section_len).cm

    puts "tmp_angle: #{tmp_angle} - #{n * section_len} (x: #{x}) (h: #{h.round(2)})"

    pdf.vertical_line 0, h_points, at: x_points


    if (h_points_prev && x_points_prev)
      pdf.line [x_points, h_points], [x_points_prev, h_points_prev]
    end

    h_points_prev = h_points
    x_points_prev = x_points
    # 9.5 - Math.tan((30 * Math::PI) / 180.0) * 2.25
    # cylinder_h - Math.tan((angle * Math::PI) / 180.0) * 2.25
  end
end


pdf.stroke_rectangle [20, 500], 200, 100

info_box=%Q(
cylinder r = #{cylinder_r} cm
cylinder h = #{cylinder_h} cm
angle cut = #{angle} °
parts = #{parts_n}
step length = #{section_len.round(3)} cm
up_h = #{up_h.round(3)} cm
down_h = #{down_h.round(3)} cm
)

pdf.text_box info_box, at: [20+5, 500-5], width: 200, size: 8

pdf.render_file 'test.pdf'
system("open test.pdf")
