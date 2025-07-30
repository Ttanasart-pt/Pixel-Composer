function Node_Tile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Tile";
	
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	////- =Tiling
	newInput(1, nodeValue_Enum_Scroll( "Scaling Type", 0, [ "Fix Dimension", "Relative To Input" ] ));
	newInput(2, nodeValue_Dimension());
	newInput(3, nodeValue_Vec2( "Amount", [2,2] ));
	// input 4
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	 
	input_display_list = [ 0,
		["Tiling", false], 1, 2, 3, 
	];
	
	attribute_surface_depth();
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		var _surf = _data[0];
		var _type = _data[1];
		var _dim  = _data[2];
		var _amo  = _data[3];
		
		inputs[2].setVisible(_type == 0);
		inputs[3].setVisible(_type == 1);
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _idim = surface_get_dimension(_surf);
		var _sw = _dim[0];
		var _sh = _dim[1];
		
		if(_type == 1) {
			_sw = _idim[0] * _amo[0];
			_sh = _idim[1] * _amo[1];
		}
		
		_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		surface_set_shader(_outSurf, sh_tile);
			shader_set_2("scale", [ _sw / _idim[0], _sh / _idim[1] ]);
			
			draw_surface_stretched(_surf, 0, 0, _sw, _sh);
		surface_reset_shader();
		
		return _outSurf;
	}
}