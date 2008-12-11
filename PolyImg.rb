class PolyImg
  attr_reader :triangles, :dif

  def initialize(tri = nil, dif = 200)    
    if tri == nil then
      @triangles = Array.new(Max) { |t| t = [[0,0],[0,0],[0,0],[0,0,0]] } 
	else
	  @triangles = tri
	end
	@dif = dif
  end
  
  def randomize()
    @triangles.map! { |t| 
      x,y = rand(Xlim),rand(Ylim)	
	  t = [[x,y],[x,y],[x,y],[rand,rand,rand]] 
	}
  end
  
  def mutate()
    @triangles.map! { |t| 
	  t[0..2].map! { |v| 
	    v[0] = [0,v[0]+rand(5)-2,Xlim].sort[1]
	    v[1] = [0,v[1]+rand(5)-2,Ylim].sort[1]
		v
	  }
	  t[3].map! { |c| c=[0,c+(rand-0.5)/100,100].sort[1] }
	  t
	}    
  end
  
  def copy()
	triangles = Array.new(Max)
    @triangles.each_index { |i| 
	  triangles[i] = [@triangles[i][0].dup, @triangles[i][1].dup, @triangles[i][2].dup, @triangles[i][3].dup]
	}
    newimg = PolyImg.new(triangles, @dif)
    
  end
  
  def draw(cat)  
	tridraw = Magick::Draw.new
	tridraw.stroke_width(0)
	
	@triangles.each { |tri| 
		tridraw.fill("rgb(#{tri[3][0]*100}%,#{tri[3][1]*100}%,#{tri[3][2]*100}%)")
		tridraw.fill_opacity(0.3)
		tridraw.polygon(tri[0][0],tri[0][1],tri[1][0],tri[1][1],tri[2][0],tri[2][1])
	}

	r,g,b = @triangles[0][3][0],@triangles[0][3][1],@triangles[0][3][2]
	canvas = Magick::ImageList.new
	canvas.new_image(Xlim, Ylim) {  
	  self.background_color = "rgb(#{r*100}%,#{g*100}%,#{b*100}%)" 
	}
	
	#puts tridraw.inspect	
	tridraw.draw(canvas)	
	@dif = canvas.distortion_channel(cat,MeanSquaredErrorMetric)	
	return canvas  
  end  
end 