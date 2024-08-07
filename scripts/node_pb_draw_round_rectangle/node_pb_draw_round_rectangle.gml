function Node_PB_Draw_Round_Rectangle(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Round Rectangle";
	
	inputs[| 3] = nodeValue_Enum_Scroll("Type", self,  0 , [ "Uniform", "Per Corner" ]);
	
	inputs[| 4] = nodeValue("Corner Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
	
	inputs[| 5] = nodeValue("Corner Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 1, 1, 1, 1 ] )
		.setArrayDepth(1)
		.setDisplay(VALUE_DISPLAY.corner);
	
	inputs[| 6] = nodeValue("Relative", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 7] = nodeValue("Cut Corner", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	input_display_list = [
		["Draw",	false], 0, 1, 2, 
		["Shape",	false], 3, 6, 4, 5, 7, 
	];
	
	corner_pixels = [
		[ // 1 corner
			[ 0, 0 ],
		], 
		[ // 2 corner
			[ 1, 0 ],
			[ 0, 1 ],
		],
		[ // 3 corner
			[ 2, 0 ],
			[ 0, 2 ],
		],
		[ // 4 corner
			[ 1, 1 ],
		]
	]
	
	static step = function() {
		var _type = getInputData(3);
		var _rela = getInputData(6);
		
		inputs[| 4].setVisible(_type == 0);
		inputs[| 5].setVisible(_type == 1);
		
		if(_rela) {
			inputs[| 4].setType(VALUE_TYPE.float);
			inputs[| 5].setType(VALUE_TYPE.float);
		} else {
			inputs[| 4].setType(VALUE_TYPE.integer);
			inputs[| 5].setType(VALUE_TYPE.integer);
		}
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _fcol = _data[1];
		var _mask = _data[2];
		var _type = _data[3];
		var _corn = _type == 0? _data[4] : _data[5];
		var _rela = _data[6];
		var _cut  = _data[7];
		
		if(_pbox == noone) return _pbox;
		
		var _nbox = _pbox.clone();
		_nbox.content = surface_verify(_nbox.content, _pbox.w, _pbox.h);
		
		var _x0 = 0;
		var _y0 = 0;
		var _x1 = _pbox.w - 1;
		var _y1 = _pbox.h - 1;
		
		surface_set_target(_nbox.content);
			DRAW_CLEAR
			
			draw_set_color(_fcol);
			draw_set_circle_precision(64);
			
			var _corners = [
				[ _x0, _y0 ],
				[ _x1, _y0 ],
				[ _x0, _y1 ],
				[ _x1, _y1 ],
			]
			
			if(_cut) {
				draw_rectangle(_x0, _y0, _x1, _y1, false);
				
				BLEND_SUBTRACT
				for( var k = 0; k < 4; k++ ) {
					var _cc = _type == 0? _corn : _corn[k];
					if(_rela) _cc = max(0, round(_cc * min(_pbox.w, _pbox.h)));
					_cc /= 2;
					
					for( var i = 0; i < _cc; i++ )
					for( var j = 0; j < _cc; j++ ) {
						if(i + j >= _cc) continue;
						
						draw_point(_corners[k][0] + i * ((k & 0b01)? -1 : 1), _corners[k][1] + j * ((k & 0b10)? -1 : 1));
					}
				}
				BLEND_NORMAL
			} else {
				if(_type == 0) {
					if(_rela) _corn = max(0, round(_corn * min(_pbox.w, _pbox.h)));
				
					if(_corn > array_length(corner_pixels)) 
						draw_roundrect_ext(_x0 - 1, _y0 - 1, _x1, _y1, 6 + _corn, 6 + _corn, false);
					else {
						draw_rectangle(_x0, _y0, _x1, _y1, false);
						BLEND_SUBTRACT
						for( var i = 0; i < _corn; i++ ) {
							var _corner = corner_pixels[i];
						
							for( var j = 0; j < 4; j++ )
							for( var k = 0; k < array_length(_corner); k++ )
								draw_point(_corners[j][0] + _corner[k][0] * ((j & 0b01)? -1 : 1), _corners[j][1] + _corner[k][1] * ((j & 0b10)? -1 : 1));
						}
						BLEND_NORMAL
					}
				} else if(_type == 1) {
					draw_rectangle(_x0 - 1, _y0 - 1, _x1, _y1, false);
				
					for( var c = 0; c < 4; c++ ) {
						var _c = c;
					
						switch(c) {
							case 0 : 
								if( _pbox.mirror_h &&  _pbox.mirror_v) _c = 3; 
								if( _pbox.mirror_h && !_pbox.mirror_v) _c = 1; 
								if(!_pbox.mirror_h &&  _pbox.mirror_v) _c = 2; 
								break;
							case 1 : 
								if( _pbox.mirror_h &&  _pbox.mirror_v) _c = 2; 
								if( _pbox.mirror_h && !_pbox.mirror_v) _c = 0; 
								if(!_pbox.mirror_h &&  _pbox.mirror_v) _c = 3; 
								break;
							case 2 : 
								if( _pbox.mirror_h &&  _pbox.mirror_v) _c = 1; 
								if( _pbox.mirror_h && !_pbox.mirror_v) _c = 3; 
								if(!_pbox.mirror_h &&  _pbox.mirror_v) _c = 0; 
								break;
							case 3 : 
								if( _pbox.mirror_h &&  _pbox.mirror_v) _c = 0; 
								if( _pbox.mirror_h && !_pbox.mirror_v) _c = 2; 
								if(!_pbox.mirror_h &&  _pbox.mirror_v) _c = 1; 
								break;
						}
					
						var _cc = _corn[_c];
						if(_rela) _cc = max(0, round(_cc * min(_pbox.w, _pbox.h)));
					
						if(_cc > array_length(corner_pixels)) {
							var _sub_surf = surface_create(_cc - 1, _cc - 1);
							surface_set_target(_sub_surf);
								draw_clear(c_white);
							
								BLEND_SUBTRACT
									draw_roundrect_ext(0, 0, _cc * 3, _cc * 3, _cc, _cc, false);
								BLEND_NORMAL
							surface_reset_target();
						
							BLEND_SUBTRACT
								switch(c) {
									case 0 : draw_surface_ext_safe(_sub_surf, _x0,     _y0,     1, 1,   0, c_white, 1); break;
									case 1 : draw_surface_ext_safe(_sub_surf, _x1 + 1, _y0,     1, 1, -90, c_white, 1); break;
									case 2 : draw_surface_ext_safe(_sub_surf, _x0,     _y1 + 1, 1, 1,  90, c_white, 1); break;
									case 3 : draw_surface_ext_safe(_sub_surf, _x1 + 1, _y1 + 1, 1, 1, 180, c_white, 1); break;
								}
							BLEND_NORMAL
						
							surface_free(_sub_surf);
						} else {
							BLEND_SUBTRACT
							for( var i = 0; i < _cc; i++ ) {
								var _corner = corner_pixels[i];
						
								for( var k = 0; k < array_length(_corner); k++ )
									draw_point(_corners[c][0] + _corner[k][0] * ((c & 0b01)? -1 : 1), _corners[c][1] + _corner[k][1] * ((c & 0b10)? -1 : 1));
							}
							BLEND_NORMAL
						}
					}
				}
			}
			
			PB_DRAW_APPLY_MASK
		surface_reset_target();
		
		PB_DRAW_CREATE_MASK
		
		return _nbox;
	}
}