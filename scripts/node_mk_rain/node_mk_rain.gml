function Node_MK_Rain(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Rain";
	update_on_frame = true;
	
	newInput(0, nodeValue_Surface("Surface In"));
	newInput(8, nodeValueSeed());
	
	////- =Shapes
	newInput( 9, nodeValue_Enum_Scroll( "Shape",           0, __enum_array_gen([ "Rain", "Snow", "Texture" ], s_node_mk_rain_type)));
	newInput( 3, nodeValue_Range(       "Raindrop Width",  [1,1]  ));
	newInput( 4, nodeValue_Range(       "Raindrop Length", [5,10] ));
	newInput(10, nodeValue_Range(       "Snow Size",       [3,4]  ));
	newInput(11, nodeValue_Surface(     "Texture" ));
	
	////- =Lifespan
	newInput(14, nodeValue_Bool(         "Limited Lifespan",    false));
	newInput(15, nodeValue_Slider_Range( "Lifespan",            [0,1])).setTooltip("Lifespan of a droplet as a ratio of the entire animation.");
	newInput(13, nodeValue_Curve(        "Size over Lifetime",  CURVE_DEF_11));
	newInput(16, nodeValue_Curve(        "Alpha over Lifetime", CURVE_DEF_11));
	
	////- =Effect
	newInput( 2, nodeValue_Float(        "Density",         5));
	newInput( 1, nodeValue_Rotation(     "Direction",       45));
	newInput( 7, nodeValue_Range(        "Velocity",        [1,2]));
	newInput(12, nodeValue_Slider_Range( "Track Extension", [0,0], { range: [ 0, 10, 0.01 ] }));
	
	////- =Render
	newInput( 5, nodeValue_Gradient(     "Color",      gra_white));
	newInput( 6, nodeValue_Slider_Range( "Alpha",      [.5,1]));
	newInput(17, nodeValue_Bool(         "Fade Alpha", false));
	
	////- =Ground
	newInput(18, nodeValue_Bool(   "Ground",        false   ));
	newInput(19, nodeValue_Float(  "Ground Start",  64      ));
	newInput(20, nodeValue_Bool(   "Ripple",        false   ));
	newInput(23, nodeValue_Float(  "Rip. Amount",   1       ));
	newInput(21, nodeValue_Float(  "Rip. Lifespan", 2       ));
	newInput(22, nodeValue_Vec2(   "Rip. Radius",   [16,8]  ));
	newInput(24, nodeValue_Slider( "Rip. Delay",   .2       ));
	newInput(25, nodeValue_Slider( "Rip. Alpha",    1       ));
	
	// inputs 25
		
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 8, 
		["Shape",    false    ], 9, 3, 4, 10, 11, 
		["Rain",     false    ], 2, 1, 7, 
		["Render",   false    ], 5, 6, 17, 
		["Lifespan",  true, 14], 15, 13, 16, 
		["Ground & Ripple", true, 18], 19, new Inspector_Spacer(ui(4), true), 20, 23, 21, 22, 24, 25, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		draw_set_color(COLORS._main_accent);
		
		var _dim = getDimension();
		var _grdUse = getInputSingle(18);
		var _grpRng = getInputSingle(19);
		
		if(_grdUse) {
			var _x0 = 0;
			var _x1 = 9999;
			var _y0 = _y + _grpRng * _s;
			
			draw_line_dashed(_x0, _y0, _x1, _y0);
			InputDrawOverlay(inputs[19].drawOverlay(hover, active, _x + _dim[0] / 2 * _s, _y, _s, _mx, _my, -90));
		}
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[0];
			var _seed = _data[8];
			
			var _shap = _data[ 9];
			var _rwid = _data[ 3];
			var _rhei = _data[ 4];
			var _snws = _data[10];
			var _text = _data[11];
			
			var _liml = _data[14];
			var _life = _data[15];
			var _llif = _data[13];
			var _alif = _data[16];
			
			var _dens = _data[ 2];
			var _dirr = _data[ 1];
			var _velo = _data[ 7];
			var _trex = _data[12];
			
			var _colr = _data[ 5];
			var _alph = _data[ 6];
			var _afad = _data[17];
			
			var _grdUse = _data[18];
			var _grpRng = _data[19];
			var _ripUse = _data[20];
			var _ripAmo = _data[23];
			var _ripLif = _data[21]; _ripLif *= TOTAL_FRAMES;
			var _ripRad = _data[22];
			var _ripDel = _data[24];
			var _ripAlp = _data[25];
			
			if(!is_surface(_surf))               return _outSurf;
			if(_shap == 2 && !is_surface(_text)) return _outSurf;
			
			inputs[ 3].setVisible(_shap == 0);
			inputs[ 4].setVisible(_shap == 0);
			inputs[10].setVisible(_shap == 1);
			inputs[11].setVisible(_shap == 2, _shap == 2);
			inputs[17].setVisible(_shap == 0);
		#endregion
		
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
		var _aa;
		
		var _prg;
		var _drpW, _drpH, _drpS;
		var _velRaw, _vel, _vex;
		var _rrad, _r_shf, _y_shf;
		
		var _rmx, _rmy;
		var _radH, _radHx, _radHy;
		var _clife, _scaL, _aaL;
		var _drpX, _drpY;
		
		draw_set_circle_precision(32);
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_surface_safe(_surf);
			var _lcc = _cc;
			
			if(_afad) BLEND_ADD
			else      BLEND_ALPHA_MULP
			
			repeat(_dens) {
				random_set_seed(_seed); _seed += 100;
				
				_velRaw = random_range(_velo[0], _velo[1]);
				_velRaw = max(1, _velRaw);
				
				_vel    = _velRaw < 1? _velRaw : floor(_velRaw);
				_vex    = _velRaw < 1?       0 : frac(_velRaw);
				
				_rrad   = _rad * (1 + _vex);
				_r_shf  = random_range( -_rad,  _rad);
				_y_shf  = random(1);
				
				switch(_shap) {
					case 0 : _drpW = irandom_range(_rwid[0], _rwid[1]); _drpH = irandom_range(_rhei[0], _rhei[1]); break;
					case 1 : _drpW =  random_range(_snws[0], _snws[1]); _drpH = _drpW;                             break;
					case 2 : _drpW = _tw;                               _drpH = _th;                               break;
				}
				
				_rmx = _rx + _in_span_x * _r_shf;
				_rmy = _ry + _in_span_y * _r_shf;
				
				_radH  = _rrad + _drpH;
				_radHx = _radH * _tr_span_x;
				_radHy = _radH * _tr_span_y;
				
				_prg = _y_shf + _vel * prg;
				_prg = frac(_prg) - 0.5;    // -0.5 - 0.5
				
				if(!_1c) _lcc = _colr.eval(random(1));
				_aa = random_range(_alph[0], _alph[1]);
				
				_clife = clamp((_prg + 0.5) / random_range(_life[0], _life[1]), 0, 1);
				_scaL  = 1;
				_aaL   = 1;
				
				if(_liml) {
					_scaL  = eval_curve_x(_llif, _clife);
					_aaL   = eval_curve_x(_alif, _clife);
				}
				
				draw_set_color_alpha(_lcc, _aa * _aaL);
				
				_drpX = _rmx - _prg * _radHx * 2;
				_drpY = _rmy - _prg * _radHy * 2;
					
				var _x0 = _drpX;
				var _y0 = _drpY;
				
				if(_grdUse) {
					var _grdY  = random_range(_grpRng, _sh);
					var _grdO  = max(0, _drpY - _grdY);
					var _grdOx = _grdO * _tr_span_x / _tr_span_y;
					
					_x0 = _drpX - _grdOx;
					_y0 = _drpY - _grdO;
					
					if(_grdO && _ripUse) {
						var _ripPrg = _grdO / _ripLif;
						
						repeat( _ripAmo ) {
							var _ripRx = _ripPrg * _ripRad[0];
							var _ripRy = _ripPrg * _ripRad[1];
							var _ripA  = clamp(1 - _ripPrg, 0, 1);
							if(_ripRx <= 1) break;
							
							draw_set_alpha(_ripAlp * _ripA);
							draw_ellipse(_x0 - _ripRx, _y0 - _ripRy, _x0 + _ripRx, _y0 + _ripRy, true);
							
							_ripPrg -= _ripDel;
						}
					}
				}
					
				switch(_shap) {
					case 0 : 						
						var _tr_span_w = _tr_span_x * _drpH; // rain drop x span
						var _tr_span_h = _tr_span_y * _drpH; // rain drop y span
						
						var _dx = (_tr_span_w * _scaL * 2);
						var _dy = (_tr_span_h * _scaL * 2);
						
						var _x1 = _x0 + _dx;
						var _y1 = _y0 + _dy;
							
						if(_grdUse) {
							_x1 = _x0 + max(0, abs(_dx) - abs(_grdOx)) * sign(_dx); 
							_y1 = _y0 + max(0, abs(_dy) - _grdO)  * sign(_dy);
						} 
						
						draw_set_color_alpha(_lcc, _aa * _aaL);
						if(_afad) { if(_drpW == 1) draw_line_color(       _x0, _y0, _x1, _y1,        _lcc, c_black );
							        else           draw_line_width_color( _x0, _y0, _x1, _y1, _drpW, _lcc, c_black ); } 
				        else {      if(_drpW == 1) draw_line(             _x0, _y0, _x1, _y1                       );
							        else           draw_line_width(       _x0, _y0, _x1, _y1, _drpW                ); }
						break;
						
					case 1 : draw_circle(_x0, _y0, _drpW * _scaL, false); break;
					case 2 : draw_surface_ext(_text, _x0 - _tw*_scaL/2, _y0 - _th*_scaL/2, _scaL, _scaL, 0, draw_get_color(), draw_get_alpha()); break;
				}
			}
			
			draw_set_alpha(1);
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}