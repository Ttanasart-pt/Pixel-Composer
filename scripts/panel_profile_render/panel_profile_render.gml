globalvar PROFILER_STAT; PROFILER_STAT = 0;
globalvar PROFILER_DATA; PROFILER_DATA = [];

function profile_log(_level, _text) { 
	if(!PROFILER_STAT) return;
	array_push(PROFILER_DATA, new profile_message(_level, _text));
}

function profile_message(_level, _text) constructor {
	type  = "message";
	node  = undefined;
	level = _level; 
	text  = _text;
}

function Panel_Profile_Render() : PanelContent() constructor {
    title      = __txt("Render Profiler");
	showHeader = true;
	auto_pin   = true;
	
	w = ui(800);
	h = ui(500);
	
	list_w     = ui(400);
	detail_w   = w - list_w - padding * 2 - ui(8);
	content_h  = h - ui(40) - padding;
	io_label_y = 0;
	
	run = 0;
	render_time      = 0;
	render_drag      = false;
	report_selecting = noone;
	report_clicked   = noone;
	
	filter_node         = noone;
	set_selecting_node  = false;
	graph_set_latest    = noone;
	
	show_io             = true;
	show_log_level      = 1;
	
	filter_list_string    = "";
	filter_content_string = "";
	
	tb_list    = textBox_Text(function(str) /*=>*/ { filter_list_string    = str; searchData(); }).setFont(f_p3).setAutoUpdate().setEmpty()
	tb_content = textBox_Text(function(str) /*=>*/ { filter_content_string = str;               }).setFont(f_p3).setAutoUpdate().setEmpty()
	
	function draw_surface_debug(surf, xx, yy, w, h, color = c_white, alpha = 1) {
		if(!is_surface(surf)) {
			draw_sprite_stretched_add(THEME.box_r2, 1, xx, yy, w, h, c_white, .15);
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(xx + w / 2, yy + h / 2, string(surf));
			return;
		}
		
		var sw = surface_get_width(surf);
		var sh = surface_get_height(surf);
		var sd = surface_get_format(surf);
		var ss = min((w - ui(144)) / sw, h / sh);
		var sx = xx;
		var sy = yy + h / 2 - sh * ss / 2
		
		draw_surface_ext(surf, sx, sy, ss, ss, 0, color, alpha);
		draw_sprite_stretched_add(THEME.box_r2, 1, sx, sy, sw * ss, sh * ss, c_white, .05);
		
		var _tx = sx + sw * ss + ui(8);
		var _ty = yy;
		draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_add(_tx, _ty, $"{surf}");                                             			_ty += ui(16);
		
		draw_text_add(_tx, _ty, $"Dimension : {sw} x {sh}");                            			_ty += ui(16);
		draw_text_add(_tx, _ty, $"Format : {surface_format_string(sd)}");               			_ty += ui(16);
		
		draw_text_add(_tx, _ty, $"Size : {sw * sh * surface_format_get_bytes(sd)} bytes");			_ty += ui(16);
	}
	
	function searchData() {
		for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
	        var _report = PROFILER_DATA[i];
	        _report.search_res = true;
	        
	        if(_report.type != "render") continue;
	        
	        var _node = _report.node;
	        
	        if(filter_node != noone && filter_node != _node) 
	        	_report.search_res = false;
	        	
		    if(filter_list_string != "" && string_pos(string_lower(filter_list_string), string_lower(_report.search_string)) == 0) 
		    	_report.search_res = false;
		}
	}
	
	function setReport(_report) {
		report_selecting = _report;
		
		if(_report == noone) return;
		if(_report.type == "render" && set_selecting_node) 
			PANEL_GRAPH.setFocusingNode(_report.node);
	}
	
	count_render_event    = 0;
	count_message_event   = 0;
	node_render_time      = 0;
	node_render_time_type = {};
	node_render_rtim_type = {};
	node_render_time_amo  = {};
	node_render_time_type_sorted = [];
	pie_selecting = noone;
	
	function summarize() {
		count_render_event    = 0;
		count_message_event   = 0;
		node_render_time      = 0;
		node_render_rtime     = 0;
		node_render_time_type = {};
		node_render_rtim_type = {};
		node_render_time_amo  = {};
		node_render_time_type_sorted = [];
		
		for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
		    var _report  = PROFILER_DATA[i];
		    var _rtype  = _report.type;
		    
			switch(_rtype) {
				case "render"  : 
				    var _node = _report.node;
				    var _time = _report.time;
				    
				    node_render_time  += _report.time;
				    node_render_rtime += _report.renderTime;
					
					count_render_event++;
					
					var _typ = instanceof(_node);
					node_render_time_type[$ _typ] = struct_try_get(node_render_time_type, _typ, 0) + _time;
					node_render_rtim_type[$ _typ] = struct_try_get(node_render_rtim_type, _typ, 0) + _report.renderTime;
					node_render_time_amo[$ _typ]  = struct_try_get(node_render_time_amo,  _typ, 0) + 1;
					break;
					
				case "message" : count_message_event++; break;
			}
		}
		
		var _pr = ds_priority_create();
		var _nods = variable_struct_get_names(node_render_time_type);
		for( var i = 0, n = array_length(_nods); i < n; i++ ) {
			var _t = _nods[i];
			var _c = make_color_hsv(random(255), 160, 160);
			var _d = {
				node   : _t, 
				color  : _c,
				
				amount : node_render_time_amo[$  _t],
				time   : node_render_time_type[$ _t], 
				rtime  : node_render_rtim_type[$ _t],
			};
			
			ds_priority_add(_pr, _d, node_render_time_type[$ _t]);
		}
		
		var sz = ds_priority_size(_pr);
		var i  = 0;
		
		repeat(sz) node_render_time_type_sorted[i++] = ds_priority_delete_max(_pr);
		ds_priority_destroy(_pr);
	}
	
	sc_profile_list = new scrollPane(list_w - ui(8), content_h - ui(8), function(_y, _m) {
	    draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
	    var _h  = ui(8);
	    var yy  = _y;
	    var _ww = sc_profile_list.surface_w;
	    var _sh = sc_profile_list.surface_h;
	    var _hovering = sc_profile_list.hover;
	    
	    var _wh = ui(20);
	    gpu_set_texfilter(true);
	    
	    if(mouse_release(mb_left)) report_clicked = noone;
	    
	    for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
	        var _report = PROFILER_DATA[i];
	        var _rtype  = _report.type;
	        
	        var _sel = report_selecting == _report;
	        var _hov = point_in_rectangle(_m[0], _m[1], 0, yy, _ww, yy + _wh);
	        var _cy  = yy + _wh / 2;
	        var _draw = _cy > -_wh && _cy < _sh + _wh;
	        
	        if(_draw && (_hov || _sel)) draw_sprite_stretched_ext(THEME.box_r5_clr, 1, 0, yy, _ww, _wh + 1, _sel? CDEF.main_ltgrey : CDEF.main_grey);
	        
	        if(_rtype == "render") {
	        	if(_report.search_res == false) continue;
		        
		        if(_draw) {
			        var _node = _report.node;
			        var _text = _node.getFullName();
			        
			        var _text = _node.getFullName();
		        	var _ng = _node.group;
		        	while(_ng != noone) {
		        		_text = $"{_ng.getDisplayName()} > {_text}";
		        		_ng = _ng.group;
		        	}
		        	
			        var cc = COLORS._main_text_sub;
			        if(report_selecting != noone && report_selecting.node == _report.node)
			        	cc = COLORS._main_text;
			        if(_sel) cc = COLORS._main_text_accent;
		        
			        draw_set_text(f_p3, fa_left, fa_center, cc);
			        draw_text_add(ui(8), _cy, $"Render {_text}");
		        }
		        
	        } else if(_rtype == "message") {
		        if(_report.level > show_log_level) continue;
		        
		        if(_draw) {
		        	var _text = _report.text;
			        
		        	draw_sprite_ui(THEME.noti_icon_log, 0, ui(16), _cy, .75, .75, 0, c_white, 1);
			        draw_set_text(f_p3, fa_left, fa_center, _sel? COLORS._main_text_accent : COLORS._main_text);
			        draw_text_add(ui(32), _cy, _text);
		        }
	        }
	        
	        if(_hov && pFOCUS) {
	        	if(mouse_lpress()) {
		            setReport(_sel? noone : _report);
		            report_clicked   = _report;
		            
	        	} else if(mouse_lclick() && report_clicked != noone && report_clicked != _report) {
	        		setReport(_report);
	        		report_clicked   = _report;
	        	}
	        }
	        
	        _h += _wh;
	        yy += _wh;
	    }
	    
	    gpu_set_texfilter(false);
	    
	    return _h;
	});
	
	__sp_ih = 0;
	__sp_oh = 0;
	
	sc_profile_detail = new scrollPane(detail_w - ui(8), content_h - ui(8), function(_y, _m) {
	    draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
	    var _h   = 0;
	    var _ww  = sc_profile_detail.surface_w;
	    var _hh  = sc_profile_detail.surface_h;
	    var _hov = sc_profile_detail.hover;
	    var _foc = sc_profile_detail.active;
	    
	    if(report_selecting == noone) {
	        if(run == 0) {
    	        draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
    	        draw_text_add(ui(8), ui(8), $"Press render to start capturing events.");    
	            return 0;
	        }
	        
	        var _tx = ui(8);
	        var _ty = _y + ui(8);
	        
	        draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	        draw_text_add(_tx, _ty, $"{count_render_event} render events");
	        
	        _ty += ui(20); _h += ui(20);
	        draw_text_add(_tx, _ty, $"Render time : {render_time / 1000}ms  ({node_render_time} / {render_time})");
	        
	        _ty += ui(28); _h += ui(28);
	        
	        var _a = 90;
	        var pr = ui(120);
	        var px = ui(16) + pr;
	        var py = max(ui(8), _ty) + pr;
	        
	        var tx_amo  = px + pr + ui(32);
	        var tx_name = tx_amo  + ui(40);
	        var tx_time = tx_name + ui(180);
	        var tx_per  = tx_time + ui(64);
	        var tx_pern = tx_per  + ui(80);
	        var tx_rtim = tx_pern + ui(80);
	        var tx_last = tx_rtim + ui(80);
	        
	        draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
        	draw_text_add(tx_name, _ty, "type");
        	
        	draw_set_halign(fa_right);
        	draw_text_add(tx_time + ui(80 - 8), _ty, "time (ns)");
        	draw_text_add(tx_per  + ui(80 - 8), _ty, "%");
        	draw_text_add(tx_pern + ui(80 - 8), _ty, "time/node");
        	draw_text_add(tx_rtim + ui(80 - 8), _ty, "render");
        	
        	if(_hov) {
        		var _ty1 = _ty + ui(19);
        		
	        	if(point_in_rectangle(_m[0], _m[1], tx_name, _ty, tx_time, _ty1)) {
	        		TOOLTIP = "Node type";
	        	}
	        	
	        	if(point_in_rectangle(_m[0], _m[1], tx_time, _ty, tx_per,  _ty1)) {
	        		TOOLTIP = "Total processing time (including graph propagation, debug data collection)";
	        		if(mouse_lpress(_foc)) array_sort(node_render_time_type_sorted, function(a,b) /*=>*/ {return b.time - a.time});
	        	}
	        	
	        	if(point_in_rectangle(_m[0], _m[1], tx_per,  _ty, tx_pern, _ty1)) {
	        		TOOLTIP = "Total time as percentage";
	        		if(mouse_lpress(_foc)) array_sort(node_render_time_type_sorted, function(a,b) /*=>*/ {return b.time - a.time});
	        	}
	        	
	        	if(point_in_rectangle(_m[0], _m[1], tx_pern, _ty, tx_rtim, _ty1)) {
	        		TOOLTIP = "Average time per node";
	        		if(mouse_lpress(_foc)) array_sort(node_render_time_type_sorted, function(a,b) /*=>*/ {return b.time/b.amount - a.time/a.amount});
	        	}
	        	
	        	if(point_in_rectangle(_m[0], _m[1], tx_rtim, _ty, tx_last, _ty1)) {
	        		TOOLTIP = "Processing time";
	        		if(mouse_lpress(_foc)) array_sort(node_render_time_type_sorted, function(a,b) /*=>*/ {return b.rtime - a.rtime});
	        	}
	        	
        	}
        	_ty += ui(20); _h += ui(20);
	        
	        var _pie_selecting = noone;
	        
	        for( var i = 0, n = array_length(node_render_time_type_sorted); i < n; i++ ) {
	        	var _timn = node_render_time_type_sorted[i];
	        	var _node = _timn.node;
	        	var _colr = _timn.color;
	        	var _amo  = _timn.amount;
	        	var _time = _timn.time;
	        	var _rtm  = _timn.rtime;
	        	
	        	var _as = _rtm / node_render_rtime * 360;
	        	var _at = _a + _as;
	        	draw_set_color(_colr);
	        	if(pie_selecting != noone) draw_set_alpha(0.25 + 0.75 * (_node == pie_selecting));
	        	draw_circle_angle(px, py, pr, _a, _at);
	        	draw_set_alpha(1);
	        	_a = _at;
	        	
	        	if(_ty >= -16 && _ty <= _hh + 16) {
		        	draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text_sub);
		        	draw_text_add(tx_amo + ui(40 - 8),  _ty, _amo);
		        	
		        	draw_set_color(_node == pie_selecting? COLORS._main_text_accent : COLORS._main_text);
		        	draw_set_halign(fa_left);
		        	draw_text_add(tx_name, _ty, _node);
		        	
		        	draw_set_halign(fa_right);
		        	draw_text_add(tx_time + ui(80 - 8), _ty, _time);
		        	draw_text_add(tx_per  + ui(80 - 8), _ty, _time / node_render_time * 100);
		        	draw_text_add(tx_pern + ui(80 - 8), _ty, round(_time / _amo));
		        	draw_text_add(tx_rtim + ui(80 - 8), _ty, _rtm);
		        	
		        	if(_hov && point_in_rectangle(_m[0], _m[1], tx_amo, _ty, _ww, _ty + ui(20) - 1))
		        		_pie_selecting = _node;
	        	}
	        	
	        	_ty += ui(20); _h += ui(20);
	        }
	        
	        pie_selecting = _pie_selecting;
	        
	        _ty += ui(20); _h += ui(20);
	        
            return _h;
	    }
	    
	    var _hovering = sc_profile_detail.hover;
	    
	    var _report = report_selecting;
	    var _rtype  = _report.type;
	    
	    if(_rtype == "render") {
		    var _node    = _report.node;
		    var _time    = _report.time;
		    var _inputs  = _report.inputs;
		    var _outputs = _report.outputs;
		    
		    var _tx = ui(8);
	        var _ty = _y + ui(8);
	        
	        draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
	        draw_text_add(_tx, _ty, $"Render {_node.getFullName()}");
	        
	        _ty += ui(24); _h += ui(24);
	        draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	        draw_text_add(_tx, _ty, $"Render time : {_time / 1000}ms  ({_time})");
		    
		    _ty += ui(28); _h += ui(28);
		    
		    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		    
		    var _iw = _ww / 2 - ui(8);
		    var _ix = ui(8);
		    var _ox = ui(8) + _iw + ui(4);
		    
		    var _io_label_y = max(_ty, ui(8));
		    
		    _ty += ui(28); _h += ui(28);
		    
		    var _yy = _ty;
		    var _ih = 0;
		    var _x0 = _ix;
		    var _x1 = _ix + _iw;
		    
		    if(show_io) {
		    	for( var i = 0, n = array_length(_inputs); i < n; i++ ) {
		        var _j = _node.inputs[i];
		        var _v = _inputs[i];
		        
		        var _type = _j.type;
		        var _wh   = ui(20);
		        
		        if(filter_content_string != "" && string_pos(string_lower(filter_content_string), string_lower(_j.name)) == 0) continue;
		        
		        draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
	            draw_text_add(_x0, _yy, _j.name);
	            
	            var _vx = _x0 + ui(8);
	            var _vy = _yy + ui(16);
	            var _vw = _iw - ui(16);
	            
		        switch(_type) {
		            case VALUE_TYPE.surface :
		                draw_surface_debug(_v, _vx, _vy, _vw, ui(128));
		                _wh += ui(128);
		                break;
		                
		            default :
		                var _tx = string(_v);
		                
		                draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
	                    draw_text_ext_add(_vx, _vy, _tx, -1, _vw);
	                    _wh += string_height_ext(_tx, -1, _vw);
		                break;
		        }
		        
		        _yy += _wh + ui(4);
		        _ih += _wh + ui(4);
		    }
		    }
		    
		    var _fy = io_label_y + ui(28);
		    var _yy = min(max(_ty, _fy), _ty + max(0, __sp_ih - __sp_oh));
		    var _oh = 0;
		    var _x0 = _ox;
		    var _x1 = _ox + _iw;
		    
		    if(show_io) {
		    	for( var i = 0, n = array_length(_outputs); i < n; i++ ) {
		        var _j = _node.outputs[i];
		        var _v = _outputs[i];
		        
		        var _type = _j.type;
		        var _wh   = ui(20);
		        
		        if(filter_content_string != "" && string_pos(string_lower(filter_content_string), string_lower(_j.name)) == 0) continue;
		        
		        draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
	            draw_text_add(_x0, _yy, _j.name);
	            
	            var _vx = _x0 + ui(8);
	            var _vy = _yy + ui(16);
	            var _vw = _iw - ui(8);
	            
		        switch(_type) {
		            case VALUE_TYPE.surface :
		                draw_surface_debug(_v, _vx, _vy, _vw, ui(128));
		                _wh += ui(128);
		                break;
		                
		            default :
		                var _tx = string(_v);
		                
		                draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
	                    draw_text_ext_add(_vx, _vy, _tx, -1, _vw);
	                    _wh += string_height_ext(_tx, -1, _vw);
		                break;
		        }
		        
		        _yy += _wh;
		        _oh += _wh;
		    }
		    }
		    
		    __sp_ih = _ih;
			__sp_oh = _oh;
		
		    _h  += max(_ih, _oh) + ui(8);
		    _ty += max(_ih, _oh) + ui(8);
		    
		    io_label_y = min(_io_label_y, _ty - ui(32));
		    
		    draw_set_color(COLORS.panel_bg_clear_inner);
		    draw_rectangle(_ix - ui(4), io_label_y - ui(10), _ix + _iw - ui(4), io_label_y + ui(16), false);
		    draw_rectangle(_ox - ui(4), io_label_y - ui(10), _ox + _iw - ui(4), io_label_y + ui(16), false);
		    
		    var _hov = _hovering && point_in_rectangle(_m[0], _m[1], 0, io_label_y, _ww, io_label_y + ui(24));
		    if(_hov && mouse_press(mb_left)) show_io = !show_io;
		    
		    draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	        draw_sprite_stretched_ext(THEME.box_r5_clr, 1, _ix - ui(4), io_label_y - ui(2), _iw, ui(24), _hov? CDEF.main_ltgrey : CDEF.main_grey);
	        draw_sprite_ui(THEME.arrow, show_io * 3, _ix + ui(12), io_label_y + ui(10), 1, 1, 0, CDEF.main_grey, 1);
	        
	        draw_text_add(_ix + ui(28), io_label_y, $"Inputs [{array_length(_inputs)}] {filter_content_string == ""? "" : " (filtered)"}");
	        
	        draw_sprite_stretched_ext(THEME.box_r5_clr, 1, _ox - ui(4), io_label_y - ui(2), _iw, ui(24), _hov? CDEF.main_ltgrey : CDEF.main_grey);
	        draw_text_add(_ox + ui(8), io_label_y, $"Outputs [{array_length(_outputs)}] {filter_content_string == ""? "" : " (filtered)"}");
	        
	        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	        
	        var _queue = _report.queue;
		    draw_sprite_stretched_ext(THEME.box_r5_clr, 1, ui(4), _ty - ui(2), _ww - ui(12), ui(24), CDEF.main_grey);
		    draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	        draw_text_add(ui(16), _ty, $"Current queue [{array_length(_queue)}]");
	        
		    _ty += ui(32); _h += ui(48);
		    
	        var _qh = ui(20);
	        var _qx = ui(8);
	        var _qy = _ty;
	        var _qhh = _qh;
	        
	        _h += _qh + ui(4);
	        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
	        
	        for( var i = 0, n = array_length(_queue); i < n; i++ ) {
	        	var _qnode = _queue[i];
	        	var _n  = _qnode.getFullName();
	        	var _qw = string_width(_n);
	        	
	        	if(_qx + _qw > _ww - ui(12)) {
	        		_qx	  = ui(8);
	        		_qy  += _qh + ui(4);
	        		_h   += _qh + ui(4);
	        		_qhh += _qh + ui(4);
	        	}
	        	
	        	var cc = COLORS._main_icon;
	        	if(filter_list_string != "" && string_pos(string_lower(filter_list_string), string_lower(_n)) != 0) 
	        		cc = COLORS._main_accent;
	        	
	        	draw_sprite_stretched_ext(THEME.box_r2, 1, _qx, _qy, _qw + ui(12), _qh, cc, .5);
	        	draw_set_color(cc);
	        	draw_text_add(_qx + ui(6), _qy + _qh / 2, _n);
	        	
	        	_qx += _qw + ui(12 + 4);
	        }
	        
	        _ty += array_length(_queue)? _qhh + ui(16) : ui(4);
	        
	        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	        
	        var _nextx = _report.nextn;
		    draw_sprite_stretched_ext(THEME.box_r5_clr, 1, ui(4), _ty - ui(2), _ww - ui(12), ui(24), CDEF.main_grey);
		    draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	        draw_text_add(ui(16), _ty, $"Next queue [{array_length(_nextx)}]");
	        
		    _ty += ui(32); _h += ui(48);
		    
	        var _qh  = ui(20);
	        var _qx  = ui(8);
	        var _qy  = _ty;
	        var _qhh = _qh;
	        
	        _h += _qh + ui(4);
	        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
	        
	        for( var i = 0, n = array_length(_nextx); i < n; i++ ) {
	        	var _qnode = _nextx[i];
	        	var _n  = _qnode.getFullName();
	        	var _qw = string_width(_n);
	        	
	        	if(_qx + _qw > _ww - ui(12)) {
	        		_qx	  = ui(8);
	        		_qy  += _qh + ui(4);
	        		_h   += _qh + ui(4);
	        		_qhh += _qh + ui(4);
	        	}
	        	
	        	var cc = COLORS._main_icon;
	        	if(filter_list_string != "" && string_pos(string_lower(filter_list_string), string_lower(_n)) != 0) 
	        		cc = COLORS._main_accent;
	        	
	        	draw_sprite_stretched_ext(THEME.box_r2, 1, _qx, _qy, _qw + ui(12), _qh, cc, .5);
	        	draw_set_color(cc);
	        	draw_text_add(_qx + ui(6), _qy + _qh / 2, _n);
	        	
	        	_qx += _qw + ui(12 + 4);
	        }
	        
	        _ty += array_length(_nextx)? _qhh + ui(16) : ui(4);
	        
	        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	        
	    } else if(_rtype == "message") {
	    	var _mesg = _report.text;
	    	
	    	var _tx   = ui(8);
	    	var _ty   = ui(8);
	    	
	    	draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
	        draw_text_ext_add(ui(8), _ty, _mesg, -1, _ww - ui(16));
	        
	        if(is(_report.node, Node)) {
	        	var _node = _report.node;
	        	
		        _ty += ui(24);
		        draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
		        draw_text_add(_tx, _ty, $"From : {_node.getFullName()}");
	        }
	        
	    }
	    
	    return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var _pd = padding;
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var _b  = THEME.button_hide_fill;
		var _bs = ui(28);
		var _bx = _pd;
		var _by = _pd;
		var _bc = COLORS._main_value_positive;
		var _m  = [ mx, my ];
		
		if(buttonInstant(_b, _bx, _by, _bs, _bs, _m, pHOVER, pFOCUS, "Render all", s_run, 1, _bc, 1, UI_SCALE) == 2) {
				
		    PROFILER_STAT = 1;
		    PROFILER_DATA = [];
		    setReport(noone);
		    
		    var _t = get_timer();
		        RenderSync(PROJECT);
	        render_time = get_timer() - _t;
		    
		    summarize();
		    PROFILER_STAT = 0;
		    run++;
		}
		_bx += _bs + ui(2);
		
		if(buttonInstant(_b, _bx, _by, _bs, _bs, _m, pHOVER, pFOCUS, "Render partial", s_run_partial, 1, _bc, 1, UI_SCALE) == 2) {
				
		    PROFILER_STAT = 1;
		    PROFILER_DATA = [];
		    setReport(noone);
		    
		    var _t = get_timer();
		        RenderSync(PROJECT, true);
	        render_time = get_timer() - _t;
		    
		    summarize();
		    PROFILER_STAT = 0;
		    run++;
		}
		_bx += _bs + ui(4);
		
		if(buttonInstant(_b, _bx, _by, _bs, _bs, _m, pHOVER, pFOCUS, "Render from selection", s_run_partial, 1, _bc, 1, UI_SCALE) == 2) {
			
		    PROFILER_STAT = 1;
		    PROFILER_DATA = [];
		    setReport(noone);
		    
	    	for( var i = 0, n = array_length(PANEL_GRAPH.nodes_selecting); i < n; i++ )
	    		PANEL_GRAPH.nodes_selecting[i].resetRender(false);
		    
		    var _t = get_timer();
		        RenderSync(PROJECT, true);
	        render_time = get_timer() - _t;
		    
		    summarize();
		    PROFILER_STAT = 0;
		    run++;
		}
		_bx += _bs + ui(4);
		
		var _bxl = _bx;
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		tb_list.setFocusHover(pFOCUS, pHOVER);		tb_list.register();
		tb_content.setFocusHover(pFOCUS, pHOVER);	tb_content.register();
		
		var _bs = ui(28);
		var _bx = _pd + list_w - _bs;
		var _by = _pd;
		
		if(buttonInstant(_b, _bx, _by, _bs, _bs, _m, pHOVER, pFOCUS, $"Log level {show_log_level}", 
			s_filter_log_level, show_log_level, COLORS._main_icon, 1, UI_SCALE) == 2)
		    show_log_level = (show_log_level + 1) % 5;
		_bx -= _bs + ui(4);
		
		if(report_selecting == noone) 
			draw_sprite_ext(s_filter_node, 0, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon, 0.25);
		else if(buttonInstant(_b, _bx, _by, _bs, _bs, _m, pHOVER, pFOCUS, "Filter node", 
			s_filter_node, 0, filter_node == noone? COLORS._main_icon : COLORS._main_accent, 1, UI_SCALE) == 2) {
		    filter_node = filter_node == report_selecting.node? noone : report_selecting.node;
		    searchData();
		}
		_bx -= _bs + ui(4);
		
		if(buttonInstant(_b, _bx, _by, _bs, _bs, _m, pHOVER, pFOCUS, "Match selecting", 
			s_filter_node_inspector, 0, set_selecting_node? COLORS._main_accent : COLORS._main_icon, 1, UI_SCALE) == 2)
		    set_selecting_node = !set_selecting_node;
		_bx -= _bs + ui(4);
		
		if(buttonInstant(_b, _bx, _by, _bs, _bs, _m, pHOVER, pFOCUS, "Render Print Flag", 
			s_filter_log_level, 0, global.FLAG.render? COLORS._main_accent : COLORS._main_icon, 1, UI_SCALE) == 2)
		    global.FLAG.render = !global.FLAG.render;
		
		_bx -= ui(4);
		var _tw = _bx - _bxl;
		tb_list.draw(_bx - _tw, _by + ui(2), _tw, _bs - ui(4), filter_list_string, _m);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var _bs = ui(28);
		var _bx = _pd + list_w + ui(8);
		var _by = _pd;
		
		draw_sprite_ext(s_filter, 0, _bx + _bs / 2, _by + _bs / 2, UI_SCALE, UI_SCALE, 0, COLORS._main_icon, 0.25);
		
		_bx += _bs + ui(4);
		tb_content.draw(_bx, _by + ui(2), ui(128), _bs - ui(4), filter_content_string, _m);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var _px0 = _bx + ui(128) + ui(32);
		var _px1 = w - _pd;
		var _py0 = _by + ui(2);
		var _py1 = _by + _bs - ui(2);
		
		var _pw  = _px1 - _px0;
		var _ph  = _py1 - _py0;
		
		draw_sprite_stretched_ext(THEME.box_r2, 0, _px0, _py0, _pw, _ph, COLORS._main_icon_dark, 1);
		
		var _selected_time = 0;
		var _running_time  = 0;
		
		for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
		    var _report  = PROFILER_DATA[i];
		    var _rtype  = _report.type;
		    
		    if(_report == report_selecting) _selected_time = _running_time;
		    
			if(_rtype == "render") {
			    var _node    = _report.node;
			    var _time    = _report.time;
			    
			    _running_time += _time;
			}
		}
		
		if(node_render_time > 0) {
			var _running_time = 0;
			
			if(mouse_release(mb_left)) render_drag = false;
			
			for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
			    var _report  = PROFILER_DATA[i];
			    var _rtype  = _report.type;
			    var _rx   = _px0 + (_running_time / node_render_time) * _pw;
			    
				if(_rtype == "render") {
					draw_set_color(COLORS._main_icon);
					draw_set_alpha(0.25);
			    	draw_line(_rx, _py0, _rx, _py0 + _ph - 2);
			    	draw_set_alpha(1);
			    	
					var _time = _report.time;
					_running_time += _time;
					
					var _rx1  = _px0 + (_running_time / node_render_time) * _pw;
					if((pHOVER && point_in_rectangle(mx, my, _rx, _py0, _rx1, _py1) || (render_drag && mx >= _rx && mx < _rx1))) {
						TOOLTIP = $"Render {_report.node.getFullName()}";
						
						if(mouse_click(mb_left, pFOCUS) || render_drag) {
							render_drag = true;
							setReport(_report);
						}
					}
					
					if(report_selecting != noone && report_selecting.node == _report.node)
						draw_sprite_stretched_ext(THEME.box_r2, 0, _rx, _py0, _rx1 - _rx, _ph, COLORS._main_icon, .2);
				}
				
				if(_rtype == "message") {
					if(_report.level > show_log_level) continue;
					draw_set_color(COLORS._main_accent);
			    	
			    	if(pHOVER && point_in_rectangle(mx, my, _rx - 4, _py0, _rx + 4, _py1)) {
			    		TOOLTIP = _report.text;
			    		draw_line_width(_rx, _py0, _rx, _py0 + _ph - ui(2), 2);
			    		
			    	} else
			    		draw_line(_rx, _py0, _rx, _py0 + _ph - ui(2));
				}
			}
			
			if(report_selecting != noone && report_selecting.type == "render") {
				var _time = report_selecting.time;
			    var _rx   = _px0 + (_selected_time / node_render_time) * _pw;
			    var _rw   = (_time / node_render_time) * _pw;
			    
			    draw_sprite_stretched_ext(THEME.box_r2, 0, _rx, _py0, _rw, _ph, COLORS._main_icon, 1);
			}
			
		}
		
		draw_sprite_stretched_add(THEME.box_r2, 1, _px0, _py0, _pw, _ph, COLORS._main_icon, .3);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		var ndx = _pd;
		var ndy = ui(44);
		
    	detail_w  = w - list_w - padding * 2 - ui(8);
    	content_h = h - ndy - padding;
    	
		var ndw = list_w;
		var ndh = content_h;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		sc_profile_list.verify(list_w - ui(8), content_h - ui(8)); 
		sc_profile_list.setFocusHover(pFOCUS, pHOVER);
		sc_profile_list.drawOffset(ndx + ui(4), ndy + ui(4), mx, my);
		
		var ndx = _pd + list_w + ui(8);
		var ndw = detail_w;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		sc_profile_detail.verify(detail_w - ui(8), content_h - ui(8)); 
		sc_profile_detail.setFocusHover(pFOCUS, pHOVER);
		sc_profile_detail.drawOffset(ndx + ui(4), ndy + ui(4), mx, my);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		if(set_selecting_node) {
			var _graph = array_empty(PANEL_GRAPH.nodes_selecting)? noone : PANEL_GRAPH.nodes_selecting[0];
			
			if(_graph != noone && graph_set_latest != _graph) {
				for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
				    var _report  = PROFILER_DATA[i];
				    if(_report.type != "render" || _report.node != _graph) continue;
				    
			    	report_selecting = _report;
			    	break;
				}
			}
			
			graph_set_latest = _graph;
		}
	}
}