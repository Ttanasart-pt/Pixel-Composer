function Node_create_WAV_File_Read(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_compat("WAV Audio (.wav)|*.wav", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_WAV_File_Read(_x, _y, _group);
	node.skipDefault();
	node.inputs[0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
}

function Node_create_WAV_File_Read_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_WAV_File_Read(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	
	return node;	
}

function Node_WAV_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "WAV File In";
	color = COLORS.node_blend_input;
	update_on_frame = true;
	parameters.timeline_override = true;
	setAlwaysTimeline(new timelineItemNode_Wav(self));
	
	////- =File
	newInput( 0, nodeValue_FPath(   "Path"        )).setDisplay(VALUE_DISPLAY.path_load, { filter: "WAV Audio (.wav)|*.wav" }).rejectArray();
	
	////- =Audio
	newInput( 1, nodeValue_Trigger( "Sync length" ));
	newInput( 2, nodeValue_Bool(    "Mono", false ));
	
	////- =Playback
	newInput( 3, nodeValue_Bool(    "Loop",           false )).rejectArray();
	newInput( 4, nodeValue_Int(     "Start Frame",    1     ));
	// 5 
		
	newOutput( 0, nodeValue_Output( "Data",        VALUE_TYPE.audioBit, noone )).setArrayDepth(1);
	newOutput( 1, nodeValue_Output( "Path",        VALUE_TYPE.path,     ""    ));
	newOutput( 2, nodeValue_Output( "Sample rate", VALUE_TYPE.integer,  44100 )).setVisible(false);
	newOutput( 3, nodeValue_Output( "Channels",    VALUE_TYPE.integer,  2     )).setVisible(false);
	newOutput( 4, nodeValue_Output( "Duration",    VALUE_TYPE.float,    0     )).setVisible(false);
	
	b_sync = button(function() /*=>*/ {
		if(content == noone) return;
		TOTAL_FRAMES = max(1, ceil(wav_duration * project.animator.framerate) + 1);
	}).setText("Sync");
	
	input_display_list  = [ 
		[ "File",     false ],  0, 
		[ "Audio",    false ], b_sync,  2, 
		[ "Playback", false ],  3,  4, 
	];
	
	output_display_list = [ 0, 1, 2, 3, 4 ];
	
	////- Node
	
	content      = noone;
	path_current = "";
	edit_time    = 0;
	
	attributes.file_checker = true;
	array_push(attributeEditors, Node_Attribute( "File Watcher", function() /*=>*/ {return attributes.file_checker}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")})} ));
	
	first_update  = false;
	preview_audio = -1;
	preview_id    = noone;
	
	wav_file_reading = false;
	wav_file_prg = 0;
	wav_file_lim = 1;
	wav_duration = 1;
	
	playback_progress = 0;
	
	#region attribute
		attributes.preview_shift = 0;
		attributes.preview_gain = 0.5;
	
		array_push(attributeEditors, "Audio Preview");
		array_push(attributeEditors, Node_Attribute( "Gain",  function() /*=>*/ {return attributes.preview_gain},  function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("preview_gain",  v)})} ));
		array_push(attributeEditors, Node_Attribute( "Shift", function() /*=>*/ {return attributes.preview_shift}, function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("preview_shift", v)})} ));
	#endregion
		
	on_drop_file = function(path) {
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	function updatePaths(path) {
		if(path == -1) return false;
		
		if(path_current == "") 
			first_update = true;
		path_current = path;
		edit_time    = max(edit_time, file_get_modify_s(path_current));
		
		var  ext  = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".wav") return false;
			
		outputs[1].setValue(path);
		
		printIf(global.FLAG.wav_import, "-- Reading file...");
		
		content = file_read_wav(path);
		content.path = path;

		logNode($"Loaded file: {path}", false);
		
		return true;
	}
	
	function readSoundComplete() {
		outputs[0].setValue(content);
		outputs[2].setValue(content.sample);
		outputs[3].setValue(content.channels);
		outputs[4].setValue(wav_duration);
		
		wav_duration = content[$ "duration"] ?? 1;
		
		printIf(global.FLAG.wav_import, "-- Creating preview buffer...");
		
		var frm = ceil(wav_duration * project.animator.framerate);
		inputs[1].getEditWidget().text = $"Sync ({frm} frames)";
		
		var bufferId = buffer_create(content.packet * 2, buffer_fixed, 1);
		buffer_seek(bufferId, buffer_seek_start, 0);
		
		var val_to_write = 1, i = 0;
		var bf_type  = buffer_s16;
		var bf_limit = 32_768;
		
		repeat(content.packet) buffer_write(bufferId, bf_type, round(content.sound[0][i++] / 2 * bf_limit));
		
		preview_audio = audio_create_buffer_sound(bufferId, bf_type, content.sample, 0, content.packet * 2, audio_mono);
		var surf = content.checkPreview(320, 128, true);
	}
	
	////- Nodes
	
	attributes.play = true;
	
	#region ++++ inspector ++++
		insp1button = button(function() /*=>*/ { 
			var path = getInputData(0); 
			if(path == "") return; 
			updatePaths(path); 
			update(); 
			
		}).setTooltip(__txt("Refresh"))
			.setIcon(THEME.refresh_icon, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
		
		insp2button = button(function() /*=>*/ { toggleAttribute("play"); }).setTooltip(__txt("play_with_timeline", "Play with timeline"))
			.setIcon(THEME.play_sound, 1, COLORS._main_icon_light).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	#endregion
	
	static step = function() {
		if(file_read_wav_step()) {
			print("Load audio complete");
			readSoundComplete();
			
			if(content != noone) {
				var frm = max(1, ceil(wav_duration * project.animator.framerate) + 1);
				b_sync.text = $"Sync ({frm} frames)";
			}
			
			RenderAllReorder();
		}
		
		if(attributes.file_checker && file_exists_empty(path_current)) {
			var _modi = file_get_modify_s(path_current);
			
			if(_modi > edit_time) {
				edit_time = _modi;
				run_in(2, function() /*=>*/ { updatePaths(); triggerRender(); });
			}
		}
		
		insp2button.icon_index = attributes.play;
		insp2button.icon_blend = attributes.play? COLORS._main_icon_light : COLORS._main_icon;
		if(preview_audio == -1) return;
		
		if(!attributes.play) { 
			if(audio_is_playing(preview_audio)) audio_stop_sound(preview_audio);
			return;
		}
		
		if((!IS_PLAYING || IS_FIRST_FRAME) && audio_is_playing(preview_audio)) // stop when pause or looping
			audio_stop_sound(preview_audio); 
		
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var path = path_get(getInputData(0));
			var mono = getInputData(2);
		#endregion
		
		if(path_current != path) updatePaths(path);
		if(!is(content, audioObject)) return;
			
		content.playback_loop  = getInputData(3);
		content.playback_start = getInputData(4);
		content.gain           = attributes.preview_gain;
		
		playback_progress = (CURRENT_FRAME - content.playback_start + 1) / project.animator.framerate - attributes.preview_shift;
		if(content.playback_loop) playback_progress = playback_progress % wav_duration;
		
		if(IS_PLAYING && !audio_is_playing(preview_audio) && playback_progress >= 0 && playback_progress < wav_duration)
			preview_id = audio_play_sound(preview_audio, 1, false, attributes.preview_gain, playback_progress); 
		
		content.mono = mono;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(content == noone) return;
		var bbox = draw_bbox;
		var surf = content.checkPreview(320, 128);
		
		if(wav_file_reading) {
			var cx = xx + w * _s / 2;
			var cy = yy + h * _s / 2;
			var rr = min(w - 64, h - 64) * _s / 2;
			
			draw_set_color(COLORS._main_icon);
			draw_arc(cx, cy, rr, 90, 90 - 360 * wav_file_prg / content.packet, 4 * _s, 180);
			return;
			
		} else if(is_surface(surf)) {
			var sw = surface_get_width_safe(surf);
			var sh = surface_get_height_safe(surf);
			var ss = min(bbox.w / sw, bbox.h / sh);
			
			var dx = bbox.xc - sw * ss / 2;
			var dy = bbox.yc - sh * ss / 2;
		
			draw_surface_ext_safe(surf, dx, dy, ss, ss,,, 0.50);
				
			var wd = clamp(playback_progress / wav_duration, 0, 1) * sw;
			draw_surface_part_ext_safe(surf, 0, 0, min(wd, sw), sh, dx, dy, ss, ss,, attributes.play? COLORS._main_accent : c_white);
			
			draw_set_color(attributes.play? COLORS._main_accent : c_white);
			draw_line(dx + wd * ss, bbox.yc - sh * ss / 2, dx + wd * ss, bbox.yc + sh * ss / 2);
		}
		
		var str = filename_name(path_current);
		draw_set_text(f_sdf, fa_center, fa_bottom, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.y1, str, ss, ss, 0);
		
		gpu_set_tex_filter(true);
		draw_sprite_ext(THEME.play_sound, attributes.play, bbox.xc , bbox.y0 + 8 * _s, _s*.4, _s*.4, 0, attributes.play? COLORS._main_accent : COLORS._main_icon);
		gpu_set_tex_filter(false);
	}
	
	////- Timeline
	
	timeline_content_dragging  = false;
	timeline_content_drag_type = 0;
	timeline_content_drag_sx   = 0;
	timeline_content_drag_mx   = 0;
	
	static drawTimeline = function(_x, _y, _s, _mx, _my, _panel) {
		if(content == noone) return;
		
		var _lens = wav_duration;
		var _lenf = ceil(_lens * project.animator.framerate);
		
		var _strt = content.playback_start;
		var _loop = content.playback_loop;
		
		var _ex0 = _x   + _strt * _s;
    	var _ex1 = _ex0 + _lenf * _s;
    	var _ey0 = _y + ui(10) - ui(8);
    	var _ey1 = _y + ui(10) + ui(8); 
    	
    	timeline_content_snap.points = [ _strt, _strt + _lenf ];
    	
    	var _ew = _ex1 - _ex0;
    	var _eh = _ey1 - _ey0;
    	var _es = ui(4);
    	
    	var _hovC = _panel.pHOVER && point_in_rectangle(_mx, _my, _ex0, _ey0, _ex1, _ey1);
    	
    	var _hov = 0;
    	if(_hovC) _hov = 1;
    	
    	var baseC = getColor();
    	if(baseC == -1) baseC = CDEF.main_ltgrey;
    	
    	var _drg = timeline_content_dragging;
    	var _hlg = _hov || _drg;
    	draw_sprite_stretched_ext(THEME.box_r2, 0, _ex0, _ey0, _ew, _eh, baseC, .2 + _hlg * .3);
    	draw_sprite_stretched_add(THEME.box_r2, 1, _ex0, _ey0, _ew, _eh, baseC, .2);
    	
    	var surf = content.checkPreview(320, 128);
    	draw_surface_stretched_ext(surf, _ex0, _ey0 + ui(2), _ew, _eh - ui(4), baseC, .7);
    	
    	if(_drg) draw_sprite_stretched_ext(THEME.box_r2, 1, _ex0, _ey0, _ew, _eh, COLORS._main_accent, 1);
    	if(_loop) draw_sprite_ui(THEME.gif_loop_type, 0, _ex1 + ui(12), _y + ui(10), .7, .7, 0, COLORS._main_icon, .75);
    	
    	if(_hov && mouse_lpress(_panel.pFOCUS)) {
			timeline_content_dragging = true;
			
			timeline_content_drag_sx = _strt;
			timeline_content_drag_mx = _mx;
    	}
    	
    	if(timeline_content_dragging) {
    		var _shft = (_mx - timeline_content_drag_mx) / _s;
    		var _targ = round(timeline_content_drag_sx + _shft);
    		var _st   = _targ;
    		var _ed   = _targ + _lenf;
    		
    		if(!key_mod_press(KCONTROL)) {
	    		var _snaps = _panel.timeline_snap_points;
	    		var _sntr  = undefined;
	    		var _sntrP = undefined;
	    		
	    		for( var i = 0, n = array_length(_snaps); i < n; i++ ) {
	    			var _sn = _snaps[i];
	    			if(!is_struct(_sn))  continue;
	    			if(_sn.node == self) continue;
	    			
	    			for( var j = 0, m = array_length(_sn.points); j < m; j++ ) {
	    				var _p = _sn.points[j];
	    				
	    				if(abs(_p - _st) < 4/_s) { _sntr = _p;         _sntrP = _p; }
	    				if(abs(_p - _ed) < 4/_s) { _sntr = _p - _lenf; _sntrP = _p; }
	    			}
	    		}
	    		
	    		if(_sntr != undefined) {
	    			_targ = _sntr;
	    			array_push(_panel.timeline_snap_line, _sntrP);
	    		}
    		}
    		
    		if(inputs[4].setValue(_targ))
    			UNDO_HOLDING = true;
    		
        	if(mouse_lrelease()) {
        		timeline_content_dragging = false;
        		UNDO_HOLDING = false;
        	}
    	}
    	
    	return _hov && timeline_content_dragging;
	}
	
	static drawAnimationTimeline = function(_shf, _w, _h, _s) {
		if(content == noone) return;
		draw_set_color(COLORS._main_icon_dark);
		draw_set_alpha(1);
		
		var _st = round(content.sample / project.animator.framerate); //sample per frame
		var _am = content.packet / _st;
		var ox, oy, nx, ny;
		
		if(!struct_has(content, "sound"))	return;
		if(array_length(content.sound) < 1) return;
		
		for( var i = 0; i <= _am; i++ ) {
			var _dat = content.sound[0][min(i * _st, content.packet - 1)];
			nx = _shf + i * _s;
			ny = _h / 2 + _dat * _h;
			
			if(i) draw_line_width(ox, oy, nx, ny, ui(1));
			
			ox = nx;
			oy = ny;
		}
		
		draw_set_alpha(1);
	}
	
	////- Actions
	
	static onDestroy = function() {
		if(preview_audio && audio_is_playing(preview_audio) && !IS_PLAYING)
			audio_stop_sound(preview_audio);
	}
	
	static dropPath = function(path) { 
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return;
		
		inputs[0].setValue(path); 
		check_directory_redirector(path);
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function timelineItemNode_Wav(_node) : timelineItemNode(_node) constructor {
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		return;
	}
}