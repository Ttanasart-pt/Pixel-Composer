function Node_Shape_Half(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "Draw Half";
	shader = sh_shape_half;
	node_draw_transform_init();
	setProcess(false);
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface( "Mask" ));
	
	////- =Transform
	newInput( 8, nodeValue_EScroll( "Type",     0, [ "Point Angle", "Two Points" ] ));
	newInput( 4, nodeValue_Vec2( "Center",    [.5,.5] )).setHotkey("G").setUnitSimple().hideLabel();
	newInput( 5, nodeValue_Vec2( "Half Size", [.5,.5] )).setHotkey("S").setUnitSimple().hideLabel();
	newInput( 6, nodeValue_Rot(  "Rotation",    0     )).setHotkey("R").setPieMenu().hideLabel();
	newInput( 9, nodeValue_Vec2( "Point 1",    [0,.5] )).setUnitSimple().hideLabel();
	newInput(10, nodeValue_Vec2( "Point 2",    [1,.5] )).setUnitSimple().hideLabel();
	
	////- =Render
	newInput( 2, nodeValue_Surface( "BG"                 ));
	newInput( 3, nodeValue_Color(   "BG Color", ca_zero  ));
	newInput( 7, nodeValue_Color(   "Color",    ca_white )).setPieMenu();
	// 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",    false ],  0,  1, 
		[ "Transform", false ],  8,  4,  6,  9, 10, 
		[ "Render",    false ],  2,  3,  7,  
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _type = getInputData( 8);
		
		if(_type == 0) {
			var _pos = getInputData( 4);
			var _rot = getInputData( 6);
			
			var px = _x + _pos[0] * _s;
			var py = _y + _pos[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_line_dashed_angle(px, py, _rot);
			
			drawOverlayInput(inputs[ 4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			drawOverlayInput(inputs[ 6].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
			
		} else {
			var _pnt1 = getInputData( 9);
			var _pnt2 = getInputData(10);
			
			var p1x = _x + _pnt1[0] * _s;
			var p1y = _y + _pnt1[1] * _s;
			
			var p2x = _x + _pnt2[0] * _s;
			var p2y = _y + _pnt2[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_line_dashed(p1x, p1y, p2x, p2y);
			
			drawOverlayInput(inputs[ 9].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			drawOverlayInput(inputs[10].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		}
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim    = _data[ 0];
			var _mask   = _data[ 1];
			var _bgSurf = _data[ 2];
			var _bgCol  = _data[ 3];
			
			var _type   = _data[ 8];
			var _pos    = _data[ 4];
			var _sca    = _data[ 5];
			var _rot    = _data[ 6];
			var _pnt1   = _data[ 9];
			var _pnt2   = _data[10];
			
			var _colr   = _data[ 7];
			
			inputs[ 4].setVisible(_type == 0);
			inputs[ 6].setVisible(_type == 0);
			inputs[ 9].setVisible(_type == 1);
			inputs[10].setVisible(_type == 1);
		#endregion
		
		if(_type == 1) {
			_pos = [ (_pnt1[0] + _pnt2[0]) / 2, (_pnt1[1] + _pnt2[1]) / 2 ];
			_rot = point_direction(_pnt1[0], _pnt1[1], _pnt2[0], _pnt2[1]);
		}
		
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
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}