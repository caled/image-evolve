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
best = 3000
polyFile = 'out/Poly.txt'

cat = ImageList.new("mona_lisa.jpg").minify.minify
Xlim = cat.cur_image.columns
Ylim = cat.cur_image.rows

pop = Array.new(MaxPop) { |img| img = PolyImg.new(); img.randomize(); img.mutate(); img }
pop[0].load(polyFile) if File::exists?( polyFile )
pop.each {|img| img.drawcompare(cat); }

cMutations, cGoodMutations = 0,0
for i in 1..10000000 do 
	pop.sort!{|x,y| x.dif <=> y.dif }
	
	pop[1] = pop[0].copy
	pop[1].mutate()
	pop[1].drawcompare(cat)
	cMutations += 1
	cGoodMutations += 1 if pop[1].dif < pop[0].dif
	
	#puts (complist+[pop[complist[0]].dif]).inspect

	print('.') if i % 10 == 0
	
	if i % 500 == 0 then #Write an image
	    puts
		puts "#{cGoodMutations} of #{cMutations} mutations used"
		cMutations, cGoodMutations = 0,0
		pop.sort! {|x,y| x.dif <=> y.dif }
		if pop[0].dif < best then 
			best = pop[0].dif			
		  	puts "Score: #{best*10000}"
			begin
				fn = "out/evo#{('00000'+gen.to_s)[-5..-1]}.jpg"
				gen += 1	  
			end while File::exists?( fn )
			
	 	    pop[0].drawgood.write(fn)
			pop[0].save(polyFile)
			puts fn
			
			  #f = File.new("out/best.svg", File::CREAT|File::TRUNC|File::WRONLY)
	          #f.write(pop[0].getsvg)		  
		end
	end
end

#puts pols.inspect

fn = "out/final.jpg"
canvas.write(fn)


puts "Runtime: #{Time.now - Start_time} sec"

