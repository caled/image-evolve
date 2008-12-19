=begin

-svg output

=end
PointSpread = 5

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
  
  def randomize()
    @polys.each { |poly|       
	  poly.randpoints!
	  poly.visible = false
	  poly.colour[0],poly.colour[1],poly.colour[2] = rand,rand,rand
	}
	@poly[0].visible = true
  end
  
  def mutate()
    srand
    @polys.each { |poly| 
	  poly.visible = !poly.visible if rand < 0.00001
	  if rand < 0.01 then #Move polygon points
	      if not poly.visible then
	        poly.randpoints!
	  	  else
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
	  end	  
	  if rand < 0.01 then #Change colours
        if not poly.visible then	    
	      poly.colour[0],poly.colour[1],poly.colour[2] = rand,rand,rand
	    else
    	  poly.colour.map! { |c| 
		    newc = c+(rand-0.5)/30 
			if newc >= 0 and newc <= 100 then newc else c end}
	    end
	  end
	  if rand < 0.01 then #swap poly points
	    r1, r2 = rand(poly.sides),rand(poly.sides)
	    poly.points[r1],poly.points[r2]=poly.points[r2],poly.points[r1]
      end	  
	}
	
	#Swap polys
	if rand < 0.02 then
		r1, r2 = rand(@polys.length),rand(@polys.length)
		@polys[r1],@polys[r2]=@polys[r2],@polys[r1]
	end
	
	#Sort invisible first
    sortpolys = Array.new(Max) 
	i = 0
	[false,true].each { |b| 
		@polys.each {|poly| 
			if poly.visible == b then
				sortpolys[i] = poly
				i += 1
			end	
		}
	}
  end
  
  def copy(parent2 = nil)
    polys = Array.new(Max) {Poly.new}
	
	if parent2 == nil then 
	    @polys.each_index { |i1|
		  @polys[i1].points.each_index { |i2|		    
  		    polys[i1].points[i2][0], polys[i1].points[i2][1] = @polys[i1].points[i2][0], @polys[i1].points[i2][1]
		  }
		  polys[i1].colour[0],polys[i1].colour[1],polys[i1].colour[2] = 
		    @polys[i1].colour[0],@polys[i1].colour[1],@polys[i1].colour[2]
		  polys[i1].visible = @polys[i1].visible
		}
	else 
=begin	
	    @triangles.each_index { |i| 
		  triangles[i] = [[0,0],[0,0],[0,0],[0,0,0],[0]]
		  @triangles[i].each_index { |i2|
			@triangles[i][i2].each_index { |i3|
			  if i2 == 4 then #Visible
			    triangles[i][i2][i3] = [@triangles[i][i2][i3],parent2.triangles[i][i2][i3]].max
			  else
			    #puts [i,i2,i3,triangles[i][i2][i3],parent2.triangles[i][i2][i3]].inspect
		        triangles[i][i2][i3] = (@triangles[i][i2][i3] + parent2.triangles[i][i2][i3])/2
			  end
			}
		  }
		}
=end
	end
	
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
#	  self.background_color = "rgb(#{r*100}%,#{g*100}%,#{b*100}%)" 
#	  self.background_color = "white" 
	  self.background_color = "black" 
	}
	
	#puts tridraw.inspect	
	getdraw.draw(canvas)	
	@dif = canvas.distortion_channel(cat,MeanSquaredErrorMetric)	
	return canvas  
  end  
  
  def drawgood()
	canvas = Magick::ImageList.new
	canvas.new_image(Xlim*2, Ylim*2) {  self.background_color = "black" }
	draw = Magick::Draw.new
	draw.scale(2,2)
	getdraw(draw).draw(canvas)	
	return canvas  
  end    
  

end 