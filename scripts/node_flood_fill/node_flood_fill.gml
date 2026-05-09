function Node_Flood_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Flood Fill";
	
	newActiveInput(3);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	newInput(2, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(1, 8); // inputs 8, 9
	
	////- =Fill
	newInput( 4, nodeValue_Vec2(    "Position",   [.5,.5]  )).setHotkey("G").setUnitSimple();
	newInput( 5, nodeValue_Color(   "Color",      ca_black )).setHotkeyAuto("C");
	newInput( 6, nodeValue_Slider(  "Threshold",   .1      ));
	newInput(10, nodeValue_EScroll( "Blend",       0, [ "Override", "Multiply" ] ));
	
	////- =Algorithm
	newInput(12, nodeValue_EScroll( "Algorithm",   0, [ "Linear Sweep", "Diffusion" ]    ));
	newInput( 7, nodeValue_Bool(    "Diagonal",    false   ));
	newInput(11, nodeValue_Int(     "Iteration",   8       ));
	
	////- =Gradient
	newInput(13, nodeValue_Bool(    "Fill Gradient", false ));
	newInput(14, nodeValue_Gradient("Gradient",    gra_black_white ));
	// input 15
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  3,
		[ "Surfaces",  false ],  0,  1,  2,  8,  9, 
		[ "Fill",      false ],  4,  6,  5, 10, 
		[ "Algorithm", false ], 12,  7, 11, 
		[ "Gradient",  false, 13 ], 14, 
	];
	
	////- Node
	
	temp_surface = [ noone, noone ];
	
	attribute_surface_depth();
	
	attributes.fill_iteration = -1;
	array_push(attributeEditors, "Algorithm");
	array_push(attributeEditors, Node_Attribute("Fill iteration", function() /*=>*/ {return attributes.fill_iteration}, function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("fill_iteration", v, true)} )}));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var inSurf = _data[0];
			if(!is_surface(inSurf)) return _outSurf;
			
			var _pos   = _data[ 4];
			var _col   = _data[ 5];
			var _thr   = _data[ 6];
			var _bnd   = _data[10];
			
			var _algo  = _data[12];
			var _dia   = _data[ 7];
			var _itr   = _data[11];
			
			var _ugrad = _data[13];
			var _grad  = _data[14];
		#endregion
		
		var _filC = surface_get_pixel_ext(inSurf, _pos[0], _pos[1]);
		var  sw   = surface_get_width_safe(inSurf);
		var  sh   = surface_get_height_safe(inSurf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			temp_surface[i] = surface_verify(temp_surface[i], sw, sh, attrDepth());
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			
			shader_set(sh_flood_fill_thres);
			shader_set_f("color", colaToVec4(_filC));
			shader_set_f("thres", _thr);
				BLEND_OVERRIDE
				draw_surface_safe(inSurf);
				BLEND_NORMAL
			shader_reset();
			
			BLEND_OVERRIDE
			draw_set_color(#FF0000);
			draw_point(_pos[0] - 1, _pos[1] - 1);
			BLEND_NORMAL
		surface_reset_target();
		
		var ind   = 0;
		var itr   = 0;
		var itrSt = 1 / max(1, _itr - 1); 
		
		repeat(_itr) {
			ind = !ind;
			surface_set_shader(temp_surface[ind], _algo? sh_flood_fill_diff : sh_flood_fill_it);
				shader_set_f( "dimension", [sw,sh] );
				shader_set_i( "diagonal",   _dia   );
				shader_set_f( "iteration",  itr * itrSt);
				
				draw_surface_safe(temp_surface[!ind]);
			surface_reset_shader();
			
			itr++;
		}
		
		surface_set_shader(_outSurf, sh_flood_fill_replace);
			shader_set_c( "color", _col );
			shader_set_s( "mask",  temp_surface[ind]);
			shader_set_i( "blend", _bnd );
			
			shader_set_i( "useGrad", _ugrad );
			shader_set_gradient(     _grad  );
			
			draw_surface_safe(inSurf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		return _outSurf;
	}
}
