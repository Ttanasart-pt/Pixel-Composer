#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_9Slice", "Preview Original", "P");
	});
#endregion

function Node_9Slice(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Nine Slice";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Slices
	newInput(1, nodeValue_Dimension());
	newInput(2, nodeValue_Padding(     "Splice",       [0,0,0,0] )).setUnitSimple();
	newInput(3, nodeValue_Enum_Scroll( "Filling modes", 0, [ "Scale", "Repeat" ] ));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface,     noone ));
	newOutput(1, nodeValue_Output("DynaSurf",    VALUE_TYPE.dynaSurface, noone ));
	
	attribute_surface_depth();
	attribute_interpolation();
	
	input_display_list = [
		["Surface", false], 0, 
		["Slices",  false], 1, 2, 3, 
	]
	
	////- Node
	
	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	tools = [ new NodeTool( "Preview Original", THEME.bone_tool_scale ) ];
	
	static onValueFromUpdate = function(index = 0) {
		if(index != 0) return;
		
		var s = getInputData(0);
		if(is_array(s)) s = s[0];
			
		if(!is_surface(s)) return;
		inputs[1].setValue( [ surface_get_width_safe(s), surface_get_height_safe(s) ] );
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim    = isUsingTool("Preview Original")? surface_get_dimension(getInputSingle(0)) : current_data[1];
		var _splice	= array_create(array_length(current_data[2]));
		
		for( var i = 0, n = array_length(current_data[2]); i < n; i++ )
			_splice[i] = round(current_data[2][i]);
			
		var sp_r = _x + (_dim[0] - _splice[0]) * _s;
		var sp_l = _x + _splice[2] * _s;
		
		var sp_t = _y + _splice[1] * _s;
		var sp_b = _y + (_dim[1] - _splice[3]) * _s;
		
		var ww = WIN_W;
		var hh = WIN_H;
		var hovering = false;
		
		draw_set_color(COLORS._main_accent);
		draw_line(sp_r, -hh, sp_r, hh);
		draw_line(sp_l, -hh, sp_l, hh);
		draw_line(-ww, sp_t, ww, sp_t);
		draw_line(-ww, sp_b, ww, sp_b);
		
		if(drag_side > -1) {
			draw_set_color(c_white);
			switch(drag_side) {
				case 0 : draw_line_width(sp_r, -hh, sp_r, hh, 3); break;
				case 1 : draw_line_width(-ww, sp_t, ww, sp_t, 3); break;
				case 2 : draw_line_width(sp_l, -hh, sp_l, hh, 3); break;
				case 3 : draw_line_width(-ww, sp_b, ww, sp_b, 3); break;
			}
			
			var vv;
			
			if(drag_side == 0)		vv = drag_sv - (_mx - drag_mx) / _s;
			else if(drag_side == 2)	vv = drag_sv + (_mx - drag_mx) / _s;
			else if(drag_side == 1)	vv = drag_sv + (_my - drag_my) / _s;
			else					vv = drag_sv - (_my - drag_my) / _s;
				
			_splice[drag_side] = vv;
			if(inputs[2].setValue(_splice))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_side = -1;
				UNDO_HOLDING = false;
			}
		}
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		if(drag_side > -1) return w_hovering;
		
		draw_set_color(COLORS._main_accent);
		
		if(distance_to_line_infinite(_mx, _my, sp_r, -hh, sp_r, hh) < 12) {
			hovering = true;
			draw_line_width(sp_r, -hh, sp_r, hh, 3);
			if(mouse_press(mb_left, active)) {
				drag_side = 0;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sv   = _splice[0];
			}
			
		} else if(distance_to_line_infinite(_mx, _my, -ww, sp_t, ww, sp_t) < 12) {
			hovering = true;
			draw_line_width(-ww, sp_t, ww, sp_t, 3);
			if(mouse_press(mb_left, active)) {
				drag_side = 1;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sv   = _splice[1];
			}
			
		} else if(distance_to_line_infinite(_mx, _my, sp_l, -hh, sp_l, hh) < 12) {
			hovering = true;
			draw_line_width(sp_l, -hh, sp_l, hh, 3);
			if(mouse_press(mb_left, active)) {
				drag_side = 2;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sv   = _splice[2];
			}
			
		} else if(distance_to_line_infinite(_mx, _my, -ww, sp_b, ww, sp_b) < 12) {
			hovering = true;
			draw_line_width(-ww, sp_b, ww, sp_b, 3);
			if(mouse_press(mb_left, active)) {
				drag_side = 3;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sv   = _splice[3];
			}
			
		}
		
		return hovering;
		
	}
	
	static processData = function(_outData, _data, _array_index) {
		var _inSurf	= _data[0];
		var _dim	= _data[1];
		var _splice	= _data[2];
		var _fill	= _data[3];
		
		if(!surface_exists(_inSurf)) return _outData;
		var _outSurf = surface_verify(_outData[0], _dim[0], _dim[1], attrDepth());
		_outData[0]  = _outSurf;
		_outData[1]  = new nineSliceSurf(_inSurf, _splice, _fill);
		
		var ww   = _dim[0];
		var hh   = _dim[1];
		var in_w = surface_get_width_safe(_inSurf);
		var in_h = surface_get_height_safe(_inSurf);
		
		surface_set_shader(_outSurf);
		shader_set_interpolation(_inSurf);
		_outData[1].draw(0, 0, ww / in_w, hh / in_h);
		surface_reset_shader();
		
		return _outData;
	}

	static getPreviewValues = function() { 
		if(isUsingTool("Preview Original")) return inputs[0].getValue();
		return outputs[0].getValue(); 
	}
}

function nineSliceSurf(_surf, _splice, _fill) : dynaSurf() constructor {
	surfaces = [ _surf, noone ];
	splice   = _splice;
	fill     = _fill;
	surfw    = surface_get_width_safe(_surf);
	surfh    = surface_get_height_safe(_surf);
	
	static getWidth     = function() /*=>*/ {return surfw};
	static getHeight    = function() /*=>*/ {return surfh};
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		var ww = surfw * _sx;
		var hh = surfh * _sy;
		
		var sp_r = splice[0];
		var sp_t = splice[1];
		var sp_l = splice[2];
		var sp_b = splice[3];
		
		var _surf   = surfaces[0];
		surfaces[1] = surface_verify(surfaces[1], ww, hh);
		
		surface_set_target(surfaces[1]);
			DRAW_CLEAR
			BLEND_OVERRIDE
			
			var cw = max(surfw - sp_l - sp_r, 1);
			var ch = max(surfh - sp_t - sp_b, 1);
			
			var sw = (ww - sp_l - sp_r) / cw;
			var sh = (hh - sp_t - sp_b) / ch;
	
			draw_surface_part_ext_safe(_surf,            0,            0, sp_l, sp_t,         0,         0, 1, 1, _ang, _col, _alp);
			draw_surface_part_ext_safe(_surf, surfw - sp_r,            0, sp_r, sp_t, ww - sp_r,         0, 1, 1, _ang, _col, _alp);
			draw_surface_part_ext_safe(_surf,            0, surfh - sp_b, sp_l, sp_b,         0, hh - sp_b, 1, 1, _ang, _col, _alp);
			draw_surface_part_ext_safe(_surf, surfw - sp_r, surfh - sp_b, sp_r, sp_b, ww - sp_r, hh - sp_b, 1, 1, _ang, _col, _alp);
			
			if(fill == 0) {
				draw_surface_part_ext_safe(_surf, sp_l,            0, cw, sp_t, sp_l,         0, sw, 1, _ang, _col, _alp);
				draw_surface_part_ext_safe(_surf, sp_l, surfh - sp_b, cw, sp_b, sp_l, hh - sp_b, sw, 1, _ang, _col, _alp);
	
				draw_surface_part_ext_safe(_surf,            0, sp_t, sp_l, ch,         0, sp_t, 1, sh, _ang, _col, _alp);
				draw_surface_part_ext_safe(_surf, surfw - sp_r, sp_t, sp_r, ch, ww - sp_r, sp_t, 1, sh, _ang, _col, _alp);
	
				draw_surface_part_ext_safe(_surf, sp_l, sp_t, cw, ch, sp_l, sp_t, sw, sh, _ang, _col, _alp);
				
			} else if(fill == 1) {
				var _cw_max = ww - sp_r;
				var _ch_max = hh - sp_b;
				
				var _xx = sp_l;
				var _c = ceil((ww - sp_r - sp_l) / cw);
				repeat(_c) {
					var _dx = min(cw, _cw_max - _xx);
					
					draw_surface_part_ext_safe(_surf, sp_l,            0, _dx, sp_t, _xx,         0, 1, 1, _ang, _col, _alp);
					draw_surface_part_ext_safe(_surf, sp_l, surfh - sp_b, _dx, sp_b, _xx, hh - sp_b, 1, 1, _ang, _col, _alp);
					_xx += cw;
				}
				
				var _yy = sp_t;
				var _r = ceil((hh - sp_b - sp_t) / ch);
				repeat(_r) {
					var _dy = min(ch, _ch_max - _yy);
					
					draw_surface_part_ext_safe(_surf,            0, sp_t, sp_l, _dy,         0, _yy, 1, 1, _ang, _col, _alp);
					draw_surface_part_ext_safe(_surf, surfw - sp_r, sp_t, sp_r, _dy, ww - sp_r, _yy, 1, 1, _ang, _col, _alp);
					_yy += ch;
				}
				
				_xx = sp_l;
				_yy = sp_t;
				
				repeat(_c) {
					_yy = sp_t;
					repeat(_r) {
						var _dx = min(cw, _cw_max - _xx);
						var _dy = min(ch, _ch_max - _yy);
						
						draw_surface_part_ext_safe(_surf, sp_l, sp_t, _dx, _dy, _xx, _yy, 1, 1, _ang, _col, _alp);
						_yy += ch;
					}
					_xx += cw;
				}
			}
			BLEND_NORMAL
		surface_reset_target();
		
		draw_surface_ext(surfaces[1], _x, _y, 1, 1, _ang, c_white, 1)
	}
	
	static drawTile = function(_x = 0, _y = 0, _xs = 1, _ys = 1, _col = c_white, _alp = 1) {
		
	}
	
	static drawPart = function(_l, _t, _w, _h, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alp = 1) {
		
	}
	
}