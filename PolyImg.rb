class PolyImg
  attr_reader :triangles, :dif

  def initialize(tri = nil, dif = 200)    
    if tri == nil then
      @triangles = Array.new(Max) { |t| t = [[0,0],[0,0],[0,0],[0,0,0],[0]] } 
	else
	  @triangles = tri
	end
	@dif = dif
  end
  
  def randomize()
    @triangles.map! { |t| 
      p = randompoint()
	  t = [p,p,p,randomcol,[0]] 
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
    @triangles.map! { |t| 
	  m = rand
	  t[4][0] = 1-t[4][0] if m < 0.01
	  t[0..2].map! { |v| 
	    if t[4][0] == 0 then
		  v = randompoint()
		else
  	      v[0] = [0,v[0]+rand*4-2,Xlim].sort[1]
	      v[1] = [0,v[1]+rand*4-2,Ylim].sort[1]
		end
		v
	  }
	  if t[4][0] == 0 then
		  t[3] = randomcol()
      else
  	    t[3].map! { |c| c=[0,c+(rand-0.5)/100,100].sort[1] }
  	  end
	  t
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
	tridraw = Magick::Draw.new
	tridraw.stroke_width(0)
	
	@triangles.each { |tri| 
      if tri[4][0] > 0 then 	
		tridraw.fill("rgb(#{tri[3][0]*100}%,#{tri[3][1]*100}%,#{tri[3][2]*100}%)")
		tridraw.fill_opacity(0.3)
		tridraw.polygon(tri[0][0],tri[0][1],tri[1][0],tri[1][1],tri[2][0],tri[2][1])
	  end
	}

	r,g,b = @triangles[0][3][0],@triangles[0][3][1],@triangles[0][3][2]
	canvas = Magick::ImageList.new
	canvas.new_image(Xlim, Ylim) {  
#	  self.background_color = "rgb(#{r*100}%,#{g*100}%,#{b*100}%)" 
	  self.background_color = "white" 
#	  self.background_color = "black" 
	}
	
	#puts tridraw.inspect	
	tridraw.draw(canvas)	
	@dif = canvas.distortion_channel(cat,MeanSquaredErrorMetric)	
	return canvas  
  end  
end 