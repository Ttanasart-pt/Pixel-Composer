function Node_create_PXC(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_compat("Pixel Composer project(.pxc)|*.pxc", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_PXC(_x, _y, _group);
	node.skipDefault();
	node.inputs[0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
}

function Node_create_PXC_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_PXC(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	return node;	
}

function Node_PXC(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "PXC";
	icon  = THEME.node_pxc;
	color = CDEF.orange;
	setAlwaysTimeline(new timelineItemNode_PXC(self));
	setCacheManual();
	
	////- Project
	newInput( 0, nodeValue_Path( "Path" )).setDisplay(VALUE_DISPLAY.path_load, { filter: "Pixel Composer project(.pxc)|*.pxc" }).rejectArray();
	
	////- Animation
	newInput( 1, nodeValue_Bool(    "Animated",          true  ));
	newInput( 4, nodeValue_EScroll( "Loop Mode",         0, ["Loop", "Ping pong", "Hold last frame", "Hide"])).rejectArray();
	newInput( 2, nodeValue_Float(   "Frame Start",       1     ));
	newInput( 3, nodeValue_Float(   "Animation Speed",   1     ));
	newInput( 5, nodeValue_Bool(    "Draw Before Start", false ));
	newInput( 6, nodeValue_Bool(    "Fractional Frame",  false ));
	// 7
	
	newOutput( 0, nodeValue_Output("Export Output", VALUE_TYPE.surface, noone));
	newOutput( 1, nodeValue_Output("Path",          VALUE_TYPE.path,    ""    )).setVisible(true, true);
	
	setting_editor = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
		if(project_object == undefined) return 0;
		
		var con_w = _panel.contentPane.surface_w - ui(4);
		
		var view  = _panel.viewMode;
		var spac  = view == INSP_VIEW_MODE.spacious;
		var _edt  = project_object.attributeEditor;
		
        var _lh, wh;
        var hh = 0;
        var yy = _y;
        
        var rx = _panel.x + ui(16);
        var ry = _panel.y + _panel.top_bar_h;
        
        var _font = spac? f_p2 : f_p3;
        
        for( var j = 0; j < 1; j++ ) {
            var title = array_safe_get(_edt[j], 0, noone);
            var param = array_safe_get(_edt[j], 1, noone);
            var editW = array_safe_get(_edt[j], 2, noone);
            var drpFn = array_safe_get(_edt[j], 3, noone);
            
            var widx = ui(8);
            var widy = yy;
            
            draw_set_text(_font, fa_left, fa_top, COLORS._main_text);
            draw_text_add(ui(16), spac? yy : yy + ui(3), __txt(title));
            
            if(spac) {
                _lh = line_get_height();
                yy += _lh + ui(6);
                hh += _lh + ui(6);
                
            } else if(view == INSP_VIEW_MODE.compact) {
                _lh = line_get_height() + ui(6);
            }
            
            var wh = 0;
            var _data = project_object.attributes[$ param];
            var _wdx  = spac? ui(16) : ui(140);
            var _wdy  = yy;
            var _wdw  = _panel.w - ui(48) - _wdx;
            var _wdh  = spac? TEXTBOX_HEIGHT  : _lh;
            
            var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, {}, _m, rx, ry)
            					.setFont(_font).setScrollpane(_panel.contentPane);
		    if(is(editW, checkBox)) _param.setHalign(fa_center);
			
            editW.setFocusHover(_focus, _hover);
            wh = editW.drawParam(_param);
            
            var jun  = PANEL_GRAPH.value_dragging;
            var widw = con_w - ui(16);
            var widh = spac? _lh + ui(6) + wh + ui(4) : max(wh, _lh);
            
            if(jun != noone && drpFn != noone && _hover && point_in_rectangle(_m[0], _m[1], widx, widy, widx + widw, widy + widh)) {
                draw_sprite_stretched_ext(THEME.ui_panel, 1, widx, widy, widw, widh, COLORS._main_value_positive, 1);
            }
            
	    	var _wdhh = spac? wh + ui(8) : max(wh, _lh) + ui(6);
        	yy += _wdhh; 
        	hh += _wdhh;
        }
        
		return hh - ui(6);
	});
	
	input_display_list = [ 
		[ "Project",   false ],  0, 
		[ "Animation", false ],  1,  4,  2,  3,  5,  6, 
		[ "Settings",  false ], setting_editor, 
		[ "Globalvar", false ], 
	];
	
	function createNewInput(_key = "globalvar") {
		var index = array_length(inputs);
		newInput(index, new NodeValue(_key, self, CONNECT_TYPE.input, VALUE_TYPE.any, 0));
		array_push(input_display_list, index);
		
		return inputs[index];
	} setDynamicInput(1, false);
	
	////- Nodes
	
	edit_time = 0;
	curr_path = "";
	
	project_content = undefined;
	project_runner  = undefined;
	project_object  = undefined;
	
	project_surface_dimension    = undefined;
	project_global_data          = undefined;
	
	attributes.timeline_override = true;
	attributes.file_checker      = true;
	attributes.project_length    = 0;
	array_push(attributeEditors, Node_Attribute("File Watcher", function() /*=>*/ {return attributes.file_checker}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")})}));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static updatePaths = function(_path, _force = false) {
		if(filename_ext(_path) != ".pxc") return;
		if(!_force && curr_path == _path) return;
		
		curr_path = _path;
		edit_time = file_get_modify_s(_path);
		
		var _name = filename_name_only(_path);
		if(!renamedManual) setDisplayName(_name, false, false);
		
		project_content = readProjectFileContent(_path);
		project_runner  = new Runner().loadProject(project_content).fetchIO();
		project_object  = project_runner.project;
		project_runner.project.path = _path;
		
		if(project_runner.output_junc == undefined)
			noti_warning("Cannot find output junction");
			
		input_display_list = array_clone(input_display_list_raw, 1);
		array_resize(inputs, input_fix_len);
		
		var _gInputs = project_object.globalNode.inputs;
		for( var i = 0, n = array_length(_gInputs); i < n; i++ ) {
			var _glo = _gInputs[i];
			var _inp = createNewInput(_glo.name);
			_inp.setType(_glo.type);
			_inp.setDisplay(_glo.display_type, _glo.display_data);
			
			var _init = true;
			if(project_global_data != undefined) {
				var _pdata = array_safe_get_fast(project_global_data, i, noone);
				if(_pdata != noone) {
					_init = false;
					_inp.applyDeserialize(_pdata);
				}
			}
			
			if(_init) _inp.applyDeserialize(_glo.serialize());
		}
	}
	
	static step = function() {
		var path = path_get(getInputData(0));
		
		if(is_array(path)) return;
		if(!file_exists_empty(path)) return;
		
		if(attributes.file_checker && file_get_modify_s(path) > edit_time) {
			updatePaths(path, true);
			triggerRender();
		}
	}
	
	static update = function() {
		#region data
			var path = path_get(getInputData(0));
			// print("update", path);
			
			var  anim  = getInputData( 1);
			var _loop  = getInputData( 4);
			var _strt  = getInputData( 2);
			var _spd   = getInputData( 3);
			var _pbef  = getInputData( 5);
			var _frac  = getInputData( 6);
		#endregion
			
		#region project path
			var _outSurf = outputs[0].getValue();
			surface_clear(_outSurf);
			outputs[0].setValue(_outSurf);
				
			update_on_frame = true;
			if(is_array(path)) return;
			
			outputs[1].setValue(path);
			updatePaths(path, false);
		#endregion
		
		if(project_object == undefined) return;
		
		var _outp  = project_runner.output_junc;
		if(!is(_outp, NodeValue)) return;
		
		#region set values
			if(project_surface_dimension != undefined) {
				project_object.attributes.surface_dimension = project_surface_dimension;
				project_surface_dimension = undefined;
			}
			
			for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
				var _inp = inputs[i];
				var _key = _inp.name;
				project_object.globalNode.overrideValue[? _key] = inputs[i].getValue();
				
			}
		#endregion
		
		#region animation
			var _frame = CURRENT_FRAME * _spd - (_strt - 1);
			if(!_frac) _frame = round(_frame);
			var _len   = project_object.animator.frames_total;
			attributes.project_length = _len;
			
			if(!_pbef && _frame < 0) return;
			
			switch(_loop) {
				case ANIMATION_END.loop : 
					_frame = safe_mod(_frame, _len);
					break;
					
				case ANIMATION_END.ping :
					_frame = safe_mod(_frame, _len * 2 - 2);
					if(_frame >= _len)
						_frame = _len * 2 - 2 - _frame;
					break;
					
				case ANIMATION_END.hold :
					// if(_frame >= _len) return;
					_frame = clamp(_frame, -_len, _len - 1);
					break;
					
				case ANIMATION_END.hide :	
					if(_frame < 0 || _frame >= _len)
						return;
			}
			
			if(_frame < 0) return;
		#endregion
		
		project_runner.render(_frame, _frame != 0);
		var _res = _outp.getValue();
		
		if(is_surface(_res)) {
			var ww = surface_get_width(_res);
			var hh = surface_get_height(_res);
			
			_outSurf = surface_verify(_outSurf, ww, hh);
			surface_set_shader(_outSurf, noone, true, BLEND.over);
				draw_surface(_res, 0, 0);
			surface_reset_shader();
			
			outputs[0].setValue(_outSurf);
		}
	}
	
	function onDoubleClick(panel) {
		if(project_object == undefined) return;
		if(PREFERENCES.panel_graph_group_require_shift && !key_mod_press(SHIFT)) return false;
		
		if(curr_path != "")
			run_in(1, function(p) /*=>*/ {return LOAD_PATH(p)}, [curr_path]);
		return true;
		
		var _graph = new Panel_Graph(project_object);
		    _graph.setSize(ui(800), ui(480));
		    _graph.setTitle(display_name);
		    
		var _dia = dialogPanelCall(_graph);
		
		return true;
	}
	
	static clearCache = function(_force = false) {
		if(project_object == undefined) return;
		
		for( var i = 0, n = array_length(project_object.allNodes); i < n; i++ )
			project_object.allNodes[i].clearCache();
	}
	
	timeline_content_dragging  = false;
	timeline_content_drag_type = 0;
	timeline_content_drag_sx   = 0;
	timeline_content_drag_mx   = 0;
	
	static drawTimeline = function(_x, _y, _s, _mx, _my, _panel) {
		if(project_object == undefined) return;
		
		var _loop = getInputData( 4);
		var _strt = getInputData( 2);
		var _spd  = getInputData( 3);
		
		var _slen = attributes.project_length;
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
    		
    		if(inputs[2].setValue(_targ))
    			UNDO_HOLDING = true;
    		
        	if(mouse_lrelease()) {
        		timeline_content_dragging = false;
        		UNDO_HOLDING = false;
        	}
    	}
    	
    	return _hov;
	}
	
	////- Serialize
	
	static doSerialize = function(_map) {
		if(project_object == undefined) return 0;
		
		_map.surface_dimension   = project_object.attributes.surface_dimension;
		
		var _ind = 0;
		_map.project_global_data = [];
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ )
			_map.project_global_data[_ind++] = inputs[i].serialize();
	}
	
	static postDeserialize = function() {
		if(has(load_map, "surface_dimension")) 
			project_surface_dimension = load_map.surface_dimension;
		
		if(has(load_map, "project_global_data")) 
			project_global_data = load_map.project_global_data;
		
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function timelineItemNode_PXC(_node) : timelineItemNode(_node) constructor {
	
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		
	}
	
	static onSerialize = function(_map) {
		_map.type = "timelineItemNode_PXC";
	}
	
}