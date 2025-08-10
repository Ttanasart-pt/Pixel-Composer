function __MK_Dialog_Data() constructor {
	from = 0;
	to   = 1;
}

function Node_MK_Dialog(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Dialog";
	update_on_frame = true;
	setAlwaysTimeline(new timelineItemNode_MKDialog(self));
	
	newInput(26, nodeValueSeed());
	
	////- =Text
	newInput( 1, nodeValue_Text("Dialogs", [] )).setArrayDepth(1).setVisible(true, true);
	newInput( 4, nodeValue_Enum_Scroll(  "Change Case", 0, [ "None", "Lowercase", "Uppercase", "Titlecase" ] ));
	
	////- =Output
	newInput( 2, nodeValue_Enum_Scroll( "Output Dimension", 1, [ "Fixed", "Dynamic" ]));
	newInput( 0, nodeValue_Dimension());
	newInput( 3, nodeValue_Padding(     "Padding",          [0,0,0,0] ));
	
	////- =Alignment
	newInput(17, nodeValue_Enum_Button(  "H Align",           0, array_create(3, THEME.inspector_text_halign)));
	newInput(18, nodeValue_Enum_Button(  "V Align",           0, array_create(3, THEME.inspector_text_valign)));
	newInput(16, nodeValue_Int(          "Max Line Width",   0     ));
	newInput( 9, nodeValue_Float(        "Line Height",      0     ));
	
	////- =Font
	newInput( 5, nodeValue_Font()).setVisible(true, false);
	newInput( 6, nodeValue_Int(          "Size",             16    ));
	newInput( 7, nodeValue_Bool(         "Anti-aliasing ",   false ));
	/* unused */ newInput( 8, nodeValue_Float(        "Letter Spacing",   0     ));
	
	////- =Rendering
	/* unused */ newInput(10, nodeValue_Bool(         "Round Position",   true      ));
	newInput(11, nodeValue_Enum_Button(  "Blend Mode",       1, [ "Normal", "Alpha" ] ));
	newInput(12, nodeValue_Color(        "Color",            ca_white  ));
	newInput(13, nodeValue_Palette(      "Color by Letter", [ca_white] ))
		.setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	
	////- =Background
	newInput(14, nodeValue_Bool(         "Render Background", false    ));
	newInput(15, nodeValue_Color(        "BG Color",          ca_black ));
	
	////- =Timing
	newInput(24, nodeValue_Float(       "Start Frame",        0  ));
	newInput(19, nodeValue_Enum_Scroll( "Duration Type",      0, [ "Fixed", "Letter Count", "Word Count (space)" ] ));
	newInput(20, nodeValue_Float(       "Fixed Duration",     10 ));
	newInput(21, nodeValue_Float(       "Multiply Duration",  1  ));
	newInput(25, nodeValue_Float(       "Dialog Spacing",     0  ));
	
	////- =Manual Timer
	newInput(22, nodeValue_Bool(        "Manual Timer", false ));
	newInput(23, nodeValue_Struct(      "Manual Data",  []    )).setArrayDepth(1).setAnimable(false);
	
	////- =Transition
	// input 27
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
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
			var cc    = i == dynamic_input_inspecting? c_white : COLORS._main_icon;
			var tc    = i == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
			var hov   = _hover && point_in_rectangle(_m[0], _m[1], _x0, _yy - lh / 2, _x1, _yy + lh / 2 - 1);
			
			if(hov && _m[0] < _x1 - ui(32)) {
				tc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus)) {
					dynamic_input_inspecting = i;
					refreshDynamicDisplay();
					triggerRender();
				}
			}
			
			var _posi = getInputData(_ind + 0);
			var _anim = getInputData(_ind + 4);
			
			draw_sprite_ext(s_node_mk_dialog_position, _posi, _x0 + ui(8), _yy, 1, 1, 0, cc);
			
			var _title = animTypeList[_anim];
			switch(_posi) {
				case 0 : _title += " in";    break;
				case 1 : _title += " out";    break;
				case 2 : _title += " in/out"; break;
			}
			
			draw_set_text(f_p2, fa_left, fa_center, tc);
			draw_text_add(_x0 + ui(28), _yy, _title);
			
			var bs = ui(24);
			var bx = _x1 - bs;
			var by = _yy - bs / 2;
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
				del_animator = i;	
		}
		
		if(del_animator > -1) 
			deleteDynamicInput(del_animator);
		
		return _h + ui(32);
	});
	
	b_match_len  = button(function() /*=>*/ { if(!array_empty(dialogTimelineData)) TOTAL_FRAMES = ceil(array_last(dialogTimelineData).to); }).setText("Match Animation Length");
	b_reset_data = button(function() /*=>*/ { attributes.manual_position = []; triggerRender(); }).setText("Reset Timing");
	
	input_display_list = [ 26, 
		[ "Text",       false ], 1, 4, 
		[ "Output",     false ], 2, 0, 3, 
		[ "Alignment",  false ], 17, 18, 16, 9, 
		[ "Font",       false ], 5, 6, 7, 
		[ "Rendering",  false ], 11, 12, 13, 
		[ "Background", false, 14 ], 15, 
		
		new Inspector_Spacer(ui(4), true, false, ui(4)), 
		[ "Timing",       false ], 24, 19, 20, 21, 25, b_match_len, 
		[ "Manual Timer", false, 22 ], b_reset_data, 
		
		new Inspector_Spacer(ui(4), true, false, ui(4)), 
		animator_renderer, 
	];
	
	animTypeList     = [ "Transform", "Blending", "Wiggle", "Wave" ];
	positionTypeList = __enum_array_gen([ "Start", "End", "Start/End", "Always" ], s_node_mk_dialog_position, COLORS._main_icon_light);
	applyGroupList   = __enum_array_gen([ "Letter", "Words", "All" ], s_node_mk_dialog_apply_group, COLORS._main_icon_light);
	
	function createNewInput(i = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		dynamic_input_inspecting = getInputAmount();
		
		////- =Selection
		newInput(i+ 0, nodeValue_Enum_Scroll( "Track Position",    0, positionTypeList ));
		newInput(i+ 1, nodeValue_Enum_Scroll( "Apply Group",       0, applyGroupList   ));
		newInput(i+ 2, nodeValue_Slider(      "Origin",            0 ));
		newInput(i+14, nodeValue_Enum_Scroll( "Duration Type",     1, [ "Frame", "Ratio" ] ));
		newInput(i+ 3, nodeValue_Float(       "Duration",         .2 ));
		newInput(i+13, nodeValue_Slider(      "Range",            .1 ));
		
		////- =Effects
		newInput(i+ 4, nodeValue_Enum_Scroll( "Animation",         0, animTypeList ));
		newInput(i+ 5, nodeValue_Vec2(        "Position",         [0,0]     ));
		newInput(i+ 6, nodeValue_Rotation(    "Rotation",          0        ));
		newInput(i+ 7, nodeValue_Vec2(        "Scale",            [0,0]     ));
		newInput(i+ 8, nodeValue_Enum_Button( "Anchor type",       1, [ "Global", "Local" ]  ));
		newInput(i+ 9, nodeValue_Anchor(      "Anchor Position", [.5,.5])).setTooltip("Anchor point for transformation, absolute value for global type, relative for local.");
		newInput(i+10, nodeValue_Color(       "Color",             ca_white ));
		newInput(i+11, nodeValue_Slider(      "Alpha",             1        ));
		newInput(i+12, nodeValue_Vec2(        "Amplitude",        [4,4], { linked: true } ));
		newInput(i+15, nodeValue_Vec2(        "Frequency",        [4,4], { linked: true } ));
		newInput(i+16, nodeValue_Vec2(        "Speed",            [4,4], { linked: true } ));
		// 17
		
		refreshDynamicDisplay();
		return inputs[i];
	} 
	
	input_display_dynamic = [ 
		["Selection", false], 0, 1, 2, 14, 3, 13, 
		["Effects",   false], 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 16, 
	];
	
	setDynamicInput(17, false);
	
	////- Nodes
	
	font = f_p0;
	_font_current  = "";
	_size_current  = 0;
	_aa_current    = false;
	
	dialogTimelineData = [];
	dialogData  = [];
	trim_cache  = {};
	labelColors = [ CDEF.blue, CDEF.cyan, CDEF.yellow, CDEF.orange, CDEF.red, CDEF.pink, CDEF.purple, CDEF.lime ];
	
	curr_data = [];
	curr_seed = 0;
	wigg_maps = [];

	attributes.manual_position = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	////- Updates
	
	static generateFont = function(_path, _size, _aa) {
		if(PROJECT.animator.is_playing) return;
		if(font_exists(font) && _path == _font_current && _size == _size_current && _aa == _aa_current) return;
		
		_font_current = _path;
		_size_current = _size;
		_aa_current   = _aa;
		
		if(!file_exists_empty(_path)) return;
		
		if(font != f_p0 && font_exists(font)) font_delete(font);
		font_add_enable_aa(_aa);
		font = font_add(_path, _size, false, false, 0, 127);
		
		trim_cache  = {};
	}
	
	static trimLine = function(dialogTextDraw, _wrapWidth, _linh) {
		var _cacheKey = $"{dialogTextDraw}|{_wrapWidth}|{_linh}";
		if(struct_has(trim_cache, _cacheKey)) return trim_cache[$ _cacheKey];
		
		var _cut_lines   = string_split(dialogTextDraw, "\n");
		var _str_lines   = [];
		var _line_widths = [];
		var _curr_line   = "";
		var _curr_width  = 0;
		
		var _letter_counts = 0;
		var _word_counts   = 0;
		
		var str_w = 0;
		var str_h = 0;
		var lineh = string_height("l") + _linh;
		
		for( var i = 0, n = array_length(_cut_lines); i < n; i++ ) {
			var _line  = _cut_lines[i];
			var _words = string_split(_line, " ");
			
			_letter_counts += string_length(_line);
			_word_counts    = array_length(_words);
		
			_curr_line   = "";
			_curr_width  = 0;
			
			for( var j = 0, m = array_length(_words); j < m; j++ ) {
				var _word = _words[j] + " ";
				var _wwid = string_width(_word);
				
				if(_curr_width + _wwid > _wrapWidth) {
					if(_curr_line != "") {
						array_push(_str_lines,   _curr_line);
						array_push(_line_widths, _curr_width);
						
						str_w  = max(str_w, _curr_width);
						str_h += lineh;
					}
					
					_curr_line  = _word;
					_curr_width = _wwid;
					continue;
				}
				
				_curr_line  += _word;
				_curr_width += _wwid;
			}
			
			if(_curr_line != "") {
				array_push(_str_lines,   _curr_line);
				array_push(_line_widths, _curr_width);
				
				str_w  = max(str_w, _curr_width);
				str_h += lineh;
			}
		}
		
		str_h -= _linh;
		
		trim_cache[$ _cacheKey] = {
			str_lines:   _str_lines,
			line_widths: _line_widths, 
			
			width:  str_w,
			height: str_h, 
			linh:   _linh,
			
			letter_counts: _letter_counts,
			words_counts:  _word_counts,
		};
		
		return trim_cache[$ _cacheKey];
	}
	
	static drawDialog = function(dialogIndex, timerValue, _lineData, sw, sh) {
		
		var _str_lines   = _lineData.str_lines;
		var _line_widths = _lineData.line_widths;
		
		var str_w = _lineData.width;
		var str_h = _lineData.height;
		var _linh = _lineData.linh;
		
		var _padd = _lineData.padd;
	    var _hali = _lineData.hali;
	    var _vali = _lineData.vali;
	    
	    var _letter_counts = max(1, _lineData.letter_counts - 1);
	    var _word_counts   = max(1, _lineData.words_counts - 1);
		var _letter_curr   = 0;
		var _word_curr     = 0;

		var lineh = string_height("l") + _linh;
		var tx = _padd[2];
		var ty = _padd[1];
		
		switch(_vali) {
			case fa_top :    ty = _padd[1];              break;
			case fa_center : ty = sh / 2 - str_h / 2;    break;
			case fa_bottom : ty = sh - _padd[3] - str_h; break;
		}
		
		var _ani_amo    = getInputAmount();
		var _dialogData = dialogTimelineData[dialogIndex];
		var _localTime  = timerValue - _dialogData.from;
		var _localTimeR = _localTime / max(1, _dialogData.duration - 1);
		
		var _colr = curr_data[12];
		var _clet = curr_data[13], _cletLen = array_length(_clet), _cletTyp = inputs[13].attributes.array_select;
		
		var __temp_p = [ 0, 0 ];
			
		var _ax, _ay;
		var _charIndx = 0;
		
		for( var i = 0, n = array_length(_lineData.str_lines); i < n; i++ ) {
			var _line = _str_lines[i];
			var _widh = _line_widths[i];
			
			switch(_hali) {
				case fa_left :   tx = _padd[2];              break;
				case fa_center : tx = sw / 2 - _widh / 2;    break;
				case fa_right :  tx = sw - _padd[0] - _widh; break;
			}
			
			var j = 1;
			var chCount = string_length(_line);
			
			repeat(chCount) {
				var _ch  = string_char_at(_line, j);
				var ttx  = tx;
				var tty  = ty;
				
				var clti = _letter_curr;
				switch(_cletTyp) {
					case 0  : clti = _letter_curr % _cletLen; break;
					case 1  : clti = _letter_curr % (_cletLen * 2 - 1); 
							  if(clti >= _cletLen) clti = _cletLen * 2 - 1 - clti; break;
					case 2  : clti = irandom(_cletLen - 1);   break;
					default : clti = _letter_curr % _cletLen; break;
				}
				
				var clt  = _clet[clti];
				var cc   = colorMultiply(_colr, clt);
				var aa   = _color_get_alpha(cc);
				
				var xs   = 1;
				var ys   = 1;
				var rot  = 0;
				
				var chw = string_width(_ch);
				var chh = string_height(_ch);
				var k   = 0;
				
				repeat(_ani_amo) {
					var _aId = k; k++;
					var _ind = input_fix_len + _aId * data_length;
					
					var _anim_sel_pos = curr_data[_ind +  0];
					var _anim_sel_apl = curr_data[_ind +  1];
					var _anim_sel_ori = curr_data[_ind +  2];
					var _anim_sel_drt = curr_data[_ind + 14];
					var _anim_sel_dur = curr_data[_ind +  3];
					var _anim_sel_rng = curr_data[_ind + 13];
					
					var _anim_type = curr_data[_ind +  4];
					var _anim_posi = curr_data[_ind +  5];
					var _anim_rota = curr_data[_ind +  6];
					var _anim_scal = curr_data[_ind +  7];
					var _anim_anct = curr_data[_ind +  8];
					var _anim_ancc = curr_data[_ind +  9];
					var _anim_colr = curr_data[_ind + 10];
					var _anim_alph = curr_data[_ind + 11];
					
					var _anim_ampl  = curr_data[_ind + 12];
					var _anim_freq  = curr_data[_ind + 15];
					var _anim_speed = curr_data[_ind + 16];
					
					var _cur_prg = 0;
					var _local_dura = _anim_sel_drt? _anim_sel_dur : _anim_sel_dur / max(1, _dialogData.duration - 1);
					
					switch(_anim_sel_pos) {
						case 0 : _cur_prg = 1 - clamp(_localTimeR / _local_dura, 0, 1); break;
						
						case 1 : _cur_prg = clamp((_localTimeR - (1 - _local_dura)) / _local_dura, 0, 1); break;
						
						case 2 : _cur_prg = max(
								1 - clamp(_localTimeR / _local_dura, 0, 1),
								clamp((_localTimeR - (1 - _local_dura)) / _local_dura, 0, 1)
							); break;
							
						case 3 : _cur_prg = 1 - _local_dura; break;
					}
					
					_cur_prg = lerp(-_anim_sel_rng, 1 + _anim_sel_rng, _cur_prg);
					var _anim_sel_rng_st = _cur_prg - _anim_sel_rng;
					var _anim_sel_rng_ed = _cur_prg + _anim_sel_rng;
					
					var _an_prg = 0, _an_prg_raw = 0;
					switch(_anim_sel_apl) {
						case 0 : _an_prg = _letter_curr / _letter_counts; _an_prg_raw = _letter_curr; break;
						case 1 : _an_prg = _word_curr   / _word_counts;   _an_prg_raw = _word_curr;   break;
						case 2 : _an_prg = 1; _anim_sel_ori = .5;         _an_prg_raw = 0;            break;
					}
					
					var _an_dst = 1 - abs(_anim_sel_ori - _an_prg);
					var _an_inf = 1 - clamp((_an_dst - _anim_sel_rng_st) / max(_anim_sel_rng, 0.00001) / 2, 0, 1);
					if(_anim_sel_pos == 3) _an_inf = 1 - _an_inf;
					
					if(_an_inf == 0) continue;
					
					switch(_anim_type) {
						case 0 : 
							ttx += _anim_posi[0] * _an_inf;
							tty += _anim_posi[1] * _an_inf;
							
							var _dsx = _an_inf * _anim_scal[0];
							var _dsy = _an_inf * _anim_scal[1];
							
							if(_dsx != 0 || _dsy != 0) {
								if(_anim_anct == 0) { // global
									_ax = _anim_ancc[0];
									_ay = _anim_ancc[1];
									
								} else if(_anim_anct == 1) { // local
									_ax = ttx + _anim_ancc[0] * chw;
									_ay = tty + _anim_ancc[1] * chh;
									
								}
								
								ttx -= chw * _dsx * _anim_ancc[0];
								tty -= chh * _dsy * _anim_ancc[1];
								
								xs += _dsx;
								ys += _dsy;
							}
							
							var _dr = _an_inf * _anim_rota;
							if(_dr != 0) {
								rot += _dr;
								
								if(_anim_anct == 0) { // global
									_ax = _anim_ancc[0];
									_ay = _anim_ancc[1];
									
								} else if(_anim_anct == 1) { // local
									_ax = ttx + _anim_ancc[0] * chw * xs;
									_ay = tty + _anim_ancc[1] * chh * ys;
									
								}
								
								__temp_p = point_rotate(ttx, tty, _ax, _ay, _dr, __temp_p);
								ttx = __temp_p[0];
								tty = __temp_p[1];
							}
							
							break;
						
						case 1 : 
							cc  = merge_color(cc, colorMultiply(cc, _anim_colr), _an_inf);
							aa  = lerp(aa, aa * _anim_alph, _an_inf);
							break;
							
						case 2 : 
							var _wmap = wigg_maps[_aId];
							
							var _wigx = _wmap[0].get(round(_an_prg * 100) + CURRENT_FRAME);
							var _wigy = _wmap[1].get(round(_an_prg * 100) + CURRENT_FRAME);
							
							ttx += _wigx * _an_inf;
							tty += _wigy * _an_inf;
							break;
						
						case 3 : 
							var _wmap = wigg_maps[_aId];
							
							var _wavx = dsin(_an_prg_raw * _anim_freq[0] + CURRENT_FRAME * _anim_speed[0]) * _anim_ampl[0];
							var _wavy = dsin(_an_prg_raw * _anim_freq[1] + CURRENT_FRAME * _anim_speed[1]) * _anim_ampl[1];
							
							ttx += _wavx * _an_inf;
							tty += _wavy * _an_inf;
							break;
					}
				}
				
				draw_set_color(cc);
				draw_set_alpha(aa);
				
				if(xs == 1 && ys == 1 && rot == 0)
					 draw_text(ttx, tty, _ch);
				else draw_text_transformed(ttx, tty, _ch, xs, ys, rot);
				
				draw_set_alpha(1);
				
				tx += chw;
				
				_letter_curr++;
				_word_curr += _ch == " ";
				j++;
			}
			
			ty += lineh;
		}
		
	}
	
	static update = function() { 
		#region data
			curr_data    = array_create_ext(array_length(inputs), function(i) /*=>*/ {return getInputData(i)});
			
			curr_seed    = curr_data[26];
			random_set_seed(curr_seed);
			
			var _dimT    = curr_data[ 2];
			var _dim     = curr_data[ 0];
			var _padd    = curr_data[ 3];
			
			var _dias    = curr_data[ 1]; if(!is_array(_dias)) _dias = [ _dias ];
			var _case    = curr_data[ 4];
			
			var _hali    = curr_data[17];
			var _vali    = curr_data[18];
			var _trck    = curr_data[ 8];
			var _linw    = curr_data[16]; if(_linw <= 0) _linw = 99999;
			var _linh    = curr_data[ 9]; if(_linh <= 0) _linh = -1;
			
			var _font    = curr_data[ 5];
			var _size    = curr_data[ 6];
			var _aa      = curr_data[ 7];
			
			var _rond    = curr_data[10];
			var _blnd    = curr_data[11];
			var _colr    = curr_data[12];
			var _clet    = curr_data[13];
			
			var _bgcol   = curr_data[15];
			var _rbg     = curr_data[14];
			
			var _durStrt = curr_data[24];
			var _durType = curr_data[19];
			var _durTimF = curr_data[20];
			var _durTimM = curr_data[21];
			var _durSpac = curr_data[25];
			
			var _manUse  = curr_data[22];
			
			inputs[ 0].setVisible(_dimT == 0);
			inputs[21].setVisible(_durType != 0);
			
			var _ani_amo = getInputAmount();
			if(_ani_amo > 0) { // animator visibility
				dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
				var _ind = input_fix_len + dynamic_input_inspecting * data_length;
				
				var _trckPos  = getInputData(_ind + 0);
				var _animType = getInputData(_ind + 4);
				
				if(_trckPos == 3) {
					inputs[_ind + 14].setName("Range Type");
					inputs[_ind +  3].setName("Range");
					
					inputs[_ind + 13].setName("Soft Edge");
					
				} else {
					inputs[_ind + 14].setName("Duration Type");
					inputs[_ind +  3].setName("Duration");
					
					inputs[_ind + 13].setName("Range");
					
				}
					
				inputs[_ind +  5].setVisible(_animType == 0);
				inputs[_ind +  6].setVisible(_animType == 0);
				inputs[_ind +  7].setVisible(_animType == 0);
				inputs[_ind +  8].setVisible(_animType == 0);
				inputs[_ind +  9].setVisible(_animType == 0);
				inputs[_ind + 10].setVisible(_animType == 1);
				inputs[_ind + 11].setVisible(_animType == 1);
				inputs[_ind + 12].setVisible(_animType == 2 || _animType == 3);
				inputs[_ind + 15].setVisible(_animType == 2 || _animType == 3);
				inputs[_ind + 16].setVisible(_animType == 3);
			}
			
			wigg_maps = [];
			for( var i = 0; i < _ani_amo; i++ ) {
				var _ind  = input_fix_len + i * data_length;
				var _amp  = curr_data[_ind + 12];
				var _freq = curr_data[_ind + 15];
				
				var wigg_map_x = new wiggleMap(curr_seed + 100, _freq[0] / 10, 100, _amp[0]).generate();
				var wigg_map_y = new wiggleMap(curr_seed + 200, _freq[1] / 10, 100, _amp[1]).generate();
				
				wigg_maps[i] = [ wigg_map_x, wigg_map_y ];
			}
		#endregion
		
		#region text
		    __font = font;
		    if(is_string(_font))   { 
				inputs[6].setVisible(_font != "");
				inputs[7].setVisible(_font != "");
			 	
			 	generateFont(_font, _size, _aa); 
			 	__font = font; 
				
			} else if(font_exists(_font))
				__font = _font; 
			
			draw_set_font(__font);
			
			var _wrapWidth = 99999;
			switch(_dimT) {
				case 0 : _wrapWidth = min(_dim[0], _linw); break;
				case 1 : _wrapWidth = _linw;               break;
			}
			
		#endregion
		
		#region dialog
			var sw = _dim[0];
			var sh = _dim[1];
			
			if(_dimT == 1) { 
				sw = 0;
				sh = 0;
			}
			
			var dialogCount    = array_length(_dias);
			dialogTimelineData = array_create(dialogCount);
			
			var timerValue = CURRENT_FRAME;
			var _duraAcc   = _durStrt;
			
			for( var i = 0; i < dialogCount; i++ ) {
				var _text  = _dias[i];
				var _dText = _text;
					
				var _duration = _durTimF;
				switch(_durType) {
					case 1 : _duration += _durTimM * string_length(_text);     break;
					case 2 : _duration += _durTimM * string_count(" ", _text); break;
				}
				
				switch(_case) {
			        case 1 : _dText = string_lower(_text);     break;
			        case 2 : _dText = string_upper(_text);     break;
			        case 3 : _dText = string_titlecase(_text); break;
			    }
			    
				var _from = _duraAcc;
				var _to   = _duraAcc + _duration;
				
				if(_manUse) {
					var _manTimID = array_safe_get_fast(attributes.manual_position, i);
					
					if(!is(_manTimID, __MK_Dialog_Data)) {
						_manTimID      = new __MK_Dialog_Data();
						_manTimID.from = _from;
						_manTimID.to   = _to;
						attributes.manual_position[i] = _manTimID;
					}
					
					_from = _manTimID.from;
					_to   = _manTimID.to;
					_duration = _to - _from;
				}
				
				dialogTimelineData[i] = {
					from :     _from,
					to :       _to,
					duration : _duration,
					color :    labelColors[i % array_length(labelColors)],
					
					text :     _dText, 
					preview :  string_copy(_dText, 1, min(16, string_length(_dText))),
					
					active : false, 
				}
				
				_duraAcc += _duration + _durSpac;
				
				if(timerValue >= _from && timerValue < _to) {
					dialogTimelineData[i].active = true;
					    
				    var _lineData = trimLine(_dText, _wrapWidth, _linh);
					if(_dimT == 1) { 
						sw = max(sw, _lineData.width); 
						sh = max(sh, _lineData.height); 
					}
					
				}
			}
			
			sw = sw + _padd[0] + _padd[2];
			sh = sh + _padd[1] + _padd[3];
		#endregion
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, sw, sh);
		
		surface_set_target(_outSurf);
			if(_rbg) draw_clear(_bgcol, _color_get_alpha(_bgcol));
			else DRAW_CLEAR
			
			switch(_blnd) {
				case 0 : BLEND_NORMAL;     break;
				case 1 : BLEND_ALPHA_MULP; break;
			} 
			
			for( var i = 0, n = array_length(dialogTimelineData); i < n; i++ ) {
				var _data = dialogTimelineData[i];
				if(!_data.active) continue;
				
				var _lineData = trimLine(_data.text, _wrapWidth, _linh);
					_lineData.padd = _padd;
					_lineData.hali = _hali;
					_lineData.vali = _vali;
					    
				draw_set_text(__font, fa_left, fa_top, _colr, 1);
				drawDialog(i, timerValue, _lineData, sw, sh);
			}
			
			BLEND_NORMAL
			draw_set_alpha(1);
		surface_reset_target();
		
		outputs[0].setValue(_outSurf); 
	}
}

function timelineItemNode_MKDialog(_node) : timelineItemNode(_node) constructor {
	h = ui(40);
	
	dragging    = noone;
	drag_type   = 0;
	dragging_mx = 0;
	dragging_sx = 0;
	dragging_sy = 0;
	
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		if(!is(node, Node_MK_Dialog))      return;
		if(!node.attributes.show_timeline) return;
		
		var _manUse  = node.inputs[22].getValue();
		var _manTim  = node.attributes.manual_position;
		
		var _datas = node.dialogTimelineData;
		var _scs   = gpu_get_scissor();
		var _hh    = ui(20);
		
		var _editing = _manUse && show;
		h = _editing? array_length(_datas) * ui(20) : ui(20);
		
		for( var i = 0, n = array_length(_datas); i < n; i++ ) {
			var _data = _datas[i];
			var _time = _editing? array_safe_get(_manTim, i) : _data;
			if(!is_struct(_time)) _time = _data;
			
			var _dx = _x + (1 + _time.from) * _s;
			var _dy = _editing? _y + i * ui(20) : _y;
			
			var _dw = (_time.to - _time.from) * _s;
			var _dh = _hh;
			
			var _act = _data.active;
			var _hov = _editing && _hover && point_in_rectangle(_msx, _msy, _dx, _dy, _dx + _dw, _dy + _dh);
			if(_hov) {
				if(_msx < _dx + 12)       _hov = 2;
				if(_msx > _dx + _dw - 12) _hov = 3;
			}
			
			draw_sprite_stretched_ext(THEME.box_r2, 0, _dx, _dy + _dh - ui(4), _dw - 2, ui(4), _data.color, .3 + .5 * _act + .3 * bool(_hov));
			
			if(_hov == 2) draw_sprite_ext(THEME.circle, 0, _dx,       _dy + _dh - ui(2), .5, .5, 0, _data.color);
			if(_hov == 3) draw_sprite_ext(THEME.circle, 0, _dx + _dw, _dy + _dh - ui(2), .5, .5, 0, _data.color);
			
			draw_set_text(f_p4, fa_left, fa_bottom, _act? COLORS._main_text : COLORS._main_text_sub);
			gpu_set_scissor(_dx, _dy, _dw - 2, _dh);
			draw_text(_dx, _dy + _dh - ui(5), _data.preview);
			gpu_set_scissor(_scs);
			
			if(_hov && mouse_lpress(_focus)) {
				dragging    = _time;
				drag_type   = _hov;
				
				dragging_mx = _msx;
				dragging_sx = _data.from;
				dragging_sy = _data.to;
			}
		}
		
		gpu_set_scissor(_scs);
		
		if(dragging != noone) {
			var _dx = (_msx - dragging_mx) / _s;
			
			if(drag_type == 1) {
				dragging.from = dragging_sx + _dx;
				dragging.to   = dragging_sy + _dx;
				
			} else if(drag_type == 2) dragging.from = dragging_sx + _dx;
			  else if(drag_type == 3) dragging.to   = dragging_sy + _dx;
			
			if(mouse_lrelease()) {
				node.triggerRender();
				dragging = noone;
			}
		}
		
		return dragging == noone;
	}
	
	static onSerialize = function(_map) {
		_map.type = "timelineItemNode_MKDialog";
	}
}

