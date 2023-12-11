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
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Rain", "Snow", "Texture" ]);
	
	inputs[| 10] = nodeValue("Snow size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 3, 4 ])
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 11] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
		
	input_display_list = [ { spr: s_MKFX }, 0, 8, 
		["Shape",	false], 9, 3, 4, 10, 11, 
		["Effect",	false], 2, 1, 7, 
		["Render",	false], 5, 6, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static step = function() { #region
		var _shap = getSingleValue(9);
		
		inputs[|  3].setVisible(_shap == 0);
		inputs[|  4].setVisible(_shap == 0);
		inputs[| 10].setVisible(_shap == 1);
		inputs[| 11].setVisible(_shap == 2);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
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
		var _text = _data[11];
		
		if(!is_surface(_surf)) return _outSurf;
		if(_shap == 2 && !is_surface(_text)) return _outSurf;
		random_set_seed(_seed);
		
		var _sw  = surface_get_width_safe(_surf);
		var _sh  = surface_get_height_safe(_surf);
		var _tw  = surface_get_width_safe(_text);
		var _th  = surface_get_height_safe(_text);
		
		var _rad = sqrt(_sw * _sw + _sh * _sh) / 2;
		var _rx  = _sw / 2;
		var _ry  = _sh / 2;
		
		var _tr_span_x = lengthdir_x(1, _dirr);
		var _tr_span_y = lengthdir_y(1, _dirr);
		
		var _in_span_x = lengthdir_x(1, _dirr + 90);
		var _in_span_y = lengthdir_y(1, _dirr + 90);
		
		var prg = CURRENT_FRAME / TOTAL_FRAMES;
		
		var _1c = array_length(_colr.keys) == 1;
		var _cc = _1c? _colr.eval(0) : _colr;
		
		draw_set_circle_precision(32);
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_surface(_surf, 0, 0);
			
			if(_1c) draw_set_color(_cc);
			BLEND_ALPHA_MULP
			repeat(_dens) {
				var _r_shf = random_range(-_rad, _rad);
				var _y_shf = random(1);
				
				var _drpW, _drpH, _drpS;
				switch(_shap) {
					case 0 : 
						_drpW = irandom_range(_rwid[0], _rwid[1]);
						_drpH = irandom_range(_rhei[0], _rhei[1]);
						break;
					case 1 : 
						_drpW = random_range(_snws[0], _snws[1]);
						_drpH = _drpW;
						break;
					case 2 : 
						_drpW = _tw;
						_drpH = _th;
						break;
				}
				
				var _rmx = _rx + _in_span_x * _r_shf;
				var _rmy = _ry + _in_span_y * _r_shf;
				
				var _radH  = _rad + _drpH;
				var _radHx = _radH * _tr_span_x;
				var _radHy = _radH * _tr_span_y;
				
				var _vel = irandom_range(_velo[0], _velo[1]);
				var _prg = _y_shf + _vel * prg;
				    _prg = frac(_prg) - 0.5;
				
				var _drpX = _rmx - _prg * _radHx * 2;
				var _drpY = _rmy - _prg * _radHy * 2;
				
				if(!_1c) draw_set_color(_colr.eval(random(1)));
				draw_set_alpha(random_range(_alph[0], _alph[1]));
				
				switch(_shap) {
					case 0 : 
						var _tr_span_w = _tr_span_x * _drpH;
						var _tr_span_h = _tr_span_y * _drpH;
						
						draw_line_width(
							_drpX - _tr_span_w, _drpY - _tr_span_h,
							_drpX + _tr_span_w, _drpY + _tr_span_h,
							_drpW
						);
						break;
					case 1 :
						draw_circle(_drpX, _drpY, _drpW, false);
						break;
					case 2 :
						draw_surface_ext(_text, _drpX, _drpY, 1, 1, 0, draw_get_color(), draw_get_alpha());
						break;
				}
			}
			
			draw_set_alpha(1);
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}