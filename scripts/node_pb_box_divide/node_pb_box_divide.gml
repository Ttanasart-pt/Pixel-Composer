function Node_PB_Box_Divide(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Divide";
	batch_output = false;
	
	inputs[| 1] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2 );
		
	inputs[| 3] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
	
	inputs[| 4] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y" ]);
		
	inputs[| 5] = nodeValue("Mirror", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0 )
		
	inputs[| 6] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Space Between", "Space Around", "Begin", "End" ]);
	
	outputs[| 0] = nodeValue("pBox Content", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, [ noone ] );
		
	outputs[| 1] = nodeValue("pBox Space", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, [ noone ] );
	
	input_display_list = [ 0, 1,
		["Divide",	false], 4, 2, 3, 6, 5, 
	]
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _layr = _data[0];
		var _pbox = _data[1];
		var _amou = _data[2];
		var _spac = _data[3];
		var _axis = _data[4];
		var _mirr = _data[5];
		var _spacing = _data[6];
		
		if(_pbox == noone) return noone;
		if(_amou < 1)      return noone;
		
		var _res = noone;
		
		if(_output_index == 0)      _res = array_create(_amou);
		else if(_output_index == 1) _res = array_create(_amou - 1);
			
		var _spAmo = _amou;
		switch(_spacing) {
			case 0 : _spAmo = _amou - 1; break;
			case 1 : _spAmo = _amou + 1; break;
			case 2 : _spAmo = _amou; break;
			case 3 : _spAmo = _amou; break;
		}
			
		if(_axis == 0) {
			var _ww = (_pbox.w - _spac * _spAmo) / _amou;
			
			if(_output_index == 0)
			for( var i = 0; i < _amou; i++ ) {
				_res[i] = _pbox.clone();
				_res[i].layer += _layr;
				
				var _sx = _pbox.x;
				if(_spacing == 1 || _spacing == 2)
					_sx += _spac;
				
				_res[i].x = _sx + i * (_ww + _spac);
				_res[i].w = _ww;
				
				_res[i].mask	= surface_stretch(_res[i].mask, _res[i].w, _res[i].h);
				_res[i].content = surface_stretch(_res[i].content, _res[i].w, _res[i].h);
				
				if(_mirr && i % 2) {
					_res[i].mirror_h = !_res[i].mirror_h;
					_res[i].mask	= surface_mirror(_res[i].mask, true, false);
					_res[i].content = surface_mirror(_res[i].content, true, false);
				}
			}
			
			if(_output_index == 1)
			for( var i = 0; i < _spAmo; i++ ) {
				_res[i] = _pbox.clone();
				_res[i].mask   = noone;
				_res[i].layer += _layr;
				
				var _sx = 0;
				if(_spacing == 0 || _spacing == 3)
					_sx += _ww + _pbox.x;
					
				_res[i].x = _sx + i * (_ww + _spac);
				_res[i].w = _spac;
			}
		} else {
			var _hh = (_pbox.h - _spac * _spAmo) / _amou;
		
			if(_output_index == 0)
			for( var i = 0; i < _amou; i++ ) {
				_res[i] = _pbox.clone();
				_res[i].layer += _layr;
				
				var _sy = _pbox.y;
				if(_spacing == 1 || _spacing == 2)
					_sy += _spac;
					
				_res[i].y = _sy + i * (_hh + _spac);
				_res[i].h = _hh;
				
				_res[i].mask	= surface_stretch(_res[i].mask, _res[i].w, _res[i].h);
				_res[i].content = surface_stretch(_res[i].content, _res[i].w, _res[i].h);
				
				if(_mirr && i % 2) {
					_res[i].mirror_v = !_res[i].mirror_v;
					_res[i].mask	= surface_mirror(_res[i].mask, false, true);
					_res[i].content = surface_mirror(_res[i].content, false, true);
				}
			}
		
			if(_output_index == 1)
			for( var i = 0; i < _spAmo; i++ ) {
				_res[i] = _pbox.clone();
				_res[i].mask   = noone;
				_res[i].layer += _layr;
				
				var _sy = 0;
				if(_spacing == 0 || _spacing == 3)
					_sy += _hh + _pbox.y;
					
				_res[i].y = _sy + i * (_hh + _spac);
				_res[i].h = _spac;
			}
		}
		
		return _res;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var _axis = current_data[4];
		var bbox = drawGetBbox(xx, yy, _s)
			.toSquare()
			.pad(8);
		
		draw_set_color(c_white);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 2);
		
		if(_axis == 0) {
			draw_line(lerp(bbox.x0, bbox.x1, 1 / 3) - 2, bbox.y0, lerp(bbox.x0, bbox.x1, 1 / 3) - 2, bbox.y1);
			draw_line(lerp(bbox.x0, bbox.x1, 1 / 3) + 2, bbox.y0, lerp(bbox.x0, bbox.x1, 1 / 3) + 2, bbox.y1);
		
			draw_line(lerp(bbox.x0, bbox.x1, 2 / 3) - 2, bbox.y0, lerp(bbox.x0, bbox.x1, 2 / 3) - 2, bbox.y1);
			draw_line(lerp(bbox.x0, bbox.x1, 2 / 3) + 2, bbox.y0, lerp(bbox.x0, bbox.x1, 2 / 3) + 2, bbox.y1);
		} else {
			draw_line(bbox.x0, lerp(bbox.y0, bbox.y1, 1 / 3) - 2, bbox.x1, lerp(bbox.y0, bbox.y1, 1 / 3) - 2);
			draw_line(bbox.x0, lerp(bbox.y0, bbox.y1, 1 / 3) + 2, bbox.x1, lerp(bbox.y0, bbox.y1, 1 / 3) + 2);
		
			draw_line(bbox.x0, lerp(bbox.y0, bbox.y1, 2 / 3) - 2, bbox.x1, lerp(bbox.y0, bbox.y1, 2 / 3) - 2);
			draw_line(bbox.x0, lerp(bbox.y0, bbox.y1, 2 / 3) + 2, bbox.x1, lerp(bbox.y0, bbox.y1, 2 / 3) + 2);
		}
	}
}