function Node_Shape_Single(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name     = "Shape Single";
	shader   = noone;
	node_draw_transform_init();
	setProcess(false);
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface( "Mask" ));
	
	////- =Transform
	newInput( 4, nodeValue_Vec2( "Center",    [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput( 5, nodeValue_Vec2( "Half Size", [.5,.5] )).setHotkey("S").setUnitSimple();
	newInput( 6, nodeValue_Rot(  "Rotation",    0     )).setHotkey("R").setPieMenu();
	
	////- =Render
	newInput( 2, nodeValue_Surface( "BG"                 ));
	newInput( 3, nodeValue_Color(   "BG Color", ca_zero  ));
	newInput( 7, nodeValue_Color(   "Color",    ca_white )).setPieMenu();
	
	input_shape_index = array_length(inputs);
	// 
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",    false ],  0,  1, 
		[ "Transform", false ],  4,  5,  6,  
	];
	
	input_display_render = [ 
		[ "Render",    false ],  2,  3,  7,  
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		node_draw_transform_box(active, _x, _y, _s, _mx, _my, 4, 6, 5, true);
	}
	
	static submitShapeShader = function(_data) {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim    = _data[ 0];
			var _mask   = _data[ 1];
			var _bgSurf = _data[ 2];
			var _bgCol  = _data[ 3];
			
			var _pos    = _data[ 4];
			var _sca    = _data[ 5];
			var _rot    = _data[ 6];
			
			var _colr   = _data[ 7];
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_shader(_outSurf, shader);
			shader_set_2( "dimension", _dim   );
			
			shader_set_i( "useMask",   is_surface(_mask) );
			shader_set_s( "mask",      _mask   );
			
			shader_set_i( "useBgSurf", is_surface(_bgSurf) );
			shader_set_s( "bgSurf",    _bgSurf );
			shader_set_c( "bgColor",   _bgCol  );
			
			shader_set_2( "position",  _pos    );
			shader_set_2( "scale",     _sca    );
			shader_set_f( "rotation",  _rot    );
			
			shader_set_c( "color",     _colr   );
			
			submitShapeShader(_data);
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}