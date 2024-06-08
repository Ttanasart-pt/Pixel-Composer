function Node_Repeat(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2)
		.rejectArray();
	
	inputs[| 3] = nodeValue("Pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Linear",   s_node_repeat_axis, 0), 
												 new scrollItem("Grid",     s_node_repeat_axis, 1), 
												 new scrollItem("Circular", s_node_repeat_axis, 2), ]);
	
	inputs[| 4] = nodeValue("Shift position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function() { return getDimension(); });
	
	inputs[| 5] = nodeValue("Repeat rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 6] = nodeValue("Scale multiply", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 7] = nodeValue("Angle range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 360])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 8] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
		
	inputs[| 9] = nodeValue("Start position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 0])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getInputData(1); });
		
	inputs[| 10] = nodeValue("Scale over copy", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11 );
	
	inputs[| 11] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone, "Make each copy follow along path." )
		.setVisible(true, true);
	
	inputs[| 12] = nodeValue("Path range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 1], "Range of the path to follow.")
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 13] = nodeValue("Path shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 14] = nodeValue("Color over copy", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(cola(c_white)) )
		.setMappable(30);
		
	inputs[| 15] = nodeValue("Alpha over copy", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11 );
	
	inputs[| 16] = nodeValue("Array select", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Whether to select image from an array in order, at random, or spread or each image to one output." )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Order", "Random", "Spread" ]);
	
	inputs[| 17] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 17].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 18] = nodeValue("Column", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 19] = nodeValue("Column shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, DEF_SURF_H / 2])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function() { return getDimension(); });
	
	inputs[| 20] = nodeValue("Animator midpoint", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 2, 0.01] });
	
	inputs[| 21] = nodeValue("Animator range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 22] = nodeValue("Animator position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 23] = nodeValue("Animator rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 24] = nodeValue("Animator scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 25] = nodeValue("Animator falloff", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_10);
	 
	inputs[| 26] = nodeValue("Stack", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Place each copy next to each other, taking surface dimension into account.")
		.setDisplay(VALUE_DISPLAY.enum_button, [ "None", "X", "Y" ]);
	
	inputs[| 27] = nodeValue("Animator blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, cola(c_white));
	
	inputs[| 28] = nodeValue("Animator alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 29] = nodeValue("Animator", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 30] = nodeValueMap("Gradient map", self);
	
	inputs[| 31] = nodeValueGradientRange("Gradient map range", self, inputs[| 14]);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surfaces",	 true],	0, 1, 16, 17,
		["Pattern",		false],	3, 9, 2, 18, 7, 8, 
		["Path",		 true],	11, 12, 13, 
		["Position",	false],	4, 26, 19, 
		["Rotation",	false],	5, 
		["Scale",		false],	6, 10, 
		["Render",		false],	14, 30,
		["Animator",	 true, 29],	20, 21, 25, 22, 23, 24, 27, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		PROCESSOR_OVERLAY_CHECK
		
		var a = inputs[| 9].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, THEME.anchor); active &= !a;
		
		var _pat  = current_data[3];
		var _spos = current_data[9];
		
		var px = _x + _spos[0] * _s;
		var py = _y + _spos[1] * _s;
		
		if(_pat == 0 || _pat == 1) {
			var a = inputs[| 4].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
			active &= !a;
			
		} else if(_pat == 2) {
			var a = inputs[| 8].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
			active &= !a;
			
		}
		
		var a = inputs[| 31].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[1]); active &= !a;
	} #endregion
	
	static preGetInputs = function() { #region
		var _arr = getSingleValue(16);
		var _pat = getSingleValue(3);
		
		inputs[|  0].setArrayDepth(_arr != 2);
		
		inputs[|  4].setVisible( _pat == 0 || _pat == 1);
		inputs[|  7].setVisible( _pat == 2);
		inputs[|  8].setVisible( _pat == 2);
		inputs[| 18].setVisible( _pat == 1);
		inputs[| 19].setVisible( _pat == 1);
		inputs[| 26].setVisible( _pat == 0);
		
		inputs[| 14].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		
		var _iSrf = _data[ 0];
		var _dim  = _data[ 1];
		var _amo  = _data[ 2];
		var _pat  = _data[ 3];
							  
		var _spos = _data[ 9];
		
		var _rpos = _data[ 4];
		var _rsta = _data[26];
		var _rrot = _data[ 5];
		var _rsca = _data[ 6];
		var _msca = _data[10];
		
		var _aran = _data[ 7];
		var _arad = _data[ 8];
		
		var _path = _data[11];
		var _prng = _data[12];
		var _prsh = _data[13];
		
		var _grad       = _data[14];
		var _grad_map   = _data[30];
		var _grad_range = _data[31];
		
		var _arr = _data[16];
		var _sed = _data[17];
		
		var _col = _data[18];
		var _cls = _data[19];
		
		var _an_use = _data[29];
		
		var _an_mid = _data[20];
		var _an_ran = _data[21];
		var _an_fal = _data[25];
		var _an_pos = _data[22];
		var _an_rot = _data[23];
		var _an_sca = _data[24];
		
		var _an_bld = _data[27];
		var _an_alp = _color_get_alpha(_an_bld);
		
		var _surf, runx, runy, posx, posy, scax, scay, rot;
				   
		random_set_seed(_sed);
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
			runx = 0;
			runy = 0;
			
			for( var i = 0; i < _amo; i++ ) {
				posx = runx;
				posy = runy;
				
				if(_pat == 0) {
					if(_path == noone || !variable_struct_exists(_path, "getPointRatio")) {
						posx += _spos[0] + _rpos[0] * i;
						posy += _spos[1] + _rpos[1] * i;
					} else {
						var rat = _prsh + _prng[0] + (_prng[1] - _prng[0]) * i / _amo;
						if(_prng[1] - _prng[0] == 0) break;
						rat = abs(frac(rat));
						
						var _p = _path.getPointRatio(rat);
						posx = _p.x;
						posy = _p.y;
					}
				} else if(_pat == 1) {
					var row = floor(i / _col);
					var col = safe_mod(i, _col);
					
					posx = _spos[0] + _rpos[0] * col + _cls[0] * row;
					posy = _spos[1] + _rpos[1] * col + _cls[1] * row;
				} else if(_pat == 2) {
					var aa = _aran[0] + (_aran[1] - _aran[0]) * i / _amo;
					posx = _spos[0] + lengthdir_x(_arad, aa);
					posy = _spos[1] + lengthdir_y(_arad, aa);
				}
				
				scax = eval_curve_x(_msca, i / (_amo - 1)) * _rsca;
				scay = scax;
				rot = _rrot[0] + (_rrot[1] - _rrot[0]) * i / (_amo - 1);
				
				var _an_dist = abs(i - _an_mid * (_amo - 1));
				var _inf = 0;
				if(_an_use && _an_dist < _an_ran * _amo) {
					_inf = eval_curve_x(_an_fal, _an_dist / (_an_ran * _amo));
					posx += _an_pos[0] * _inf;
					posy += _an_pos[1] * _inf;
					rot  += _an_rot    * _inf;
					scax += _an_sca[0] * _inf;
					scay += _an_sca[1] * _inf;
				}
				
				var _surf = _iSrf;
				
				if(is_array(_iSrf)) {
					var _sid = 0;
					
					     if(_arr == 0) _sid = safe_mod(i, array_length(_iSrf));
					else if(_arr == 1) _sid = irandom(array_length(_iSrf) - 1);
					
					_surf = array_safe_get_fast(_iSrf, _sid);
				}
				
				if(!is_surface(_surf)) continue;
				
				var _sw = surface_get_width_safe(_surf);
				var _sh = surface_get_height_safe(_surf);
				var sw = _sw * scax;
				var sh = _sh * scay;
				
				if(i) {
					if(_rsta == 1) { 
						runx += _sw / 2;
						posx += _sw / 2;
					}
					if(_rsta == 2) { 
						runy += _sh / 2;
						posy += _sh / 2;
					}
				}
				
				var pos = point_rotate(-sw / 2, -sh / 2, 0, 0, rot);
				var cc  = evaluate_gradient_map(i / (_amo - 1), _grad, _grad_map, _grad_range, inputs[| 14]);
				var aa  = _color_get_alpha(cc);
				
				cc = colda(cc);
				if(_an_use) {
					cc = merge_color(cc, colorMultiply(cc, _an_bld), _inf);
					aa += _an_alp * _inf;
				}
				
				draw_surface_ext_safe(_surf, posx + pos[0], posy + pos[1], scax, scay, rot, cc, aa);
				
				if(_rsta == 1)	runx += _sw / 2;
				if(_rsta == 2)	runy += _sh / 2;
			}
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}