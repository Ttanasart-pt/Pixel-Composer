function Process_Anim_Track(_node = undefined) constructor {
	node    = _node;
	node_id = "";
	output  = 0;
	values  = [];
	title   = "";
	color   = c_white;
	
	animated = true;
	start    = 0;
	duration = 30;
	trans    = 0;
	tranRat  = .8;
	
	store    = false;
	receive  = false;
	shadow   = true;
	
	if(node != undefined) {
		values = array_create(array_length(node.inputs), noone);
		color  = choose(CDEF.blue, CDEF.yellow, CDEF.orange, CDEF.pink, CDEF.purple, CDEF.lime);
	}
	
	static getNode = function() /*=>*/ {
		if(node != undefined) return node;
		node = PROJECT.nodeMap[? node_id];
		return node;
	}
	
	static apply = function(_t) {
		getNode();
		if(!is(node, Node)) return;
		
		for( var i = 0, n = array_length(values); i < n; i++ ) {
			var ky = values[i];
			if(ky == noone) continue;
			
			var in = node.inputs[i];
			var vv;
			
			if(is_array(ky.valueStart)) {
				vv = [];
				for( var j = 0, m = array_length(ky.valueStart); j < m; j++ )
					vv[j] = lerp(ky.valueStart[j], ky.valueEnd[j], _t);
				
			} else
				vv = lerp(ky.valueStart, ky.valueEnd, _t);
			
			in.__tempValue = vv;
		}
		
	}
	
	static reset = function() {
		if(!is(node, Node)) return;
		
		for( var i = 0, n = array_length(values); i < n; i++ ) {
			var ky = values[i];
			if(ky == noone) continue;
			
			var in = node.inputs[i];
			in.__tempValue = undefined;
		}
	}
	
	static serialize = function() {
		var _m = {};
		
		_m.node      = node.node_id;
		_m.title     = title;
		_m.output    = output;
		_m.values    = variable_clone(values);
		_m.color     = color;
		_m.duration  = duration;
		_m.trans     = trans;
		_m.store     = store;
		_m.shadow    = shadow;
		_m.animated  = animated;
		
		return _m;
	}
	
	static deserialize = function(_m) {
		node_id  = _m.node;
		values   = variable_clone(_m.values);
		
		title    = _m[$ "title"]    ?? title;
		output   = _m[$ "output"]   ?? output;
		color    = _m[$ "color"]    ?? color;
		duration = _m[$ "duration"] ?? duration;
		trans    = _m[$ "trans"]    ?? trans;
		store    = _m[$ "store"]    ?? store;
		shadow   = _m[$ "shadow"]   ?? shadow;
		animated = _m[$ "animated"] ?? animated;
		
		return self;
	}
}

function Process_Anim() constructor {
	tracks = [];
	title  = "";
	titleColor = COLORS._main_accent;
	
	outputNode   = undefined;
	outputNodeID = -1;
	
	intro_duration = 60;
	outro_duration = 120;
		
	audio_intro   = "";
	audio_loop    = "";
	audio_outtro  = "";
	
	animated = false;
		
	static getOutputNode = function() {
		if(outputNode != undefined || outputNodeID == -1) return outputNode;
		outputNode = PROJECT.nodeMap[? outputNodeID];
		return outputNode;
	}
	
	static serialize = function() {
		var _m = {};
		
		_m.tracks = array_map(tracks, function(t) /*=>*/ {return t.serialize()} );
		_m.onode  = getOutputNode() == undefined? -1 : outputNode.node_id;
		
		_m.title           = title;
		_m.titleColor      = titleColor;
		
		_m.intro_duration  = intro_duration;
		_m.outro_duration  = outro_duration;
		
		_m.audio_intro     = audio_intro;
		_m.audio_loop      = audio_loop;
		_m.audio_outtro    = audio_outtro;
		
		_m.animated        = animated;
		
		return _m;
	}
	
	static deserialize = function(_m) {
		tracks = array_create(array_length(_m.tracks));
		for( var i = 0, n = array_length(_m.tracks); i < n; i++ )
			tracks[i] = new Process_Anim_Track().deserialize(_m.tracks[i]);
			
		outputNodeID    = _m[$ "onode"] ?? -1;
		title           = _m[$ "title"] ?? title;
		titleColor      = _m[$ "titleColor"] ?? titleColor;
		
		intro_duration  = _m[$ "intro_duration"]  ?? intro_duration;
		outro_duration  = _m[$ "outro_duration"]  ?? outro_duration;
		
		audio_intro     = _m[$ "audio_intro"]  ?? audio_intro;
		audio_loop      = _m[$ "audio_loop"]   ?? audio_loop;
		audio_outtro    = _m[$ "audio_outtro"] ?? audio_outtro;
		
		animated        = _m[$ "animated"] ?? animated;
		
		return self;
	}
}

function Process_Stored_Surface(_node, _surf) constructor {
	node    = _node;
	surface = _surf;
	process = 0;
	index   = 0;
	x = undefined;
	y = undefined;
	s = undefined;
	a = 0;
	
	w = surface_get_width_safe(surface);
	h = surface_get_height_safe(surface);
}

function Panel_Process_Maker() : PanelContent() constructor {
	context_str  = "Shorts";
	title    = "Process Maker";
	auto_pin = true;
	min_w    = ui(160)
	min_h    = ui(128)
	w        = ui(640);
	h        = ui(160);
	
	#region data
		playing       = false;
		play_frame    = 0;
		play_time     = 0;
		play_speed    = 1;
		preview_speed = 1/30;
		
		output_preview = false;
		
		prev_output    = noone;
		prev_surface   = noone;
		curr_output    = noone;
		
		temp_surface   = array_create(4, noone);
		output_surface = noone;
		output_width   = 900;
		output_height  = 1600;
		
		stored_surface = [];
		stored_map     = {};
		
		exporting     = false;
		export_dir    = "";
		
		view_thumbnail = false;
		show_all_prop  = false;
	#endregion
	
	#region track
		track_sel     = undefined;
		
		prev_track    = noone;
		curr_track    = noone;
		
		total_length  = 0;
		track_len     = 0; 
		track_height  = ui(32);
		track_x       = 0;
		track_x_to    = 0;
		track_x_max   = 0;
		track_w       = 0;
		track_scale   = 2.5;
		
		scrubbing     = false;
		scrub_frame   = undefined;
		
	#endregion
	
	#region audio
		audio_loop_curr = "";
		audio_loop_dura = 0;
	#endregion
	
	#region widgets
		editing       = undefined;
		editing_type  = 0;
		tb_value_edit = textBox_Number(function(v) /*=>*/ {
			if(editing == undefined) return;
			     if(editing_type == 0) editing.valueStart = v;
			else if(editing_type == 1) editing.valueEnd   = v;
			editing = undefined;
			
		}).setFont(f_p4).setAlign(fa_right);
		
		tb_title          = textBox_Text(   function(t) /*=>*/ { PROJECT.trackAnim.title = t; }).setFont(f_p3).setEmpty();
		tb_track_title    = textBox_Text(   function(t) /*=>*/ { if(is(track_sel, Process_Anim_Track)) track_sel.title    = t; }).setFont(f_p3).setEmpty();
		tb_track_duration = textBox_Number( function(t) /*=>*/ { 
			if(track_sel == undefined) return;
			
			     if(track_sel == -10) PROJECT.trackAnim.intro_duration = t;
			else if(track_sel == -20) PROJECT.trackAnim.outro_duration = t;
			else                      track_sel.duration = t; 
			
		}).setFont(f_p3).setEmpty();
		cl_title_color    = new buttonColor(function(c) /*=>*/ { PROJECT.trackAnim.titleColor = c; }).isSimple();
		
		sp_transition  = new scrollBox([ 
			"None", "Wipe Diagonal", "Wipe Diagonal Inv", "Wipe Hori", "Wipe Hori Inv", "Wipe Vert", "Wipe Vert Inv",  
			-1, 
			"Wipe Circle In", "Wipe Circle Out", "Wipe Square In", "Wipe Square Out", "Wipe Plus In", "Wipe Plus Out", 
			-1,
			"Fade", "Morph", 
		], function(i) /*=>*/ { if(is(track_sel, Process_Anim_Track)) track_sel.trans = i; }).setFont(f_p3);
	#endregion
	
	#region hotkey
		var t = "Shorts";
		var n = MOD_KEY.none;
		var c = MOD_KEY.ctrl;
		var s = MOD_KEY.shift;
		var a = MOD_KEY.alt;
		
		registerFunction(t, "Play/Pause", vk_space, n, function() /*=>*/ { 
			if(!playing) togglePlay(true, 1); 
			else if(play_speed == 1) play_speed = 5;
			else togglePlay(false, 1); 
		} ).hotkey.setInterrupt();
		
		registerFunction(t, "Resume", vk_space, s, function() /*=>*/ { togglePlay(false, 1); } ).hotkey.setInterrupt();
	#endregion
	
	sc_prop_start = new scrollPane(1, 1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _node = track_sel.getNode();
		var _vals = track_sel.values;
		
		var hov = sc_prop_start.hover;
		var foc = sc_prop_start.active;
		var ww  = sc_prop_start.surface_w;
		
		var yy = _y + ui(8);
		var hh = ui(8);
		var hg = line_get_height(f_p4, 4);
		var bs = hg;
		var _c = [ COLORS._main_icon, COLORS._main_icon_light ];
		
		var dsp = !show_all_prop && is_array(_node.input_display_list);
		var amo = dsp? array_length(_node.input_display_list) : array_length(_node.inputs);
		var _inp, _ind;
		
		for( var i = 0; i < amo; i++ ) {
			if(!dsp) {
				_ind = i;
				_inp = _node.inputs[i];
				
			} else {
				_ind = _node.input_display_list[i];
				if(!is_numeric(_ind)) continue;
				_inp = _node.inputs[_ind];
			}
			
			if(!is(_inp, NodeValue) || (!show_all_prop && !_inp.show_in_inspector)) continue;
			
			var _name = _inp.getName();
			var _val  = array_safe_get(_vals, _ind, noone);
			
			var bx = ui(8);
			var by = yy - ui(2);
			var bc = _val == noone? _c : COLORS._main_accent;
			var b  = buttonInstant(noone, bx, by, bs, bs, _m, hov, foc, "", THEME.animate_clock, 0, bc, .9);
			if(b == 3) _val = noone;
			if(b == 2) {
				var _v = _inp.getValue();
				
				if(_val == noone)
					_vals[_ind] = { valueStart : _v, valueEnd : _v, }
				else
					_vals[_ind].valueStart = _v;
			}
			
			draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text);
			draw_text_add(ui(32), yy, _name);
			
			if(_val != noone) {
				var bx = ww - bs;
				var by = yy - ui(2);
				var b  = buttonInstant(noone, bx, by, bs, bs, _m, hov, foc, "", THEME.gear_16, 0, _c, .9);
				if(b == 2) {
					editing       = _val;
					editing_type  = 0;
					tb_value_edit.activate(_val.valueStart);
					
				} bx -= ui(4);
				
				if(editing == _val && editing_type == 0) {
					var bw = ui(100);
					tb_value_edit.setFocusHover(foc, hov);
					tb_value_edit.draw(bx - bw, yy - ui(4), bw, bs, _val.valueStart, _m);
					
				} else {
					draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text_sub);
					draw_text_add(bx, yy, _val.valueStart);
				}
			}
			
			yy += hg + ui(0);
			hh += hg + ui(0);
		}
			
		return hh + ui(8);
	});
	
	sc_prop_end = new scrollPane(1, 1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _node = track_sel.getNode();
		var _vals = track_sel.values;
		
		var hov = sc_prop_end.hover;
		var foc = sc_prop_end.active;
		var ww  = sc_prop_end.surface_w;
		
		var yy = _y + ui(8);
		var hh = ui(8);
		var hg = line_get_height(f_p4, 4);
		var bs = hg;
		var _c = [ COLORS._main_icon, COLORS._main_icon_light ];
		
		var dsp = !show_all_prop && is_array(_node.input_display_list);
		var amo = dsp? array_length(_node.input_display_list) : array_length(_node.inputs);
		
		for( var i = 0; i < amo; i++ ) {
			if(!dsp) {
				_ind = i;
				_inp = _node.inputs[i];
				
			} else {
				_ind = _node.input_display_list[i];
				if(!is_numeric(_ind)) continue;
				_inp = _node.inputs[_ind];
			}
			
			if(!is(_inp, NodeValue) || (!show_all_prop && !_inp.show_in_inspector)) continue;
			
			var _name = _inp.getName();
			var _val  = array_safe_get(_vals, _ind, noone);
			
			var bx = ui(8);
			var by = yy - ui(2);
			var bc = _val == noone? _c : COLORS._main_accent;
			var b  = buttonInstant(noone, bx, by, bs, bs, _m, hov, foc, "", THEME.animate_clock, 0, bc, .9);
			if(b == 3) _val = noone;
			if(b == 2) {
				var _v = _inp.getValue();
				
				if(_val == noone)
					_vals[_ind] = { valueStart : _v, valueEnd : _v, }
				else
					_vals[_ind].valueEnd = _v;
			}
			
			draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text);
			draw_text_add(ui(32), yy, _name);
			
			if(_val != noone) {
				var bx = ww - bs;
				var by = yy - ui(2);
				var b  = buttonInstant(noone, bx, by, bs, bs, _m, hov, foc, "", THEME.gear_16, 0, _c, .9);
				if(b == 2) {
					editing       = _val;
					editing_type  = 1;
					tb_value_edit.activate(_val.valueEnd);
					
				} bx -= ui(4);
				
				if(editing == _val && editing_type == 1) {
					var bw = ui(100);
					tb_value_edit.setFocusHover(foc, hov);
					tb_value_edit.draw(bx - bw, yy - ui(4), bw, bs, _val.valueEnd, _m);
					
				} else {
					draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text_sub);
					draw_text_add(bx, yy, _val.valueEnd);
				}
			}
			
			yy += hg + ui(0);
			hh += hg + ui(0);
		}
			
		return hh + ui(8);
	});
	
	function addNodeTrack(_node) {
		var _track = new Process_Anim_Track(_node);
		array_push(PROJECT.trackAnim.tracks, _track);
		track_sel = _track;
	}
	
	function insertNodeTrack(_pos, _node) {
		var _track = new Process_Anim_Track(_node);
		array_insert(PROJECT.trackAnim.tracks, _pos, _track);
		track_sel = _track;
		
		refreshTracks(false);
	}
	
	function refreshTracks(_render = true) {
		output_preview = false;
		var _outNode = PROJECT.trackAnim.getOutputNode();
		if(is(_outNode, Node)) { 
			var _prec = _outNode.getPreviewValues();
			if(is_surface(_prec)) output_preview = true;
		}
				
		track_len = output_preview * PROJECT.trackAnim.intro_duration;
		for( var i = 0, n = array_length(PROJECT.trackAnim.tracks); i < n; i++ ) {
			var t = PROJECT.trackAnim.tracks[i];
			t.start    = track_len;
			track_len += t.duration;
		}
		
		total_length = track_len + output_preview * PROJECT.trackAnim.outro_duration;
		
		if(_render) RenderAll();
	}
	
	function resetTracks() {
		PROJECT.animator.is_rendering = false;
		
		stored_surface = [];
		stored_map     = {};
		
		for( var i = 0, n = array_length(PROJECT.trackAnim.tracks); i < n; i++ )
			PROJECT.trackAnim.tracks[i].reset();
	}
	
	function togglePlay(_reset = true, _speed = 1, _export = false) {
		playing   = !playing;
		play_time = 0;
		if(_reset) play_frame = 0;
		
		play_speed = _speed;
		exporting  = _export;
		
		refreshTracks();
		
		if(!playing) resetTracks();
	}
	
	function RenderOutput(_step = 0, _data = noone, _trans = 0) {
		temp_surface[0] = surface_verify(temp_surface[0], output_width, output_height);
		temp_surface[3] = surface_verify(temp_surface[3], output_width, output_height);
		output_surface  = surface_verify(output_surface,  output_width, output_height);
		
		#region title
			draw_set_font(f_pixel);
			var lw = (output_width - 192) / 6;
			var tt = PROJECT.trackAnim.title == ""? filename_name_only(PROJECT.path) : PROJECT.trackAnim.title;
			if(tt == "") tt = "Untitled";
			var text_w = string_width_ext(tt, -1, lw)  * 6 + 128;
			var text_h = string_height_ext(tt, -1, lw) * 6 + 128;
			temp_surface[1] = surface_verify(temp_surface[1], text_w, text_h);
			temp_surface[2] = surface_verify(temp_surface[2], text_w, text_h);
			
			surface_set_shader(temp_surface[1]);
				DRAW_CLEAR
				draw_set_text(f_pixel, fa_center, fa_center, PROJECT.trackAnim.titleColor);
				draw_text_ext_transformed(text_w/2, text_h/2, tt, -1, lw, 6, 6, 0);
			surface_reset_shader();
			
			surface_set_shader(temp_surface[2], sh_blur_simple);
				shader_set_2("dimension",     [text_w, text_h] );
				shader_set_f("size",          64 );
				shader_set_i("useMask",       0  );
				shader_set_i("gamma",         0  );
				shader_set_i("useGradient",   0  );
				shader_set_i("overrideColor", 1  );
				shader_set_c("overColor",     PROJECT.trackAnim.titleColor  );
				
				draw_surface(temp_surface[1], 0, 0);
			surface_reset_shader();
			
		#endregion
		
		var cx = output_width  / 2;
		var cy = output_height / 2 - 64;
		var nx = cx;
		var ny = cy;
		var prg = 0;
		
		surface_set_target(temp_surface[3]);
			DRAW_CLEAR
			
			switch(_step) {
				case 0 :
					if(!is_surface(_data)) break;
					var sw = surface_get_width(_data);
					var sh = surface_get_height(_data);
					var ss = min((output_width - 192) / sw, (output_height - 192) / sh);
					
					var prg = clamp(play_frame / (PROJECT.trackAnim.intro_duration * .6), 0, 1);
					    prg = smoothstep_cubic(prg);
					var ds  = PROJECT.trackAnim.animated? ss : ss * lerp(.6, 1, prg);
					
					var x0 = cx - sw * ds / 2;
					var y0 = cy - sh * ds / 2;
					
					var iprg = clamp((1 - play_frame / PROJECT.trackAnim.intro_duration) * 5, 0, 1);
					    iprg = smoothstep_cubic(iprg);
					    
					draw_surface_ext(_data, x0, y0, ds, ds, 0, c_white, 1);
					
					ny = cy + sh * ss / 2 + 64;
					
					draw_set_text(f_pixel, fa_center, fa_top, COLORS._main_text);
					draw_text_transformed(nx, ny, $"In {array_length(PROJECT.trackAnim.tracks)} steps", 4, 4, 0);
					break;
					
				case 1 :
					if(_data == noone) break;
					var _node = _data.getNode();
					if(!is(_node, Node)) break;
					
					var _outp = _node.outputs[_data.output];
					var _outv = undefined;
					
					if(_outp.type == VALUE_TYPE.surface)
						 _outv = _outp.getValue();
					else _outv = _node.getGraphPreviewSurface();
						
					if(is_surface(_outv)) {
						if(curr_output != _outp) {
							prev_output = curr_output;
							curr_output = _outp;
							
							prev_track  = curr_track;
							curr_track  = _data;
						}
						
						var sw = surface_get_width(_outv);
						var sh = surface_get_height(_outv);
						var ss = min((output_width - 192) / sw, (output_height - 192) / sh);
						
						var x0 = cx - sw * ss / 2;
						var y0 = cy - sh * ss / 2;
						
						if(!_data.shadow) {
							draw_sprite_stretched(THEME.box_r5, 0, x0, y0, sw * ss, sh * ss);
							gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_zero, bm_one);
							draw_sprite_stretched_ext(THEME.box_r5, 0, x0, y0, sw * ss, sh * ss, CDEF.main_mdblack, 1);
							draw_sprite_tiled_ext(s_transparent, 0, x0, y0, 4, 4, CDEF.main_black, 1);
							BLEND_NORMAL
						}
						
						if(_data.trans) {
							var _prev_surface = noone;
							if(prev_output) {
								_prev_surface = prev_output.getValue();
								if(!is_surface(_prev_surface))
									_prev_surface = prev_output.node.getGraphPreviewSurface();
									
								if(is_surface(_prev_surface) && !prev_track.shadow) {
									prev_surface = surface_verify(prev_surface, sw * ss, sh * ss);
									
									surface_set_target(prev_surface);
										draw_sprite_stretched(THEME.box_r5, 0, 0, 0, sw * ss, sh * ss);
										gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_zero, bm_one);
										draw_sprite_stretched_ext(THEME.box_r5, 0, 0, 0, sw * ss, sh * ss, CDEF.main_mdblack, 1);
										draw_sprite_tiled_ext(s_transparent, 0, 0, 0, 4, 4, CDEF.main_black, 1);
										draw_surface_ext(_prev_surface, 0, 0, ss, ss, 0, c_white, 1);
										BLEND_NORMAL
									surface_reset_target();
									
									_prev_surface = prev_surface;
								}
							}
							
							shader_set(sh_process_maker_transition);
								shader_set_i("type",     _data.trans);
								shader_set_f("progress", _trans);
								shader_set_s("prevSurf", _prev_surface);
								
								draw_surface_ext(_outv, x0, y0, ss, ss, 0, c_white, 1);
							shader_reset();
							
						} else draw_surface_ext(_outv, x0, y0, ss, ss, 0, c_white, 1);
						
						BLEND_NORMAL
						
						ny = y0 + sh * ss + 64;
					}
					
					if(_node.drawProcessShort != undefined) {
						var size = output_width - 192;
						var cush = _node.drawProcessShort(cx, cy, size, size, _trans);
						
						if(cush != undefined) ny = cy + cush / 2 + 64;
					}
					
					var _name = _data.title == ""? _node.getDisplayName() : _data.title;
					draw_set_text(f_pixel, fa_center, fa_top, COLORS._main_text);
					draw_text_transformed(nx, ny, _name, 4, 4, 0);
					break;
			
				case 2 :
					if(!is_surface(_data)) break;
					var sw = surface_get_width(_data);
					var sh = surface_get_height(_data);
					var ss = min((output_width - 192) / sw, (output_height - 192) / sh);
					var s2 = min((output_width -  64) / sw, (output_height -  64) / sh);
					
					var pss = smoothstep_bounce(clamp(_trans * 6, 0, 1));
					var prg = smoothstep_bounce(clamp(_trans * 2, 0, 1));
					var ds  = lerp(ss, s2, pss);
					var x0 = cx - sw * ds / 2;
					var y0 = cy - sh * ds / 2;
					
					shader_set(sh_process_maker_shine);
						shader_set_2("dimension", [ sw, sh ] );
						shader_set_f("frame",     play_frame );
						shader_set_f("progress",  prg        );
						
						draw_surface_ext_safe(_data, x0, y0, ds, ds, 0, c_white, 1);
					shader_reset();
					
					iprg = prg;
					ny   = cy + sh * ss / 2 + 64;
					
					draw_set_text(f_pixel, fa_center, fa_top, COLORS._main_text);
					draw_text_transformed(nx, ny, $"Success!!", 4, 4, 0);
					break;
			}
		surface_reset_target();
		
		surface_set_target(temp_surface[0]);
			draw_clear(CDEF.main_bg);
			
			gpu_set_tex_filter(true);
			draw_sprite_tiled_ext(s_workshop_bg, 0, -play_frame, -play_frame, 1, 1, c_white, 1);
			gpu_set_tex_filter(false);
			
			switch(_step) {
				case 0 : 
				case 2 : 
					if(!is_surface(_data)) break;
					shader_set(sh_process_maker_ending_trans);
						shader_set_s("surface",  _data );
						shader_set_2("scale",    [ output_width/sw, output_height/sh ] );
						shader_set_f("size",     ss / 2.5         );
						shader_set_f("frame",    play_frame       );
						shader_set_f("progress", iprg             );
						shader_set_c("blend",    CDEF.main_dkgrey );
						
						draw_empty();
					shader_reset();
					break;
			}
			
			var _intensity = .5;
			
			shader_set(sh_process_maker_shadow);
				shader_set_2("dimension", [ output_width, output_height ] );
				shader_set_f("shadow",     48 );
				shader_set_f("intensity",  _intensity );
				shader_set_c("color",      c_black );//#1e1e2b );
				
				draw_surface(temp_surface[3], 0, 0);
			shader_reset();
			
			if(_step == 1) {
				var stsx = 112;
				var stsy = 448;
				var stss = 192;
				var stos;
				
				for( var i = 0, n = array_length(stored_surface); i < n; i++ ) {
					stos   = stored_surface[i];
					var _surf = stos.surface;
					if(!is_surface(_surf)) continue;
					
					var sw = surface_get_width(_surf);
					var sh = surface_get_height(_surf);
					var ss = min((output_width - 256) / sw, (output_height - 256) / sh);
					
					stos.x = stos.x ?? cx;
					stos.y = stos.y ?? cy;
					stos.s = stos.s ?? ss;
					
					if(stos.process) {
						stos.a = lerp(stos.a,  1,     .2);
						var _x = lerp(stos.x, cx, stos.a);
						var _y = lerp(stos.y, cy, stos.a);
						var _s = lerp(stos.s, ss, stos.a);
						
						var _sxx = _x - stos.w * _s / 2;
						var _syy = _y - stos.h * _s / 2;
						
						draw_surface_ext(stos.surface, _sxx, _syy, _s, _s, 0, c_white, 1 - stos.a);
						
					} else {
						
						var _stsx = stsx;
						var _stsy = stsy; stsy += stss + 4;
						var _stss = (stss - 32) / stos.h;
						
						stos.x = lerp(stos.x, _stsx, .2);
						stos.y = lerp(stos.y, _stsy, .2);
						stos.s = lerp(stos.s, _stss, .2);
						
						var _sxx = stos.x - stos.w * stos.s / 2;
						var _syy = stos.y - stos.h * stos.s / 2;
						
						draw_surface_ext(stos.surface, _sxx, _syy, stos.s, stos.s, 0, c_white, 1);
					}
					
				}
			}
			
			var _ttx = output_width/2 - text_w/2;
			var _tty = 200 - text_h/2;
			
			draw_set_text(f_pixel, fa_center, fa_center, COLORS._main_text_sub);
			var ss = 4 + .3 * dsin(play_frame * 6);
			draw_text_transformed(224, _tty + 56, "How to make", ss, ss, 20);
			
			draw_surface(temp_surface[1], _ttx, _tty);
			BLEND_ADD 
			draw_surface_ext(temp_surface[2], _ttx, _tty, 1, 1, 0, c_white, .75);
			draw_surface_ext(temp_surface[2], _ttx, _tty, 1, 1, 0, c_white, .75);
			if(_step == 2) draw_surface_ext(temp_surface[2], _ttx, _tty, 1, 1, 0, c_white, prg);
			BLEND_NORMAL
			
			#region track list
				var _amo = array_length(PROJECT.trackAnim.tracks);
				var _siz = 72;
				var _col = floor((output_width - 96) / _siz);
				var _row = ceil(_amo / _col);
				var _rendered = true;
				
				gpu_set_tex_filter(true);
				for( var i = 0; i < _row; i++ ) {
					var _cCol = min(_col, _amo - i * _col);
					var _sx   = output_width / 2 - _cCol * _siz / 2;
					var _yy   = ny + 96 + i * _siz;
					
					for( var j = 0; j < _cCol; j++ ) {
						var _xx  = _sx + j * _siz;
						var _ind = i * _col + j;
						
						var t = PROJECT.trackAnim.tracks[_ind];
						var _n     = t.getNode();
						if(_n.node_database == undefined) break;
						
						var spr = _n.node_database.spr;
						var thx = _xx + _siz / 2;
						var thy = _yy + _siz / 2;
						var rr  = (dsin(play_frame * 6) * 15) * (_ind % 2 - .5) * 2;
						var ss  = (_siz - 24) / 64;
						var aa  = 1;
						
						if(_step == 1) {
							aa = .4 + .6 * (_data == t);
							if(_data == t) _rendered = false;
						}
						
						draw_sprite_ext(spr, 0, thx, thy, ss, ss, rr, c_white, aa);
					}
				}
				gpu_set_tex_filter(false);
			#endregion
			
			gpu_set_tex_filter(true);
			draw_sprite_uniform(s_title, 0, output_width - 16 - 512*.8, output_height - 16 - 80*.8, .8);
			gpu_set_tex_filter(false);
			
			if(PROJECT.trackAnim.audio_loop != "") {
				var _sound = PROJECT.trackAnim.audio_loop;
				var _sname = filename_name_only(_sound);
				var _authr = filename_name_only(filename_dir(_sound));
				
				var i = 1;
				var a = string_length(_sname);
				var s = "";
				repeat(a) {
					var ch = string_char_at(_sname, i);
					if(i > 1 && char_is_upper(ch)) 
						s += " ";
					s += ch;
					i++;
				}
				
				var aa = 1 - clamp((play_frame - 45) / 30, 0, 1);
				draw_set_alpha(aa);
				
				var tx = output_width - 16;
				var ty = 16;
				
				draw_set_text(f_pixel, fa_right, fa_top, COLORS._main_text);
				draw_text_transformed(tx, ty, s, 2.5, 2.5, 0);
				tx -= string_width(s) * 2.5 + 8;
				
				draw_sprite_ui(THEME.play_sound, 1, tx - 24, ty + 16, 1, 1, 0, COLORS._main_text, aa * .8);
				ty += string_height(s) * 2.5;
				
				draw_set_text(f_pixel, fa_right, fa_top, COLORS._main_text_sub);
				draw_text_transformed(output_width - 16, ty, _authr, 2, 2, 0);
				draw_set_alpha(1);
			}
			
		surface_reset_target();
		
		#region vignette
			surface_set_shader(output_surface, sh_vignette);
				shader_set_i("light", 0 );
				
				shader_set_2("exposure",     [50,50] );
				shader_set_i("exposureUseSurf",   0  ); 
				
				shader_set_2("strength",     [.5,.5] );
				shader_set_i("strengthUseSurf",   0  ); 
				
				shader_set_2("smoothness",     [0,0] ); 
				shader_set_i("smoothnessUseSurf", 0  ); 
				
				draw_surface(temp_surface[0], 0, 0);
			surface_reset_shader();
		#endregion
		
		PANEL_PREVIEW.__temp_preview = output_surface;
		
		if(exporting) {
			var _fname = filename_combine(export_dir, $"{string_lead_zero(play_frame, 5)}.png");
			surface_save(output_surface, _fname);
		}
	}
	
	function trackStart(_t) {
		var _node = _t.getNode();
		var _from = _node.getNodeFrom();
		
		for( var i = 0, n = array_length(_from); i < n; i++ ) {
			var fn = _from[i].node_id;
			
			if(has(stored_map, fn)) {
				var sr = stored_map[$ fn];
				sr.process = 1;
				_t.receive = true;
			}
		}
	}
	
	function trackStore(_t) {
		var _node = _t.getNode();
		var _outp = _node.outputs[_t.output];
		var _surf = _outp.getValue();
		if(!is_surface(_surf)) return;
		
		var _st   = new Process_Stored_Surface(_node, _surf);
		_st.index = array_length(stored_surface);
		array_push(stored_surface, _st);
		stored_map[$ _node.node_id] = _st;
	}
	
	function Player() {
		if(!playing) return;
		
		if(play_speed != infinity) {
			play_time += DELTA_TIME * play_speed;
			if(play_time < preview_speed) return;
			play_time = play_time - preview_speed;
		}
		
		PROJECT.animator.is_rendering = true;
		
		play_frame++;
		PlayFrame(play_frame);
	}
	
	function PlayFrame(_fr) {
		play_frame = _fr;
		
		if(output_preview && play_frame <= PROJECT.trackAnim.intro_duration) {
			var _outNode = PROJECT.trackAnim.getOutputNode();
			var _prec    = _outNode.getPreviewValues();
			
			if(PROJECT.trackAnim.animated) {
				var fr = floor(play_frame % GLOBAL_TOTAL_FRAMES);
				PROJECT.animator.setFrame(fr);
			}
			RenderOutput(0, _prec);
			
			if(play_frame == PROJECT.trackAnim.intro_duration) {
				for( var i = 0, n = array_length(PROJECT.trackAnim.tracks); i < n; i++ )
					PROJECT.trackAnim.tracks[i].apply(0);
				RenderAll();
			}
			
		} else if(play_frame < track_len) {
			var _currTrack = noone;
			var _currTrans = 0;
			
			for( var i = 0, n = array_length(PROJECT.trackAnim.tracks); i < n; i++ ) {
				var t = PROJECT.trackAnim.tracks[i];
				var ts = t.start;
				var te = t.start + t.duration;
				
				var rt = (play_frame - ts) / (t.duration * t.tranRat);
				    rt = smoothstep_cubic(clamp(rt, 0, 1));
				
				t.apply(rt);
				if(play_frame >= ts && play_frame < te) {
					if(PROJECT.trackAnim.animated && t.animated) {
						var fr = floor((play_frame - ts) / t.duration * GLOBAL_TOTAL_FRAMES);
						PROJECT.animator.setFrame(fr);
					}
					
					_currTrack = i;
					_currTrans = rt;
					t.node.rendered = false;
				}
				
				if(play_frame == ts && !scrubbing) 
					trackStart(t);
					
				if(play_frame == te && !scrubbing && t.store) 
					trackStore(t);
			}
			
			var currtr = _currTrack == noone? noone : PROJECT.trackAnim.tracks[_currTrack];
			if(currtr != noone) {
				track_sel = currtr;
				
				if(PROJECT.trackAnim.animated && currtr.animated) {
					PROJECT.animator.frame_progress = false;
					var _renderObj = new RenderObject(PROJECT, false);
					_renderObj.render(infinity);
					
				} else {
					var _renderObj = new RenderObject(PROJECT, true);
				    _renderObj.renderTo(currtr.node);
				}
			}
			
			RenderOutput(1, currtr, _currTrans);
			
		} else if(!output_preview) {
			playing = false;
			resetTracks();
			if(exporting) Export();
			
		} else {
			var _outNode = PROJECT.trackAnim.getOutputNode();
			var _prec    = _outNode.getPreviewValues();
			
			if(PROJECT.trackAnim.animated) {
				var fr = floor((play_frame - track_len) % GLOBAL_TOTAL_FRAMES);
				PROJECT.animator.setFrame(fr);
			}
			RenderOutput(2, _prec, (play_frame - track_len) / PROJECT.trackAnim.outro_duration);
				
			if(play_frame >= total_length) {
				playing = false;
				resetTracks();
				if(exporting) Export();
			}
		}
		
		for( var i = array_length(stored_surface) - 1; i >= 0; i-- ) {
			var stos = stored_surface[i];
			if(stos.process == 1 && stos.a == 1) {
				array_delete(stored_surface, i, 1);
				struct_remove(stored_map, stos.node.node_id);
			}
		}
	}
	
	function Export() {
		var rate = 30;
		var qual = 16;
		var temp_path   = string_quote(filename_combine(export_dir, $"%05d.png"));
		
		var parent_path = filename_dir(export_dir);
		var target_name = filename_name_only(export_dir);
		var target_path = string_quote(filename_combine(parent_path, $"{target_name}.mp4"));
		
		var	shell_cmd  = $"-hide_banner -loglevel quiet -framerate {rate} ";
		    shell_cmd += $"-i {temp_path} ";
		    
		if(PROJECT.trackAnim.audio_loop != "") {
			var _aloop = string_quote(PROJECT.trackAnim.audio_loop);
			shell_cmd += $"-stream_loop -1 -i {_aloop} -shortest -map 0:v:0 -map 1:a:0 ";
		}
		
		    shell_cmd += $"-c:v libx264 -r {rate} -pix_fmt yuv420p -crf {qual} ";
		    shell_cmd += $"-y {target_path} ";
		var ffmpeg     = filepath_resolve(PREFERENCES.ffmpeg_path) + "bin/ffmpeg.exe";
		shell_execute(ffmpeg, shell_cmd, self);
		
		shellOpenExplorer(parent_path);
		run_in_s(1, function(p) /*=>*/ {return directory_destroy(p)}, [export_dir]);
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		Player();
		
		var pd = ui(8);
		var m  = [mx,my];
		
		#region audio
			var _aud = PROJECT.trackAnim.audio_loop;
			if(audio_loop_curr != _aud) {
				audio_loop_dura = file_exists(_aud)? WAV_get_length(_aud) : 0;
				audio_loop_curr = _aud;
			}
		#endregion
		
		#region header
			var bb = THEME.button_hide;
			var bs = ui(24);
			var by = pd;
			
			var _n = PANEL_INSPECTOR.getInspecting();
			
			var bx = pd;
			var cc = playing? COLORS._main_value_positive : COLORS._main_icon;
			var ii = playing? 0 : 1;
			var b  = buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "", THEME.sequence_control, ii, cc, 1, .75);
			     if(b == 2) togglePlay(true,  1, false);
			else if(b == 3) togglePlay(false, 1, false);
			
			bx += bs + ui(2);
			
			var cc = playing && play_speed > 1? COLORS._main_value_positive : COLORS._main_icon;
			var b  = buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "", THEME.play_all, 0, cc, 1, .75);
			     if(b == 2) togglePlay(true,  5, false);
			else if(b == 3) togglePlay(false, 5, false);
			
			bx += bs + ui(2);
			
			var cc = playing && play_speed == 3? COLORS._main_value_positive : COLORS._main_icon;
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "", THEME.save, 0, cc, 1, .75) == 2) {
				var tt = PROJECT.trackAnim.title == ""? filename_name_only(PROJECT.path) : PROJECT.trackAnim.title;
				var path   = get_open_directory_compat(tt);
				if(path != "") {
					play_speed = infinity;
					export_dir = path;
					
					if(directory_exists(export_dir)) directory_destroy(export_dir);
					togglePlay(true, 5, true);
				}
			} bx += bs + ui(2);
			
			var bw = ui(96);
			tb_title.setFocusHover(pFOCUS, pHOVER);
			tb_title.draw(bx, by, bw, bs, PROJECT.trackAnim.title, m);
			bx += bw + ui(2);
			
			cl_title_color.setFocusHover(pFOCUS, pHOVER);
			cl_title_color.draw(bx, by, ui(12), bs, PROJECT.trackAnim.titleColor, m);
			bx += ui(12) + ui(2);
			
			var ii = PROJECT.trackAnim.animated;
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Animated", THEME.sequence_control, ii, COLORS._main_icon, 1, .75) == 2) {
				PROJECT.trackAnim.animated = !PROJECT.trackAnim.animated;
			} bx += bs + ui(2);
			
			bx += ui(2);
			var ii = PROJECT.trackAnim.audio_loop != "";
			var cc = COLORS._main_icon;
			if(PROJECT.trackAnim.audio_loop != "" && !file_exists(PROJECT.trackAnim.audio_loop)) cc = COLORS._main_value_negative;
			var b  = buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Set Audio", THEME.play_sound, ii, cc, 1, .75)
			if(b == 3) PROJECT.trackAnim.audio_loop = "";
			if(b == 2) {
				var _path  = get_open_filename_compat("WAV Audio|*.wav", "");
				if(_path != "") PROJECT.trackAnim.audio_loop = _path;
			} bx += bs + ui(2);
			
			if(PROJECT.trackAnim.audio_loop != "") {
				bx += ui(2);
				var aname = filename_name_only(PROJECT.trackAnim.audio_loop);
				draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text_sub);
				draw_text_add(bx, by + bs / 2, aname);
				bx += string_width(aname) + ui(4);
			}
			
			///////////////////////////////
			
			var cc = _n? COLORS._main_value_positive : COLORS._main_icon;
			var bx = w - pd - bs;
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Add Node Track", THEME.add_16, 0, cc) == 2) {
				if(_n) addNodeTrack(_n);
			} bx -= bs + ui(2);
			
			var cc = _n? COLORS._main_icon_light : COLORS._main_icon;
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Set Output", THEME.node_goto_16, 0, cc) == 2) {
				if(_n) PROJECT.trackAnim.outputNode = _n;
			} bx -= bs + ui(2); 
			
			var cc = COLORS._main_icon;
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Show Thumbnail", THEME.splash_thumbnail, 0, cc, 1, .8) == 2) {
				view_thumbnail = !view_thumbnail;
			} bx -= bs + ui(2); 
			
			var cc = COLORS._main_icon;
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Show all inputs", THEME.visible_12, show_all_prop, cc, 1, 1.25) == 2) {
				show_all_prop = !show_all_prop;
			} bx -= bs + ui(2); 
			
		#endregion
	    
		#region track
			var _trx = pd;
			var _try = pd + bs + ui(4);
			var _trw = w - pd - _trx;
	        var _tlh = ui(10);
			var _trh = _tlh + track_height + ui(8);
			
	        draw_sprite_stretched(     THEME.ui_panel_bg, 1, _trx, _try, _trw, _trh);
	        draw_sprite_stretched_ext( THEME.ui_panel_bg, 2, _trx, _try, _trw, _trh, COLORS.panel_animation_timeline_blend, 1);
	    	draw_sprite_stretched_ext( THEME.ui_panel_bg, 2, _trx, _try, _trw, _tlh, CDEF.main_white);
	    	
	    	if(playing) {
	    		track_x_to = play_frame * track_scale - _trw / 2;
	    		track_x    = track_x_to;
	    	}
	    	
	    	if(pHOVER && point_in_rectangle(mx, my, _trx, _try, _trx + _trw, _try + _tlh)) {
	    		if(mouse_lclick(pFOCUS)) 
	    			scrubbing = true;
	    	}
	    	
	    	if(scrubbing) {
	    		var _frame = round((track_x + mx - _trx) / track_scale);
	    		PlayFrame(_frame);
	    		scrub_frame = _frame;
	    		
	    		if(mouse_lrelease()) {
	    			scrubbing   = false;
	    			scrub_frame = undefined;
	    			resetTracks();
	    		}
	    	}
	    	
	        var _scis = gpu_get_scissor();
	        gpu_set_scissor(_trx + ui(2), _try + ui(2), _trw - ui(4), _trh - ui(4));
	        
	        var tsx = _trx + ui(4) - track_x;
	        var tsy = _try + _tlh + ui(4);
	        var tsh = track_height;
	        var tss = track_scale;
	        var del = undefined;
	        var hover = pHOVER && point_in_rectangle(mx, my, _trx, _try, _trx + _trw, _try + _trh);
	        var trw = 0;
	        
	        // if(audio_loop_dura > 0) {
	        // 	var _audF = audio_loop_dura * 30;
	        // 	var _audW = _audF * tss;
	        // 	draw_sprite_stretched_ext(THEME.ui_panel, 0, tsx, _try + ui(1), _audW, _tlh - ui(2), COLORS._main_accent, .25);
	        // }
	        
	    	for( var i = 0; i <= track_w; i += 30 ) {
	    		var lx = tsx + i * tss;
	    		var ss = i / 30
	    		var hl = ss % 2 == 0;
    			draw_set_color(COLORS._main_icon);
    			draw_set_alpha(.6 + .4 * hl);
	    		draw_line_width(lx, _try, lx, _try + _tlh - 1, 1);
				draw_set_alpha(1);
	    		
	    		draw_set_text(f_p4, fa_left, fa_top, COLORS._main_icon);
	    		draw_text_transform_add(lx + 3, _try, ss, .65, 0);
	    	}
	    	
	        var hovETrck   = undefined;
	        var hovETrck_x = undefined;
	        var hovETrck_y = undefined;
	        
        	var tr, tw, cc, otr = undefined;
        	var _node;

	        for( var i = -1, n = array_length(PROJECT.trackAnim.tracks); i <= n; i++ ) {
	        	if(i == -1) {
		        	tr    = -10;
		        	tw    = PROJECT.trackAnim.intro_duration * tss;
	        		_node = PROJECT.trackAnim.getOutputNode();
	        		
	        		cc = COLORS._main_icon;
	        		
	        	} else if(i == n) {
		        	tr    = -20;
		        	tw    = PROJECT.trackAnim.outro_duration * tss;
	        		_node = PROJECT.trackAnim.getOutputNode();
	        		
	        		cc = COLORS._main_icon;
	        		
	        	} else {
		        	tr    = PROJECT.trackAnim.tracks[i];
		        	tw    = tr.duration * tss;
		        	_node = tr.getNode();
		        	
		        	cc  = tr.color;
	        	}
	        	
	        	if(!is(_node, Node)) continue;
	        	
	        	var trk = is(tr, Process_Anim_Track);
	        	var tx = tsx + ui(1);
	        	var ty = tsy + ui(1);
	        	var ww = tw  - ui(2)
	        	var hh = tsh - ui(2);
	        	
	        	var hov = hover && point_in_rectangle(mx, my, tx, ty, tx + ww, ty + hh);
	        	var sel = track_sel == tr;
	        	
	        	if(trk) {
		        	if(tr.store)   draw_sprite_ui(THEME.arrow, 1, tx + ww - ui(4), _try + _tlh / 2 + ui(2), .5, .5, 0, COLORS._main_value_positive);
		        	if(tr.receive) draw_sprite_ui(THEME.arrow, 3, tx + ww + ui(4), _try + _tlh / 2 + ui(2), .5, .5, 0, COLORS._main_value_negative);
	        	}
	        	
	        	draw_sprite_stretched_ext(THEME.ui_panel, 0, tx, ty, ww, hh, cc);
	        	if(sel) {
	        		draw_sprite_stretched_ext(THEME.ui_panel, 2, tx+1, ty+1, ww-2, hh-2, CDEF.main_dkblack);
	        		draw_sprite_stretched_ext(THEME.ui_panel, 2, tx,   ty,   ww,   hh,   CDEF.main_dkblack);
	        		draw_sprite_stretched_ext(THEME.ui_panel, 2, tx-1, ty-1, ww+2, hh+2, COLORS._main_accent, 1);
	        	}
	        	draw_sprite_stretched_add(THEME.ui_panel, 1, tx, ty, ww, hh, c_white, .1 + hov * .3);
	        	
	        	// if(trk) {
	        	// 	if(i && tr.trans) {
	        	// 		var _tnw = ui(6) + tr.duration * tr.tranRat * tss;
	        	// 		var _tnh = ui(6);
	        	// 		var _tnx = tx - ui(6);
	        	// 		var _tny = ty// + hh / 2 - _tnh / 2;
	        	// 		var cc = otr.color;
	        			
	        	// 		draw_sprite_stretched_ext(THEME.ui_panel, 0, _tnx, _tny, _tnw, _tnh, cc);
	        	// 	}
	        	// }
				
	        	if(view_thumbnail == 0) {
					if(_node.node_database != undefined) {
						var spr = _node.node_database.spr;
						var sww = min(hh - ui(4), ww - ui(4));
						draw_sprite_stretched_ext(THEME.ui_panel, 0, tx + ui(2), ty + ui(2), sww, hh - ui(4), CDEF.main_dkblack);
						draw_sprite_ext(spr, 0, tx + hh/2, ty + hh/2, .4, .4);
					}
	        	} else {
	        		var _thumb = _node.getGraphPreviewSurface();
	        		if(is_surface(_thumb)) {
						var sww = min(hh - ui(4), ww - ui(4));
						draw_sprite_stretched_ext(THEME.ui_panel, 0, tx + ui(2), ty + ui(2), sww, hh - ui(4), CDEF.main_dkblack);
						
						var ssw = surface_get_width(_thumb);
						var ssh = surface_get_height(_thumb);
						var sss = min(sww / ssw, (hh - ui(4)) / ssh);
						draw_surface_ext(_thumb, tx + hh/2 - ssw*sss/2, ty + hh/2 - ssh*sss/2, sss, sss, 0, c_white, 1);
	        		}
	        		
	        	}
	        	
	        	if(trk) {
	        		if(!tr.animated) draw_sprite_ui(THEME.sequence_control, 0, tx + ui(8), ty + ui(8), .4, .4, 0, COLORS._main_accent);
	        	}
				
	        	if(hov) {
	        		if(mouse_lpress(pFOCUS)) track_sel = track_sel == tr? undefined : tr;
	        		if(mouse_rpress(pFOCUS) && trk) del = i;
	        	}
	        	
	        	if(i == 0 && hover && point_in_circle(mx, my, tx - ui(1), ty + hh/2, ui(6))) {
	        		hovETrck   = -1;
	        		hovETrck_x = tx - ui(1);
	        		hovETrck_y = ty + hh/2;
	        	} 
	        	
	        	if(trk && hover && point_in_circle(mx, my, tx + ww + ui(1), ty + hh/2, ui(6))) {
	        		hovETrck   = i;
	        		hovETrck_x = tx + ww + ui(1);
	        		hovETrck_y = ty + hh/2;
	        	}
	        	
	        	tsx += tw;
	        	trw += tw;
	        	
	        	otr = tr;
	        }
	        
	        if(_n && hovETrck != undefined) {
	        	draw_set_color(CDEF.main_dkblack);
	        	draw_circle_prec(hovETrck_x, hovETrck_y, ui(8), false);
	        	draw_sprite_ui(THEME.add_16, 0, hovETrck_x, hovETrck_y, .75, .75, 0, COLORS._main_value_positive);
	        	
	        	if(mouse_lpress(pFOCUS))
	        		insertNodeTrack(hovETrck + 1, _n);
	        }
	        
	        track_x     = lerp_float(track_x, track_x_to, 4);
	        track_x_max = trw;
	        track_w     = trw / tss;
	        if(hover) track_x_to -= MOUSE_WHEEL * 32;
        	track_x_to = clamp(track_x_to, -_trw/2, track_x_max - _trw/2);
	        
	        if(del != undefined) {
	        	array_delete(PROJECT.trackAnim.tracks, del, 1);
	        	refreshTracks();
	        }
	        
        	var px = _trx + ui(4) - track_x + play_frame * tss;
        	var cc = playing || scrubbing? COLORS._main_accent : COLORS._main_icon;
        	draw_set_color(cc);
        	draw_line_width(px, _try + _tlh, px, _try + _trh, 2);
        	draw_sprite_stretched_ext(THEME.box_r2, 0, px - ui(3), _try + 1, ui(6) + 1, _tlh, cc);
	        
	        gpu_set_scissor(_scis);
	        draw_sprite_stretched_add( THEME.ui_panel, 1, _trx, _try, _trw, _trh, c_white, .2);
		#endregion
		
		#region selecting
			var tx = pd;
			var ty = _try + _trh + pd;
			
			var tw = w - pd * 2;
			var th = ui(24);
			
			var bs = th;
			var bx = w - pd - bs;
			var by = ty;
			var cc = is(track_sel, Process_Anim_Track)? COLORS._main_icon : merge_color(COLORS._main_icon_dark, COLORS._main_icon, .5);
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Output Channel...", THEME.panel_preview_icon, 0, cc) == 2) {
				if(is(track_sel, Process_Anim_Track)) {
					var _outs = [];
					var _node = track_sel.node;
					for( var i = 0, n = array_length(_node.outputs); i < n; i++ ) {
						var _outp = _node.outputs[i];
						array_push(_outs, new MenuItem(_outp.name, function(p) /*=>*/ { track_sel.output = p; }).setParam(i));
					}
					
					menuCall("", _outs);
				}
			} bx -= bs + ui(4); tw -= bs + ui(4); 
			
			if(is(track_sel, Process_Anim_Track)) {
				var cc = track_sel.store? COLORS._main_value_positive : COLORS._main_icon;
				if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Store Output", THEME.save, 0, cc, 1, .75) == 2) {
					track_sel.store = !track_sel.store;
				} bx -= bs + ui(4); tw -= bs + ui(4); 
				
				var spr = THEME.node_junction_selecting;
				var aa  = track_sel.shadow? 1 : .5;
				if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Shadow", spr, 0, COLORS._main_icon, aa, .75) == 2) {
					track_sel.shadow = !track_sel.shadow;
				} bx -= bs + ui(4); tw -= bs + ui(4); 
				
				var spr = THEME.sequence_control;
				var ii  = track_sel.animated;
				if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Animated", spr, ii, COLORS._main_icon, 1, .75) == 2) {
					track_sel.animated = !track_sel.animated;
				} bx -= bs + ui(4); tw -= bs + ui(4); 
				
				var spw = ui(160);
				sp_transition.setFocusHover(pFOCUS, pHOVER);
				sp_transition.draw(bx + bs - spw, ty, spw, th, track_sel.trans, m, x, y);
				tw -= spw + ui(4);
			}
			
			var dx = tx;
			if(track_sel != undefined) {
				var dw = ui(40);
				var vv = 0;
				
				     if(track_sel == -10) vv = PROJECT.trackAnim.intro_duration;
				else if(track_sel == -20) vv = PROJECT.trackAnim.outro_duration;
				else                      vv = track_sel.duration;
				
				tb_track_duration.setFocusHover(pFOCUS, pHOVER);
				tb_track_duration.draw(dx, ty, dw, th, vv, m);
			    dx += dw + ui(4);
			    tw -= dw + ui(4);
			}
			
			if(is(track_sel, Process_Anim_Track)) {
				tb_track_title.setFocusHover(pFOCUS, pHOVER);
				tb_track_title.draw(dx, ty, tw, th, track_sel.title, m);
				
			} else 
				tb_track_title.draw(dx, ty, tw, th, "", m);
			
			ty += th + ui(4);
			var tw = (w - pd * 2.5) / 2;
			var th = h - pd - ty;
			
			var tx2 = tx + tw + pd / 2;
			
	        draw_sprite_stretched( THEME.ui_panel_bg, 1, tx,  ty, tw, th);
	        draw_sprite_stretched( THEME.ui_panel_bg, 1, tx2, ty, tw, th);
	        
			if(is(track_sel, Process_Anim_Track)) {
				sc_prop_start.verify(tw - ui(6), th - ui(2));
				sc_prop_start.setFocusHover(pFOCUS, pHOVER);
				sc_prop_start.drawOffset(tx + ui(1), ty + ui(1), mx, my);
				
				sc_prop_end.verify(tw - ui(6), th - ui(2));
				sc_prop_end.setFocusHover(pFOCUS, pHOVER);
				sc_prop_end.drawOffset(tx2 + ui(1), ty + ui(1), mx, my);
				
				if(sc_prop_end.hover) {
					sc_prop_start.scroll_y     = sc_prop_end.scroll_y;
					sc_prop_start.scroll_y_raw = sc_prop_end.scroll_y_raw;
					sc_prop_start.scroll_y_to  = sc_prop_end.scroll_y_to;
					
				} else {
					sc_prop_end.scroll_y     = sc_prop_start.scroll_y;
					sc_prop_end.scroll_y_raw = sc_prop_start.scroll_y_raw;
					sc_prop_end.scroll_y_to  = sc_prop_start.scroll_y_to;
				}
			}
		#endregion
	        
	}
	
	refreshTracks();
}