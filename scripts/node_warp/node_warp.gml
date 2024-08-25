function Node_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Warp";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Vec2("Top left", self, [ 0, 0 ] ))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(2, nodeValue_Vec2("Top right", self, [ DEF_SURF_W, 0 ] ))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(3, nodeValue_Vec2("Bottom left", self, [ 0, DEF_SURF_H ] ))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(4, nodeValue_Vec2("Bottom right", self, DEF_SURF ))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Bool("Use custom dimension", self, false));
	
	newInput(7, nodeValue_Dimension(self));
	
	newInput(8, nodeValue_Bool("Tile", self, false));
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 5,
		["Surfaces", false], 0, 6, 7, 8, 
		["Wrap",	 false], 1, 2, 3, 4
	]
	
	attribute_surface_depth();
	attribute_interpolation();

	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_s    = [[0, 0], [0, 0]];
	
	attributes.initalset = LOADING || APPENDING;
	
	warp_surface = array_create(2);
	
	static onValueFromUpdate = function(index) { 
		if(index == 0 && attributes.initalset == false) {
			var _surf = getInputData(0);
			if(!is_surface(_surf)) return;
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			
			inputs[1].setValue([   0,   0 ]);
			inputs[2].setValue([ _sw,   0 ]);
			inputs[3].setValue([   0, _sh ]);
			inputs[4].setValue([ _sw, _sh ]);
			
			attributes.initalset = true;
		}
	} if(!LOADING && !APPENDING) run_in(1, function() { onValueFromUpdate(0); }) 
	
	static step = function() { 
		var _useDim = getInputData(6);
		
		inputs[7].setVisible(_useDim);
		dimension_index = _useDim? 7 : 0;
	} 
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, params) {
		PROCESSOR_OVERLAY_CHECK
		
		var _surf = outputs[0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var _ss = current_data[0];
		if(!is_surface(_ss)) return;
		
		var tl = array_clone(current_data[1]);
		var tr = array_clone(current_data[2]);
		var bl = array_clone(current_data[3]);
		var br = array_clone(current_data[4]);
		
		tl[0] = _x + tl[0] * _s;
		tr[0] = _x + tr[0] * _s;
		bl[0] = _x + bl[0] * _s;
		br[0] = _x + br[0] * _s;
		
		tl[1] = _y + tl[1] * _s;
		tr[1] = _y + tr[1] * _s;
		bl[1] = _y + bl[1] * _s;
		br[1] = _y + br[1] * _s;
		
		#region preview
			var sw = surface_get_width(_surf)  * _s;
			var sh = surface_get_height(_surf) * _s;
			
			warp_surface[0] = surface_verify(warp_surface[0], params.w, params.h);
			warp_surface[1] = surface_verify(warp_surface[1], sw, sh);
			
			surface_set_target(warp_surface[1]);
				draw_clear(c_black);
				draw_set_color(c_dkgrey);
				
				for(var i = 0; i <= 1; i += 0.125) {
					draw_line_width(0, i * sh, sw, i * sh, 2);
					draw_line_width(i * sw, 0, i * sw, sh, 2);
				}
			surface_reset_target();
			
			warpSurface( warp_surface[0], warp_surface[1], params.w, params.h, tl, tr, bl, br, true );
			
			// BLEND_ADD
			// 	draw_surface_safe(warp_surface[0]);
			// BLEND_NORMAL
		#endregion
		
		draw_set_color(COLORS._main_accent);
		draw_line(tl[0], tl[1], tr[0], tr[1]);
		draw_line(tl[0], tl[1], bl[0], bl[1]);
		draw_line(br[0], br[1], tr[0], tr[1]);
		draw_line(br[0], br[1], bl[0], bl[1]);
		
		var _hactive = active;
		if(point_in_circle(_mx, _my, tl[0], tl[1], 12)) _hactive = false;
		if(point_in_circle(_mx, _my, tr[0], tr[1], 12)) _hactive = false;
		if(point_in_circle(_mx, _my, bl[0], bl[1], 12)) _hactive = false;
		if(point_in_circle(_mx, _my, br[0], br[1], 12)) _hactive = false;
		
		var dx = 0;
		var dy = 0;
		
		if(drag_side > -1) {
			dx = (_mx - drag_mx) / _s;
			dy = (_my - drag_my) / _s;
			
			if(mouse_release(mb_left)) {
				drag_side = -1;	
				UNDO_HOLDING = false;
			}
		}
		
		#region edit
			draw_set_color(COLORS.node_overlay_gizmo_inactive);
			if(drag_side == 0) {
				draw_line_width(tl[0], tl[1], tr[0], tr[1], 3);
			
				var _tlx = value_snap(drag_s[0][0] + dx, _snx);
				var _tly = value_snap(drag_s[0][1] + dy, _sny);
			
				var _trx = value_snap(drag_s[1][0] + dx, _snx);
				var _try = value_snap(drag_s[1][1] + dy, _sny);
			
				var _up1 = inputs[1].setValue([ _tlx, _tly ]);
				var _up2 = inputs[2].setValue([ _trx, _try ]);
			
				if(_up1 || _up2) UNDO_HOLDING = true;
			} else if(drag_side == 1) {
				draw_line_width(tl[0], tl[1], bl[0], bl[1], 3);
			
				var _tlx = value_snap(drag_s[0][0] + dx, _snx);
				var _tly = value_snap(drag_s[0][1] + dy, _sny);
								  
				var _blx = value_snap(drag_s[1][0] + dx, _snx);
				var _bly = value_snap(drag_s[1][1] + dy, _sny);
			
				var _up1 = inputs[1].setValue([ _tlx, _tly ]);
				var _up3 = inputs[3].setValue([ _blx, _bly ]);
			
				if(_up1 || _up3) UNDO_HOLDING = true;
			} else if(drag_side == 2) {
				draw_line_width(br[0], br[1], tr[0], tr[1], 3);
			
				var _brx = value_snap(drag_s[0][0] + dx, _snx);
				var _bry = value_snap(drag_s[0][1] + dy, _sny);
								  
				var _trx = value_snap(drag_s[1][0] + dx, _snx);
				var _try = value_snap(drag_s[1][1] + dy, _sny);
			
				var _up4 = inputs[4].setValue([ _brx, _bry ]);
				var _up2 = inputs[2].setValue([ _trx, _try ]);
			
				if(_up4 || _up2) UNDO_HOLDING = true;
			} else if(drag_side == 3) {
				draw_line_width(br[0], br[1], bl[0], bl[1], 3);
			
				var _brx = value_snap(drag_s[0][0] + dx, _snx);
				var _bry = value_snap(drag_s[0][1] + dy, _sny);
								  
				var _blx = value_snap(drag_s[1][0] + dx, _snx);
				var _bly = value_snap(drag_s[1][1] + dy, _sny);
			
				var _up4 = inputs[4].setValue([ _brx, _bry ]);
				var _up3 = inputs[3].setValue([ _blx, _bly ]);
			
				if(_up4 || _up3) UNDO_HOLDING = true;
			} else if(_hactive) {
				draw_set_color(COLORS._main_accent);
				if(distance_to_line_infinite(_mx, _my, tl[0], tl[1], tr[0], tr[1]) < 12) {
					draw_line_width(tl[0], tl[1], tr[0], tr[1], 3);
					if(mouse_press(mb_left)) {
						drag_side = 0;
						drag_mx = _mx;
						drag_my = _my;
						drag_s = [ current_data[1], current_data[2] ];
					}
				} else if(distance_to_line_infinite(_mx, _my, tl[0], tl[1], bl[0], bl[1]) < 12) {
					draw_line_width(tl[0], tl[1], bl[0], bl[1], 3);
					if(mouse_press(mb_left)) {
						drag_side = 1;
						drag_mx = _mx;
						drag_my = _my;
						drag_s = [ current_data[1], current_data[3] ];
					}
				} else if(distance_to_line_infinite(_mx, _my, br[0], br[1], tr[0], tr[1]) < 12) {
					draw_line_width(br[0], br[1], tr[0], tr[1], 3);
					if(mouse_press(mb_left)) {
						drag_side = 2;
						drag_mx = _mx;
						drag_my = _my;
						drag_s = [ current_data[4], current_data[2] ];
					}
				} else if(distance_to_line_infinite(_mx, _my, br[0], br[1], bl[0], bl[1]) < 12) {
					draw_line_width(br[0], br[1], bl[0], bl[1], 3);
					if(mouse_press(mb_left)) {
						drag_side = 3;
						drag_mx = _mx;
						drag_my = _my;
						drag_s = [ current_data[4], current_data[3] ];
					}
				}
			}
		
			var _hov = false;
			var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active = !hv; _hov |= hv;
			var  hv  = inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active = !hv; _hov |= hv;
			var  hv  = inputs[3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active = !hv; _hov |= hv;
			var  hv  = inputs[4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active = !hv; _hov |= hv;
			
			return _hov;
		#endregion
	}
	
	static warpSurface = function(surf, warp, sw, sh, tl, tr, bl, br, tile = false) {
		var teq = round(tl[1]) == round(tr[1]);
		var beq = round(bl[1]) == round(br[1]);
		var leq = round(tl[0]) == round(bl[0]);
		var req = round(tr[0]) == round(br[0]);
		
		var _wdim = surface_get_dimension(warp);
		
		if(teq && beq && leq && req) { // rectangle
			surface_set_shader(surf)
				shader_set_interpolation(warp);
				
				// if(filt) gpu_set_tex_filter(true);
				if(tile) draw_surface_tiled_ext(warp, tl[0], tl[1], (tr[0] - tl[0]) / _wdim[0], (bl[1] - tl[1]) / _wdim[1], c_white, 1);
				else     draw_surface_stretched_safe(warp, tl[0], tl[1], tr[0] - tl[0], bl[1] - tl[1]);
				// if(filt) gpu_set_tex_filter(false);
			surface_reset_shader();
			
		} else {
			surface_set_shader(surf, sh_warp_4points);
			shader_set_interpolation(warp);
			
				shader_set_f("dimension", surface_get_dimension(warp));
				shader_set_f("p0", br[0] / sw, br[1] / sh);
				shader_set_f("p1", tr[0] / sw, tr[1] / sh);
				shader_set_f("p2", tl[0] / sw, tl[1] / sh);
				shader_set_f("p3", bl[0] / sw, bl[1] / sh);
				shader_set_i("tile", tile);
			
				// if(filt) gpu_set_tex_filter(true);
				draw_surface_stretched(warp, 0, 0, sw, sh);
				// if(filt) gpu_set_tex_filter(false);
			surface_reset_shader();
		}
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var tl   = _data[1];
		var tr   = _data[2];
		var bl   = _data[3];
		var br   = _data[4];
		var tile = _data[8];
		
		var _useDim = _data[6];
		var _dim    = _data[7];
		
		if(!is_surface(_data[0])) return _outSurf;
		
		var sw = _useDim? _dim[0] : surface_get_width_safe(_data[0]);
		var sh = _useDim? _dim[1] : surface_get_height_safe(_data[0]);
		
		warpSurface(_outSurf, _data[0], sw, sh, tl, tr, bl, br, tile);
		
		return _outSurf;
	}
}