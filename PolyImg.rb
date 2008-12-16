class Poly
  attr_accessor :sides, :points, :colour, :visible 

  def initialize()
    @sides = 5
	@points = Array.new(@sides, [0,0].dup)
	@colour = [0,0,0]
	@visible = false
  end
end

class PolyImg
  attr_reader :triangles, :dif

  def initialize(polys = nil, dif = 2000)
    if polys == nil then	  
      @polys = Array.new(Max, Poly.new)
	else
	  @polys = polys
	end
	@dif = dif
  end
  
  def randomize()
    @polys.each { |poly|       
	  poly.points.each { |p| 
	    rpnt = randompoint()
		p[0], p[1] = rpnt[0], rpnt[1] 
	  }
	  poly.visible = false
	  rcol = randomcol()
	  poly.colour[0],poly.colour[1],poly.colour[2] = rcol[0],rcol[1],rcol[2]
	}
  end
  
  def randomcol()
    [rand,rand,rand]
  end
  
  def randompoint()
    x,y = rand(Xlim),rand(Ylim)
    [x,y]
  end
  
  def mutate()
    srand
    @polys.map! { |poly| 
	  poly.visible = !poly.visible if rand < 0.01
	  if rand < 0.03 then
	      if not poly.visible then
			rpnt = randompoint()
	        poly.points.each { |p| p[0], p[1] = rpnt[0], rpnt[1] }
	  	  else
			poly.points.map! { |pnt| 
			  newc = pnt[0]+rand*4-2
			  pnt[0] = newc if newc >= 0 and newc < Xlim
			  newc = pnt[1]+rand*4-2
			  pnt[1] = newc if newc >= 0 and newc < Ylim
			  pnt
			}
	  	  end
	  end	  
	  if rand < 0.03 then
        if not poly.visible then	    
 		  rcol = randomcol()
	      poly.colour[0],poly.colour[1],poly.colour[2] = rcol[0],rcol[1],rcol[2]
	    else
    	  poly.colour.map! { |c| 
		    newc = c+(rand-0.5)/100 
			if newc >= 0 and newc <= 100 then newc else c end}
	    end
	  end
	  poly
	}
  end
  
  def copy(parent2 = nil)
	triangles = Array.new(Max) 
	if parent2 == nil then 
	    @triangles.each_index { |i| 
		  triangles[i] = [@triangles[i][0].dup, @triangles[i][1].dup, @triangles[i][2].dup, @triangles[i][3].dup]
		}
	else 
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
	end
	
    newimg = PolyImg.new(triangles, @dif)
    
  end
  
  def draw(cat)  
	polydraw = Magick::Draw.new
	polydraw.stroke_width(0)
	
	@polys.each { |poly| 	  
#	  puts poly.inspect
      if poly.visible then
	    polydraw.fill("rgb(#{poly.colour[0]*100}%,#{poly.colour[1]*100}%,#{poly.colour[2]*100}%)")
	    polydraw.fill_opacity(0.3)
#	    poly.points.each {}
  	    puts poly.points.inspect
         
	    polydraw.polygon(poly.points[0], poly.points[1..-1])
	  end
	}

#	r,g,b = @triangles[0][3][0],@triangles[0][3][1],@triangles[0][3][2]
	canvas = Magick::ImageList.new
	canvas.new_image(Xlim, Ylim) {  
#	  self.background_color = "rgb(#{r*100}%,#{g*100}%,#{b*100}%)" 
	  self.background_color = "white" 
#	  self.background_color = "black" 
	}
	
	#puts tridraw.inspect	
	polydraw.draw(canvas)	
	@dif = canvas.distortion_channel(cat,MeanSquaredErrorMetric)	
	return canvas  
  end  
end 