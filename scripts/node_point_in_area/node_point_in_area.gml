function Node_Point_In_Area(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Point in Area";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Area("Area", self, DEF_AREA ));
	
	newInput(1, nodeValue_Vec2("Point", self, [ 0, 0 ] ))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Bool("Include Boundary", self, true ));
	
	newOutput(0, nodeValue_Output("Is in", self, VALUE_TYPE.boolean, false ));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var hhv = false;
		var hov = hover;
		var _hv = inputs[1].drawOverlay(hov, active, _x, _y, _s, _mx, _my, _snx, _sny); hhv |= _hv; hov &= !_hv;
		var _hv = inputs[0].drawOverlay(hov, active, _x, _y, _s, _mx, _my, _snx, _sny); hhv |= _hv; hov &= !_hv;
			
		return hhv;
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
	    var _area = _data[0];
	    var _pont = _data[1];
	    var _bond = _data[2];
	    
	    var px = _pont[0];
	    var py = _pont[1];
	    
	    var cx =     _area[AREA_INDEX.center_x];
	    var cy =     _area[AREA_INDEX.center_y];
	    var hw = abs(_area[AREA_INDEX.half_w]);
	    var hh = abs(_area[AREA_INDEX.half_h]);
	    var sh =     _area[AREA_INDEX.shape];
	    
	    var x0 = cx - hw;
	    var x1 = cx + hw;
	    var y0 = cy - hh;
	    var y1 = cy + hh;
	    
	    if(sh == AREA_SHAPE.rectangle) {
	        if(_bond) return px >= x0 && px <= x1 && py >= y0 && py <= y1;
	        else      return px > x0  && px < x1  && py >  y0 && py <  y1;
	    } else {
	        var _nx = (px - cx) / hw;
	        var _ny = (py - cy) / hh;
	        
	        if(_bond) return sqr(_nx) + sqr(_ny) <= 1;
	        else      return sqr(_nx) + sqr(_ny) <  1;
	    }
	    
	    return false;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _in  = getSingleValue(0,, true);
		
		draw_sprite_bbox_uniform(THEME.node_draw_area, 0, bbox, _in? COLORS._main_value_positive : COLORS._main_value_negative);
	}
}