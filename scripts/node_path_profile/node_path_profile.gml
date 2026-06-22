#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Path_Profile", "Side > Toggle",          "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 4); });
		addHotkey("Node_Path_Profile", "Mirror > Toggle",        "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 2); });
		addHotkey("Node_Path_Profile", "Anti-aliasing > Toggle", "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[6].setValue((_n.inputs[6].getValue() + 1) % 2); });
		addHotkey("Node_Path_Profile", "Fill > Toggle",          "F", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 2); });
	});
#endregion

function Node_Path_Profile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Path Profile";
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Profile
	newInput( 1, nodeValue_Path( "Path" ));
	newInput( 2, nodeValue_Int( "Resolution", 64 ));
	
	////- =Render
	newInput( 9, nodeValue_EButton( "Fill",          0, [ "Odd", "All" ]       ));
	newInput( 3, nodeValue_EButton( "Side",          0, [ "L", "R", "T", "D" ] ));
	newInput( 5, nodeValue_Color(   "Color",         ca_white ));
	newInput( 4, nodeValue_EScroll( "Mirror",        0, [ "None", "Right", "Left" ]    ));
	newInput( 6, nodeValue_Bool(    "Anti-aliasing", false    ));
	
	////- =Transform
	newInput(10, nodeValue_Vec2(     "Position", [.5,.5] )).setUnitSimple();
	newInput(11, nodeValue_Anchor(   "Anchor",   [.5,.5] ));
	newInput(12, nodeValue_Rotation( "Rotation", 0       ));
	newInput(13, nodeValue_Vec2(     "Scale",    [1,1]   ));
	
	////- =Rendering
	newInput( 7, nodeValue_Bool(  "Background",    false    ));
	newInput( 8, nodeValue_Color( "BG Color",      ca_black ));
	// input 14
	
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.surface, noone ));
	
	input_display_list = [  0,
		[ "Profile",    false ],  1,  2, 
		[ "Render",     false ],  9,  3,  5,  4,  6, 
		[ "Transform",  false ], 10, 11, 12, 13, 
		[ "Rendering",  false ],  7,  8, 
	];
	
	////- Node
	
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim  = getDimension();
		var _side = current_data[3];
		var _mirr = current_data[4];
		
		if(_mirr) {
			var _x0 = _x;
			var _y0 = _y;
			var _x1 = _x + _dim[0] * _s;
			var _y1 = _y + _dim[1] * _s;
			var _xc = _x + _dim[0] * _s / 2;
			var _yc = _y + _dim[1] * _s / 2;
			
			draw_set_color(COLORS._main_accent);
			if(_side < 2) draw_line_dashed(_xc, _y0, _xc, _y1);
			else          draw_line_dashed(_x0, _yc, _x1, _yc);
		}
		
		InputDrawOverlay(inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		#region data
			var _dim  = _data[ 0];
			
			var _path = _data[ 1];
			var _res  = _data[ 2]; _res = max(_res, 2);
			
			var _mode = _data[ 9];
			var _side = _data[ 3];
			var _colr = _data[ 5];
			var _mirr = _data[ 4];
			var _aa   = _data[ 6];
			
			var _pos  = _data[10];
			var _anc  = _data[11];
			var _rot  = _data[12];
			var _sca  = _data[13];
			
			var _bg   = _data[ 7];
			var _bgC  = _data[ 8];
		#endregion
		
		if(!is_path(_path)) return;
		
		var _points = array_create(_res * 2);
		var _p      = new __vec2P();
		
		for( var i = 0; i < _res; i++ ) {
			_p = _path.getPointRatio(i / _res, 0, _p);
			_points[i * 2 + 0] = _p.x;
			_points[i * 2 + 1] = _p.y;
		}
		
		surface_set_shader(_outSurf, sh_path_fill_profile, true, _bg? BLEND.alphamulp : BLEND.over);
			if(_bg) draw_clear_alpha(_bgC, color_get_alpha(_bgC));
			shader_set_f( "dimension",  _dim    );
			
			shader_set_f( "path",       _points );
			shader_set_i( "pathLength", _res    );
			
			shader_set_i( "mode",       _mode   );
			shader_set_i( "side",       _side   );
			shader_set_c( "color",      _colr   );
			shader_set_i( "mirror",     _mirr   );
			shader_set_i( "aa",         _aa     );
			
			shader_set_2( "position",   _pos    );
			shader_set_2( "anchor",     _anc    );
			shader_set_f( "rotation",   _rot    );
			shader_set_2( "scale",      _sca    );
			
			shader_set_i( "bg",         _bg     );
			shader_set_c( "bgColor",    _bgC    );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
}