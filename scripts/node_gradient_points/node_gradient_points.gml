function Node_Gradient_Points(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "4 Points Gradient";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Center 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	inputs[| 2] = nodeValue("Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 3] = nodeValue("Center 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	inputs[| 4] = nodeValue("Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 5] = nodeValue("Center 3", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, DEF_SURF_H ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	inputs[| 6] = nodeValue("Color 3", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 7] = nodeValue("Center 4", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	inputs[| 8] = nodeValue("Color 4", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 9] = nodeValue("Use palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 10] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 11] = nodeValue("Falloff 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 6 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 32, 1 ]);
	
	inputs[| 12] = nodeValue("Falloff 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 6 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 32, 1 ]);
	
	inputs[| 13] = nodeValue("Falloff 3", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 6 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 32, 1 ]);
	
	inputs[| 14] = nodeValue("Falloff 4", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 6 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 32, 1 ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",		 true],	0,
		["Positions",	false],	1, 3, 5, 7,
		["Falloff",		 true],	11, 12, 13, 14, 
		["Colors",		false],	9, 10, 2, 4, 6, 8,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 5].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 7].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
	}
	
	static step = function() {
		var _usePal = inputs[| 9].getValue();
		
		inputs[| 10].setVisible(_usePal, _usePal);
		
		inputs[|  2].setVisible(!_usePal, !_usePal);
		inputs[|  4].setVisible(!_usePal, !_usePal);
		inputs[|  6].setVisible(!_usePal, !_usePal);
		inputs[|  8].setVisible(!_usePal, !_usePal);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		var _usePal = _data[9];
		var _pal    = _data[10];
		
		var _1cen = _data[1];
		var _1col = _data[2];
		var _2cen = _data[3];
		var _2col = _data[4];
		var _3cen = _data[5];
		var _3col = _data[6];
		var _4cen = _data[7];
		var _4col = _data[8];
		
		var _1str = _data[11];
		var _2str = _data[12];
		var _3str = _data[13];
		var _4str = _data[14];
		
		var colArr = [];
		
		if(_usePal) {
			for( var i = 0; i < 4; i++ )
				colArr = array_append(colArr, colorArrayFromReal(array_safe_get(_pal, i, c_black)));
		} else
			colArr = array_merge(colorArrayFromReal(_1col), colorArrayFromReal(_2col), colorArrayFromReal(_3col), colorArrayFromReal(_4col))
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		shader_set(sh_gradient_points);
			shader_set_f("dimension", _dim[0], _dim[1]);
			shader_set_f("center", array_merge(_1cen, _2cen, _3cen, _4cen));
			shader_set_f("color", colArr);
			shader_set_f("strength", _1str, _2str, _3str, _4str);
			
			draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], c_white, 1);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}