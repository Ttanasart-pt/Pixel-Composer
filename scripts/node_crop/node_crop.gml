function Node_Crop(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Crop";
	preview_alpha = 0.5;
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Padding("Crop", self, [ 0, 0, 0, 0 ])
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue_Bool("Active", self, true);
		active_index = 2;
		
	inputs[| 3] = nodeValue_Enum_Scroll("Aspect Ratio", self,  0, [ "None", "Manual", "1:1", "3:2", "4:3", "16:9" ]);
		
	inputs[| 4] = nodeValue_Vector("Ratio", self, [ 1, 1 ]);
	
	inputs[| 5] = nodeValue_Vector("Center", self, [ .5, .5 ])
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
		
	inputs[| 6] = nodeValue_Float("Width", self, 8 );
		
	inputs[| 7] = nodeValue_Enum_Scroll("Fit Mode", self,  0, [ "Manual", "Width", "Height", "Minimum" ]);
		
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 2,
		["Surface", true], 0, 
		["Crop",   false], 3, 4, 1, 7, 5, 6, 
	]
	
	attribute_surface_depth();
	
	tool_drag = new NodeTool("Draw crop area", THEME.crop_tool, "Node_Crop");
	
	tool_fitw = new NodeTool("Fit Width",      THEME.crop_fit_width)
					.setToolFn(function() {
						var _dim = getDimension(preview_index);
						var _asp = current_data[3];
						var _rat = current_data[4];
						var _cen = current_data[5];
						
						var _ratio  = getRatio(_asp, _rat);
						
						inputs[| 5].setValue([ _dim[0] / 2, _cen[1] ]);
						inputs[| 6].setValue(_dim[0]);
					});
					
	tool_fith = new NodeTool("Fit Height",      THEME.crop_fit_height)
					.setToolFn(function() {
						var _dim = getDimension(preview_index);
						var _asp = current_data[3];
						var _rat = current_data[4];
						var _cen = current_data[5];
						
						var _ratio  = getRatio(_asp, _rat);
						
						inputs[| 5].setValue([ _cen[0], _dim[1] / 2 ]);
						inputs[| 6].setValue(_dim[1] * _ratio);
					});
					
	tools = [ tool_drag ];
	
	drag_side = noone;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	static getPreviewValues = function() { return getInputData(0); }
	
	static getRatio = function(_asp, _rat) {
		switch(_asp) {
			case 1 : return _rat[0] / _rat[1]; 	break;
			case 2 : return  1 / 1;				break;
			case 3 : return  3 / 2;				break;
			case 4 : return  4 / 3;				break;
			case 5 : return 16 / 9;				break;
		}
		return 1;
	}
	
	static step = function() {
		var _asp = getInputData(3);
		var _fit = getInputData(7);
		
		inputs[| 1].setVisible(_asp == 0);
		inputs[| 4].setVisible(_asp == 1);
		inputs[| 5].setVisible(_asp >  0 && _fit == 0);
		inputs[| 6].setVisible(_asp >  0 && _fit == 0);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, params) {
		PROCESSOR_OVERLAY_CHECK
		
		var _inSurf	= current_data[0];
		var _spRaw 	= current_data[1];
		var _asp	= current_data[3];
		var _fit	= current_data[7];
		var _splice;
		
		if(_asp == 0) {
			tools = [ tool_drag ];
			
			for( var i = 0, n = array_length(_spRaw); i < n; i++ )
				_splice[i] = round(_spRaw[i]);
			
			var dim = [ surface_get_width_safe(_inSurf), surface_get_height_safe(_inSurf) ];
			
			var sp_r = _x + (dim[0] - _splice[0]) * _s;
			var sp_l = _x + _splice[2] * _s;
			
			var sp_t = _y + _splice[1] * _s;
			var sp_b = _y + (dim[1] - _splice[3]) * _s;
			
			var _out = getSingleValue(0,, true);
			draw_surface_ext_safe(_out, sp_l, sp_t, _s, _s);
			
			if(isUsingTool(0)) {
				if(drag_side) {
					var _mx0 = min(_mx, drag_mx);
					var _mx1 = max(_mx, drag_mx);
					var _my0 = min(_my, drag_my);
					var _my1 = max(_my, drag_my);
					
					_mx0 = value_snap(round((_mx0 - _x) / _s), _snx);
					_mx1 = value_snap(round((_mx1 - _x) / _s), _snx);
					_my0 = value_snap(round((_my0 - _y) / _s), _sny);
					_my1 = value_snap(round((_my1 - _y) / _s), _sny);
					
					if(inputs[| 1].setValue([dim[0] - _mx1, _my0, _mx0, dim[1] - _my1]))
						UNDO_HOLDING = true;
					
					draw_set_color(COLORS._main_accent);
					draw_set_alpha(0.50);
					draw_line(_x + _mx0 * _s, 0, _x + _mx0 * _s, params.h);
					draw_line(0, _y + _my0 * _s, params.w, _y + _my0 * _s);
					draw_line(_x + _mx1 * _s, 0, _x + _mx1 * _s, params.h);
					draw_line(0, _y + _my1 * _s, params.w, _y + _my1 * _s);
					draw_set_alpha(1);
					
					if(mouse_release(mb_left, active)) {
						drag_side    = noone;
						UNDO_HOLDING = false;
					}
				} else {
					var _mxs = _x + value_snap(round((_mx - _x) / _s), _snx) * _s;
					var _mys = _y + value_snap(round((_my - _y) / _s), _sny) * _s;
					
					draw_set_color(COLORS._main_accent);
					draw_set_alpha(0.50);
					draw_line(_mxs, 0, _mxs, params.h);
					draw_line(0, _mys, params.w, _mys);
					draw_set_alpha(1);
				
					if(mouse_press(mb_left, active)) {
						drag_side = 1;
						drag_mx   = _mx;
						drag_my   = _my;
					}
				}
				
				draw_set_color(COLORS._main_accent);
				draw_line_width(sp_r, sp_t - 1, sp_r, sp_b + 1, 2);
				draw_line_width(sp_l, sp_t - 1, sp_l, sp_b + 1, 2);
				draw_line_width(sp_l - 1, sp_t, sp_r + 1, sp_t, 2);
				draw_line_width(sp_l - 1, sp_b, sp_r + 1, sp_b, 2);
				return;
			}
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.50);
			draw_line(sp_r, 0, sp_r, params.h);
			draw_line(sp_l, 0, sp_l, params.h);
			draw_line(0, sp_t, params.w, sp_t);
			draw_line(0, sp_b, params.w, sp_b);
			draw_set_alpha(1);
			
			draw_line_width(sp_r, sp_t - 1, sp_r, sp_b + 1, 2);
			draw_line_width(sp_l, sp_t - 1, sp_l, sp_b + 1, 2);
			draw_line_width(sp_l - 1, sp_t, sp_r + 1, sp_t, 2);
			draw_line_width(sp_l - 1, sp_b, sp_r + 1, sp_b, 2);
			
			var _hov = noone;
			
			if(drag_side != noone) {
				var vv;
				
				if(drag_side < 4) {
					     if(drag_side == 0)	vv = value_snap(drag_sv - (_mx - drag_mx) / _s, _snx);
					else if(drag_side == 1)	vv = value_snap(drag_sv + (_my - drag_my) / _s, _sny);
					else if(drag_side == 2)	vv = value_snap(drag_sv + (_mx - drag_mx) / _s, _snx);
					else if(drag_side == 3)	vv = value_snap(drag_sv - (_my - drag_my) / _s, _sny);
					
					_splice[drag_side] = vv;
				} else if(drag_side < 8) {
					if(drag_side == 4)	{
						_splice[2] = value_snap(drag_sv[2] + (_mx - drag_mx) / _s, _snx);
						_splice[1] = value_snap(drag_sv[1] + (_my - drag_my) / _s, _sny);
					} else if(drag_side == 5)	{
						_splice[0] = value_snap(drag_sv[0] - (_mx - drag_mx) / _s, _snx);
						_splice[1] = value_snap(drag_sv[1] + (_my - drag_my) / _s, _sny);
					} else if(drag_side == 6)	{
						_splice[2] = value_snap(drag_sv[2] + (_mx - drag_mx) / _s, _snx);
						_splice[3] = value_snap(drag_sv[3] - (_my - drag_my) / _s, _sny);
					} else if(drag_side == 7)	{
						_splice[0] = value_snap(drag_sv[0] - (_mx - drag_mx) / _s, _snx);
						_splice[3] = value_snap(drag_sv[3] - (_my - drag_my) / _s, _sny);
					}
				} else if(drag_side == 8) {
					_splice[0] = value_snap(drag_sv[0] - (_mx - drag_mx) / _s, _snx);
					_splice[1] = value_snap(drag_sv[1] + (_my - drag_my) / _s, _sny);
					_splice[2] = value_snap(drag_sv[2] + (_mx - drag_mx) / _s, _snx);
					_splice[3] = value_snap(drag_sv[3] - (_my - drag_my) / _s, _sny);
				}
				
				if(inputs[| 1].setValue(_splice))
					UNDO_HOLDING = true;
				
				if(mouse_release(mb_left, active)) {
					drag_side    = noone;
					UNDO_HOLDING = false;
				}
			}
			
			draw_set_color(merge_color(c_white, COLORS._main_accent, 0.5));
			
			if(hover) {
				if(drag_side == 4 || point_in_circle(_mx, _my, sp_l, sp_t, 12)) {
					draw_line_width(sp_l, 0, sp_l, params.h, 4);
					draw_line_width(0, sp_t, params.w, sp_t, 4);
					draw_sprite_colored(THEME.anchor_selector, 1, sp_l, sp_t);
					_hov = 4;
				} else if(drag_side == 5 || point_in_circle(_mx, _my, sp_r, sp_t, 12)) {
					draw_line_width(sp_r, 0, sp_r, params.h, 4);
					draw_line_width(0, sp_t, params.w, sp_t, 4);
					draw_sprite_colored(THEME.anchor_selector, 1, sp_r, sp_t);
					_hov = 5;
				} else if(drag_side == 6 || point_in_circle(_mx, _my, sp_l, sp_b, 12)) {
					draw_line_width(sp_l, 0, sp_l, params.h, 4);
					draw_line_width(0, sp_b, params.w, sp_b, 4);
					draw_sprite_colored(THEME.anchor_selector, 1, sp_l, sp_b);
					_hov = 6;
				} else if(drag_side == 7 || point_in_circle(_mx, _my, sp_r, sp_b, 12)) {
					draw_line_width(sp_r, 0, sp_r, params.h, 4);
					draw_line_width(0, sp_b, params.w, sp_b, 4);
					draw_sprite_colored(THEME.anchor_selector, 1, sp_r, sp_b);
					_hov = 7;
				} else if(drag_side == 0 || distance_to_line(_mx, _my, sp_r, 0, sp_r, params.h) < 12) {
					draw_line_width(sp_r, 0, sp_r, params.h, 4);
					_hov = 0;
				} else if(drag_side == 1 || distance_to_line(_mx, _my, 0, sp_t, params.w, sp_t) < 12) {
					draw_line_width(0, sp_t, params.w, sp_t, 4);
					_hov = 1;
				} else if(drag_side == 2 || distance_to_line(_mx, _my, sp_l, 0, sp_l, params.h) < 12) {
					draw_line_width(sp_l, 0, sp_l, params.h, 4);
					_hov = 2;
				} else if(drag_side == 3 || distance_to_line(_mx, _my, 0, sp_b, params.w, sp_b) < 12) {
					draw_line_width(0, sp_b, params.w, sp_b, 4);
					_hov = 3;
				} else if(drag_side == 8 || point_in_rectangle(_mx, _my, sp_l, sp_t, sp_r, sp_b)) {
					draw_line_width(sp_r, sp_t - 1, sp_r, sp_b + 1, 4);
					draw_line_width(sp_l, sp_t - 1, sp_l, sp_b + 1, 4);
					draw_line_width(sp_l - 1, sp_t, sp_r + 1, sp_t, 4);
					draw_line_width(sp_l - 1, sp_b, sp_r + 1, sp_b, 4);
					_hov = 8;
				}
			}
			
			if(_hov != 4) draw_sprite_colored(THEME.anchor_selector, 0, sp_l, sp_t);
			if(_hov != 5) draw_sprite_colored(THEME.anchor_selector, 0, sp_r, sp_t);
			if(_hov != 6) draw_sprite_colored(THEME.anchor_selector, 0, sp_l, sp_b);
			if(_hov != 7) draw_sprite_colored(THEME.anchor_selector, 0, sp_r, sp_b);
			
			if(drag_side == noone && _hov != noone) {
				if(mouse_press(mb_left, active)) {
					drag_side = _hov;
					drag_mx   = _mx;
					drag_my   = _my;
					drag_sv   = _hov < 4? _splice[_hov] : _splice;
				}
			}
		} else if(_fit == 0) {
			tools = [ tool_fitw, tool_fith ];
			
			var _rat   = current_data[4];
			var _cent  = current_data[5];
			var _width = abs(current_data[6]);
			
			var _ratio  = getRatio(_asp, _rat);
			var _height = ceil(_width / _ratio);
			
			var _x0 = round(_cent[0] - _width  / 2);
			var _y0 = round(_cent[1] - _height / 2);
			
			var _px0 = _x + _x0 * _s;
			var _py0 = _y + _y0 * _s;
			var _px1 = _px0 + _width  * _s;
			var _py1 = _py0 + _height * _s;
			
			var _out = getSingleValue(0,, true);
			draw_surface_ext_safe(_out, _px0, _py0, _s, _s);
			
			draw_set_color(COLORS._main_accent);
			draw_rectangle(_px0, _py0, _px1, _py1, true);
			
			var _px = _x + _cent[0] * _s;
			var _py = _y + _cent[1] * _s;
			
			var a = inputs[| 5].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny); 	active &= !a;
			var a = inputs[| 6].drawOverlay(hover, active, _px, _py, _s / 2, _mx, _my, _snx, _sny); active &= !a;
			
		} else {
			var _idim = surface_get_dimension(_inSurf);
			var _out  = getSingleValue(0,, true);
			var _odim = surface_get_dimension(_out);
			
			var _x0 = _idim[0] / 2 - _odim[0] / 2;
			var _y0 = _idim[1] / 2 - _odim[1] / 2;
			
			var _px0 = _x + _x0 * _s;
			var _py0 = _y + _y0 * _s;
			var _px1 = _px0 + _odim[0] * _s;
			var _py1 = _py0 + _odim[1] * _s;
			
			draw_surface_ext_safe(_out, _px0, _py0, _s, _s);
			
			draw_set_color(COLORS._main_accent);
			draw_rectangle(_px0, _py0, _px1, _py1, true);
		}
		
	}
	
	static onValueUpdate = function(index) {
		if(index != 3) return;
			
		var _dim = getDimension(0);
		var _asp = inputs[| 3].getValue();
		var _rat = inputs[| 4].getValue();
		
		var _ratio  = getRatio(_asp, _rat);
		
		inputs[| 5].setValue([ _dim[0] / 2, _dim[1] / 2 ]);
		inputs[| 6].setValue(min(_dim[0], _dim[1] * _ratio));
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _inSurf	= _data[0];
		var _crop	= _data[1];
		var _asp	= _data[3];
		var _rat 	= _data[4];
		var _cent 	= _data[5];
		var _width 	= abs(_data[6]);
		var _fit  	= _data[7];
		
		var _sdim = surface_get_dimension(_inSurf);
		
		if(_asp == 0) {
			var _dim  = [ _sdim[0] - _crop[0] - _crop[2], 
			              _sdim[1] - _crop[1] - _crop[3] ];
			
			_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
			
			surface_set_shader(_outSurf, noone);
				draw_surface_safe(_inSurf, -_crop[2], -_crop[1]);
			surface_reset_shader();
			
		} else if(_fit == 0) {
			var _ratio  = getRatio(_asp, _rat);
			var _height = ceil(_width / _ratio);
			
			var _x0 = round(_cent[0] - _width  / 2);
			var _y0 = round(_cent[1] - _height / 2);
			
			_outSurf = surface_verify(_outSurf, _width, _height);
			
			surface_set_shader(_outSurf, noone);
				draw_surface_safe(_inSurf, -_x0, -_y0);
			surface_reset_shader();
			
		} else {
			var _ratio  = getRatio(_asp, _rat);
			var _w = 1, _h = 1, _x0, _y0;
			
			if(_fit == 1) {
				_w = _sdim[0];
				_h = _w * _ratio;
				
			} else if(_fit == 2) {
				_h = _sdim[1];
				_w = _h / _ratio;
				
			} else if(_fit == 3) {
				_w = min(_sdim[0], _sdim[1] * _ratio);
				_h = _w * _ratio;
			}
			
			var _x0 = round(_sdim[0] / 2 - _w / 2);
			var _y0 = round(_sdim[1] / 2 - _h / 2);
			
			_outSurf = surface_verify(_outSurf, _w, _h);
			
			surface_set_shader(_outSurf, noone);
				draw_surface_safe(_inSurf, -_x0, -_y0);
			surface_reset_shader();
			
		}
		
		return _outSurf;
	}
}