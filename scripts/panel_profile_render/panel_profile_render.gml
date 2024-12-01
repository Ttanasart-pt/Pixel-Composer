globalvar PROFILER_STAT, PROFILER_DATA;

PROFILER_STAT = 0;
PROFILER_DATA = [];

function Panel_Profile_Render() : PanelContent() constructor {
    title = __txt("Render Profiler");
	showHeader = true;
	padding    = ui(4);
	auto_pin   = true;
	
	w = ui(800);
	h = ui(500);
	
	list_w    = ui(300);
	detail_w  = w - list_w - padding * 2 - ui(8);
	content_h = h - ui(40) - padding;
	
	io_label_y = 0;
	
	run = 0;
	render_time = 0;
	render_drag = false;
	report_selecting = noone;
	report_clicked   = noone;
	
	filter_node         = noone;
	set_selecting_node  = false;
	graph_set_latest    = noone;
	
	show_io             = true;
	show_log_level      = 1;
	
	count_render_event  = 0;
	count_message_event = 0;
	
	filter_list_string = "";
	tb_list = new textBox( TEXTBOX_INPUT.text, function(str) /*=>*/ { filter_list_string = str; searchData(); })
		.setFont(f_p3)
		.setAutoUpdate()
		.setEmpty()
	
	filter_content_string = "";
	tb_content = new textBox( TEXTBOX_INPUT.text, function(str) /*=>*/ { filter_content_string = str; })
		.setFont(f_p3)
		.setAutoUpdate()
		.setEmpty()
	
	function draw_surface_debug(surf, xx, yy, w, h, color = c_white, alpha = 1) {
		if(!is_surface(surf)) {
			draw_sprite_stretched_add(THEME.s_box_r2, 1, xx, yy, w, h, c_white, .15);
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
		draw_sprite_stretched_add(THEME.s_box_r2, 1, sx, sy, sw * ss, sh * ss, c_white, .05);
		
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
	
	function onResize() {
		padding = in_dialog? ui(4) : ui(8);
		
    	list_w    = ui(300);
    	detail_w  = w - list_w - padding * 2 - ui(8);
    	content_h = h - ui(40) - padding;
    	
	    sc_profile_list.resize(list_w - ui(8), content_h - ui(8)); 
	    sc_profile_detail.resize(detail_w - ui(8), content_h - ui(8)); 
	} 
	
	function setReport(_report) {
		report_selecting = _report;
		
		if(_report == noone) return;
		if(_report.type == "render" && set_selecting_node) 
			PANEL_GRAPH.nodes_selecting = [ _report.node ];
	}
	
	sc_profile_list = new scrollPane(list_w - ui(8), content_h - ui(8), function(_y, _m) {
	    draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
	    var _h  = ui(8);
	    var yy  = _y;
	    var _ww = sc_profile_list.surface_w;
	    var _sh = sc_profile_list.surface_h;
	    var _hovering = sc_profile_list.hover;
	    
	    var _wh = ui(24);
	    gpu_set_texfilter(true);
	    
	    if(mouse_release(mb_left)) report_clicked = noone;
	    
	    for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
	        var _report = PROFILER_DATA[i];
	        var _rtype  = _report.type;
	        
	        var _sel = report_selecting == _report;
	        var _hov = point_in_rectangle(_m[0], _m[1], 0, yy, _ww, yy + _wh);
	        var _cy  = yy + _wh / 2;
	        var _draw = _cy > -_wh && _cy < _sh + _wh;
	        
	        if(_draw && (_hov || _sel)) draw_sprite_stretched_ext(THEME.s_box_r5_clr, 1, 0, yy, _ww, _wh + 1, _sel? CDEF.main_ltgrey : CDEF.main_grey);
	        
	        if(_rtype == "render") {
	        	if(_report.search_res == false) continue;
		        
		        var _node = _report.node;
		        var _text = _node.getFullName();
		        
		        var cc = COLORS._main_text_sub;
		        if(report_selecting != noone && report_selecting.node == _report.node)
		        	cc = COLORS._main_text;
		        if(_sel) cc = COLORS._main_text_accent;
		        
		        if(_draw) {
			        draw_set_text(f_p2, fa_left, fa_center, cc);
			        draw_text_add(ui(8), _cy, $"Render {_text}");
		        }
		        
	        } else if(_rtype == "message") {
		        if(_report.level > show_log_level) continue;
		        
		        if(_draw) {
		        	var _text = _report.text;
			        
		        	draw_sprite_ext(THEME.noti_icon_log, 0, ui(16), _cy, .75, .75, 0, c_white, 1);
			        draw_set_text(f_p2, fa_left, fa_center, _sel? COLORS._main_text_accent : COLORS._main_text);
			        draw_text_add(ui(32), _cy, _text);
		        }
	        }
	        
	        if(_hov) {
	        	if(mouse_press(mb_left, pFOCUS)) {
		            setReport(_sel? noone : _report);
		            report_clicked   = _report;
		            
	        	} else if(mouse_click(mb_left, pFOCUS) && report_clicked != noone && report_clicked != _report) {
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
	    var _h = 0;
	    
	    if(report_selecting == noone) {
	        if(run == 0) {
    	        draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
    	        draw_text_add(ui(8), ui(8), $"Press render to start capturing events.");    
	            return 0;
	        }
	        
	        var _tx = ui(8);
	        var _ty = ui(8);
	        
	        draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	        draw_text_add(_tx, _ty, $"{count_render_event} render events");
	        
	        _ty += ui(20); _h += ui(20);
	        draw_text_add(_tx, _ty, $"Render time : {render_time / 1000}ms  ({render_time})");
            return 0;
	    }
	    
	    var _ww = sc_profile_detail.surface_w;
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
	        draw_sprite_stretched_ext(THEME.s_box_r5_clr, 1, _ix - ui(4), io_label_y - ui(2), _iw, ui(24), _hov? CDEF.main_ltgrey : CDEF.main_grey);
	        draw_sprite_ext(THEME.arrow, show_io * 3, _ix + ui(12), io_label_y + ui(10), 1, 1, 0, CDEF.main_grey, 1);
	        
	        draw_text_add(_ix + ui(28), io_label_y, $"Inputs [{array_length(_inputs)}] {filter_content_string == ""? "" : " (filtered)"}");
	        
	        draw_sprite_stretched_ext(THEME.s_box_r5_clr, 1, _ox - ui(4), io_label_y - ui(2), _iw, ui(24), _hov? CDEF.main_ltgrey : CDEF.main_grey);
	        draw_text_add(_ox + ui(8), io_label_y, $"Outputs [{array_length(_outputs)}] {filter_content_string == ""? "" : " (filtered)"}");
	        
	        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	        
	        var _queue = _report.queue;
		    draw_sprite_stretched_ext(THEME.s_box_r5_clr, 1, ui(4), _ty - ui(2), _ww - ui(12), ui(24), CDEF.main_grey);
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
	        	
	        	draw_sprite_stretched_ext(THEME.s_box_r2, 1, _qx, _qy, _qw + ui(12), _qh, cc, .5);
	        	draw_set_color(cc);
	        	draw_text_add(_qx + ui(6), _qy + _qh / 2, _n);
	        	
	        	_qx += _qw + ui(12 + 4);
	        }
	        
	        _ty += array_length(_queue)? _qhh + ui(16) : ui(4);
	        
	        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	        
	        var _nextx = _report.nextn;
		    draw_sprite_stretched_ext(THEME.s_box_r5_clr, 1, ui(4), _ty - ui(2), _ww - ui(12), ui(24), CDEF.main_grey);
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
	        	
	        	draw_sprite_stretched_ext(THEME.s_box_r2, 1, _qx, _qy, _qw + ui(12), _qh, cc, .5);
	        	draw_set_color(cc);
	        	draw_text_add(_qx + ui(6), _qy + _qh / 2, _n);
	        	
	        	_qx += _qw + ui(12 + 4);
	        }
	        
	        _ty += array_length(_nextx)? _qhh + ui(16) : ui(4);
	        
	        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	        
	    } else if(_rtype == "message") {
	    	var _mesg = _report.text;
	    	var _node = _report.node;
	    	
	    	var _tx   = ui(8);
	    	var _ty   = ui(8);
	    	
	    	draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
	        draw_text_ext_add(ui(8), _ty, _mesg, -1, _ww - ui(16));
	        
	        _ty += ui(24);
	        draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	        draw_text_add(_tx, _ty, $"From : {_node.getFullName()}");
	        
	    }
	    
	    return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var _pd = padding;
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var _bs = ui(28);
		var _bx = _pd;
		var _by = _pd;
		
		if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mx, my ], pFOCUS, pHOVER, "Render all", s_run, 1, COLORS._main_value_positive, 1, 1) == 2) {
		    PROFILER_STAT = 1;
		    PROFILER_DATA = [];
		    setReport(noone);
		    
		    var _t = get_timer();
		        Render();
	        render_time = get_timer() - _t;
		        
		    PROFILER_STAT = 0;
		    run++;
		}
		_bx += _bs + ui(2);
		
		if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mx, my ], pFOCUS, pHOVER, "Render partial", s_run_partial, 1, COLORS._main_value_positive, 1, 1) == 2) {
		    PROFILER_STAT = 1;
		    PROFILER_DATA = [];
		    setReport(noone);
		    
		    var _t = get_timer();
		        Render(true);
	        render_time = get_timer() - _t;
		        
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
		
		if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mx, my ], pFOCUS, pHOVER, $"Log level {show_log_level}", s_filter_log_level, show_log_level, COLORS._main_icon, 1, 1) == 2)
		    show_log_level = (show_log_level + 1) % 5;
		_bx -= _bs + ui(4);
		
		if(report_selecting == noone) 
			draw_sprite_ext(s_filter_node, 0, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon, 0.25);
		else if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mx, my ], pFOCUS, pHOVER, "Filter node", s_filter_node, 0, filter_node == noone? COLORS._main_icon : COLORS._main_accent, 1, 1) == 2) {
		    filter_node = filter_node == report_selecting.node? noone : report_selecting.node;
		    searchData();
		}
		_bx -= _bs + ui(4);
		
		if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mx, my ], pFOCUS, pHOVER, "Match selecting", s_filter_node_inspector, 0, set_selecting_node? COLORS._main_accent : COLORS._main_icon, 1, 1) == 2)
		    set_selecting_node = !set_selecting_node;
		
		_bx -= ui(4);
		var _tw = _bx - _bxl;
		tb_list.draw(_bx - _tw, _by + ui(2), _tw, _bs - ui(4), filter_list_string, [ mx, my ]);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var _bs = ui(28);
		var _bx = _pd + list_w + ui(8);
		var _by = _pd;
		
		draw_sprite_ext(s_filter, 0, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon, 0.25);
		
		_bx += _bs + ui(4);
		tb_content.draw(_bx, _by + ui(2), ui(128), _bs - ui(4), filter_content_string, [ mx, my ]);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var _px0 = _bx + ui(128) + ui(32);
		var _px1 = w - _pd;
		var _py0 = _by + ui(2);
		var _py1 = _by + _bs - ui(2);
		
		var _pw  = _px1 - _px0;
		var _ph  = _py1 - _py0;
		
		draw_sprite_stretched_ext(THEME.s_box_r2, 0, _px0, _py0, _pw, _ph, COLORS._main_icon_dark, 1);
		
		var _total_time    = 0;
		var _selected_time = 0;
		var _running_time  = 0;
		
		count_render_event  = 0;
		count_message_event = 0;
		
		for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
		    var _report  = PROFILER_DATA[i];
		    var _rtype  = _report.type;
		    
		    if(_report == report_selecting) _selected_time = _running_time;
		    
			if(_rtype == "render") {
				count_render_event++;
			    var _node    = _report.node;
			    var _time    = _report.time;
			    
			    _total_time   += _time;
			    _running_time += _time;
			    
			} else if(_rtype == "message") {
				count_message_event++;
			}
		}
		
		if(_total_time > 0) {
			var _running_time = 0;
			
			if(mouse_release(mb_left)) render_drag = false;
			
			for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
			    var _report  = PROFILER_DATA[i];
			    var _rtype  = _report.type;
			    var _rx   = _px0 + (_running_time / _total_time) * _pw;
			    
				if(_rtype == "render") {
					draw_set_color(COLORS._main_icon);
					draw_set_alpha(0.25);
			    	draw_line(_rx, _py0, _rx, _py0 + _ph - 2);
			    	draw_set_alpha(1);
			    	
					var _time = _report.time;
					_running_time += _time;
					
					var _rx1  = _px0 + (_running_time / _total_time) * _pw;
					if((pHOVER && point_in_rectangle(mx, my, _rx, _py0, _rx1, _py1) || (render_drag && mx >= _rx && mx < _rx1))) {
						TOOLTIP = $"Render {_report.node.getFullName()}";
						
						if(mouse_click(mb_left, pFOCUS) || render_drag) {
							render_drag = true;
							setReport(_report);
						}
					}
					
					if(report_selecting != noone && report_selecting.node == _report.node)
						draw_sprite_stretched_ext(THEME.s_box_r2, 0, _rx, _py0, _rx1 - _rx, _ph, COLORS._main_icon, .2);
				}
				
				if(_rtype == "message") {
					if(_report.level > show_log_level) continue;
					draw_set_color(COLORS._main_accent);
			    	
			    	if(pHOVER && point_in_rectangle(mx, my, _rx - 4, _py0, _rx + 4, _py1)) {
			    		TOOLTIP = _report.text;
			    		draw_line_width(_rx, _py0, _rx, _py0 + _ph - 2, 2);
			    		
			    	} else
			    		draw_line(_rx, _py0, _rx, _py0 + _ph - 2);
				}
			}
			
			if(report_selecting != noone && report_selecting.type == "render") {
				var _time = report_selecting.time;
			    var _rx   = _px0 + (_selected_time / _total_time) * _pw;
			    var _rw   = (_time / _total_time) * _pw;
			    
			    draw_sprite_stretched_ext(THEME.s_box_r2, 0, _rx, _py0, _rw, _ph, COLORS._main_icon, 1);
			}
			
		}
		
		draw_sprite_stretched_add(THEME.s_box_r2, 1, _px0, _py0, _pw, _ph, COLORS._main_icon, .3);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var ndx = _pd;
		var ndy = ui(40);
		var ndw = list_w;
		var ndh = content_h;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		sc_profile_list.setFocusHover(pFOCUS, pHOVER);
		sc_profile_list.draw(ndx + ui(4), ndy + ui(4), mx - ndx - ui(4), my - ndy - ui(4));
		
		var ndx = _pd + list_w + ui(8);
		var ndw = detail_w;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		sc_profile_detail.setFocusHover(pFOCUS, pHOVER);
		sc_profile_detail.draw(ndx + ui(4), ndy + ui(4), mx - ndx - ui(4), my - ndy - ui(4));
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		if(set_selecting_node) {
			var _graph = array_empty(PANEL_GRAPH.nodes_selecting)? noone : PANEL_GRAPH.nodes_selecting[0];
			if(_graph != noone && graph_set_latest != _graph) {
				for( var i = 0, n = array_length(PROFILER_DATA); i < n; i++ ) {
				    var _report  = PROFILER_DATA[i];
				    if(_report.type == "render" && _report.node == _graph) {
				    	report_selecting = _report;
				    	break;
				    }
				}
			}
			graph_set_latest = _graph;
		}
	}
}