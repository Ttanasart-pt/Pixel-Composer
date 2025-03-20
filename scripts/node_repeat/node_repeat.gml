#region
	global.node_repeat_keys = [ "repeat polar", "repeat circular" ];
	
	function Node_create_Repeat(_x, _y, _group = noone, _param = {}) {
		var node = new Node_Repeat(_x, _y, _group);
		node.skipDefault();
		
		var query = struct_try_get(_param, "query", "");
		
		switch(query) {
			case "repeat polar" : 
			case "repeat circular" : 
				node.inputs[3].setValue(2);
				node.inputs[9].unit.setMode(VALUE_UNIT.reference);
				node.inputs[9].setValueDirect([ 0.5, 0.5 ]);
				break;
		}
		
		return node;
	} 
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Repeat", "Pattern > Toggle", "P", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 3); });
	});
	
#endregion

function Node_Repeat(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat";
	dimension_index = 1;
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Dimension(self));
	
	newInput(2, nodeValue_Int("Amount", self, 2))
		.rejectArray();
	
	newInput(3, nodeValue_Enum_Scroll("Pattern", self,  0, [ new scrollItem("Linear",   s_node_repeat_axis, 0), 
												             new scrollItem("Grid",     s_node_repeat_axis, 1), 
												             new scrollItem("Circular", s_node_repeat_axis, 2), ]));
	
	newInput(4, nodeValue_Vec2("Shift position", self, [ .5, 0 ]))
		.setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	
	newInput(5, nodeValue_Rotation_Range("Repeat rotation", self, [ 0, 0 ]));
	
	newInput(6, nodeValue_Float("Scale multiply", self, 1));
	
	newInput(7, nodeValue_Rotation_Range("Angle range", self, [ 0, 360 ]));
	
	newInput(8, nodeValue_Float("Radius", self, 1));
		
	newInput(9, nodeValue_Vec2("Start position", self, [ 0, 0 ]))
		.setUnitRef(function() /*=>*/ {return getInputData(1)}, VALUE_UNIT.reference);
		
	newInput(10, nodeValue_Curve("Scale over copy", self, CURVE_DEF_11 ));
	
	newInput(11, nodeValue_PathNode("Path", self, noone, "Make each copy follow along path." ))
		.setVisible(true, true);
	
	newInput(12, nodeValue_Slider_Range("Path range", self, [0, 1]))
		.setTooltip("Range of the path to follow.");
	
	newInput(13, nodeValue_Float("Path shift", self, 0));
	
	newInput(14, nodeValue_Gradient("Color over copy", self, new gradientObject(cola(c_white))))
		.setMappable(30);
		
	newInput(15, nodeValue_Curve("Alpha over copy", self, CURVE_DEF_11 ));
	
	newInput(16, nodeValue_Enum_Button("Array select", self, 0, [ "Order", "Random", "Spread" ]))
		.setTooltip("Whether to select image from an array in order, at random, or spread each image to its own output.");
	
	newInput(17, nodeValueSeed(self));
	
	newInput(18, nodeValue_Int("Column", self, 4));
	
	newInput(19, nodeValue_Vec2("Column shift", self, [0, .5]))
		.setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	
	/* deprecated */ newInput(20, nodeValue_Float("Animator midpoint", self, 0.5))                                          
		               .setDisplay(VALUE_DISPLAY.slider, { range: [-1, 2, 0.01] });
	
	/* deprecated */ newInput(21, nodeValue_Float("Animator range", self, 0.1))                                             
		               .setDisplay(VALUE_DISPLAY.slider);
	
	/* deprecated */ newInput(22, nodeValue_Vec2("Animator position", self, [ 0, 0 ]));                                     
	
	/* deprecated */ newInput(23, nodeValue_Rotation("Animator rotation", self, 0));                                        
		
	/* deprecated */ newInput(24, nodeValue_Vec2("Animator scale", self, [ 0, 0 ]));                                        
		
	/* deprecated */ newInput(25, nodeValue_Curve("Animator falloff", self, CURVE_DEF_10)); 
	 
	newInput(26, nodeValue_Enum_Button("Stack", self,  0, [ "None", "X", "Y" ]))
		.setTooltip("Place each copy next to each other, taking surface dimension into account.");
	
	/* deprecated */ newInput(27, nodeValue_Color("Animator blend", self, cola(c_white)));                                  
	
	/* deprecated */ newInput(28, nodeValue_Float("Animator alpha", self, 1))                                               
		               .setDisplay(VALUE_DISPLAY.slider);
	
	/* deprecated */ newInput(29, nodeValue_Bool("Animator", self, false))                                                  
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(30, nodeValueMap("Gradient map", self));
	
	newInput(31, nodeValueGradientRange("Gradient map range", self, inputs[14]));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(32, nodeValue_Rotation("Start rotation", self, 0));
		
	newInput(33, nodeValue_Rotation("Base rotation", self, 0));
		
	newInput(34, nodeValue_Enum_Scroll("Blend Mode", self,  0, [ "Normal", "Additive", "Maximum" ]));
	
	newInput(35, nodeValue_Enum_Scroll("Output dimension type", self, OUTPUT_SCALING.constant, [
																			new scrollItem("Same as input"),
																			new scrollItem("Constant"),
																			new scrollItem("Relative to input").setTooltip("Set dimension as a multiple of input surface."),
																			new scrollItem("Fit content").setTooltip("Automatically set dimension to fit content."),
																		]));
	
	newInput(36, nodeValue_Vec2("Relative dimension", self, [ 1, 1 ]));
	
	newInput(37, nodeValue_Padding("Padding", self, [ 0, 0, 0, 0 ]));
	
	newInput(38, nodeValue_Curve("Shift per copy", self, CURVE_DEF_11 ));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	typeList = [ "Linear Transform", "Blending" ];
	
	static createNewInput = function(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		dynamic_input_inspecting = getInputAmount();
		
		newInput(index + 0, nodeValue_Enum_Scroll("Animator type", self, 0, typeList));
		
		newInput(index + 1, nodeValue_Enum_Scroll("Select mode", self, 0, [ new scrollItem("Index",   s_node_repeat_selection_types, 0), 
																			 new scrollItem("Area",    s_node_repeat_selection_types, 1),
																			 new scrollItem("Surface", s_node_repeat_selection_types, 2),]));
		
		newInput(index + 2, nodeValue_Vec2("Position", self, [ 0, 0 ]));
		
		newInput(index + 3, nodeValue_Rotation("Rotation", self, 0));
		
		newInput(index + 4, nodeValue_Vec2("Scale", self, [ 0, 0 ]));
		
		newInput(index + 5, nodeValue_Enum_Button("Anchor type", self, 1, [ "Global", "Local" ]));
		
		newInput(index + 6, nodeValue_Vec2("Anchor Position", self, [ 0.5, 0.5 ]))
			.setTooltip("Anchor point for transformation, absolute value for global type, relative for local.");
		
		newInput(index + 7, nodeValue_Color("Color", self, cola(c_white)));
		
		newInput(index + 8, nodeValue_Float("Alpha", self, 0))
			.setDisplay(VALUE_DISPLAY.slider, { range : [ -1, 1, 0.01 ] });
		
		newInput(index + 9, nodeValue_Area("Selection area", self, DEF_AREA_REF))
			.setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
		
		newInput(index + 10, nodeValue_Float("Selection index", self, 0));
		
		newInput(index + 11, nodeValue_Float("Selection range", self, 2));
		
		newInput(index + 12, nodeValue_Float("Selection falloff", self, 0));
		
		newInput(index + 13, nodeValue_Curve("Selection falloff curve", self, CURVE_DEF_10));
		
		newInput(index + 14, nodeValue_Surface("Selection surface", self, noone));
		
		newInput(index + 15, nodeValue_Float("Strength", self, 0))
			.setDisplay(VALUE_DISPLAY.slider, { range : [ -1, 1, 0.01 ] });
		
		refreshDynamicDisplay();
		return inputs[index];
	} 
	
	animator_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		
		var bs = ui(24);
		var bx = _x + ui(20);
		var by = _y;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			createNewInput();
			triggerRender();
		}
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(bx + bx + ui(8), by + bs / 2, "Animators");
		
		var amo = getInputAmount();
		var lh  = ui(28);
		var _h  = ui(12) + lh * amo;
		var yy  = _y + bs + ui(4);
		
		var del_animator = -1;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, yy, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for(var i = 0; i < amo; i++) {
			var _x0 = _x + ui(24);
			var _x1 = _x + _w - ui(16);
			var _yy = ui(6) + yy + i * lh + lh / 2;
			
			var _ind  = input_fix_len + i * data_length;
			var _dtyp = current_data[_ind + 0];
			var _styp = current_data[_ind + 1];
			var cc    = i == dynamic_input_inspecting? COLORS._main_icon : COLORS._main_icon;
			var tc    = i == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
			var hov   = _hover && point_in_rectangle(_m[0], _m[1], _x0, _yy - lh / 2, _x1, _yy + lh / 2 - 1);
			
			if(hov && _m[0] < _x1 - ui(32)) {
				tc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus)) {
					dynamic_input_inspecting = i;
					refreshDynamicDisplay();
				}
			}
			
			draw_sprite_ext(s_node_repeat_selection_types, _styp, _x0 + ui(8), _yy, 1, 1, 0, cc);
			
			draw_set_text(f_p2, fa_left, fa_center, tc);
			draw_text_add(_x0 + ui(28), _yy, typeList[_dtyp]);
			
			var bs = ui(24);
			var bx = _x1 - bs;
			var by = _yy - bs / 2;
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
				del_animator = i;	
		}
		
		if(del_animator > -1) 
			deleteDynamicInput(del_animator);
		
		return ui(32) + _h;
	});
	
	input_display_dynamic = [ 
		["Selection", false], 1, 9, 10, 11, 12, 13, 14, 
		["Effects",   false], 0, 2, 3, 4, 5, 6, 7, 8, 15, 
	];
	
	input_display_list = [
		["Surfaces",	 true],	0, 35, 36, 37, 1, 16, 17,
		["Pattern",		false],	3, 9, 32, 2, 18, 7, 8, 
		["Path",		 true],	11, 12, 13, 
		["Position",	false],	4, 26, 19, 38, 
		["Rotation",	false],	33, 5, 
		["Scale",		false],	6, 10, 
		["Render",		false],	34, 14, 30, 
		new Inspector_Spacer(8, true),
		new Inspector_Spacer(2, false, false),
		animator_renderer, 
	];
	
	setDynamicInput(16, false);
	
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
		var hv = inputs[11].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);                  active &= !hv; _hov |= hv;
	
		var _ani_amo = getInputAmount();
		if(_ani_amo == 0) return _hov;
		
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		
		var _prop = current_data[_ind + 0];
		var _selc = current_data[_ind + 1];
		
		if(_selc == 1) {
			var hv = inputs[_ind + 9].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv;
		}
		
		return _hov;
	}
	
	static getTool = function() { 
		var _path = getInputData(11);
		return is_instanceof(_path, Node)? _path : self; 
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
		inputs[38].setVisible( _pat == 0);
		
		inputs[14].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {	
		
		var _iSrf = _data[ 0];
		
		var _dimt = _data[35];
		var _dimc = _data[ 1];
		var _dims = _data[36];
		var _padd = _data[37];
		
		var _amo  = _data[ 2];
		var _pat  = _data[ 3];
							  
		var _spos = _data[ 9];
		var _srot = _data[32];
		
		var _rpos = _data[ 4];
		var _cpos = _data[38];
		
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
		
		var _arr    = _data[16];
		var _sed    = _data[17];
		
		var _col    = _data[18];
		var _cls    = _data[19];
		var _bld_md = _data[34];
		
		var _ani_amo = getInputAmount();
		
		if(_ani_amo > 0) { // animator visibility
			dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
			var _ind = input_fix_len + dynamic_input_inspecting * data_length;
			
			var _prop = _data[_ind + 0];
			var _selc = _data[_ind + 1];
			
			inputs[_ind +  2].setVisible(_prop == 0);
			inputs[_ind +  3].setVisible(_prop == 0);
			inputs[_ind +  4].setVisible(_prop == 0);
			inputs[_ind +  5].setVisible(_prop == 0);
			inputs[_ind +  6].setVisible(_prop == 0);
			inputs[_ind +  7].setVisible(_prop == 1);
			inputs[_ind +  8].setVisible(_prop == 1);
			// inputs[_ind + 15].setVisible(_prop == 2);
			
			inputs[_ind +  9].setVisible(_selc == 1);
			inputs[_ind + 10].setVisible(_selc == 0);
			inputs[_ind + 11].setVisible(_selc == 0);
			inputs[_ind + 12].setVisible(_selc != 2);
			inputs[_ind + 13].setVisible(_selc != 2);
			inputs[_ind + 14].setVisible(_selc == 2, _selc == 2);
		}
		
		var _surf, posx, posy, scax, scay, rot;
		var _dim, _sdim = [ 1, 1 ];
		var _surf = _iSrf;
		
		var minx =  999999, miny =  999999;
		var maxx = -999999, maxy = -999999;
		
		if(is_array(_surf)) {
			for( var i = 0, n = array_length(_surf); i < n; i++ ) {
				var _ddim = surface_get_dimension(_surf[i]);
				_sdim[0] = max(_sdim[0], _ddim[0]);
				_sdim[1] = max(_sdim[1], _ddim[1]);
			}
			
		} else if(is_surface(_surf))
			_sdim = surface_get_dimension(_surf);
		
		random_set_seed(_sed);
		
		var atlases = array_create(_amo, 0);
		var atlas_i = 0;
		var runx = 0;
		var runy = 0;
		
		var _rposx = 0;
		var _rposy = 0;
		
		for( var i = 0; i < _amo; i++ ) {
			posx = runx;
			posy = runy;
			
			var _prg = i / (_amo - 1);
			
			if(_pat == 0) {
				if(struct_has(_path, "getPointRatio")) {
					var rat = _prsh + _prng[0] + (_prng[1] - _prng[0]) * i / _amo;
					if(_prng[1] - _prng[0] == 0) break;
					rat = abs(frac(rat));
					
					var _p = _path.getPointRatio(rat);
					posx = _p.x;
					posy = _p.y;
					
				} else {
					posx += _spos[0] + _rposx;
					posy += _spos[1] + _rposy;
					
					var _rpos_sca = eval_curve_x(_cpos, _prg);
					_rposx += _rpos[0] * _rpos_sca;
					_rposy += _rpos[1] * _rpos_sca;
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
			
			scax = eval_curve_x(_msca, _prg) * _rsca;
			scay = scax;
			rot  = _rots + lerp(_rrot[0], _rrot[1], i / _amo);
			
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
			
			var cc  = evaluate_gradient_map(i / (_amo - 1), _grad, _grad_map, _grad_range, inputs[14]);
			var aa  = _color_get_alpha(cc);
			
			atlases[atlas_i++] = {
				surface : _surf, 
				x       : posx, 
				y       : posy, 
				sx      : scax, 
				sy      : scay, 
				rot     : rot, 
				color   : cc, 
				alpha   : aa
			};
			
			if(_rsta == 1)	runx += _sw / 2;
			if(_rsta == 2)	runy += _sh / 2;
		}
		
		var __temp_p = [ 0,0 ];
		
		for( var i = 0, n = atlas_i; i < n; i++ ) { // animators
			var _a    = atlases[i];
			var _surf = _a.surface;
			
			var _x = _a.x;
			var _y = _a.y;
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			
			for( var j = 0; j < _ani_amo; j++ ) {
				var _ii = input_fix_len + j * data_length;
				
				var _an_prop = _data[_ii + 0];
				var _an_selt = _data[_ii + 1];
				
				var _an_posi = _data[_ii + 2];
				var _an_rota = _data[_ii + 3];
				var _an_scal = _data[_ii + 4];
				var _an_anct = _data[_ii + 5];
				var _an_ancp = _data[_ii + 6];
				var _an_colr = _data[_ii + 7];
				var _an_alph = _data[_ii + 8];
				
				var _an_sare = _data[_ii +  9];
				var _an_sind = _data[_ii + 10];
				var _an_srng = _data[_ii + 11];
				var _an_sfal = _data[_ii + 12];
				var _an_sfcr = _data[_ii + 13];
				var _an_ssrf = _data[_ii + 14];
				// var _an_strn = _data[_ii + 15];
				
				var _inf = 0;
				var _ax = 0, _ay = 0;
				
				if(_an_selt == 0) { // index
					if(i < _an_sind - _an_srng - _an_sfal || i > _an_sind + _an_srng + _an_sfal)
						_inf = 1;
					else if (_an_sfal > 0 && (i < _an_sind - _an_srng || i > _an_sind + _an_srng))
						_inf = clamp(min(abs(i - (_an_sind - _an_srng)), abs(i - (_an_sind + _an_srng))) / _an_sfal, 0, 1);
					else 
						_inf = 0;
					
				} else if(_an_selt == 1) { // area
					_inf = 1 - area_point_in_fallout(_an_sare, _x, _y, _an_sfal);
					
				} else if(_an_selt == 2) { // surface
					if(is_surface(_an_ssrf)) {
						var b = surface_getpixel(_an_ssrf, _x, _y);
						_inf = 1 - _color_get_light(b);
					}
				}
				
				_inf = eval_curve_x(_an_sfcr, _inf);
				if(_inf == 0) continue;
				
				switch(_an_prop) {
					case 0 : // transform
						_x += _inf * _an_posi[0];
						_y += _inf * _an_posi[1];
						
						var _dr = _inf * _an_rota;
						if(_dr != 0) {
							_a.rot += _dr;
							
							if(_an_anct == 0) { // global
								_ax = _an_ancp[0];
								_ay = _an_ancp[1];
								
							} else if(_an_anct == 1) { // local
								_ax = _x + _an_ancp[0] * _sw;
								_ay = _y + _an_ancp[1] * _sh;
								
							}
							
							__temp_p = point_rotate(_x, _y, _ax, _ay, _dr, __temp_p);
							_x = __temp_p[0];
							_y = __temp_p[1];
						}
						
						var _dsx = _inf * _an_scal[0];
						var _dsy = _inf * _an_scal[1];
						if(_dsx != 0 || _dsy != 0) {
							if(_an_anct == 0) { // global
								_ax = _an_ancp[0];
								_ay = _an_ancp[1];
								
							} else if(_an_anct == 1) { // local
								_ax = _x + (_an_ancp[0] - .5) * _sw;
								_ay = _y + (_an_ancp[1] - .5) * _sh;
								
							}
							
							_a.sx  += _inf * _an_scal[0];
							_a.sy  += _inf * _an_scal[1];
							
							_x += _dsx * (_x - _ax);
							_y += _dsy * (_y - _ay);
						}
						break;
						
					case 1 : 
						_a.color  = merge_color(_a.color, _an_colr, _inf);
						_a.alpha += _inf * _an_alph;
						break;
				}
				
			}
			
			var  sw = _sw * _a.sx;
			var  sh = _sh * _a.sy;
			var pos = point_rotate(-sw / 2, -sh / 2, 0, 0, _a.rot);
			
			minx = min(minx, _x + pos[0], _x - pos[0], _x + pos[1], _x - pos[1]);
			miny = min(miny, _y + pos[0], _y - pos[0], _y + pos[1], _y - pos[1]);
			maxx = max(maxx, _x + pos[0], _x - pos[0], _x + pos[1], _x - pos[1]);
			maxy = max(maxy, _y + pos[0], _y - pos[0], _y + pos[1], _y - pos[1]);
			
			_a.x = _x + pos[0];
			_a.y = _y + pos[1];
		}
		
		/////////////////////////////////////// ===== DIMENSION
		
		inputs[ 1].setVisible(false);
		inputs[36].setVisible(false);
		inputs[37].setVisible(false);
		
		switch(_dimt) {
			case OUTPUT_SCALING.same_as_input :
				_dim = _sdim;
				break;
				
			case OUTPUT_SCALING.constant :
				inputs[ 1].setVisible(true);

				_dim = _dimc;
				break;
				
			case OUTPUT_SCALING.relative :
				inputs[36].setVisible(true);
				
				_dim = [ _sdim[0] * _dims[0], _sdim[1] * _dims[1] ];
				break;
				
			case OUTPUT_SCALING.scale :
				inputs[37].setVisible(true);
				
				_dim = [ 
					abs(maxx - minx) + _padd[0] + _padd[2], 
					abs(maxy - miny) + _padd[1] + _padd[3] 
				];
				break;
				
		}
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		var _x, _y;
		
		/////////////////////////////////////// ===== RENDERING
		
		surface_set_shader(_outSurf);
			     if(_bld_md == 0) { BLEND_ALPHA_MULP }
			else if(_bld_md == 1) { BLEND_ADD        }
			else if(_bld_md == 2) { BLEND_MAX        }
			
			for( var i = 0, n = atlas_i; i < n; i++ ) {
				var _a = atlases[i];
				
				shader_set_interpolation(_a.surface);
				var _x = _a.x;
				var _y = _a.y;
				
				if(_dimt == OUTPUT_SCALING.scale) {
					_x += _padd[2] - minx;
					_y += _padd[1] - miny;
				}
				
				// print(dec_to_hex(color_real(_a.color)));
				draw_surface_ext_safe(_a.surface, _x, _y, _a.sx, _a.sy, _a.rot, _a.color, _a.alpha);
			}
			
			BLEND_NORMAL
		surface_reset_shader();
		
		return _outSurf;
	}
}