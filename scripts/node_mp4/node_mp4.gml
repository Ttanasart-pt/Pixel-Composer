function Node_create_Image_mp4(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_compat("mp4|*.mp4", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Image_mp4(_x, _y, _group);
	node.skipDefault();
	node.inputs[0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
}

function Node_create_Image_mp4_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_Image_mp4(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_Image_mp4(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "MP4";
	color = COLORS.node_blend_input;
	update_on_frame = true;
	setAlwaysTimeline(new timelineItemNode_Image_mp4(self));
	
	newInput( 8, nodeValue_Bool( "Edit in Timeline",   true  ));
	
	////- =Image
	newInput( 0, nodeValue_Path("Path")).setDisplay(VALUE_DISPLAY.path_load, { filter: "mp4|*.mp4" });
	detail = new Inspector_Label("Mp4 file");
	
	////- =Output
	newInput( 2, nodeValue_Bool( "Output as Array",   false ));
	
	////- =Animation
	newInput( 1, nodeValue_Trigger("Match Animation Length" ));
	b_match_len = button(function() /*=>*/ { TOTAL_FRAMES = max(1, array_length(sprs)); }).setText("Match Length");
	
	newInput( 3, nodeValue_EScroll( "Loop Mode",         0, ["Loop", "Ping pong", "Hold last frame", "Hide"])).rejectArray();
	newInput( 4, nodeValue_Int(     "Start Frame",       1    ));
	newInput( 7, nodeValue_Float(   "Animation Speed",   1    ));
	newInput( 9, nodeValue_Bool(    "Draw Before Start", true ));
	
	////- =Custom Order
	newInput( 5, nodeValue_Bool( "Custom frame order",  false ));
	newInput( 6, nodeValue_Int(  "Frame",               0     ));
	// input 10
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Path",        VALUE_TYPE.path,    ""    )).setVisible(true, true);
	newOutput(2, nodeValue_Output( "Dimension",   VALUE_TYPE.integer, [1,1] )).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 8, 
		[ "Image",     false ],  0, detail, 
		[ "Output",    false ],  2, 
		[ "Animation", false ], b_match_len,  3,  4,  7,  9, 
		[ "Custom Frame Order", false, 5 ],  6,
	];
	
	////- Node
	
	attribute_surface_depth();
	
	ffmpeg       = filepath_resolve(PREFERENCES.ffmpeg_path) + "bin/ffmpeg.exe";
	path_current = "";
	sprs         = [];
	surfaces	 = [];
	
	shell_cmd    = undefined;
	shell_pid    = undefined;
	
	video_width  = 1;
	video_height = 1;
	
	file_reading     = false;
	file_hash        = "";
	file_reader_pid  = 0;
	file_read_cursor = 0;
	
	edit_time = 0;
	attributes.file_checker = true;
	array_push(attributeEditors, Node_Attribute("File Watcher", function() /*=>*/ {return attributes.file_checker}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")})}));
	
	on_drop_file = function(path) /*=>*/ { inputs[0].setValue(path); if(!updatePaths(path)) return false; doUpdate(); return true; }
	
	insp1button = button(function() /*=>*/ { updatePaths(path_get(getInputData(0))); }).setTooltip(__txt("Refresh"))
		.setIcon(THEME.refresh_icon, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
		
	function updatePaths(path = path_current) {
		if(path == -1) return false;
		
		edit_time = file_get_modify_s(path_current);
		path_current = path;
		
		var ext   = string_lower(filename_ext(path));
		if(ext != ".mp4") return false;
		
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(!renamedManual) setDisplayName(_name, false, false);
		outputs[1].setValue(path);
		
		mp4init();
		
		return true;
	}
	
	static mp4init = function() {
		if(file_reading) return;
		
		var _filemod = file_get_modify_s(path_current);
		
		file_reading     = true;
		file_hash        = md5_string_unicode($"{path_current}{_filemod}");
		file_read_cursor = 1;
		var targ_dir = $"{DIRECTORY}Cache/{file_hash}";
		
		if(!directory_exists(targ_dir)) {
			directory_verify(targ_dir);
			
			shell_cmd = $"-hide_banner -loglevel quiet -i \"{path_current}\" -pix_fmt rgba \"{targ_dir}/frame%04d.png\"";
			file_reader_pid = shell_execute_async(ffmpeg, shell_cmd);
		}
		
		for( var i = 0, n = array_length(sprs); i < n; i++ ) 
			sprite_delete_safe(sprs[i]);
		sprs = [];
	}
	
	static mp4step = function() {
		var targ_dir  = $"{DIRECTORY}Cache/{file_hash}";
		var timeStart = get_timer();
		var loadAll   = !ProcIdExists(file_reader_pid);
		
		while(true) {
			var fpath = $"{targ_dir}/frame{string_lead_zero(file_read_cursor,4)}.png";
			if(!file_exists(fpath)) return loadAll;
			
			if(file_read_cursor == 1) {
				var fSpr = sprite_add(fpath);
				sprs[file_read_cursor - 1] = fSpr;
				video_width  = sprite_get_width(fSpr);
				video_height = sprite_get_height(fSpr);
				
			} else {
				asyncCallGroup("image", sprite_add_ext(fpath, 1, 0, 0, true), function(_callBack, _load) /*=>*/ {
					var _sid = _load[?"id"];
					if(!sprite_exists(_sid)) return;
					
					sprs[_callBack.index] = _sid;
					return _sid;
				}, { index: file_read_cursor - 1 });
			}
			
			file_read_cursor++;
			
			if(get_timer() - timeStart > 1_000_000 / 60) return false;
		}
		
		return loadAll;
	}
	
	static step = function() {
		if(file_reading) {
			var readall = mp4step();
			if(readall && !ProcIdExists(file_reader_pid)) {
				file_reading = false;
				triggerRender();
			}
		}
		
		if(attributes.file_checker && file_exists_empty(path_current)) {
			var _modi = file_get_modify_s(path_current);
			
			if(_modi > edit_time) {
				edit_time = _modi;
				run_in(2, function() /*=>*/ { updatePaths(); triggerRender(); });
			}
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(file_reading) return;
		
		#region data
			var path = path_get(getInputData(0));
			if(path_current != path) updatePaths(path);
			
			var _edit = getInputData( 8);
			var _arr  = getInputData( 2);
			
			var _lop  = getInputData( 3);
			var _cus  = getInputData( 5);
			
			var _loop = getInputData( 3);
			var _strt = getInputData( 4);
			var _spd  = getInputData( 7);
			var _pbef = getInputData( 9);
			
			var _cust = getInputData( 5);
			var _cfrm = getInputData( 6);
			
			inputs[3].setVisible(!_arr);
			inputs[4].setVisible(!_cus);
			inputs[6].setVisible( _cus);
			inputs[7].setVisible(!_cus);
			
			attributes.timeline_override = _edit;
		#endregion
		
		if(array_empty(sprs)) return;
		
		var ww = video_width;
		var hh = video_height;
		
		var _outsurf = outputs[0].getValue();
		
		if(_arr) {
			var amo = array_length(sprs);
			if(array_length(surfaces) == amo && is_surface(surfaces[0])) {
				outputs[0].setValue(surfaces);
				return;
			}
			
			surface_array_free(_outsurf);
			surfaces = array_create(amo);
			
			for( var i = 0; i < amo; i++ ) {
				if(!sprs[i]) continue;
				
				surfaces[i] = surface_create_valid(ww, hh, attrDepth());
				
				surface_set_shader(surfaces[i]);
					draw_sprite(sprs[i], 0, 0, 0);
				surface_reset_shader();
			}
			
			outputs[0].setValue(surfaces);
			return;
		}
		
		var _len = array_length(sprs);
		var _drw = true;
		var _frm = _cust? _cfrm : CURRENT_FRAME * _spd - (_strt - 1);
		
		if(!_pbef && _frm < 0) {
			surface_clear(_outsurf);
			return;
		}
		
		switch(_loop) {
			case ANIMATION_END.loop : 
				_frm = ((_frm % _len) + _len) % _len;
				break;
				
			case ANIMATION_END.ping :
				var plen = _len * 2 - 2;
				_frm = ((_frm % plen) + plen) % plen;
				
				if(_frm >= _len)
					_frm = plen - _frm;
				break;
				
			case ANIMATION_END.hold :
				_frm = clamp(_frm, 0, _len - 1);
				break;
				
			case ANIMATION_END.hide :	
				if(_frm < 0 || _frm >= _len) 
					_drw = false;
				break;
		}
		
		if(_frm < 0) _drw = false;
		
		_outsurf = surface_verify(_outsurf, ww, hh, attrDepth());
		outputs[0].setValue(_outsurf);
		outputs[2].setValue([ww, hh]);
		
		surface_set_shader(_outsurf);
			if(sprs[_frm] && _drw) draw_sprite(sprs[_frm], 0, 0, 0);
		surface_reset_shader();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(file_reading) draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	}
	
	static dropPath = function(path) {
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return;
		
		inputs[0].setValue(path);
	
	}
	
	static onCleanUp = function() {
		for( var i = 0, n = array_length(sprs); i < n; i++ ) 
			sprite_delete_safe(sprs[i]);
	}
	
	timeline_content_dragging  = false;
	timeline_content_drag_type = 0;
	timeline_content_drag_sx   = 0;
	timeline_content_drag_mx   = 0;
	
	static drawTimeline = function(_x, _y, _s, _mx, _my, _panel) {
		if(array_empty(sprs)) return false;
		
		var _cust = getInputData( 5);
		if(_cust) return false;
		
		var _loop = getInputData( 3);
		var _strt = getInputData( 4);
		var _spd  = getInputData( 7);
		
		var _slen = array_length(sprs);
		var _plen = _slen / _spd;
		
		var _ex0 = _x   + _strt * _s;
    	var _ex1 = _ex0 + _plen * _s;
    	var _ey0 = _y + ui(10) - ui(8);
    	var _ey1 = _y + ui(10) + ui(8); 
    	
    	timeline_content_snap.points = [ _strt, _strt + _plen ];
    	
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
    	
    	if(_drg) draw_sprite_stretched_ext(THEME.box_r2, 1, _ex0, _ey0, _ew, _eh, COLORS._main_accent, 1);
    	
    	draw_sprite_ui(THEME.gif_loop_type, _loop, _ex1 + ui(12), _y + ui(10), .7, .7, 0, COLORS._main_icon, .75);
    	
    	if(_hov && mouse_lpress(_panel.pFOCUS)) {
			timeline_content_dragging = true;
			
			timeline_content_drag_sx = _strt;
			timeline_content_drag_mx = _mx;
    	}
    	
    	if(timeline_content_dragging) {
    		var _shft = (_mx - timeline_content_drag_mx) / _s;
    		var _targ = round(timeline_content_drag_sx + _shft);
    		var _st   = _targ;
    		var _ed   = _targ + _plen;
    		
    		if(!key_mod_press(CTRL)) {
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
	    				if(abs(_p - _ed) < 4/_s) { _sntr = _p - _plen; _sntrP = _p; }
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
    	
    	return _hov;
	}
	
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function timelineItemNode_Image_mp4(_node) : timelineItemNode(_node) constructor {
	
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		if(!is(node, Node_Image_mp4))      return;
		if(!node.attributes.show_timeline) return;
		return;
		
		var _sprs = node.sprs;
		if(!array_empty(_sprs)) return;
		
		var _rx, _ry;
		var _sw = sprite_get_width(_sprs[0]);
		var _sh = sprite_get_height(_sprs[0]);
		var _ss = h / max(_sw, _sh);
		
		var _hw = _sw * _ss / 2;
		var _hh = _sh * _ss / 2;
		var _aa;
		
		for (var i = 0, n = array_length(_sprs); i < n; i++) {
			if(i >= NODE_TOTAL_FRAMES) break;
			if(!_sprs[i]) continue;
			
			_rx = _x + (i + 1) * _s;
			_ry = h / 2 + _y;
			
			_aa = .5 + .5 * (i == NODE_CURRENT_FRAME);
			draw_sprite_ext(_sprs[i], 0, _rx - _hw, _ry - _hh, _ss, _ss, 0, c_white, _aa);
		}
	}
	
	static onSerialize = function(_map) {
		_map.type = "timelineItemNode_Image_mp4";
	}
	
}