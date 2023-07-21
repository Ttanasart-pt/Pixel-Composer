function Node_PB_Box_Divide_Grid(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Divide Grid";
	
	inputs[| 1] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 2, 2 ] )
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 3] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
	
	inputs[| 4] = nodeValue("Mirror", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0 )
	
	outputs[| 0] = nodeValue("pBox", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, [ noone ] );
	
	input_display_list = [ 0, 1, 
		["Divide",	false], 2, 3, 4, 
	]
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _bs = outputs[| 0].getValue();
		if(_bs == noone)   return;
		if(!is_array(_bs)) return;
		
		for( var i = 0; i < array_length(_bs); i++ ) {
			var _b   = _bs[i];
			if(_b == noone) continue;
			var _bx0 = _x   + _b.x * _s;
			var _by0 = _y   + _b.y * _s;
			var _bx1 = _bx0 + _b.w * _s;
			var _by1 = _by0 + _b.h * _s;
		
			draw_set_color(c_red);
			draw_rectangle(_bx0, _by0, _bx1, _by1, true);
		}
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _layr = _data[0];
		var _pbox = _data[1];
		var _amou = _data[2];
		var _spac = _data[3];
		var _mirr = _data[4];
		
		if(_pbox == noone) return noone;
		
		var _amo = _amou[0] * _amou[1];
		if(_amo < 1) return;
		
		var _res = array_create(_amo);
		var _ww  = (_pbox.w - _spac * (_amou[0] - 1)) / _amou[0];
		var _hh  = (_pbox.h - _spac * (_amou[1] - 1)) / _amou[1];
		
		for( var i = 0; i < _amou[1]; i++ )
		for( var j = 0; j < _amou[0]; j++ ) {
			var _ind = i * _amou[0] + j;
			_res[_ind] = _pbox.clone();
			
			_res[_ind].layer += _layr;
			
			_res[_ind].x = _pbox.x + j * (_ww + _spac);
			_res[_ind].w = _ww;
			
			_res[_ind].y = _pbox.y + i * (_hh + _spac);
			_res[_ind].h = _hh;
			
			if(_mirr && j % 2) _res[_ind].mirror_h = !_res[_ind].mirror_h;
			if(_mirr && i % 2) _res[_ind].mirror_v = !_res[_ind].mirror_v;
		}
		
		return _res;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s)
			.toSquare()
			.pad(4);
		
		draw_set_color(c_white);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 2);
		
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.xc - 2, bbox.yc - 2, 1);
		draw_rectangle_border(bbox.xc + 2, bbox.y0, bbox.x1, bbox.yc - 2, 1);
		draw_rectangle_border(bbox.x0, bbox.yc + 2, bbox.xc - 2, bbox.y1, 1);
		draw_rectangle_border(bbox.xc + 2, bbox.yc + 2, bbox.x1, bbox.y1, 1);
	}
}