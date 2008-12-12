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

cat = ImageList.new("Fruit_Candles.jpg")
Xlim = cat.cur_image.columns
Ylim = cat.cur_image.rows

pop = Array.new(MaxPop) { |img| img = PolyImg.new(); img.randomize(); img.draw(cat); img }

for i in 1..100000 do 
    complist = []
    complist = [rand(MaxPop),rand(MaxPop),rand(MaxPop)] until complist.uniq.length == 3
	
	complist.sort! {|x,y| pop[x].dif <=> pop[y].dif }
	
	pop[complist[2]] = pop[complist[1]].copy(pop[complist[0]])
	pop[complist[2]].mutate()
	canvas = pop[complist[2]].draw(cat)
	
	puts [complist+[pop[complist[2]].dif]].inspect

	if i % 100 == 50 then
	  sgen = gen.to_s
	  sgen = '0'+sgen while sgen.length < 5
	  fn = "out/test#{sgen}.jpg"
      canvas.write(fn)
	  puts fn
	  gen += 1	  
	end

end

#puts pols.inspect

fn = "out/final.jpg"
canvas.write(fn)


puts "Runtime: #{Time.now - Start_time} sec"

