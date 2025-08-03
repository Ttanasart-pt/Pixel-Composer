#region create
	enum LIGHT_SHAPE_2D {
		point,
		ellipse,
		line,
		line_asym,
		saber,
		spot,
		flame,
	}
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_2D_light", "Shape > Toggle", "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].scrollValue(); });
	});
	
#endregion

function Node_2D_light(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "2D Light";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	typeList    = __enum_array_gen([ "Point", "Ellipse", "Line", "Line asymmetric", "Saber", "Spot", "Flame" ], s_node_2d_light_shape);
	typeListStr = array_create_ext(array_length(typeList), function(i) /*=>*/ {return typeList[i].name});
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		dynamic_input_inspecting = getInputAmount();
		
		var _val = nodeValue_Enum_Scroll("Light shape", 0, typeList);
			_val.options_histories = [ typeListStr, { cond: function() /*=>*/ {return LOADING_VERSION < 1_18_00_0 && !CLONING}, list: [ "Point", "Line", "Line asymmetric", "Spot" ] } ];
			
		newInput(index + 14, nodeValue_Active());
		
		////- =Shape
		newInput(index +  0, _val);
		newInput(index +  1, nodeValue_Vec2(     "Center",           [16,16] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)});
		newInput(index +  5, nodeValue_Vec2(     "Start",            [16,16] ));
		newInput(index +  6, nodeValue_Vec2(     "Finish",           [32,16] ));
		newInput(index +  7, nodeValue_ISlider(  "Sweep",             15, [-80, 80, 0.1] ));
		newInput(index +  8, nodeValue_ISlider(  "Sweep End",         0,  [-80, 80, 0.1] ));
		newInput(index + 22, nodeValue_Int(      "Sweep Soft",        1      ));
		newInput(index + 23, nodeValue_Float(    "Sweep Spread",      1      ));
		newInput(index + 15, nodeValue_Float(    "Radius x",          16     ));
		newInput(index + 16, nodeValue_Float(    "Radius y",          16     ));
		newInput(index + 17, nodeValue_Rotation( "Rotation",          0      ));
		newInput(index + 20, nodeValue_Bool(     "Two Sides",         false  ));
		newInput(index + 21, nodeValue_Float(    "Thickness",         2      ));
		
		////- =Light
		newInput(index +  2, nodeValue_Float(   "Range",              16                ));
		newInput(index +  3, nodeValue_Slider(  "Intensity",          1, [ 0, 4, 0.01 ] ));
		newInput(index +  4, nodeValue_Color(   "Color",              ca_white          ));
		newInput(index + 11, nodeValue_ISlider(  "Radial Banding",    0, [0, 16, 0.1]   ));
		newInput(index + 12, nodeValue_Rotation( "Radial Start",      0                 ));
		newInput(index + 13, nodeValue_Slider(   "Radial Band Ratio", 0.5               ));
		
		////- =Render
		newInput(index + 10, nodeValue_Enum_Scroll("Attenuation",     0, __enum_array_gen([ "Quadratic", "Invert quadratic", "Linear" ], s_node_curve_type)))
			 .setTooltip("Control how light fade out over distance.");
		newInput(index +  9, nodeValue_ISlider( "Banding",            0,  [0, 16, 0.1] ));
		newInput(index + 18, nodeValue_Float(    "Exponent",          2                ));
		newInput(index + 19, nodeValue_Bool(     "Anti Aliasing",     false            ));
		// input 24
		
		refreshDynamicDisplay();
		return inputs[index];
	} 
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Light only",  VALUE_TYPE.surface, noone ));
	
	lights_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(array_length(current_data) != array_length(inputs)) return 0;
		
		var bs = ui(24);
		var bx = _x + ui(20);
		var by = _y;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			createNewInput();
			triggerRender();
		}
			
		var amo = getInputAmount();
		var lh  = ui(28);
		var _h  = ui(12) + lh * amo;
		var yy  = _y + bs + ui(4);
		
		var del_light = -1;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, yy, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for(var i = 0; i < amo; i++) {
			var _x0 = _x + ui(24);
			var _x1 = _x + _w - ui(16);
			var _yy = ui(6) + yy + i * lh + lh / 2;
			
			var _ind = input_fix_len + i * data_length;
			var _typ = current_data[_ind + 0];
			var _col = current_data[_ind + 4];
			
			var tc   = i == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
			var hov  = _hover && point_in_rectangle(_m[0], _m[1], _x0, _yy - lh / 2, _x1, _yy + lh / 2 - 1);
			
			if(hov && _m[0] < _x1 - ui(32)) {
				tc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus)) {
					dynamic_input_inspecting = i;
					refreshDynamicDisplay();
				}
			}
			
			draw_sprite_ext(s_node_2d_light_shape, _typ, _x0 + ui(8), _yy, 1, 1, 0, _col, .5 + .5 * (i == dynamic_input_inspecting));
			
			draw_set_text(f_p2, fa_left, fa_center, tc);
			draw_text_add(_x0 + ui(28), _yy, typeListStr[_typ]);
			
			if(amo > 1) {
				var bs = ui(24);
				var bx = _x1 - bs;
				var by = _yy - bs / 2;
				if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
					del_light = i;	
			}
		}
		
		if(del_light > -1) 
			deleteDynamicInput(del_light);
		
		return ui(32) + _h;
	});
	
	input_display_dynamic = [ // 14, 
		["Shape",	false], 0, 1, 5, 6, 7, 8, 22, 23, 15, 16, 17, 20, 21,
		["Light",	false], 2, 3, 4, 11, 12, 13,
		["Render",	false], 10, 9, 18, 19, 
	];
	
	input_display_list = [ 0, lights_renderer ];
	
	setDynamicInput(24, false);
	if(!LOADING && !APPENDING) createNewInput();
	
	attribute_surface_depth();
	temp_surface = [ noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK

		if(getInputAmount() == 0) return;
		
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		
		var _shape = current_data[_ind + 0];
		
		draw_set_circle_precision(64);
		
		switch(_shape) {
			case LIGHT_SHAPE_2D.point :
				var pos = current_data[_ind + 1];
				var rad = current_data[_ind + 2];
				
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.5);
				draw_circle_dash(px, py, rad * _s, 1, 8);
				draw_set_alpha(1);
				
				InputDrawOverlay(inputs[_ind + 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[_ind + 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
				break;
			
			case LIGHT_SHAPE_2D.ellipse :
				var pos = current_data[_ind +  1];
				var rdx = current_data[_ind + 15];
				var rdy = current_data[_ind + 16];
				var ang = current_data[_ind + 17];
				
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.5);
				draw_ellipse_dash(px, py, rdx * _s, rdy * _s, 1, 8, ang);
				draw_set_alpha(1);
				
				InputDrawOverlay(inputs[_ind +  1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[_ind + 15].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, ang));
				InputDrawOverlay(inputs[_ind + 16].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, ang + 90));
				InputDrawOverlay(inputs[_ind + 17].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
				break;
			
			case LIGHT_SHAPE_2D.line      :
			case LIGHT_SHAPE_2D.line_asym :
			case LIGHT_SHAPE_2D.spot      :
			case LIGHT_SHAPE_2D.flame     :
				InputDrawOverlay(inputs[_ind + 5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[_ind + 6].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				break;
				
			case LIGHT_SHAPE_2D.saber     :
				InputDrawOverlay(inputs[_ind + 5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[_ind + 6].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				
				var pos = current_data[_ind +  5];
				var rad = current_data[_ind +  2];
				var thk = current_data[_ind + 21];
				
				var px = _x + pos[0] * _s;
				var py = _y + pos[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.5);
				draw_circle(px, py, thk * _s, 1);
				draw_circle_dash(px, py, rad * _s, 1, 8);
				draw_set_alpha(1);
				
				inputs[_ind + 21].overlay_text_valign = fa_bottom;
				InputDrawOverlay(inputs[_ind +  2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[_ind + 21].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
				break;
		}
		
		return w_hovering;
	}
	
	static applyLight = function(_data, _ind, _lightSurf) {
		#region data
			var _surf  = _data[0];
			var _dim   = surface_get_dimension(_surf);
			
			var _shape = _data[_ind +  0];
			var _pos   = _data[_ind +  1];
			var _range = _data[_ind +  2];
			var _inten = _data[_ind +  3];
			var _color = _data[_ind +  4];
			
			var _start = _data[_ind +  5];
			var _finis = _data[_ind +  6];
			var _sweep = _data[_ind +  7];
			var _swep2 = _data[_ind +  8];
			var _swepS = _data[_ind + 22];
			var _swepA = _data[_ind + 23];
			
			var _band  = _data[_ind +  9];
			var _attn  = _data[_ind + 10];
			var _rbnd  = _data[_ind + 11];
			var _rbns  = _data[_ind + 12];
			var _rbnr  = _data[_ind + 13];
			
			var _rngx  = _data[_ind + 15];
			var _rngy  = _data[_ind + 16];
			var _anng  = _data[_ind + 17];
			
			var _expo  = _data[_ind + 18];
			var _aa    = _data[_ind + 19];
			var _both  = _data[_ind + 20];
			var _thick = _data[_ind + 21];
		#endregion
		
		surface_set_shader(temp_surface[0], noone);
			draw_clear(c_black);
			BLEND_ADD
			
			draw_set_circle_precision(64);
			
			switch(_shape) {
				case LIGHT_SHAPE_2D.point :
					if(_rbnd < 2)
						draw_circle_color(_pos[0], _pos[1], _range, c_white, c_black,  0);
					else {
						_rbnd *= 2;
						var bnd_amo = ceil(64 / _rbnd); //band radial per step
						var step = bnd_amo * _rbnd;
						var astp = 360 / step;
						var ox, oy, nx, ny;
						
						draw_primitive_begin(pr_trianglelist);
						
						for( var i = 0; i <= step; i++ ) {
							var dir = _rbns + i * astp;
							nx = _pos[0] + lengthdir_x(_range, dir);
							ny = _pos[1] + lengthdir_y(_range, dir);
							
							if(safe_mod(i, bnd_amo) / bnd_amo < _rbnr && i) {
								draw_vertex_color(_pos[0], _pos[1], c_white, 1);
								draw_vertex_color(ox, oy, c_black, 1);
								draw_vertex_color(nx, ny, c_black, 1);
							}
							
							ox = nx;
							oy = ny;
						}
						
						draw_primitive_end();
					}
					break;
				
				case LIGHT_SHAPE_2D.ellipse :
					draw_ellipse_angle_color(_pos[0], _pos[1], _rngx, _rngy, _anng, c_white, c_black);
					break;
					
				case LIGHT_SHAPE_2D.line :
				case LIGHT_SHAPE_2D.line_asym :
					var dir = point_direction(_start[0], _start[1], _finis[0], _finis[1]) + 90;
					_swepS  = max(1, _swepS);
					
					var _r   = _range / dcos(_sweep);
					var sw0  = dir + _sweep;
					var sw1  = dir - ((_shape == LIGHT_SHAPE_2D.line_asym)? _swep2 : _sweep);
					var swS  = (_swepS - 1) / 2 * _swepA;
					var _alp = 1 / _swepS;
					
					for( var i = 1; i <= _swepS; i++ ) {
						
						var sw0x = lengthdir_x(_r, sw0 - swS + i * _swepA), sw0y = lengthdir_y(_r, sw0 - swS + i * _swepA);
						var sw1x = lengthdir_x(_r, sw1 + swS - i * _swepA), sw1y = lengthdir_y(_r, sw1 + swS - i * _swepA);
						
						draw_primitive_begin(pr_trianglestrip);
							draw_vertex_color(_start[0], _start[1], c_white, _alp);
							draw_vertex_color(_finis[0], _finis[1], c_white, _alp);
							draw_vertex_color(_start[0] + sw0x, _start[1] + sw0y, c_black, _alp);
							draw_vertex_color(_finis[0] + sw1x, _finis[1] + sw1y, c_black, _alp);
						draw_primitive_end();
						
					}
					
					if(_both) {
						var sw0 = dir + 180 - _sweep;
						var sw1 = dir + 180 + ((_shape == LIGHT_SHAPE_2D.line_asym)? _swep2 : _sweep);
						
						for( var i = 1; i <= _swepS; i++ ) {
						
							var sw0x = lengthdir_x(_r, sw0 - swS + i * _swepA), sw0y = lengthdir_y(_r, sw0 - swS + i * _swepA);
							var sw1x = lengthdir_x(_r, sw1 + swS - i * _swepA), sw1y = lengthdir_y(_r, sw1 + swS - i * _swepA);
						
							draw_primitive_begin(pr_trianglestrip);
								draw_vertex_color(_start[0], _start[1], c_white, _alp);
								draw_vertex_color(_finis[0], _finis[1], c_white, _alp);
								draw_vertex_color(_start[0] + sw0x, _start[1] + sw0y, c_black, _alp);
								draw_vertex_color(_finis[0] + sw1x, _finis[1] + sw1y, c_black, _alp);
							draw_primitive_end();
						}
						
					}
					break;	
				
				case LIGHT_SHAPE_2D.saber :
					draw_set_color(c_white);
					draw_line_round(_start[0], _start[1], _finis[0], _finis[1], _thick * 2, true, true, 64);
					
					var _r  = _range + _thick;
					var dir = point_direction(_start[0], _start[1], _finis[0], _finis[1]) + 90;
					
					draw_primitive_begin(pr_trianglestrip);
					draw_vertex_color(_start[0],                        _start[1],                        c_white, 1);
					draw_vertex_color(_finis[0],                        _finis[1],                        c_white, 1);
					draw_vertex_color(_start[0] + lengthdir_x(_r, dir), _start[1] + lengthdir_y(_r, dir), c_black, 1);
					draw_vertex_color(_finis[0] + lengthdir_x(_r, dir), _finis[1] + lengthdir_y(_r, dir), c_black, 1);
					draw_primitive_end();
					
					draw_primitive_begin(pr_trianglelist);
					var ox, oy, nx, ny;
					for( var i = 0; i <= 90; i++ ) {
						var _d = dir + i * 2;
						nx = _start[0] + lengthdir_x(_r, _d);
						ny = _start[1] + lengthdir_y(_r, _d);
						
						if(i) {
							draw_vertex_color(_start[0], _start[1], c_white, 1);
							draw_vertex_color(ox, oy, c_black, 1);
							draw_vertex_color(nx, ny, c_black, 1);
						}
						
						ox = nx;
						oy = ny;
					}
					draw_primitive_end();
					
					dir += 180;
					draw_primitive_begin(pr_trianglestrip);
					draw_vertex_color(_start[0],                        _start[1],                        c_white, 1);
					draw_vertex_color(_finis[0],                        _finis[1],                        c_white, 1);
					draw_vertex_color(_start[0] + lengthdir_x(_r, dir), _start[1] + lengthdir_y(_r, dir), c_black, 1);
					draw_vertex_color(_finis[0] + lengthdir_x(_r, dir), _finis[1] + lengthdir_y(_r, dir), c_black, 1);
					draw_primitive_end();
					
					draw_primitive_begin(pr_trianglelist);
					var ox, oy, nx, ny;
					for( var i = 0; i <= 90; i++ ) {
						var _d = dir + i * 2;
						nx = _finis[0] + lengthdir_x(_r, _d);
						ny = _finis[1] + lengthdir_y(_r, _d);
						
						if(i) {
							draw_vertex_color(_finis[0], _finis[1], c_white, 1);
							draw_vertex_color(ox, oy, c_black, 1);
							draw_vertex_color(nx, ny, c_black, 1);
						}
						
						ox = nx;
						oy = ny;
					}
					draw_primitive_end();
					
					break;	
					
				case LIGHT_SHAPE_2D.spot :
				case LIGHT_SHAPE_2D.flame :
					var dir  = point_direction(_start[0], _start[1], _finis[0], _finis[1]);
					var astr = dir - _sweep;
					var aend = dir + _sweep;
					var stp  = 2;
					var amo  = ceil(_sweep * 2 / stp);
					var ran  = point_distance(_start[0], _start[1], _finis[0], _finis[1]);
					var cc;
					
					draw_primitive_begin(pr_trianglelist);
						for( var i = 0; i < amo; i++ )  {
							var a0 = clamp(astr + (i    ) * stp, astr, aend);
							var a1 = clamp(astr + (i + 1) * stp, astr, aend);
							
							if(_shape == LIGHT_SHAPE_2D.spot)
								cc = c_white;
							else {
								var aa = amo > 2? 1. - abs(i / (amo - 1) - .5) * 2 : 1;
								    cc = _make_color_rgb(aa, aa, aa);
							}
							
							draw_vertex_color(_start[0],                        _start[1],                        cc,      1);
							draw_vertex_color(_start[0] + lengthdir_x(ran, a0), _start[1] + lengthdir_y(ran, a0), c_black, 1);
							draw_vertex_color(_start[0] + lengthdir_x(ran, a1), _start[1] + lengthdir_y(ran, a1), c_black, 1);
						}
					draw_primitive_end();
					break;	
			}
			
		surface_reset_shader(); 
		
		var _ls = temp_surface[0];
		
		surface_set_shader(temp_surface[1], sh_2d_light);
			draw_clear(c_black);
			
			shader_set_color("color", _color);
			shader_set_f("intensity", _inten * _color_get_alpha(_color));
			shader_set_f("band",      _band);
			shader_set_i("atten",     _attn);
			shader_set_f("exponent",  _expo);
			
			BLEND_OVERRIDE draw_surface_safe(_ls);
		surface_reset_shader();
		
		_ls = temp_surface[1];
		
		if(_aa) {
			surface_set_shader(temp_surface[2], sh_FXAA);
			gpu_set_texfilter(true);
			shader_set_2("dimension",  _dim);
			shader_set_f("cornerDis",  0.5);
			shader_set_f("mixAmo",     1);
			
			BLEND_OVERRIDE draw_surface_safe(_ls);
			gpu_set_texfilter(false);
			surface_reset_shader();
			
			_ls = temp_surface[2];
		}
		
		surface_set_target(_lightSurf);
			BLEND_ADD
			draw_surface_safe(_ls);
			BLEND_NORMAL
		surface_reset_target(); 
	}
	
	static processData = function(_outData, _data, _array_index) {
		var _surf  = _data[0];
		
		if(getInputAmount() == 0) return;
		
		#region visibility
			dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
			var _ind = input_fix_len + dynamic_input_inspecting * data_length;
			
			var _shape = _data[_ind +  0];
			var _attn  = _data[_ind + 10];
			
			inputs[_ind +  1].setVisible(false);
			inputs[_ind +  2].setVisible(false);
			inputs[_ind +  5].setVisible(false);
			inputs[_ind +  6].setVisible(false);
			inputs[_ind +  7].setVisible(false);
			inputs[_ind +  8].setVisible(false);
			inputs[_ind + 11].setVisible(false);
			inputs[_ind + 12].setVisible(false);
			inputs[_ind + 13].setVisible(false);
			inputs[_ind + 15].setVisible(false);
			inputs[_ind + 16].setVisible(false);
			inputs[_ind + 17].setVisible(false);
			inputs[_ind + 20].setVisible(false);
			inputs[_ind + 21].setVisible(false);
			inputs[_ind + 22].setVisible(false);
			inputs[_ind + 23].setVisible(false);
			
			switch(_shape) {
				case LIGHT_SHAPE_2D.point :
					inputs[_ind +  1].setVisible(true);
					inputs[_ind +  2].setVisible(true);
					inputs[_ind + 11].setVisible(true);
					inputs[_ind + 12].setVisible(true);
					inputs[_ind + 13].setVisible(true);
					break;
					
				case LIGHT_SHAPE_2D.ellipse :
					inputs[_ind +  1].setVisible(true);
					inputs[_ind + 15].setVisible(true);
					inputs[_ind + 16].setVisible(true);
					inputs[_ind + 17].setVisible(true);
					break;
					
				case LIGHT_SHAPE_2D.line :
				case LIGHT_SHAPE_2D.line_asym :
					inputs[_ind +  2].setVisible(true);
					inputs[_ind +  5].setVisible(true);
					inputs[_ind +  6].setVisible(true);
					inputs[_ind +  7].setVisible(true);
					inputs[_ind +  8].setVisible(_shape == LIGHT_SHAPE_2D.line_asym);
					inputs[_ind + 20].setVisible(true);
					inputs[_ind + 22].setVisible(true);
					inputs[_ind + 23].setVisible(true);
					break;
				
				case LIGHT_SHAPE_2D.saber :
					inputs[_ind +  2].setVisible(true);
					inputs[_ind +  5].setVisible(true);
					inputs[_ind +  6].setVisible(true);
					inputs[_ind + 21].setVisible(true);
					break;
					
				case LIGHT_SHAPE_2D.spot :
				case LIGHT_SHAPE_2D.flame :
					inputs[_ind + 5].setVisible(true);
					inputs[_ind + 6].setVisible(true);
					inputs[_ind + 7].setVisible(true);
					break;
			}
			
			inputs[_ind + 18].setVisible(_attn == 0 || _attn == 1);
		#endregion
		
		if(!is_surface(_surf)) return _outData;
		
		var _dim       = surface_get_dimension(_surf);
		var _outSurf   = surface_verify(_outData[0], _dim[0], _dim[1]);
		var _lightSurf = surface_verify(_outData[1], _dim[0], _dim[1]);
		
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba32float);
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1]);
		temp_surface[2] = surface_verify(temp_surface[2], _dim[0], _dim[1]);
		
		surface_set_target(_lightSurf);
			draw_clear(c_black);
		surface_reset_target();
		
		for( var i = 0; i < getInputAmount(); i++ ) {
			var _ind = input_fix_len + i * data_length;
			applyLight(_data, _ind, _lightSurf);
		}
		
		surface_set_shader(_outSurf, sh_2d_light_apply, true, BLEND.over);
			shader_set_surface("base",  _surf);
			shader_set_surface("light", _lightSurf);
			
			draw_empty();
		surface_reset_shader(); 
		
		return [ _outSurf, _lightSurf ];
	}
	
}