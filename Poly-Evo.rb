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

cat = ImageList.new("img/Flower_Hat.jpg")
Xlim = cat.cur_image.columns
Ylim = cat.cur_image.rows

pols = Array.new(Max) { |e| 
  x,y = rand(Xlim),rand(Ylim)
  e = [x,y, x,y,x,y] +
      [rand(1000),rand(1000),rand(1000),10]
}
dif = 200

for i in 1..1000000 do 
	circle = Magick::Draw.new
	circle.stroke_width(0)
	
	newpols = Array.new(Max)
	newpols.each_index {|i| newpols[i] = pols[i].dup}
	
	newpols.each { |pol| 
	    pol[0] = [0,pol[0]+rand(5)-2,Xlim].sort[1]
	    pol[1] = [0,pol[1]+rand(5)-2,Ylim].sort[1]
	    pol[2] = [0,pol[2]+rand(5)-2,Xlim].sort[1]
	    pol[3] = [0,pol[3]+rand(5)-2,Ylim].sort[1]
	    pol[4] = [0,pol[4]+rand(5)-2,Xlim].sort[1]
	    pol[5] = [0,pol[5]+rand(5)-2,Ylim].sort[1]
		
	    pol[6] = [0,pol[6]+rand(5)-2,1000].sort[1]
	    pol[7] = [0,pol[7]+rand(5)-2,1000].sort[1]
	    pol[8] = [0,pol[8]+rand(5)-2,1000].sort[1]
	    pol[9] = [10,pol[9]+rand(5)-2,100].sort[1]
	 
		circle.fill("rgb(#{0.1*pol[6]}%,#{0.1*pol[7]}%,#{0.1*pol[8]}%)")
		circle.fill_opacity(0.01*pol[9])
		circle.polygon(pol[0],pol[1],pol[2],pol[3],pol[4],pol[5])
	}

	canvas = Magick::ImageList.new
	canvas.new_image(Xlim, Ylim) {  
	  self.background_color = "rgb(#{0.1*newpols[0][6]}%,#{0.1*newpols[0][7]}%,#{0.1*newpols[0][8]}%)" 
	}
	
	circle.draw(canvas)

	newdif = canvas.compare_channel(cat,MeanSquaredErrorMetric)[1]
	if newdif <= dif then
	  pols = newpols
	  dif = newdif
	  sgen = gen.to_s
	  sgen = '0'+sgen while sgen.length < 5
	  fn = "out/test#{sgen}.gif"
      canvas.write(fn)
	  puts newdif.to_s+' '+fn
	  gen += 1	  
	end		
	
end

puts pols.inspect

puts "Runtime: #{Time.now - Start_time} sec"

