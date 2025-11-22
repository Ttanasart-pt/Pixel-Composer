function Node_PB_FX_Bevel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bevel";
	
	newInput(0, nodeValue_Surface( "Surface" ));
	
	////- =Bevel
	newInput(1, nodeValue_Int( "Height", 2 ));
	
	////- =Colors
	newInput(2, nodeValue_Gradient( "Color Over Height", new gradientObject( ca_white )))
	newInput(3, nodeValue_Gradient( "Color Over Angles", new gradientObject( [ ca_black, ca_white ] )))
	newInput(4, nodeValue_Rotation( "Shift Angle", 0 )).hideLabel();
	
	////- =Highlight
	newInput(5, nodeValue_Bool(     "Highlight",           false    ));
	newInput(6, nodeValue_Color(    "Highlight Color",     ca_white ));
	newInput(7, nodeValue_Rotation( "Highlight Direction", 0        ));
	newInput(8, nodeValue_Bool(     "Highlight All",       false    ));
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output( "Inner Area",  VALUE_TYPE.surface, noone)).setVisible(false);
	
	input_display_list = [ 0,
	    [ "Bevel",      false    ], 1, 
	    [ "Colors",     false    ], 2, 3, 4, 
	    [ "Highlight",  false, 5 ], 8, 7, 6, 
    ];
	
	////- Node
	
	temp_surface = [ noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _surf = current_data[0];
		if(!is_surface(_surf)) return false;
		
		var _dim = surface_get_dimension(_surf);
		var _cx = _x + _dim[0] * _s / 2;
		var _cy = _y + _dim[1] * _s / 2;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 0, 2));
		InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
	    var _surf  = _data[0];
	    var _heigh = _data[1];
	    var _grHig = _data[2];
	    var _grRad = _data[3];
	    var _radsh = _data[4];
	    
	    var _high = _data[5];
	    var _hgcl = _data[6];
	    var _hdir = _data[7];
	    var _hall = _data[8];
	    
	    inputs[7].setVisible(!_hall);
	    
	    var _dim = surface_get_dimension(_surf);
	    for( var i = 0, n = array_length(temp_surface); i < n; i++ )
	        temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
	    
	    surface_set_shader(temp_surface[0], sh_pb_fx_bevel_edge);
	        shader_set_2("dimension", _dim);
	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    surface_set_shader(temp_surface[1], sh_pb_fx_bevel_angle);
	        shader_set_2("dimension", _dim);
	        draw_surface_safe(temp_surface[0]);
	    surface_reset_shader();
	    
	    var _outSurf   = surface_verify(_outData[0], _dim[0], _dim[1]);
	    var _innerSurf = surface_verify(_outData[1], _dim[0], _dim[1]);
	    
	    shader_set(sh_pb_fx_bevel);
    	    surface_set_target_ext(0, temp_surface[2]);
    	    surface_set_target_ext(1, _innerSurf);
	        DRAW_CLEAR
	        
	        shader_set_2("dimension",  _dim);
	        shader_set_f("height",     _heigh);
	        shader_set_f("shiftAngle", _radsh / 360);
	        shader_set_surface("edgeSurf", temp_surface[1]);
			
			_grHig.shader_submit("height");
			_grRad.shader_submit("radius");
			
	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    surface_set_shader(_outSurf, sh_pb_fx_bevel_apply);
	        shader_set_dim("dimension", _surf);
	        
			shader_set_i("highlight",      _high);
	        shader_set_c("highlightColor", _hgcl);
	        shader_set_f("highlightDir",   degtorad(_hdir));
	        shader_set_i("highlightAll",   _hall);
	        shader_set_surface("insideSurf", _innerSurf);
	        
	        draw_surface_safe(temp_surface[2]);
	    surface_reset_shader();
	    
	    return [ _outSurf, _innerSurf ]; 
	}
}