function Node_Simple_Pattern(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Simple Pattern";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface( "Mask" ));
	
	////- =Pattern
	newInput( 5, nodeValue_IVec2( "Pattern Size", [3,3], true ));
	newInput( 2, nodeValue_Vec2(  "Scale",        [1,1], true ));
	
	////- =Rendering
	newInput( 3, nodeValue_Color( "Color 1", ca_black ));
	newInput( 4, nodeValue_Color( "Color 2", ca_white ));
	// 6
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	pattern_set = undefined;
	pattern_editor = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _size = getInputSingle( 5);
		
		attributes.pattern = array_verify(attributes.pattern, _size[0]);
		for( var i = 0; i < _size[0]; i++ ) 
			attributes.pattern[i] = array_verify(attributes.pattern[i], _size[1]);
		var pattern = attributes.pattern;
		
		var _s = ui(20);
		var _h = ui(16) + _s * _size[1];
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		var _cx = _x + _w / 2 - _s * (_size[0] - 1) / 2;
		var _cy = _y + _h / 2 - _s * (_size[1] - 1) / 2;
		
		for( var i = 0; i < _size[0]; i++ ) 
		for( var j = 0; j < _size[1]; j++ ) {
			var bx = _cx + i * _s;
			var by = _cy + j * _s;
			
			var pat = pattern[i][j];
			var bc  = pat? COLORS._main_accent : COLORS._main_icon;
			
			var b = buttonInstant_Pad(THEME.button_def, bx-_s/2, by-_s/2, _s, _s, _m, _hover, _focus);
			if(pat) draw_sprite_stretched_ext(THEME.checkbox_def, 2, bx-_s/2, by-_s/2, _s, _s, bc);
			
			if(b == 1 && pattern_set != undefined && pattern[i][j] != pattern_set) {
				pattern[i][j] = pattern_set;
				triggerRender();
			}
			
			if(b == 2) pattern_set = !pat;
		}
		
		if(mouse_lrelease()) pattern_set = undefined;
		
		return _h;
	});
		
	input_display_list = [ 
		[ "Output",    false ],  0,  1, 
		[ "Pattern",   false ],  5, pattern_editor, 2, 
		[ "Rendering", false ],  3,  4, 
	];
	
	////- Nodes
	
	attributes.pattern = [];
	temp_surface = [ noone ];
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim  = _data[ 0];
			var _mask = _data[ 1];
			
			var _size = _data[ 5];
			var _scal = _data[ 2];
			
			var _col1 = _data[ 3];
			var _col2 = _data[ 4];
		#endregion
		
		attributes.pattern = array_verify(attributes.pattern, _size[0]);
		for( var i = 0; i < _size[0]; i++ ) 
			attributes.pattern[i] = array_verify(attributes.pattern[i], _size[1]);
		var pattern = attributes.pattern;
		
		temp_surface[0] = surface_verify(temp_surface[0], _size[0], _size[1]);
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			for( var i = 0; i < _size[0]; i++ ) 
			for( var j = 0; j < _size[1]; j++ ) {
				var _pat = pattern[i][j];
				draw_point_color(i, j, _pat? c_white : c_black);
			}
		surface_reset_target();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		surface_set_shader(_outSurf, sh_pattern_simple);
			shader_set_2( "baseDimension", _dim  );
			shader_set_2( "pattDimension", _size );
			
			shader_set_s( "mask",    _mask );
			shader_set_i( "useMask", is_just_surface(_mask) );
			shader_set_s( "pattern", temp_surface[0] );
			
			shader_set_2( "scale", _scal );
			
			shader_set_c( "color1", _col1 );
			shader_set_c( "color2", _col2 );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}