#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Mirror_Polar", "Spokes > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[4].setValue(toNumber(chr(keyboard_key))); });
		addHotkey("Node_Mirror_Polar", "Angle > Rotate CCW",  "R", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[2].setValue((_n.inputs[2].getValue() + 90) % 360); });
		addHotkey("Node_Mirror_Polar", "Reflective > Toggle", "F", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[5].setValue((_n.inputs[5].getValue() + 1) % 2); });
	});
#endregion

function Node_Mirror_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Polar Mirror";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_Rotation("Angle", self, 0));
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
	
	newInput(4, nodeValue_Float("Spokes", self, 4));
	
	newInput(5, nodeValue_Bool("Reflective", self, false));
	
	newInput(6, nodeValue_Vec2("Scale", self, [ 1, 1 ]));
	
	newInput(7, nodeValue_Enum_Scroll("Output Dimension", self, 0, [ "Same as input", "Relative", "Constant" ]));
	
	newInput(8, nodeValue_Vec2("Relative Dimension", self, [ 1, 1 ]));
	
	newInput(9, nodeValue_Vec2("Constant Dimension", self, DEF_SURF));
	
	newInput(10, nodeValue_Enum_Scroll("Radial Scale", self, 0, [ "Linear", "Exponential" ]));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3,
		["Surfaces", false], 0, 7, 8, 9, 
		["Mirror",	 false], 1, 2, 6, 10, 
		["Spokes",	 false], 4, 5, 
	]
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _pos   = current_data[1];
		var _ang   = current_data[2];
		var _posx = _pos[0] * _s + _x;
		var _posy = _pos[1] * _s + _y;
		
		var dx0 = _posx + lengthdir_x(1000, _ang);
		var dx1 = _posx + lengthdir_x(1000, _ang + 180);
		var dy0 = _posy + lengthdir_y(1000, _ang);
		var dy1 = _posy + lengthdir_y(1000, _ang + 180);
		
		draw_set_color(COLORS._main_accent);
		draw_line(dx0, dy0, dx1, dy1);
		
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);		active &= !hv; _hov |= hv;
		var  hv  = inputs[2].drawOverlay(hover, active, _posx, _posy, _s, _mx, _my, _snx, _sny);  active &= !hv; _hov |= hv;
		
		return _hov;
	}
	
	static getDimension = function(arr = 0) { 
		var _surf = getSingleValue(0, arr);
		var _outt = getSingleValue(7, arr);
		var _relS = getSingleValue(8, arr);
		var _conS = getSingleValue(9, arr);
		
		var _dim = surface_get_dimension(_surf);
		
		switch(_outt) {
			case 1 : 
				_dim[0] *= _relS[0];
				_dim[1] *= _relS[1];
				break;
				
			case 2 : _dim = _conS; break;
		}
		
		return _dim;
	} 
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _suf = _data[0];
		var _pos = _data[1];
		var _ang = _data[2];
		var _spk = _data[4];
		var _ref = _data[5];
		var _sca = _data[6];
		
		var _outt = _data[7];
		var _relS = _data[8];
		var _conS = _data[9];
		
		var _rsca = _data[10];
		
		inputs[8].setVisible(_outt == 1);
		inputs[9].setVisible(_outt == 2);
		
		var _dim = surface_get_dimension(_outSurf);
		
		surface_set_shader(_outSurf, sh_mirror_polar);
			shader_set_interpolation(_data[0]);
			shader_set_f("dimension", _dim);
			shader_set_2("position",  _pos);
			shader_set_f("angle",     degtorad(_ang));
			shader_set_f("spokes",    _spk);
			shader_set_i("reflecc",   _ref);
			shader_set_2("scale",     _sca);
			shader_set_i("rscale",   _rsca);
			
			draw_surface_stretched_safe(_suf, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf;
	}
}