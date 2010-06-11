=begin



=end
require 'rubygems'
require 'RMagick'
require 'PolyImg'
include Magick
include Math

Start_time = Time.now

Max = 100
MaxPop = 2
gen = 1

cat = ImageList.new("mona_lisa.jpg").minify.minify
Xlim = cat.cur_image.columns
Ylim = cat.cur_image.rows

pop = Array.new(MaxPop) { img = PolyImg.new(); img.randomize(); img.drawcompare(cat); img }

canvas = pop[0].drawgood
canvas.write("out/test1.jpg")

500.times { pop[0].mutate() }
100.times { |t|
	pop[0].mutate()
	canvas = pop[0].drawgood
	canvas.write("out/test#{('000'+t.to_s)[-3..-1]}.jpg")
}

pop[1] = pop[0].copy()
canvas = pop[1].drawgood
canvas.write("out/test2.jpg")

f = File.new("out/test.svg", File::CREAT|File::TRUNC|File::RDWR)
f.write(pop[0].getsvg)


puts "Runtime: #{Time.now - Start_time} sec"

