function Node_Gradient_Points(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw 4 Points Gradient";
	
	inputs[0] = nodeValue_Dimension(self);
	
	inputs[1] = nodeValue_Vec2("Center 1", self, [ 0, 0 ] )
		.setUnitRef(function(index) { return getDimension(index); });
	inputs[2] = nodeValue_Color("Color 1", self, c_white );
	
	inputs[3] = nodeValue_Vec2("Center 2", self, [ DEF_SURF_W, 0 ] )
		.setUnitRef(function(index) { return getDimension(index); });
	inputs[4] = nodeValue_Color("Color 2", self, c_white );
	
	inputs[5] = nodeValue_Vec2("Center 3", self, [ 0, DEF_SURF_H ] )
		.setUnitRef(function(index) { return getDimension(index); });
	inputs[6] = nodeValue_Color("Color 3", self, c_white );
	
	inputs[7] = nodeValue_Vec2("Center 4", self, DEF_SURF , { useGlobal : false })
		.setUnitRef(function(index) { return getDimension(index); });
	inputs[8] = nodeValue_Color("Color 4", self, c_white );
	
	inputs[9] = nodeValue_Bool("Use palette", self, false );
	
	inputs[10] = nodeValue_Palette("Palette", self, array_clone(DEF_PALETTE));
	
	inputs[11] = nodeValue_Float("Falloff 1", self, 6 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 32, 0.1 ] });
	
	inputs[12] = nodeValue_Float("Falloff 2", self, 6 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 32, 0.1 ] });
	
	inputs[13] = nodeValue_Float("Falloff 3", self, 6 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 32, 0.1 ] });
	
	inputs[14] = nodeValue_Float("Falloff 4", self, 6 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 32, 0.1 ] });
		
	inputs[15] = nodeValue_Bool("Normalize weight", self, false )
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",		 true],	0,
		["Positions",	false],	1, 3, 5, 7,
		["Falloff",		 true],	11, 12, 13, 14, 15, 
		["Colors",		false],	9, 10, 2, 4, 6, 8,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) active &= !hv; _hov |= hv;
		var  hv  = inputs[3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) active &= !hv; _hov |= hv;
		var  hv  = inputs[5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) active &= !hv; _hov |= hv;
		var  hv  = inputs[7].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) active &= !hv; _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		var _usePal = getInputData(9);
		
		inputs[10].setVisible(_usePal, _usePal);
		
		inputs[ 2].setVisible(!_usePal, !_usePal);
		inputs[ 4].setVisible(!_usePal, !_usePal);
		inputs[ 6].setVisible(!_usePal, !_usePal);
		inputs[ 8].setVisible(!_usePal, !_usePal);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		var _usePal = _data[9];
		var _pal    = _data[10];
		
		var _1cen = _data[1], _1col = _data[2];
		var _2cen = _data[3], _2col = _data[4];
		var _3cen = _data[5], _3col = _data[6];
		var _4cen = _data[7], _4col = _data[8];
		
		var _1str = _data[11];
		var _2str = _data[12];
		var _3str = _data[13];
		var _4str = _data[14];
		
		var _blnd = _data[15];
		
		var colArr = [];
		
		if(_usePal) {
			for( var i = 0; i < 4; i++ )
				colArr = array_append(colArr, colorToArray(array_safe_get_fast(_pal, i, c_black)));
		} else
			colArr = array_merge(colorToArray(_1col), colorToArray(_2col), colorToArray(_3col), colorToArray(_4col))
		
		surface_set_shader(_outSurf, sh_gradient_points);
			
			shader_set_f("dimension", _dim);
			shader_set_f("center",    array_merge(_1cen, _2cen, _3cen, _4cen));
			shader_set_f("color",     colArr);
			shader_set_f("strength",  _1str, _2str, _3str, _4str);
			shader_set_i("blend",     _blnd);
			
			draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], c_white, 1);
			
		surface_reset_shader();
		
		return _outSurf;
	}
}