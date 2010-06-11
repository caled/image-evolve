=begin

-svg output

=end
PointSpread = 5
VisChance = 800_000
GoodImageScale = 4

class Poly
  attr_accessor :sides, :points, :colour, :visible 

  def initialize()
    @sides = 5
	@points = Array.new(@sides) {[0,0].dup}
	@colour = [0,0,0]
	@visible = false
  end
  
  def randpoints!()
    rx, ry = rand(Xlim-PointSpread),rand(Ylim-PointSpread)
	@points.each {|pnt|
	  pnt[0], pnt[1] = rx+rand(PointSpread), ry+rand(PointSpread)
	}
  end
  
  def randAll!()
    randpoints!
    @colour[0],@colour[1],@colour[2] = rand,rand,rand	
  end
  
end

class PolyImg
  attr_reader :triangles, :dif

  def initialize(polys = nil, dif = 2000)
    if polys == nil then	  
      @polys = Array.new(Max) {Poly.new}
	else
	  @polys = polys
	end
	@dif = dif
  end
  
  def randomize(vis = false)
    @polys.each { |poly|       
	  poly.visible = vis
	  poly.randAll!()	  
	}
	@polys[0].visible = true
  end
  
  def mutate()
    srand
    @polys.each { |poly| 
	    if not poly.visible then
			if rand*VisChance < 1 then
				poly.randAll!()
				poly.visible = !poly.visible 
			end
		else	  
			if rand < 0.01 then #Move polygon points
				poly.points.each { |pnt| 
					if rand < 0.2
						newc = pnt[0]+rand*4-2
						pnt[0] = newc if newc >= 0 and newc < Xlim
						newc = pnt[1]+rand*4-2
						pnt[1] = newc if newc >= 0 and newc < Ylim
					end
#			  puts newc
				}
		  	end
			if rand < 0.01 then #Change colours
				poly.colour.map! { |c| 
				newc = c+(rand-0.5)/30 
				if newc >= 0 and newc <= 100 then newc else c end}
			end
			if rand < 0.01 then #swap poly points
				r1, r2 = rand(poly.sides),rand(poly.sides)
				poly.points[r1],poly.points[r2]=poly.points[r2],poly.points[r1]
			end 
		end
	}
	
	#Swap polys ( changes the draw order )
	if rand < 0.02 then
		r1, r2 = rand(@polys.length),rand(@polys.length)
		@polys[r1],@polys[r2]=@polys[r2],@polys[r1]
	end
  end
  
  def copy
    polys = Array.new(Max) {Poly.new}
	
	@polys.each_index { |i1|
	  @polys[i1].points.each_index { |i2|		    
		polys[i1].points[i2][0], polys[i1].points[i2][1] = @polys[i1].points[i2][0], @polys[i1].points[i2][1]
	  }
	  polys[i1].colour[0],polys[i1].colour[1],polys[i1].colour[2] = 
		@polys[i1].colour[0],@polys[i1].colour[1],@polys[i1].colour[2]
	  polys[i1].visible = @polys[i1].visible
	}
	
	#puts polys.inspect
    PolyImg.new(polys, @dif)	
  end
  
  def getdraw(polydraw = Magick::Draw.new)	
	polydraw.stroke_width(0)
	@polys.each { |poly| 	  
#	  puts poly.inspect
      if poly.visible then
	    polydraw.fill("rgb(#{poly.colour[0]*100}%,#{poly.colour[1]*100}%,#{poly.colour[2]*100}%)")
	    polydraw.fill_opacity(0.3)
#  	    puts poly.points.inspect         
	    polydraw.polygon(poly.points[0], poly.points[1..-1])
	  end
	}
	polydraw
  end
  
  def getsvg()
    svg = '<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg width="100%" height="100%" version="1.1"
xmlns="http://www.w3.org/2000/svg">
'+"
<g transform=\"scale(2)\">
<rect width=\"#{Xlim}\" height=\"#{Ylim}\"
style=\"fill:rgb(0,0,0);stroke-width:0\"/>

"
	
	@polys.each { |poly| 
		if poly.visible then
			pnts = ''
			poly.points.each {|p| pnts += p[0].to_s+','+p[1].to_s+' '}
			svg += "<polygon points=\"#{pnts}\"
style=\"fill:rgb(#{poly.colour[0]*100}%,#{poly.colour[1]*100}%,#{poly.colour[2]*100}%);fill-opacity:0.3\"/>
"
		end
	}
	
	svg += "</g></svg>\n"
  
    svg
  end  
  
  def drawcompare(cat)  
	canvas = Magick::ImageList.new
	canvas.new_image(Xlim, Ylim) {  
	  self.background_color = "black" 
	}
	
	getdraw.draw(canvas)	
	@dif = canvas.distortion_channel(cat,MeanSquaredErrorMetric)	
	return canvas  
  end  
  
  def drawgood()
	canvas = Magick::ImageList.new
	canvas.new_image(Xlim*GoodImageScale, Ylim*GoodImageScale) {  self.background_color = "black" }
	draw = Magick::Draw.new
	draw.scale(GoodImageScale,GoodImageScale)
	getdraw(draw).draw(canvas)	
	return canvas  
  end    
  
	def save(out)
		lines = []
		@polys.each { |poly| 
			line = []
			line << (poly.visible ? 1 : 0)
			poly.colour.each {|c| line << c}
			poly.points.each {|p| line << p[0]; line << p[1]}
			lines << line.join(',')
		}
		outFile = File.new(out, "w")
		if outFile
			outFile.syswrite(lines.join("\n"))
		else
			puts "Unable to open file!"
		end
		outFile.close
	end 

	def load(inFileName)
		lines = File.open(inFileName).readlines.map { |z| z = z.split(',') }	
		
		@polys.each_index { |i| 
			line = lines[i]
			break if !line
			poly = @polys[i]
			poly.visible = (line.delete_at(0).to_i==1 ? true : false)
			poly.colour.map! {line.delete_at(0).to_f}
			poly.points.each {|p| 
				p[0] = line.delete_at(0).to_f; 
				p[1] = line.delete_at(0).to_f; 
			}
		}
		puts 'Opening '+inFileName
	end 	  
end 