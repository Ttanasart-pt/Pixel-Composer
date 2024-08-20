function Node_PB_Box_Divide_Grid(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Divide Grid";
	
	newInput(1, nodeValue("pBox", self, CONNECT_TYPE.input, VALUE_TYPE.pbBox, noone ))
		.setVisible(true, true);
		
	newInput(2, nodeValue_Vec2("Amount", self, [ 2, 2 ] ));
		
	newInput(3, nodeValue_Int("Spacing", self, 1 ));
	
	newInput(4, nodeValue_Bool("Mirror", self, 0 ))
	
	outputs[0] = nodeValue_Output("pBox", self, VALUE_TYPE.pbBox, [ noone ] );
	
	input_display_list = [ 0, 1, 
		["Divide",	false], 2, 3, 4, 
	]
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
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
			
			_res[_ind].mask = surface_stretch(_res[_ind].mask, _res[_ind].w, _res[_ind].h);
			
			if(_mirr && j % 2) {
				_res[_ind].mirror_h = !_res[_ind].mirror_h;
				_res[_ind].mask		= surface_mirror(_res[_ind].mask, true, false);
				_res[_ind].content	= surface_mirror(_res[_ind].content, true, false);
			}
			
			if(_mirr && i % 2) {
				_res[_ind].mirror_v = !_res[_ind].mirror_v;
				_res[_ind].mask		= surface_mirror(_res[_ind].mask, false, true);
				_res[_ind].content	= surface_mirror(_res[_ind].content, false, true);
			}
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