function Node_create_Composite(_x, _y) {
	var node = new Node_Composite(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

enum COMPOSE_OUTPUT_SCALING {
	first,
	largest,
	constant
}

function Node_Composite(_x, _y) : Node_Processor(_x, _y) constructor {
	name		= "Composite";
	
	uniform_dim = shader_get_uniform(sh_blend_normal_dim, "dimension");
	uniform_pos = shader_get_uniform(sh_blend_normal_dim, "position");
	uniform_sca = shader_get_uniform(sh_blend_normal_dim, "scale");
	uniform_rot = shader_get_uniform(sh_blend_normal_dim, "rotation");
	uniform_for = shader_get_sampler_index(sh_blend_normal_dim, "fore");
	
	inputs[| 0] = nodeValue(0, "Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.padding);
	
	inputs[| 1] = nodeValue(1, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, COMPOSE_OUTPUT_SCALING.first)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "First surface", "Largest surface", "Constant" ]);
	
	inputs[| 2] = nodeValue(2, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d)
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	input_fix_len	= ds_list_size(inputs);
	data_length		= 4;
	
	attributes[? "layer_visible"] = ds_list_create();
	
	hold_visibility = true;
	layer_dragging = noone;
	layer_remove = -1;
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var amo = (ds_list_size(inputs) - input_fix_len) / data_length - 1;
		
		var lh = 32;
		var _h = 8 + max(1, amo) * (lh + 4) + 8;
		layer_renderer.h = _h;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		var _vis = attributes[? "layer_visible"];
		var ly   = _y + 8;
		var ssh  = lh - 6;
		var hoverIndex = noone;
		draw_set_color(COLORS.node_composite_separator);
		draw_line(_x + 16, ly, _x + _w - 16, ly);
		
		layer_remove = -1;
		for(var i = 0; i < amo; i++) {
			var ind = amo - i - 1;
			var index = input_fix_len + ind * data_length;
			var _surf = current_data[index + 0];
			var _pos  = current_data[index + 1];
			
			var _bx = _x + _w - 24;
			var _cy = ly + i * (lh + 4);
			
			if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 16)) {
				draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_value_negative);
				
				if(_focus && mouse_check_button_pressed(mb_left))
					layer_remove = ind;
			} else 
				draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_icon);
			
			if(!is_surface(_surf)) continue;
			
			var aa = (ind != layer_dragging || layer_dragging == noone)? 1 : 0.5;
			var vis = _vis[| ind];
			var hover = point_in_rectangle(_m[0], _m[1], _x, _cy, _x + _w, _cy + lh);
			
			draw_set_color(COLORS.node_composite_separator);
			draw_line(_x + 16, _cy + lh + 2, _x + _w - 16, _cy + lh + 2);
			
			var _bx = _x + 24 * 2 + 8;
			if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 12)) {
				draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _cy + lh / 2, 1, c_white);
				
				if(_focus) {
					if(mouse_check_button_pressed(mb_left))
						hold_visibility = !_vis[| ind];
					
					if(mouse_check_button(mb_left) && _vis[| ind] != hold_visibility) {
						_vis[| ind] = hold_visibility;
						update();
					}
				}
			} else 
				draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _cy + lh / 2, 1, COLORS._main_icon);
			
			draw_set_color(COLORS.node_composite_bg);
			var _sx0 = _x + 24 * 3 + 8;
			var _sx1 = _sx0 + ssh;
			var _sy0 = _cy + 3;
			var _sy1 = _sy0 + ssh;
			draw_rectangle(_sx0, _sy0, _sx1, _sy1, true);
			
			var _ssw = surface_get_width(_surf);
			var _ssh = surface_get_height(_surf);
			var _sss = min(ssh / _ssw, ssh / _ssh);
			draw_surface_ext(_surf, _sx0, _sy0, _sss, _sss, 0, c_white, 1);
			
			draw_set_text(f_p1, fa_left, fa_center, hover? COLORS._main_text : COLORS._main_text);
			draw_set_alpha(aa);
			draw_text(_sx1 + 12, _cy + lh / 2, inputs[| index].name);
			draw_set_alpha(1);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _cy, _x + _w, _cy + lh)) {
				hoverIndex = ind;
				if(layer_dragging != noone) {
					draw_set_color(COLORS._main_accent);
					if(layer_dragging > ind)
						draw_line_width(_x + 16, _cy + lh + 2, _x + _w - 16, _cy + lh + 2, 2);
					else if(layer_dragging < ind)
						draw_line_width(_x + 16, _cy - 2, _x + _w - 16, _cy - 2, 2);
				}
			}
			
			if(layer_dragging == noone || layer_dragging == ind) {
				var _bx = _x + 24;
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 16)) {
					draw_sprite_ui_uniform(THEME.hamburger, 3, _bx, _cy + lh / 2, .75, c_white);
				
					if(_focus && mouse_check_button_pressed(mb_left))
						layer_dragging = ind;
				} else 
					draw_sprite_ui_uniform(THEME.hamburger, 3, _bx, _cy + lh / 2, .75, COLORS._main_icon);
			}
		}
		
		if(layer_dragging != noone && mouse_check_button_released(mb_left)) {
			if(layer_dragging != hoverIndex && hoverIndex != noone) {
				var index = input_fix_len + layer_dragging * data_length;
				var targt = input_fix_len + hoverIndex * data_length;
				var _vis = attributes[? "layer_visible"];
				
				var ext = [];
				var vis = _vis[| layer_dragging];
				ds_list_delete(_vis, layer_dragging);
				ds_list_insert(_vis, hoverIndex, vis);
				
				for( var i = 0; i < data_length; i++ ) {
					ext[i] = inputs[| index];
					ds_list_delete(inputs, index);
					//show_debug_message("remove: " + ext[i].name);
				}
				for( var i = 0; i < data_length; i++ ) {
					ds_list_insert(inputs, targt + i, ext[i]);
					//show_debug_message("place: " + ext[i].name + " at " + string(targt + i));
				}
				
				update();
			}
			layer_dragging = noone;
		}
	});
	
	input_display_list = [
		["Output",	true],	0, 1, 2,
		["Layers",	false],	layer_renderer,
		["Surface",	true],	
	];
	input_display_list_len = array_length(input_display_list);
	
	function deleteLayer(index) {
		var idx = input_fix_len + index * data_length;
		for( var i = 0; i < data_length; i++ ) {
			ds_list_delete(inputs, idx);
			array_remove(input_display_list, idx + i);
		}
		for( var i = input_display_list_len; i < array_length(input_display_list); i++ ) {
			if(input_display_list[i] > idx)
				input_display_list[i] = input_display_list[i] - data_length;
		}
		update();
	}
	
	function createNewSurface() {
		var index = ds_list_size(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		
		inputs[| index + 0] = nodeValue( index + 0, _s? ("Surface " + string(_s)) : "Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
		
		inputs[| index + 1] = nodeValue( index + 1, "Position " + string(_s), self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
			.setDisplay(VALUE_DISPLAY.vector);
		
		inputs[| index + 2] = nodeValue( index + 2, "Rotation " + string(_s), self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
			.setDisplay(VALUE_DISPLAY.rotation);
		
		inputs[| index + 3] = nodeValue( index + 3, "Scale " + string(_s), self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
			.setDisplay(VALUE_DISPLAY.vector);
		
		array_push(input_display_list, index + 0);
		array_push(input_display_list, index + 1);
		array_push(input_display_list, index + 2);
		array_push(input_display_list, index + 3);
		
		while(_s >= ds_list_size(attributes[? "layer_visible"])) {
			ds_list_add(attributes[? "layer_visible"], true);
		}
	}
	createNewSurface();
	
	function addFrom(_nodeFrom) {
		inputs[| ds_list_size(inputs) - data_length].setFrom(_nodeFrom);
	}
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	temp_surf = [ PIXEL_SURFACE, PIXEL_SURFACE ];
	
	surf_dragging = -1;
	input_dragging = -1;
	drag_type = 0;
	dragging_sx = 0;
	dragging_sy = 0;
	dragging_mx = 0;
	dragging_my = 0;
	
	rot_anc_x = 0;
	rot_anc_y = 0;
	
	overlay_w = 0;
	overlay_h = 0;
	
	static updateValueFrom = function(index) {
		if(index + data_length >= ds_list_size(inputs))
			createNewSurface();
	}
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		var pad = inputs[| 0].getValue();
		var ww  = overlay_w;
		var hh  = overlay_h;
		
		var x0  = _x + pad[2] * _s;
		var x1  = _x + (ww - pad[0]) * _s;
		var y0  = _y + pad[1] * _s;
		var y1  = _y + (hh - pad[3]) * _s;
		draw_set_color(COLORS._main_accent);
		draw_line(x0, y0, x0, y1);
		draw_line(x1, y0, x1, y1);
		draw_line(x0, y0, x1, y0);
		draw_line(x0, y1, x1, y1);
		
		if(input_dragging > -1) {
			if(drag_type == 0) {
				var pos_x = dragging_sx + (_mx - dragging_mx) / _s;
				var pos_y = dragging_sy + (_my - dragging_my) / _s;
				if(keyboard_check(vk_control)) {
					pos_x = round(pos_x);
					pos_y = round(pos_y);
				}
			
				if(inputs[| input_dragging].setValue([ pos_x, pos_y ]))
					UNDO_HOLDING = true;
			} else if(drag_type == 1) {
				var aa = point_direction(rot_anc_x, rot_anc_y, _mx, _my);
				var da = angle_difference(dragging_mx, aa);
				var sa;
				
				if(keyboard_check(vk_control)) 
					sa = round((dragging_sx - da) / 15) * 15;
				else 
					sa = dragging_sx - da;
			
				if(inputs[| input_dragging].setValue(sa))
					UNDO_HOLDING = true;	
			} else if(drag_type == 2) {
				var _surf = inputs[| surf_dragging].getValue();
				var _sw = surface_get_width(_surf);
				var _sh = surface_get_width(_surf);
				
				var sca_x = dragging_sx + (_mx - dragging_mx) / _s / _sw;
				var sca_y = dragging_sy + (_my - dragging_my) / _s / _sh;
				
				if(keyboard_check(vk_shift)) {
					sca_x = min(sca_x, sca_y);
					sca_y = min(sca_x, sca_y);
				}
				
				if(inputs[| input_dragging].setValue([ sca_x, sca_y ]))
					UNDO_HOLDING = true;	
			}
			
			if(mouse_check_button_released(mb_left)) {
				input_dragging = -1;
				UNDO_HOLDING = false;
			}
		}
		
		var hovering = -1;
		var hovering_type = 0;
		var _vis = attributes[? "layer_visible"];
		
		var amo = (ds_list_size(inputs) - input_fix_len) / data_length;
		if(array_length(current_data) < input_fix_len + amo * data_length)
			return;
		
		for(var i = 0; i < amo; i++) {
			var vis = _vis[| i];
			if(!vis) continue;
			
			var index = input_fix_len + i * data_length;
			var _surf = current_data[index + 0];
			var _pos  = current_data[index + 1];
			
			if(!_surf || is_array(_surf)) continue;
			
			var _ww  = surface_get_width(_surf);
			var _hh  = surface_get_height(_surf);
			
			var _dx0 = _x + _pos[0] * _s;
			var _dy0 = _y + _pos[1] * _s;
			var _dx1 = _dx0 + _ww * _s;
			var _dy1 = _dy0 + _hh * _s;
			var _borcol = COLORS.node_composite_overlay_border;
			
			var _rx = (_dx0 + _dx1) / 2;
			var _ry = _dy0 - 16;
			var _ri = 0;
			
			var _sx = _dx1;
			var _sy = _dy1;
			var _si = 0;
			
			if(point_in_circle(_mx, _my, _sx, _sy, 12)) {
				hovering = index;
				hovering_type = 2;
				_si = 1;
			} else if(point_in_rectangle(_mx, _my, _dx0, _dy0, _dx1, _dy1)) {
				hovering = index;
				hovering_type = 0;
			} else if(point_in_circle(_mx, _my, _rx, _ry, 12)) {
				hovering = index;
				hovering_type = 1;
				_ri = 1;
			}
			
			draw_sprite_ui_uniform(THEME.anchor_rotate, _ri, _rx, _ry);
			draw_sprite_ui_uniform(THEME.anchor_scale, _si, _sx, _sy);
			
			draw_set_color(_borcol);
			draw_rectangle(_dx0, _dy0, _dx1, _dy1, true);
		}
		
		if(hovering != -1) {
			var _surf = current_data[hovering];
			var _pos = current_data[hovering + 1];
			var _rot = current_data[hovering + 2];
			var _sca = current_data[hovering + 3];
			
			var _ww  = surface_get_width(_surf);
			var _hh  = surface_get_height(_surf);
			var _dx0 = _x + _pos[0] * _s;
			var _dy0 = _y + _pos[1] * _s;
			var _dx1 = _dx0 + _ww * _s;
			var _dy1 = _dy0 + _hh * _s;
			
			if(hovering_type == 0) {
				draw_set_color(COLORS._main_accent);
				draw_rectangle_border(_dx0, _dy0, _dx1, _dy1, 2);
				
				if(_active && mouse_check_button_pressed(mb_left)) {
					surf_dragging = hovering;
					input_dragging = hovering + 1;
					drag_type = hovering_type;
					dragging_sx = _pos[0];
					dragging_sy = _pos[1];
					dragging_mx = _mx;
					dragging_my = _my;
				}
			} else if(hovering_type == 1) { //rot
				if(_active && mouse_check_button_pressed(mb_left)) {
					surf_dragging = hovering;
					input_dragging = hovering + 2;
					drag_type = hovering_type;
					dragging_sx = _rot;
					
					rot_anc_x = _dx0 + _ww / 2 * _s;
					rot_anc_y = _dy0 + _hh / 2 * _s;
					dragging_mx = point_direction(rot_anc_x, rot_anc_y, _mx, _my);
				}
			} else if(hovering_type == 2) { //sca
				if(_active && mouse_check_button_pressed(mb_left)) {
					surf_dragging = hovering;
					input_dragging = hovering + 3;
					drag_type = hovering_type;
					dragging_sx = _sca[0];
					dragging_sy = _sca[1];
					dragging_mx = _mx;
					dragging_my = _my;
				}
			}
		}
		
		if(layer_remove > -1) {
			deleteLayer(layer_remove);
			layer_remove = -1;
		}
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _pad = _data[0];
		var _dim_type = _data[1];
		var _dim = _data[2];
		var base = _data[3];
		var ww = 0, hh = 0;
		
		switch(_dim_type) {
			case COMPOSE_OUTPUT_SCALING.first :
				inputs[| 2].setVisible(false);
				ww = surface_get_width(base);
				hh = surface_get_height(base);
				break;
			case COMPOSE_OUTPUT_SCALING.largest :
				inputs[| 2].setVisible(false);
				for(var i = input_fix_len; i < array_length(_data) - data_length; i += data_length) {
					var _s = _data[i];
					ww = max(ww, surface_get_width(_s));
					hh = max(hh, surface_get_height(_s));
				}
				break;
			case COMPOSE_OUTPUT_SCALING.constant :	
				inputs[| 2].setVisible(true);
				ww = _dim[0];
				hh = _dim[1];
				break;
		}
		ww += _pad[0] + _pad[2];
		hh += _pad[1] + _pad[3];
		
		overlay_w = ww;
		overlay_h = hh;
	
		if(is_surface(base)) 
			surface_size_to(_outSurf, ww, hh);
		
		for(var i = 0; i < 2; i++) {
			if(!is_surface(temp_surf[i])) temp_surf[i] = surface_create_valid(surface_get_width(_outSurf), surface_get_height(_outSurf));
			else surface_size_to(temp_surf[i], surface_get_width(_outSurf), surface_get_height(_outSurf));
			
			surface_set_target(temp_surf[i]);
			draw_clear_alpha(0, 0);
			surface_reset_target();
		}
		
		var res_index = 0, bg = 0;
		var imageAmo = (ds_list_size(inputs) - input_fix_len) / data_length;
		var _vis = attributes[? "layer_visible"];
		
		BLEND_OVERRIDE
		for(var i = 0; i < imageAmo; i++) {
			var vis  = _vis[| i];
			if(!vis) continue;
			
			var startDataIndex = input_fix_len + i * data_length;
			var _s   = _data[startDataIndex + 0];
			var _pos = _data[startDataIndex + 1];
			var _rot = _data[startDataIndex + 2];
			var _sca = _data[startDataIndex + 3];
			
			if(!_s || is_array(_s)) continue;
			
			surface_set_target(temp_surf[bg]);
				shader_set(sh_blend_normal_dim);
				shader_set_uniform_f_array(uniform_dim, [ surface_get_width(_s) / ww, surface_get_height(_s) / hh ]);
				shader_set_uniform_f_array(uniform_pos, [ _pos[0] / ww, _pos[1] / hh]); 
				shader_set_uniform_f_array(uniform_sca, _sca) 
				shader_set_uniform_f(uniform_rot, degtorad(_rot)); 
				texture_set_stage(uniform_for, surface_get_texture(_s));
				
				draw_surface_safe(temp_surf[!bg], 0, 0);
				shader_reset();
			surface_reset_target();
			
			res_index = bg;
			bg = !bg;
		}
		BLEND_NORMAL
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
			draw_surface_safe(temp_surf[res_index], 0, 0);
		BLEND_NORMAL
		surface_reset_target();
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length) {
			if(i > input_fix_len)
				createNewSurface();
			inputs[| i + 0].deserialize(_inputs[| i + 0]);
			inputs[| i + 1].deserialize(_inputs[| i + 1]);
			inputs[| i + 2].deserialize(_inputs[| i + 2]);
			inputs[| i + 3].deserialize(_inputs[| i + 3]);
		}
	}
	
	static attributeSerialize = function() {
		var att = ds_map_create();
		ds_map_add_list(att, "layer_visible", ds_list_clone(attributes[? "layer_visible"]));
		return att;
	}
	
	static attributeDeserialize = function(attr) {
		if(ds_map_exists(attr, "layer_visible"))
			attributes[? "layer_visible"] = ds_list_clone(attr[? "layer_visible"], true);
	}
}

