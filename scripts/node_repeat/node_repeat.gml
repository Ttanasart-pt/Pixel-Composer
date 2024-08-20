global.node_repeat_keys = [ "repeat polar", "repeat circular" ];

function Node_create_Repeat(_x, _y, _group = noone, _param = {}) {
	var _node = new Node_Repeat(_x, _y, _group).skipDefault();
	var query = struct_try_get(_param, "query", "");
	
	switch(query) {
		case "repeat polar" : 
		case "repeat circular" : 
			_node.inputs[3].setValue(2);
			_node.inputs[9].unit.setMode(VALUE_UNIT.reference);
			_node.inputs[9].setValueDirect([ 0.5, 0.5 ]);
			break;
	}
	
	return _node;
} 

function Node_Repeat(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat";
	dimension_index = 1;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Dimension(self));
	
	newInput(2, nodeValue_Int("Amount", self, 2))
		.rejectArray();
	
	newInput(3, nodeValue_Enum_Scroll("Pattern", self,  0, [ new scrollItem("Linear",   s_node_repeat_axis, 0), 
												             new scrollItem("Grid",     s_node_repeat_axis, 1), 
												             new scrollItem("Circular", s_node_repeat_axis, 2), ]));
	
	newInput(4, nodeValue_Vec2("Shift position", self, [ DEF_SURF_W / 2, 0 ]))
		.setUnitRef(function() { return getDimension(); });
	
	newInput(5, nodeValue_Rotation_Range("Repeat rotation", self, [0, 0]));
	
	newInput(6, nodeValue_Float("Scale multiply", self, 1));
	
	newInput(7, nodeValue_Rotation_Range("Angle range", self, [0, 360]));
	
	newInput(8, nodeValue_Float("Radius", self, 1));
		
	newInput(9, nodeValue_Vec2("Start position", self, [0, 0]))
		.setUnitRef(function(index) { return getInputData(1); });
		
	newInput(10, nodeValue("Scale over copy", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_11 ));
	
	newInput(11, nodeValue_PathNode("Path", self, noone, "Make each copy follow along path." ))
		.setVisible(true, true);
	
	newInput(12, nodeValue_Slider_Range("Path range", self, [0, 1]))
		.setTooltip("Range of the path to follow.");
	
	newInput(13, nodeValue_Float("Path shift", self, 0));
	
	newInput(14, nodeValue_Gradient("Color over copy", self, new gradientObject(cola(c_white))))
		.setMappable(30);
		
	newInput(15, nodeValue("Alpha over copy", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_11 ));
	
	newInput(16, nodeValue_Enum_Button("Array select", self, 0, [ "Order", "Random", "Spread" ]))
		.setTooltip("Whether to select image from an array in order, at random, or spread or each image to one output.");
	
	newInput(17, nodeValue_Int("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[17].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	newInput(18, nodeValue_Int("Column", self, 4));
	
	newInput(19, nodeValue_Vec2("Column shift", self, [0, DEF_SURF_H / 2]))
		.setUnitRef(function() { return getDimension(); });
	
	newInput(20, nodeValue_Float("Animator midpoint", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 2, 0.01] });
	
	newInput(21, nodeValue_Float("Animator range", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(22, nodeValue_Vec2("Animator position", self, [ 0, 0 ]));
	
	newInput(23, nodeValue_Rotation("Animator rotation", self, 0));
		
	newInput(24, nodeValue_Vec2("Animator scale", self, [ 0, 0 ]));
		
	newInput(25, nodeValue("Animator falloff", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_10));
	 
	newInput(26, nodeValue_Enum_Button("Stack", self,  0, [ "None", "X", "Y" ]))
		.setTooltip("Place each copy next to each other, taking surface dimension into account.");
	
	newInput(27, nodeValue_Color("Animator blend", self, cola(c_white)));
	
	newInput(28, nodeValue_Float("Animator alpha", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(29, nodeValue_Bool("Animator", self, false))
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(30, nodeValueMap("Gradient map", self));
	
	newInput(31, nodeValueGradientRange("Gradient map range", self, inputs[14]));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(32, nodeValue_Rotation("Start rotation", self, 0));
		
	newInput(33, nodeValue_Rotation("Rotation", self, 0));
		
	newInput(34, nodeValue_Enum_Scroll("Blend Mode", self,  0, [ "Normal", "Additive", "Maximum" ]));
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surfaces",	 true],	0, 1, 16, 17,
		["Pattern",		false],	3, 9, 32, 2, 18, 7, 8, 
		["Path",		 true],	11, 12, 13, 
		["Position",	false],	4, 26, 19, 
		["Rotation",	false],	33, 5, 
		["Scale",		false],	6, 10, 
		["Render",		false],	34, 14, 30, 
		["Animator",	 true, 29],	20, 21, 25, 22, 23, 24, 27, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _hov = false;
		var  hv  = inputs[9].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv;
		
		var _pat  = current_data[3];
		var _spos = current_data[9];
		
		var px = _x + _spos[0] * _s;
		var py = _y + _spos[1] * _s;
		
		if(_pat == 0 || _pat == 1) { var hv = inputs[4].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv; }
		else if(_pat == 2)         { var hv = inputs[8].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv; }
		
		var hv = inputs[31].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[1]); active &= !hv; _hov |= hv;
		
		return _hov;
	}
	
	static preGetInputs = function() {
		var _arr = getSingleValue(16);
		var _pat = getSingleValue(3);
		
		inputs[ 0].setArrayDepth(_arr != 2);
		
		inputs[ 4].setVisible( _pat == 0 || _pat == 1);
		inputs[ 7].setVisible( _pat == 2);
		inputs[ 8].setVisible( _pat == 2);
		inputs[18].setVisible( _pat == 1);
		inputs[19].setVisible( _pat == 1);
		inputs[26].setVisible( _pat == 0);
		inputs[32].setVisible( _pat == 2);
		
		inputs[14].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {	
		
		var _iSrf = _data[ 0];
		var _dim  = _data[ 1];
		var _amo  = _data[ 2];
		var _pat  = _data[ 3];
							  
		var _spos = _data[ 9];
		var _srot = _data[32];
		
		var _rpos = _data[ 4];
		var _rsta = _data[26];
		var _rrot = _data[ 5];
		var _rots = _data[33];
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
		
		var _bld_md = _data[34];
		
		var _surf, runx, runy, posx, posy, scax, scay, rot;
				   
		random_set_seed(_sed);
		
		surface_set_shader(_outSurf);
			     if(_bld_md == 0)   BLEND_ALPHA_MULP
			else if(_bld_md == 1)   BLEND_ADD
			else if(_bld_md == 2) { BLEND_ALPHA_MULP gpu_set_blendequation(bm_eq_max); }
			
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
					var aa = _srot + lerp(_aran[0], _aran[1], i / _amo);
					posx = _spos[0] + lengthdir_x(_arad, aa);
					posy = _spos[1] + lengthdir_y(_arad, aa);
				}
				
				scax = eval_curve_x(_msca, i / (_amo - 1)) * _rsca;
				scay = scax;
				rot = _rots + _rrot[0] + (_rrot[1] - _rrot[0]) * i / _amo;
				
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
				var cc  = evaluate_gradient_map(i / (_amo - 1), _grad, _grad_map, _grad_range, inputs[14]);
				var aa  = _color_get_alpha(cc);
				
				if(_an_use) {
					cc = merge_color_a(cc, colorMultiply(cc, _an_bld), _inf);
					aa += _an_alp * _inf;
				}
				
				shader_set_interpolation(_surf);
				draw_surface_ext_safe(_surf, posx + pos[0], posy + pos[1], scax, scay, rot, cc, aa);
				
				if(_rsta == 1)	runx += _sw / 2;
				if(_rsta == 2)	runy += _sh / 2;
			}
			
			BLEND_NORMAL
			gpu_set_blendequation(bm_eq_add);
		surface_reset_shader();
		
		return _outSurf;
	}
}