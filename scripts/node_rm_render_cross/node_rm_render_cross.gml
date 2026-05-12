function Node_RM_Render_Cross(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "RM Render Cross";
	
	newInput( 0, nodeValue_Dimension());
	
	////- Object
	newInput( 1, nodeValue_SDF( "SDF Object" )).setVisible(true, true);
	
	////- Cross Section
	newInput( 2, nodeValue_EButton( "Axis",      0, [ "X", "Y", "Z" ] ));
	newInput( 3, nodeValue_Vec2(    "Midpoint", [0,0] ));
	newInput( 4, nodeValue_Vec2(    "Span",     [1,1] ));
	newInput( 6, nodeValue_Float(   "Offset",    0    ));
	
	////- Render
	newInput( 5, nodeValue_Range(   "Range",    [0,1]   ));
	// 7
		
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 0, 
		[ "Object",        false ],  1,   
		[ "Cross Section", false ],  2,  3,  4,  6, 
		[ "Render",        false ],  5,   
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static drawOverlay3D = function(active, _mx, _my, _params) {
		var _panel = _params[$ "panel"] ?? noone;
		
		#region draw result
			var _outSurf = outputs[0].getValue();
			if(is_array(_outSurf)) _outSurf = array_safe_get_fast(_outSurf, 0);
			if(!is_surface(_outSurf)) return;
			
			var _w = _panel.w;
			var _h = _panel.h - _panel.toolbar_height;
			var _pw = surface_get_width_safe(_outSurf);
			var _ph = surface_get_height_safe(_outSurf);
			var _ps = ui(128) / max(_ph, _pw);
			
			var _pws = _pw * _ps;
			var _phs = _ph * _ps;
			
			var _px = _w - ui(8) - _pws;
			var _py = _h - ui(8) - _phs;
			
			draw_surface_ext_safe(_outSurf, _px, _py, _ps, _ps);
			draw_set_color(COLORS._main_icon);
			draw_rectangle(_px, _py, _px + _pws, _py + _phs, true);
		#endregion
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		#region data
			var _dim  = _data[ 0];
			
			var _shp  = _data[ 1];
			
			var _axis = _data[ 2];
			var _mid  = _data[ 3];
			var _spa  = _data[ 4];
			var _off  = _data[ 6];
			
			var _dep  = _data[ 5];
			
			if(!is(_shp, RM_Object)) return _outSurf;
		#endregion
		
		_shp.flatten();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		surface_set_shader(_outSurf, sh_rm_render_cross);
			shader_set_i( "axis",   _axis );
			shader_set_2( "middle", _mid  );
			shader_set_2( "span",   _spa  );
			shader_set_f( "offset", _off  );
			shader_set_2( "depth",  _dep  );
			_shp.apply();
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}