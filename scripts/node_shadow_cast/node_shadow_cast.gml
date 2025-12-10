function Node_Shadow_Cast(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Cast Shadow";
	
	newActiveInput(17);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Background" ));
	newInput(1, nodeValue_Surface( "Solid"      ));
	
	////- =BG Shadow Caster
	newInput(10, nodeValue_Bool(   "Use BG Color", false, "If checked, background color will be used as shadow caster."));
	newInput(11, nodeValue_Slider( "BG Threshold", .1 ));
	
	////- =Light
	newInput( 5, nodeValue_Enum_Scroll( "Light Type",        0, __enum_array_gen(["Point", "Sun"], s_node_shadow_type)));
	newInput(12, nodeValue_Slider(      "Light Intensity",   1, [0, 2, 0.01] ));
	newInput( 8, nodeValue_Float(       "Light Radius",      16  ));
	newInput( 2, nodeValue_Vec2(        "Light Position",  [0,0] ))
		.setUnitRef(function(i) /*=>*/ { 
			var _surf = getInputData(0);
			if(is_array(_surf) && array_empty(_surf))
				return [1, 1];
				
			if(is_array(_surf))
				_surf = _surf[0];
				
			if(!is_surface(_surf)) 
				return [1, 1];
			
			return surface_get_dimension(_surf);
		}, VALUE_UNIT.reference);
		
	////- =Soft Light
	newInput(4, nodeValue_ISlider( "Light Density",     1, [1, 16, 0.1] ));
	newInput(3, nodeValue_Slider(  "Soft Light Radius", 1, [0, 2, 0.01] ));
		
	////- =Render
	newInput(13, nodeValue_ISlider(     "Banding",      0, [0, 16, 0.1] ));
	newInput(14, nodeValue_Enum_Scroll( "Attenuation",  0, __enum_array_gen(["Quadratic", "Invert quadratic", "Linear"], s_node_curve_type)))
		.setTooltip("Control how light fade out over distance.");
		
	newInput(7, nodeValue_Color( "Light Color",   ca_white     ));
	newInput(6, nodeValue_Color( "Ambient Color", cola(c_grey) ));
	newInput(9, nodeValue_Bool(  "Render Solid",  true        ));
	
	////- =Ambient Occlusion
	newInput(15, nodeValue_ISlider( "Ambient Occlusion",           0, [0, 16, 0.1]    ));
	newInput(16, nodeValue_Slider(  "Ambient Occlusion Strength", .1, [0, 0.5, 0.001] ));
	// inputs 18
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output( "Light mask", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 17, 
		["Surfaces",		   true], 0, 1, 
		["BG Shadow Caster",   true, 10], 11,
		["Light",			  false], 5, 12, 8, 2,
		["Soft Light",		  false], 4, 3, 
		["Render",			  false], 13, 14, 7, 6, 9, 
		["Ambient Occlusion", false], 15, 16,
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		if(array_length(current_data) != array_length(inputs)) return w_hovering;
		
		var _type = current_data[5];
		if(_type == 0) {
			var pos = current_data[2];
			var px = _x + pos[0] * _s;
			var py = _y + pos[1] * _s;
			
			InputDrawOverlay(inputs[8].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, 0, 1 / 4));
		}
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _bg     = _data[ 0];
			var _solid  = _data[ 1];
			
			var _bg_use = _data[10];
			var _bg_thr = _data[11];
			
			var _type   = _data[ 5];
			var _int    = _data[12];
			var _lrad   = _data[ 8];
			var _pos    = _data[ 2];
			
			var _den    = _data[ 4];
			var _rad    = _data[ 3];
			
			var _band   = _data[13];
			var _attn   = _data[14];
			var _lclr   = _data[ 7];
			var _lamb   = _data[ 6];
			var _sol    = _data[ 9];
			
			var _ao     = _data[15];
			var _ao_str = _data[16];
		#endregion
		
		inputs[8].setVisible(_type == 0);
		
		if(!is_surface(_bg)) return _outData;
		
		for( var i = 0, n = array_length(_outData); i < n; i++ ) {
			var _outSurf = _outData[i];
			
			surface_set_shader(_outSurf, sh_shadow_cast);
				shader_set_2("dimension", surface_get_dimension(_bg) );
				shader_set_i("mask",      i );
				
				shader_set_i("bgUse",            _bg_use );
				shader_set_f("bgThres",          _bg_thr );
				
				shader_set_i("lightType",        _type   );
				shader_set_f("lightInt",         _int    );
				shader_set_f("pointLightRadius", _lrad   );
				shader_set_2("lightPos",         _pos    );
				
				shader_set_f("lightDensity",     _den    );
				shader_set_f("lightRadius",      _rad    );
				
				shader_set_f("lightBand",        _band   );
				shader_set_f("lightAttn",        _attn   );
				shader_set_color("lightClr",     _lclr   );
				shader_set_color("lightAmb",     _lamb   );
				shader_set_i("renderSolid",      _sol    );
				
				shader_set_f("ao",               _ao     );
				shader_set_f("aoStr",            _ao_str );
				
				shader_set_i("useSolid",         is_surface(_solid));
				shader_set_s("solid",            _solid);
					
				draw_surface_safe(_bg);
			surface_reset_shader();
		}
		
		return _outData;
	}
}