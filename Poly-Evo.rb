=begin



=end
require 'rubygems'
require 'RMagick'
require 'PolyImg'
include Magick
include Math

Start_time = Time.now

Max = 100
Pop = 100
gen = 1

cat = ImageList.new("Flower_Hat.jpg")
Xlim = cat.cur_image.columns
Ylim = cat.cur_image.rows

tri = PolyImg.new()
tri.randomize()

for i in 1..10 do 
    newtri = tri.copy()
	#puts newtri.inspect

    newtri.mutate() 
	canvas = newtri.draw(cat)	
	
	if newtri.dif <= tri.dif then
	  tri = newtri
	  sgen = gen.to_s
	  sgen = '0'+sgen while sgen.length < 5
	  fn = "out/test#{sgen}.jpg"
      canvas.write(fn)
	  puts newtri.dif.to_s+' '+fn
	  gen += 1	  
	end
end

#puts pols.inspect

puts "Runtime: #{Time.now - Start_time} sec"

