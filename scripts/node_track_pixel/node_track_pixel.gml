function Node_Track_Pixel(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Track Pixel";
	update_on_frame = true;
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Tracking
	newInput( 1, nodeValue_Vec2(    "Origin",       [.5,.5]  )).setUnitSimple().setAnimable(false).hideLabel();
	newInput( 2, nodeValue_Int(     "Track Radius",   4      )).setAnimable(false);
	newInput( 3, nodeValue_Int(     "Scan Radius",    8      )).setAnimable(false);
	
	////- =Tolerance
	newInput( 4, nodeValue_Slider(  "Color Tolerance",  .2   )).setAnimable(false);
	newInput( 5, nodeValue_Slider(  "Pixel Tolerance",  .5   )).setAnimable(false);
	// 6
	
	newOutput( 0, nodeValue_Output( "Position",      VALUE_TYPE.integer, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput( 1, nodeValue_Output( "All Positions", VALUE_TYPE.integer, []    )).setDisplay(VALUE_DISPLAY.vector);
	
	b_manual_track = button(function(fr) /*=>*/ { track_manual = !track_manual; triggerRender(); }).setText(__txt("Manual Tracking"));
	b_manual_clear = button(function(fr) /*=>*/ { 
		for( var i = 0, n = array_length(attributes.trackStat); i < n; i++ )
			if(attributes.trackStat[i] == 2) attributes.trackStat[i] = 0;
		triggerRender(); 
	}).setText(__txt("Clear Manual Track Data")).setBaseColor(COLORS._main_value_negative);
	
	input_display_list = [ 0, 
		[ "Tracking",  false ],  1,  2,  3, 
		[ "Tolerance", false ],  4,  5, 
		
		[ "Manual Tracking", false ], b_manual_track, b_manual_clear, 
	];
	
	////- Node
	
	attribute_oversample(true);
	
	temp_surface = [ noone, noone ];
	
	track_manual = false;
	tracking     = false;
	
	manual_editing = false;
	manual_edit_sx = 0;
	manual_edit_sy = 0;
	manual_edit_mx = 0;
	manual_edit_my = 0;
	
	autoTrack_frame = 0;
	
	attributes.trackData = undefined;
	attributes.trackStat = [];
	
	insp1button = button(function(fr) /*=>*/ { trackInit(); }).setTooltip(__txt("Track All"))
		.setIcon(THEME.pixel_track_action, 0, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	insp2button = button(function(fr) /*=>*/ { track_manual = !track_manual; triggerRender(); }).setTooltip(__txt("Manual Tracking"))
		.setIcon(THEME.pixel_track_action, 1, COLORS._main_icon).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static getDimension     = function() /*=>*/ {return surface_get_dimension(inputs[0].getValue())};
	static getPreviewValues = function() /*=>*/ {return getInputData(0)};
	
	static trackInit        = function() /*=>*/ { tracking = true; project.animator.render(); autoTrack_frame = 0; }
	static onAnimationEnd   = function() /*=>*/ { tracking = false; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		if(attributes.trackData != undefined) {
			var ox = undefined, oy, nx, ny;
			
			draw_set_color_alpha(COLORS._main_accent, .75);
			
			for( var i = 0, n = array_length(attributes.trackData); i < n; i++ ) {
				var _dat = attributes.trackData[i];
				if(!is_array(_dat)) continue;
				
				nx = _x + _dat[0] * _s;
				ny = _y + _dat[1] * _s;
				
				if(ox != undefined) draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
			
			draw_set_alpha(1);
		}
		
		InputDrawOverlay(inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
		
		var _orig = getInputData( 1);
		var _wind = getInputData( 2) * _s;
		var _scan = getInputData( 3) * _s;
		
		var _data = array_safe_get(attributes.trackData, CURRENT_FRAME);
		var _stat = array_safe_get(attributes.trackStat, CURRENT_FRAME, false);
		if(is_array(_data)) _orig = _data;
		
		var ox = _x + _orig[0] * _s;
		var oy = _y + _orig[1] * _s;
		
		draw_set_color_alpha(c_black, .5);
		draw_rectangle_width(ox - _scan, oy - _scan, ox + _scan, oy + _scan, 4);
		draw_rectangle_width(ox - _wind, oy - _wind, ox + _wind, oy + _wind, 4);
		draw_set_alpha(1);
		
		draw_set_color(COLORS._main_icon);
		draw_rectangle_width(ox - _scan, oy - _scan, ox + _scan, oy + _scan, 2);
		
		switch(_stat) {
			case 0 : draw_set_color(COLORS._main_value_negative); break;
			case 1 : draw_set_color(COLORS._main_accent);         break;
			case 2 : draw_set_color(COLORS._main_value_positive); break;
		}
		draw_rectangle_width(ox - _wind, oy - _wind, ox + _wind, oy + _wind, 2);
		
		var l = ui(4);
		draw_set_color_alpha(c_black, .5);   draw_line_width(ox-l, oy, ox+l, oy, 4); draw_line_width(ox, oy-l, ox, oy+l, 4); draw_set_alpha(1);
		draw_set_color(COLORS._main_accent); draw_line_width(ox-l, oy, ox+l, oy, 2); draw_line_width(ox, oy-l, ox, oy+l, 2);
		
		var hov = false;
		if(track_manual && attributes.trackData != undefined) {
			if(manual_editing) {
				hov = true;
				attributes.trackStat[CURRENT_FRAME] = 2;
				draw_set_color_alpha(c_white, .5)
				draw_rectangle_width(ox - _wind, oy - _wind, ox + _wind, oy + _wind, 2);
				draw_set_alpha(1);
				
				var vx = manual_edit_sx + (_mx - manual_edit_mx) / _s;
				var vy = manual_edit_sy + (_my - manual_edit_my) / _s;
				attributes.trackData[CURRENT_FRAME] = [vx, vy];
				autoTrack_frame = CURRENT_FRAME + 1;
				triggerRender();
				
				if(mouse_lrelease())
					manual_editing = false;
				
			} else {
				var _hov = hover && point_in_rectangle(_mx, _my, ox - _wind, oy - _wind, ox + _wind, oy + _wind);
				if(_hov) {
					hov = true;
					draw_set_color_alpha(c_white, .5)
					draw_rectangle_width(ox - _wind, oy - _wind, ox + _wind, oy + _wind, 2);
					draw_set_alpha(1);
					
					if(mouse_lpress(active)) {
						manual_editing = true;
						manual_edit_sx = _orig[0];
						manual_edit_sy = _orig[1];
						manual_edit_mx = _mx;
						manual_edit_my = _my;
					}
				}
			}
				
			switch(_stat) {
				case 0 : draw_set_color(COLORS._main_value_negative); break;
				case 1 : draw_set_color(COLORS._main_accent);         break;
				case 2 : draw_set_color(COLORS._main_value_positive); break;
			}
			
			draw_circle(ox - _wind, oy - _wind, ui(3), false);
			draw_circle(ox + _wind, oy - _wind, ui(3), false);
			draw_circle(ox - _wind, oy + _wind, ui(3), false);
			draw_circle(ox + _wind, oy + _wind, ui(3), false);
		}
		
		return hov;
	}
	
	static update = function() {
		b_manual_track.setBaseColor(track_manual? COLORS._main_accent : c_white);
		insp2button.icon_blend    = track_manual? COLORS._main_accent : COLORS._main_icon;
		
		if(attributes.trackData != undefined)
			outputs[1].setValue(attributes.trackData);
		
		if(!tracking && !track_manual) {
			if(attributes.trackData == undefined) return;
			
			var _data = array_safe_get(attributes.trackData, CURRENT_FRAME);
			if(is_array(_data)) outputs[0].setValue(_data);
			return;
		}
		
		#region data
			var _surf = getInputData( 0);
			
			var _orig = getInputData( 1);
			var _wind = getInputData( 2);
			var _scan = getInputData( 3);
			
			var _ctlr = getInputData( 4);
			var _ptlr = getInputData( 5);
			
			if(!is_just_surface(_surf)) return;
		#endregion
		
		var _winSiz = _wind * 2 + 1;
		var _scaSiz = _scan * 2 + 1;
		
		temp_surface[0] = surface_verify(temp_surface[0], _winSiz, _winSiz, surface_rgba16float);
		temp_surface[1] = surface_verify(temp_surface[1], _scaSiz, _scaSiz, surface_rgba16float);
		
		if(IS_FIRST_FRAME) {
			// print($"Tracking First frame");
			
			attributes.trackStat = array_verify(attributes.trackStat, TOTAL_FRAMES);
			attributes.trackData = array_verify(attributes.trackData, TOTAL_FRAMES);
			
			attributes.trackStat[CURRENT_FRAME] = true;
			attributes.trackData[CURRENT_FRAME] = [_orig[0], _orig[1]];
			outputs[0].setValue(attributes.trackData[CURRENT_FRAME]);
			
			surface_set_shader(temp_surface[0], sh_track_pixel_draw);
				draw_surface(_surf, -(_orig[0] - _wind), -(_orig[1] - _wind));
			surface_reset_shader();
			autoTrack_frame = CURRENT_FRAME + 1;
			return;
		}
		
		// print($"Tracking frame {CURRENT_FRAME} / [{autoTrack_frame}]");
		
		var _prevData = array_safe_get(attributes.trackData, CURRENT_FRAME - 1);
		if(!is_array(_prevData)) return;
		
		if(attributes.trackStat[CURRENT_FRAME] == 2 || autoTrack_frame != CURRENT_FRAME) {
			var _tData = attributes.trackData[CURRENT_FRAME];
			outputs[0].setValue(_tData);
			
			surface_set_shader(temp_surface[0], sh_track_pixel_draw);
				draw_surface(_surf, -(_tData[0] - _wind), -(_tData[1] - _wind));
			surface_reset_shader();
			return;
		}
		
		var px = _prevData[0];
		var py = _prevData[1];
		
		var prevSurf = temp_surface[0];
		var dim = surface_get_dimension(_surf);
		
		surface_set_shader(temp_surface[1], sh_track_pixel_diff);
			shader_set_interpolation(_surf);
			shader_set_2( "dimension",  dim );
			shader_set_2( "offset",     [-(px - _scan), -(py - _scan)] );
			
			shader_set_s( "trackTarget", prevSurf );
			shader_set_f( "windowSize",  _wind    );
			shader_set_f( "scanSize",    _scan    );
			shader_set_f( "colorTolr",   _ctlr    );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		// printSurface("trackTarget", prevSurf);
		// printSurface("scanResult",  temp_surface[1]);
		
		var _bScanRes = buffer_create(_scaSiz * _scaSiz * 2 * 4, buffer_fixed, 2);
		buffer_get_surface(_bScanRes, temp_surface[1], 0);
		
		var _maxXs = [];
		var _maxYs = [];
		var _minD  = infinity; // diff
		
		buffer_to_start(_bScanRes);
		for( var i = 0; i < _scaSiz; i++ ) 
		for( var j = 0; j < _scaSiz; j++ ) {
			var _fr = buffer_read(_bScanRes, buffer_f16);
			var _fg = buffer_read(_bScanRes, buffer_f16);
			var _fb = buffer_read(_bScanRes, buffer_f16);
			var _fa = buffer_read(_bScanRes, buffer_f16);
			
			if(_fr == _minD) {
				array_push(_maxXs, j);
				array_push(_maxYs, i);
				
			} else if(_fr < _minD) {
				_maxXs = [j];
				_maxYs = [i];
				_minD  = _fr;
			}
		}
		
		var _trkX = px;
		var _trkY = py;
		
		if(_minD > _ptlr) {
			logNode($"Lose track at frame {CURRENT_FRAME}: [{_minD}]");
			attributes.trackStat[CURRENT_FRAME] = false;
			
		} else {
			attributes.trackStat[CURRENT_FRAME] = true;
			
			var _maxX = 0;
			var _maxY = 0;
			var _maxA = array_length(_maxXs);
			
			for( var i = 0; i < _maxA; i++ ) {
				_maxX += _maxXs[i];
				_maxY += _maxYs[i];
			}
			
			_maxX = round(_maxX / _maxA);
			_maxY = round(_maxY / _maxA);
			
			_trkX = px + _maxX - _scan;
			_trkY = py + _maxY - _scan;
		}
		
		_trkX = clamp(_trkX, 0, dim[0]);
		_trkY = clamp(_trkY, 0, dim[1]);
		
		// print("    >", px, py, _maxXs, _maxYs, _maxX, _maxY, _trkX, _trkY)
		
		attributes.trackData[CURRENT_FRAME] = [_trkX, _trkY];
		outputs[0].setValue(attributes.trackData[CURRENT_FRAME]);
		
		surface_set_shader(temp_surface[0], sh_track_pixel_draw);
			draw_surface(_surf, -(_trkX - _wind), -(_trkY - _wind));
		surface_reset_shader();
		
		autoTrack_frame = CURRENT_FRAME + 1;
		// printSurface("nextTarget",  temp_surface[0]);
	}
	
	static drawAnimationTimeline = function(_shf, _w, _h, _s) {
		var _stat = attributes.trackStat;
		if(_stat == undefined) return;
		
        for( var i = 0, n = array_length(_stat); i < n; i++ ) {
            var x0 = (i + 0) * _s + _shf;
            var x1 = (i + 1) * _s + _shf;
            
            switch(_stat[i]) {
				case 0 : draw_set_color_alpha(COLORS._main_value_negative, .4); break;
				case 1 : draw_set_color_alpha(COLORS._main_accent,         .1); break;
				case 2 : draw_set_color_alpha(COLORS._main_value_positive, .4); break;
			}
            
            draw_rectangle(x0, 0, x1 - 1, _h, false);
        }
        draw_set_alpha(1);
        
        var ax = autoTrack_frame * _s + _shf;
        draw_set_color(COLORS._main_value_positive);
        draw_line(ax, 0, ax, _h);
	}
	
}