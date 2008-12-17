=begin



=end
require 'rubygems'
require 'RMagick'
require 'PolyImg'
include Magick
include Math

Start_time = Time.now

Max = 100
MaxPop = 10
gen = 1

cat = ImageList.new("mona_lisa.jpg").minify.minify
Xlim = cat.cur_image.columns
Ylim = cat.cur_image.rows

pop = Array.new(MaxPop) { img = PolyImg.new(); img.randomize(); img.draw(cat); img }

canvas = pop[0].draw(cat)	
canvas.write("out/test1.jpg")

100.times { |t|
	pop[0].mutate()
	canvas = pop[0].draw(cat)
	canvas.write("out/final#{('000'+t.to_s)[-3..-1]}.jpg")
}

pop[1] = pop[0].copy()
canvas = pop[1].draw(cat)	
canvas.write("out/test2.jpg")

puts "Runtime: #{Time.now - Start_time} sec"

