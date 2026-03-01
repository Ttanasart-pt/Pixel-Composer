function Node_create_Image_Animated(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filenames_compat(FILE_SEL_IMAGE, "");
		key_release();
		if(path == "") return noone;
	}
	
	var node  = new Node_Image_Animated(_x, _y, _group);
	node.skipDefault();
	
	var paths = string_splice(path, "\n");
	node.inputs[0].setValue(paths);
	
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
}

function Node_create_Image_Animated_path(_x, _y, _path) {
	var node = new Node_Image_Animated(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(_path);
	node.doUpdate();
	
	return node;
}

enum ANIMATION_END {
	loop,
	ping,
	hold,
	hide
}

function Node_Image_Animated(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Image Sequence";
	spr   = [];
	color = COLORS.node_blend_input;
	setAlwaysTimeline(new timelineItemNode_Image_Animated(self));
	
	update_on_frame = true;
	
	newInput(11, nodeValue_Bool( "Edit in Timeline",   true  ));
	
	////- =Image
	newInput( 0, nodeValue_Path(        "Path",        []        )).setDisplay(VALUE_DISPLAY.path_array, { filter: [FILE_SEL_IMAGE, ""] });
	newInput( 1, nodeValue_Padding(     "Padding",     [0,0,0,0] )).rejectArray();
	newInput( 8, nodeValue_Enum_Scroll( "Canvas Size", 2, [ "First", "Minimum", "Maximum" ])).rejectArray();
	
	////- =Animation
	newInput( 5, nodeValue_Trigger( "Set animation length to match" ));
	b_match_len = button(function() /*=>*/ { if(array_empty(spr)) return; TOTAL_FRAMES = array_length(spr); }).setText("Match Length");
	
	newInput( 4, nodeValue_EScroll( "Loop Modes",        0, ["Loop", "Ping pong", "Hold last frame", "Hide"]       )).rejectArray();
	newInput( 2, nodeValue_Bool(    "Stretch Frame",     false, "Stretch animation speed to match project length." )).rejectArray();
	newInput( 9, nodeValue_Int(     "Start Frame",       1    ));
	newInput( 3, nodeValue_Float(   "Animation Speed",   1    )).rejectArray();
	newInput(10, nodeValue_Bool(    "Draw Before Start", true ));
		
	////- =Custom Order
	newInput( 6, nodeValue_Bool( "Custom Frame Order", false ));
	newInput( 7, nodeValue_Int(  "Frame", 0 ));
	// input 12
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Dimension",   VALUE_TYPE.integer, [1,1] )).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 11, 
		[ "Image",     false ],  0,  1,  8, 
		[ "Animation", false ], b_match_len,  4,  2,  9,  3, 10, 
		[ "Custom Frame Order", false, 6 ],  7, 
	];
	
	attribute_surface_depth();
	
	path_current = [];
	edit_time    = 0;
	
	attributes.file_checker = true;
	array_push(attributeEditors, Node_Attribute("File Watcher", function() /*=>*/ {return attributes.file_checker}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")})}));
	
	on_drop_file = function(_path) {
		if(directory_exists(_path)) {
			with(dialogCall(o_dialog_drag_folder, WIN_W / 2, WIN_H / 2)) {
				dir_paths = _path;
				target    = other;
			}
			return true;
		}
		
		var paths = paths_to_array_ext(_path);
		
		inputs[0].setValue(paths);
		if(updatePaths(paths)) {
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	function updatePaths(paths = path_current) {
		if(!is_array(paths) && ds_exists(paths, ds_type_list))
			paths = ds_list_to_array(paths);
		
		for(var i = 0; i < array_length(spr); i++) {
			if(spr[i] && sprite_exists(spr[i]))
				sprite_delete(spr[i]);
		}
		
		spr = [];
		path_current = [];
		
		for( var i = 0, n = array_length(paths); i < n; i++ )  {
			var _path = path_get(paths[i]);
			if(_path == -1) continue;
			
			array_push(path_current, _path);
			if(file_exists_empty(_path)) setDisplayName(filename_name_only(_path), false);
			
			var _spr = sprite_add_map(_path);
			if(_spr == -1) { noti_warning($"Image node: File not a valid image.", noone, self); continue; }
			
			edit_time = max(edit_time, file_get_modify_s(_path));
			array_push(spr, _spr);
			logNode($"Loaded file: {_path}", false);
		}
		
		return true;
	}
	
	insp1button = button(function() /*=>*/ { updatePaths(path_get(getInputData(0))); triggerRender(); }).setTooltip(__txt("Refresh"))
		.setIcon(THEME.refresh_icon, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static step = function() {
		if(attributes.file_checker)
		for( var i = 0, n = array_length(path_current); i < n; i++ ) {
			if(file_get_modify_s(path_current[i]) > edit_time) {
				updatePaths();
				triggerRender();
				break;
			}
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		insp2button.tooltip    = attributes.cache_use? __txt("Remove Cache") : __txt("Cache");
		insp2button.icon       = attributes.cache_use? THEME.dCache_clear : THEME.cache_group;
		insp2button.icon_blend = attributes.cache_use? c_white : COLORS._main_icon;
		
		#region data
			var path = getInputData(0);
			    path = path_get(path);
			if(!array_equals(path_current, path)) 
				updatePaths(path);
				
			var _sprs = attributes.cache_use? cache_spr : spr;
			if(array_length(_sprs) == 0) return;
			if(!sprite_exists(_sprs[0])) return;
			
			var _pad   = getInputData( 1);
			var _siz   = getInputData( 8); 
			
			var _stret = getInputData( 2);
			var _loop  = getInputData( 4);
			var _start = getInputData( 9);
			var _rawsp = getInputData( 3);
			var _drawb = getInputData(10);
			
			var _cusor = getInputData( 6);
			var _cusfr = getInputData( 7);
			
			var _edit = getInputData(11);
			attributes.timeline_override = _edit;
			
			inputs[2].setVisible(!_cusor);
			inputs[3].setVisible(!_cusor && !_stret);
			inputs[4].setVisible(!_cusor && !_stret);
			
		#endregion
		
		var _speed = _stret? (TOTAL_FRAMES + 1) / array_length(_sprs) : 1 / _rawsp;
		if(_speed == 0) _speed = 1;
		
		var _frame = _cusor? _cusfr : floor(CURRENT_FRAME / _speed) - (_start - 1);
		
		var _len = array_length(_sprs);
		var _drw = true;
		
		var sw = sprite_get_width(_sprs[0]); 
		var sh = sprite_get_height(_sprs[0]);
		
		if(_siz) {
			for( var i = 1, n = array_length(_sprs); i < n; i++ ) {
				var _sw = sprite_get_width(_sprs[i]); 
				var _sh = sprite_get_height(_sprs[i]);
				
				if(_siz == 1) {
					sw = min(_sw, sw);
					sh = min(_sh, sh);
				} else if(_siz == 2) {
					sw = max(_sw, sw);
					sh = max(_sh, sh);
				}
			}
		}
		
		var ww = sw;
		var hh = sh;
		
		ww += _pad[0] + _pad[2];
		hh += _pad[1] + _pad[3];
		
		var surfs = outputs[0].getValue();
		surfs = surface_verify(surfs, ww, hh, attrDepth());
		outputs[0].setValue(surfs);
		outputs[1].setValue([ww, hh]);
		
		if(!_drawb && _frame < 0) {
			surface_clear(surfs);
			return;
		}
		
		switch(_loop) {
			case ANIMATION_END.loop : _frame = safe_mod(_frame, _len); break;
				
			case ANIMATION_END.ping :
				_frame = safe_mod(_frame, _len * 2 - 2);
				if(_frame >= _len) _frame = _len * 2 - 2 - _frame;
				break;
				
			case ANIMATION_END.hold : _frame = min(_frame, _len - 1); break;
			case ANIMATION_END.hide : if(_frame < 0 || _frame >= _len) _drw = false; break;
		}
		
		var _spr = array_safe_get_fast(_sprs, _frame, noone);
		if(_spr == noone) {
			surface_clear(surfs);
			return;
		}
		
		var curr_w = sprite_get_width(_spr);
		var curr_h = sprite_get_height(_spr);
		var curr_x = _pad[2] + (sw - curr_w) / 2;
		var curr_y = _pad[1] + (sh - curr_h) / 2;
		
		surface_set_shader(surfs);
			if(_drw) draw_sprite(_spr, 0, curr_x, curr_y);
		surface_reset_shader();
	}
	
	timeline_content_dragging  = false;
	timeline_content_drag_type = 0;
	timeline_content_drag_sx   = 0;
	timeline_content_drag_mx   = 0;
	
	static drawTimeline = function(_x, _y, _s, _mx, _my, _panel) {
		var _sprs = attributes.cache_use? cache_spr : spr;
		if(array_length(_sprs) == 0) return false;
		if(!sprite_exists(_sprs[0])) return false;
		
		var _cust = getInputData( 6);
		if(_cust) return false;
		
		var _loop = getInputData( 4);
		var _strt = getInputData( 9);
		var _spd  = getInputData( 3);
		
		var _slen = array_length(_sprs);
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
			timeline_content_dragging   = true;
			
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
    		
    		if(inputs[9].setValue(_targ))
    			UNDO_HOLDING = true;
    		
        	if(mouse_lrelease()) {
        		timeline_content_dragging = false;
        		UNDO_HOLDING = false;
        	}
    	}
    	
    	return _hov;
	}
	
	////- Cache
	
	attributes.cache_use  = false;
	attributes.cache_data = "";
	cache_spr = [];
	
	static cacheData = function() {
		attributes.cache_use  = true;
		cache_spr = spr;
		attributes.cache_data = sprite_array_serialize(spr);
		triggerRender();
	}
	
	static uncacheData = function() {
		attributes.cache_use  = false;
		triggerRender();
	}
	
	insp2button = button(function() /*=>*/ { if(attributes.cache_use) uncacheData() else cacheData(); }).setTooltip(__txt("Cache"))
		.setIcon(THEME.cache_group, 0, COLORS._main_icon).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	////- Serialize
	
	static postDeserialize = function() {
		if(!attributes[$ "cache_use"] ?? 0) return;
		cache_spr = sprite_array_deserialize(attributes[$ "cache_data"] ?? "");
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function timelineItemNode_Image_Animated(_node) : timelineItemNode(_node) constructor {
	
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		if(!is(node, Node_Image_Animated)) return;
		if(!node.attributes.show_timeline) return;
		return;
		
		var _sprs = node.spr;
		var _spr, _rx, _ry;
		var _aa;
		
		for (var i = 0, n = array_length(_sprs); i < n; i++) {
			if(i >= NODE_TOTAL_FRAMES) break;
			
			_spr = _sprs[i];
			if(!sprite_exists(_spr)) continue;
			
			_rx = _x + (i + 1) * _s;
			_ry = h / 2 + _y;
			
			var _sw = sprite_get_width(_spr);
			var _sh = sprite_get_height(_spr);
			var _ss = h / max(_sw, _sh);
			
			_aa = .5 + .5 * (i == NODE_CURRENT_FRAME);
			draw_sprite_ext(_spr, 0, _rx - _sw * _ss / 2, _ry - _sh * _ss / 2, _ss, _ss, 0, c_white, _aa);
		}
	}
	
	static onSerialize = function(_map) {
		_map.type = "timelineItemNode_Image_Animated";
	}
	
	static dropPath = function(path) { 
		if(!is_array(path)) path = [ path ];
		inputs[0].setValue(path); 
	}
}