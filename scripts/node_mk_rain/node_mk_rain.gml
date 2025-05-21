function Node_MK_Rain(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Rain";
	update_on_frame = true;
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Rotation("Direction", 45));
	
	newInput(2, nodeValue_Float("Density", 5));
	
	newInput(3, nodeValue_Range("Raindrop width", [ 1, 1 ]));
	
	newInput(4, nodeValue_Range("Raindrop length", [ 5, 10 ]));
	
	newInput(5, nodeValue_Gradient("Color", new gradientObject(ca_white)));
	
	newInput(6, nodeValue_Slider_Range("Alpha", [ 0.5, 1 ]));
		
	newInput(7, nodeValue_Range("Velocity", [ 1, 2 ]));
	
	newInput(8, nodeValueSeed(self));
	
	newInput(9, nodeValue_Enum_Scroll("Shape",  0, [ new scrollItem("Rain",    s_node_mk_rain_type, 0),
												           new scrollItem("Snow",    s_node_mk_rain_type, 1),
												           new scrollItem("Texture", s_node_mk_rain_type, 2) ]));
	
	newInput(10, nodeValue_Range("Snow size", [ 3, 4 ]));
	
	newInput(11, nodeValue_Surface("Texture"));
	
	newInput(12, nodeValue_Slider_Range("Track extension", [ 0, 0 ], { range: [ 0, 10, 0.01 ] }));
	
	newInput(13, nodeValue_Curve("Size over lifetime", CURVE_DEF_11));
	
	newInput(14, nodeValue_Bool("Limited lifespan", false));
	
	newInput(15, nodeValue_Slider_Range("Lifespan", [ 0, 1 ]))
		.setTooltip("Lifespan of a droplet as a ratio of the entire animation.");
		
	newInput(16, nodeValue_Curve("Alpha over lifetime", CURVE_DEF_11));
		
	newInput(17, nodeValue_Bool("Fade alpha", false));
		
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 8, 
		["Shape",		false], 9, 3, 4, 10, 11, 
		["Lifespan",	false, 14], 15, 13, 16, 
		["Effect",		false], 2, 1, 7, 
		["Render",		false], 5, 6, 17, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	static step = function() { #region
		var _shap = getSingleValue(9);
		
		inputs[ 3].setVisible(_shap == 0);
		inputs[ 4].setVisible(_shap == 0);
		inputs[10].setVisible(_shap == 1);
		inputs[11].setVisible(_shap == 2);
		inputs[17].setVisible(_shap == 0);
	} #endregion
	
	static processData = function(_outSurf, _data, _array_index) { #region
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
		var _trex = _data[12];
		
		var _llif = _data[13];
		var _liml = _data[14];
		var _life = _data[15];
		var _alif = _data[16];
		
		var _afad = _data[17];
		
		if(!is_surface(_surf)) return _outSurf;
		if(_shap == 2 && !is_surface(_text)) return _outSurf;
		
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
			
			draw_surface_safe(_surf);
			var _lcc = _cc;
			
			if(_afad) BLEND_ADD
			else      BLEND_ALPHA_MULP
			
			repeat(_dens) {
				random_set_seed(_seed); _seed += 100;
				
				var _velRaw = random_range(_velo[0], _velo[1]);
				    _velRaw = max(1, _velRaw);
				
				var _vel    = _velRaw < 1? _velRaw : floor(_velRaw);
				var _vex    = _velRaw < 1?       0 : frac(_velRaw);
				
				var _rrad   = _rad * (1 + _vex);
				var _r_shf  = random_range( -_rad,  _rad);
				var _y_shf  = random(1);
				
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
				
				var _radH  = _rrad + _drpH;
				var _radHx = _radH * _tr_span_x;
				var _radHy = _radH * _tr_span_y;
				
				var _prg = _y_shf + _vel * prg;
				    _prg = frac(_prg) - 0.5;    // -0.5 - 0.5
				
				if(!_1c) _lcc = _colr.eval(random(1));
				var _aa = random_range(_alph[0], _alph[1]);
				
				var _clife = clamp((_prg + 0.5) / random_range(_life[0], _life[1]), 0, 1);
				var _scaL  = 1;
				var _aaL   = 1;
				
				if(_liml) {
					_scaL  = eval_curve_x(_llif, _clife);
					_aaL   = eval_curve_x(_alif, _clife);
				}
				
				draw_set_color(_lcc);
				draw_set_alpha(_aa * _aaL);
				
				var _drpX = _rmx - _prg * _radHx * 2;
				var _drpY = _rmy - _prg * _radHy * 2;
					
				switch(_shap) {
					case 0 : 						
						var _tr_span_w = _tr_span_x * _drpH; // rain drop x span
						var _tr_span_h = _tr_span_y * _drpH; // rain drop y span
							
						var _x0 = _drpX - _tr_span_w;
						var _x1 = _x0   + _tr_span_w * 2 * _scaL;
						
						var _y0 = _drpY - _tr_span_h;
						var _y1 = _y0   + _tr_span_h * 2 * _scaL;
						
						if(_afad) {
							if(_drpW == 1) draw_line_color(       _x0, _y0, _x1, _y1, _lcc, c_black );
							else		   draw_line_width_color( _x0, _y0, _x1, _y1, _drpW, _lcc, c_black );
						} else {
							if(_drpW == 1) draw_line(       _x0, _y0, _x1, _y1 );
							else		   draw_line_width( _x0, _y0, _x1, _y1, _drpW );
						}
						break;
					case 1 :
						draw_circle(_drpX, _drpY, _drpW * _scaL, false);
						break;
					case 2 :
						draw_surface_ext(_text, _drpX, _drpY, _scaL, _scaL, 0, draw_get_color(), draw_get_alpha());
						break;
				}
			}
			
			draw_set_alpha(1);
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}