function Node_MK_Rain(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Rain";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 45)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 2] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 5);
	
	inputs[| 3] = nodeValue("Raindrop width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 2 ])
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 4] = nodeValue("Raindrop length", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 5, 10 ])
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 5] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white));
	
	inputs[| 6] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
		
	inputs[| 7] = nodeValue("Velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 2 ])
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 8] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom_range(100_000, 999_999));
	
	inputs[| 9] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Rain", "Snow" ]);
	
	inputs[| 10] = nodeValue("Snow size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 3, 4 ])
		.setDisplay(VALUE_DISPLAY.vector_range);
		
	input_display_list = [ 0, 8, 
		["Shape",	false], 9, 3, 4, 10, 
		["Effect",	false], 1, 2, 7, 
		["Render",	false], 5, 6, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	drops = [];
	
	static step = function() {
		var _shap = getSingleValue(9);
		
		inputs[|  3].setVisible(_shap == 0);
		inputs[|  4].setVisible(_shap == 0);
		inputs[| 10].setVisible(_shap == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _dirr = _data[1];
		var _dens = _data[2];
		var _rwid = _data[3];
		var _rhei = _data[4];
		var _colr = _data[5];
		var _alph = _data[6];
		var _velo = _data[7];
		var _seed = _data[8];
		var _shap = _data[9];
		var _snws = _data[10];
		
		if(!is_surface(_surf)) return _outSurf;
		random_set_seed(_seed);
		
		var _sw  = surface_get_width_safe(_surf);
		var _sh  = surface_get_height_safe(_surf);
		var _rad = sqrt(_sw * _sw + _sh * _sh) / 2;
		var _rx  = _sw / 2;
		var _ry  = _sh / 2;
		
		var _tr_span_x = lengthdir_x(1, _dirr);
		var _tr_span_y = lengthdir_y(1, _dirr);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_surface(_surf, 0, 0);
			
			BLEND_ALPHA_MULP
			for( var i = 0; i < _dens; i++ ) {
				var _r_shf = random_range(-_rad, _rad);
				var _y_shf = random(1);
				
				var _rmx = _rx + lengthdir_x(_r_shf, _dirr + 90);
				var _rmy = _ry + lengthdir_y(_r_shf, _dirr + 90);
				
				var _drpW, _drpH;
				
				switch(_shap) {
					case 0 : 
						_drpW = irandom_range(_rwid[0], _rwid[1]);
						_drpH = irandom_range(_rhei[0], _rhei[1]);
						break;
					case 1 : 
						_drpW = random_range(_snws[0], _snws[1]);
						_drpH = _drpW;
						break;
				}
				
				var _t0x = _rmx + (_tr_span_x * (_rad + _drpH));
				var _t0y = _rmy + (_tr_span_y * (_rad + _drpH));
				
				var _vel = irandom_range(_velo[0], _velo[1]);
				var _prg = _y_shf + _vel * (CURRENT_FRAME / TOTAL_FRAMES);
				    _prg = frac(_prg);
					
				var _drpX = _t0x - _prg * _tr_span_x * ((_rad + _drpH) * 2);
				var _drpY = _t0y - _prg * _tr_span_y * ((_rad + _drpH) * 2);
				
				draw_set_color(_colr.eval(random(1)));
				draw_set_alpha(random_range(_alph[0], _alph[1]));
				
				switch(_shap) {
					case 0 : 
						draw_line_width(
							_drpX - _tr_span_x * _drpH,
							_drpY - _tr_span_y * _drpH,
							_drpX + _tr_span_x * _drpH,
							_drpY + _tr_span_y * _drpH,
							_drpW
						);
						break;
					case 1 :
						draw_circle(_drpX, _drpY, _drpW, false);
						break;
				}
			}
			
			draw_set_alpha(1);
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}