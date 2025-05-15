#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Solid", "Empty > Toggle", "E", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 2); });
	});
#endregion

function Node_Solid(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Solid";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Color("Color", self, ca_white));
	
	newInput(2, nodeValue_Bool("Empty", self, false));
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Bool("Use mask dimension", self, true));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surfaces",	false], 0, 3, 4,
		["Solid",		false], 1, 2,
	];
	
	attribute_surface_depth();
		
	static processData = function(_outSurf, _data, _array_index) {
		var _dim = _data[0];
		var _col = _data[1];
		var _emp = _data[2];
		var _msk = _data[3];
		var _msd = _data[4];
		
		var _maskUse = is_surface(_msk);
		
		inputs[4].setVisible(_maskUse);
		if(_maskUse && _msd) _dim = [ surface_get_width_safe(_msk), surface_get_height_safe(_msk) ];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		if(_emp) {
			surface_set_target(_outSurf);
				DRAW_CLEAR
			surface_reset_target();
			return _outSurf;
		}
		
		if(_maskUse) {
			surface_set_shader(_outSurf, sh_solid);
				draw_surface_stretched_ext(_msk, 0, 0, _dim[0], _dim[1], _col, _color_get_alpha(_col));
			surface_reset_shader();
		
			return _outSurf;
		}
		
		surface_set_target(_outSurf);
			draw_clear(_col);
		surface_reset_target();
		
		return _outSurf;
	}
}