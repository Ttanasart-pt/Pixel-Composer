function Node_Move_Point(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Transform Point";
	color = COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	////- =Points
	newInput(0, nodeValue_Vec2( "Point",        [ 0, 0] )).setVisible(true, true);
	newInput(1, nodeValue_Vec2( "Anchor Point", [.5,.5] )).setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	////- =Position
	newInput(2, nodeValue_Vec2(     "Position", [0,0] )).setHotkey("G");
	
	////- =Rotation
	newInput(3, nodeValue_Rotation( "Rotation",  0    )).setHotkey("R");
	
	////- =Scale
	newInput(4, nodeValue_Vec2(     "Scale",    [1,1] ));
	// input 5
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.float, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		["Points",   false], 0, 1, 
		["Position", false], 2, 
		["Rotation", false], 3, 
		["Scale",    false], 4, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _anc = getSingleValue(1);
		var _px  = _x + _anc[0] * _s;
		var _py  = _y + _anc[1] * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _pnt = [ _data[0][0], _data[0][1] ];
		var _anc = _data[1];
		
		var _pos = _data[2];
		var _rot = _data[3];
		var _sca = _data[4];
		
		point_rotate_array(_pnt, _anc, _rot);
		_pnt[0]  = _anc[0] + (_pnt[0] - _anc[0]) * _sca[0];
		_pnt[1]  = _anc[1] + (_pnt[1] - _anc[1]) * _sca[1];
		
		_pnt[0] += _pos[0];
		_pnt[1] += _pos[1];
		
		return _pnt;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_move_point, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}