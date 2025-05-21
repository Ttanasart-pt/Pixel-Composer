function Node_PB_FX_Extrude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Extrude";
	
	newInput(0, nodeValue_Surface("Surface"));
	
	newInput(1, nodeValue_Rotation(  "Angle", 0));
	newInput(2, nodeValue_Int(  "Distance", 1));
	
	newInput(3, nodeValue_Color(  "Color", ca_white));
	newInput(4, nodeValue_Bool(  "Clone Color", false));
	
	newInput(5, nodeValue_Bool(  "Highlight", false));
	newInput(6, nodeValue_Color(  "Highlight Color", ca_white));
	newInput(7, nodeValue_Rotation(  "Highlight Direction", 0));
	
	newInput( 8, nodeValue_Pbbox("Shape PBBOX"));
	newInput( 9, nodeValue_Pbbox("Target PBBOX"));
	newInput(10, nodeValue_Bool("Use PBBOX", true));
	newInput(11, nodeValue_Enum_Scroll("PBBOX Mode", 0, [ "4 Directions", "Extends" ]));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
	    ["PBBOX",       true, 10], 8, 9, 11, 
	    ["Surface",    false    ], 0, 
	    ["Extrude",    false    ], 1, 2, 
	    ["Render",     false    ], 3, 4, 
	    ["Highlight",  false,  5], 7, 6, 
    ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pbbox = getSingleValue(8);
		if(is(_pbbox, __pbBox)) _pbbox.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
		
		var _pbbox = getSingleValue(9);
		if(is(_pbbox, __pbBox)) _pbbox.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
	}
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
	    var _surf = _data[0];
	    var _ang  = _data[1];
	    var _dist = _data[2];
	    
	    var _col  = _data[3];
	    var _ccol = _data[4];
	    
	    var _high = _data[5];
	    var _hgcl = _data[6];
	    var _hdir = _data[7];
	    
	    var _usePB  = _data[10];
	    var _pbMode = _data[11];
	    var _pbFr   = _data[8];
	    var _pbTo   = _data[9];
	    
	    var _boxFr = _pbFr.getBBOX();
	    var _boxTo = _pbTo.getBBOX();
	    
	    surface_set_shader(_outSurf, sh_pb_fx_extrude);
	        shader_set_dim("dimension",  _surf);
			shader_set_i("useBox",       _usePB);
			shader_set_i("boxMode",      _pbMode);
			shader_set_4("boxFrom",      _boxFr);
			shader_set_4("boxTo",        _boxTo);
			shader_set_f("angle",        degtorad(_ang));
			shader_set_f("extDistance",  _dist);
			
			shader_set_c("extColor",     _col);
			shader_set_i("cloneColor",   _ccol);
	        
			shader_set_i("highlight",      _high);
	        shader_set_c("highlightColor", _hgcl);
	        shader_set_f("highlightDir",   degtorad(_hdir));
	        
	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    return _outSurf; 
	}
}