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
best = 3000

cat = ImageList.new("mona_lisa.jpg").minify.minify
Xlim = cat.cur_image.columns
Ylim = cat.cur_image.rows

pop = Array.new(MaxPop) { |img| img = PolyImg.new(); img.randomize(); img.mutate(); img.drawcompare(cat); img }

for i in 1..10000000 do 
    complist = []
    complist = [rand(MaxPop),rand(MaxPop),rand(MaxPop)] until complist.uniq.length == 3
	
	complist.sort! {|x,y| pop[x].dif <=> pop[y].dif }
	
	pop[complist[2]] = pop[complist[0]].copy
	pop[complist[2]].mutate()
	pop[complist[2]].drawcompare(cat)
	
	#puts (complist+[pop[complist[0]].dif]).inspect

	print('.') if i % 10 == 0
	
	if i % 100 == 0 then
	    puts
		pop.sort! {|x,y| x.dif <=> y.dif }
		if pop[0].dif < best then 
		  best = pop[0].dif			
	  	  puts best
		  fn = "out/test#{('00000'+gen.to_s)[-5..-1]}.jpg"
 	      pop[0].drawgood.write(fn)
		  puts fn
		  gen += 1	  
	  end
	end

end

#puts pols.inspect

fn = "out/final.jpg"
canvas.write(fn)


puts "Runtime: #{Time.now - Start_time} sec"

