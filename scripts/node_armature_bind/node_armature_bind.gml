function Node_Armature_Bind(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Armature Bind";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Armature", self, JUNCTION_CONNECT.input, VALUE_TYPE.armature, noone)
		.setVisible(true, true)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Atlas data", self, JUNCTION_CONNECT.output, VALUE_TYPE.atlas, [])
		.rejectArrayProcess();
	
	attribute_surface_depth();
	attribute_interpolation();
	
	input_fix_len	= ds_list_size(inputs);
	data_length		= 2;
	
	attributes.layer_visible = [];
	attributes.layer_selectable = [];
	
	attributes.display_bone = 0;
	array_push(attributeEditors, ["Display bone", "display_bone", 
		new scrollBox(["Above", "Below", "Hide"], function(ind) { 
			attributes.display_bone = ind;
		})]);
	
	boneMap = ds_map_create();
	surfMap = ds_map_create();
	
	hold_visibility = true;
	hold_select		= true;
	layer_dragging	= noone;
	layer_remove	= -1;
	
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region 
		ds_map_clear(surfMap);
		
		for(var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length) {
			var _surf = current_data[i];
			var _id = inputs[| i].extra_data[0];
			if(_id == "") continue;
			
			if(ds_map_exists(surfMap, _id))
				array_push(surfMap[? _id], _surf);
			else
				surfMap[? _id] = [ _surf ];
				
			print($"Add {_surf} to {_id}");
		}
		
		#region draw bones
			var _b  = inputs[| 1].getValue();
			var amo = _b.childCount();
			var _hh = ui(28);
			var bh  = ui(32 + 16) + amo * _hh;
			var ty  = _y;
			
			draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_x + ui(16), ty + ui(4), "Bones");
			
			ty += ui(32);
		
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, bh - ui(32), COLORS.node_composite_bg_blend, 1);
			draw_set_color(COLORS.node_composite_separator);
			draw_line(_x + 16, ty + ui(8), _x + _w - 16, ty + ui(8));
		
			ty += ui(8);
		
			var hovering = noone;
			var _bst = ds_stack_create();
			ds_stack_push(_bst, [ _b, _x, _w ]);
			
			while(!ds_stack_empty(_bst)) {
				var _st  = ds_stack_pop(_bst);
				var bone = _st[0];
				var __x  = _st[1];
				var __w  = _st[2];
				
				if(!bone.is_main) {
					draw_sprite_ui(THEME.bone, 0, __x + 12, ty + 12,,,, COLORS._main_icon);
					draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
					draw_text(__x + 24, ty + 12, bone.name);
					
					if(ds_map_exists(surfMap, bone.id)) {
						var _surf = surfMap[? bone.id];
						print($"{_id} has surface {_surf}");
						var _sx = __x + 24 + string_width(bone.name) + 8;
						var _sy = ty + 4;
						
						for( var i = 0; i < array_length(_surf); i++ ) {
							var _sw = surface_get_width(_surf[i]);
							var _sh = surface_get_height(_surf[i]);
							var _ss = (_hh - 8) / _sh;
							
							draw_surface_ext_safe(_surf[i], _sx, _sy, _ss, _ss, 0, c_white, 1);
							draw_set_color(COLORS.node_composite_bg);
							draw_rectangle(_sx, _sy, _sx + _sw * _ss, _sy + _sh * _ss, true);
							
							_sy += _sh * _ss + 4;
						}
					}
					
					if(layer_dragging != noone && point_in_rectangle(_m[0], _m[1], _x, ty, _x + _w, ty + _hh - 1)) {
						draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, ty, _w, _hh, COLORS._main_accent, 1);
						hovering = bone;
					}
					
					ty += _hh;
		
					draw_set_color(COLORS.node_composite_separator);
					draw_line(_x + 16, ty, _x + _w - 16, ty);
				}
				
				for( var i = 0; i < array_length(bone.childs); i++ )
					ds_stack_push(_bst, [ bone.childs[i], __x + 16, __w - 16 ]);
			}
		
			ds_stack_destroy(_bst);
		
			if(layer_dragging != noone && hovering && mouse_release(mb_left)) {
				var _lind = input_fix_len + layer_dragging * data_length;
				inputs[| _lind].extra_data[0] = hovering.id;
				
				layer_dragging = noone;
			}
		#endregion
		
		var amo = (ds_list_size(inputs) - input_fix_len) / data_length - 1;
		if(array_length(current_data) != ds_list_size(inputs)) return 0;
		
		var ty = _y + bh + ui(8);
		
		//draw_set_color(COLORS.node_composite_separator);
		//draw_line(_x + 16, ty - ui(4), _x + _w - 16, ty - ui(4));
		
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
		draw_text_add(_x + ui(16), ty + ui(4), "Surfaces");
			
		ty += ui(32);
		
		var lh = 32;
		var sh = 8 + max(1, amo) * (lh + 4) + 8;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, sh, COLORS.node_composite_bg_blend, 1);
		
		var _vis = attributes.layer_visible;
		var _sel = attributes.layer_selectable;
		var ly   = ty + 8;
		var ssh  = lh - 6;
		var hoverIndex = noone;
		draw_set_color(COLORS.node_composite_separator);
		draw_line(_x + 16, ly, _x + _w - 16, ly);
		
		layer_remove = -1;
		var index = -1;
		for(var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length) {
			var _surf = current_data[i];
			
			index++;
			var _bx = _x + _w - 24;
			var _cy = ly + index * (lh + 4);
			
			if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 16)) {
				draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_value_negative);
				
				if(mouse_press(mb_left, _focus))
					layer_remove = index;
			} else 
				draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_icon);
			
			if(!is_surface(_surf)) continue;
			
			var aa = (index != layer_dragging || layer_dragging == noone)? 1 : 0.5;
			var vis = _vis[index];
			var sel = _sel[index];
			var hover = point_in_rectangle(_m[0], _m[1], _x, _cy, _x + _w, _cy + lh);
			
			draw_set_color(COLORS.node_composite_separator);
			draw_line(_x + 16, _cy + lh + 2, _x + _w - 16, _cy + lh + 2);
			
			var _bx = _x + 24 * 2 + 8;
			if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 12)) {
				draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _cy + lh / 2, 1, c_white);
				
				if(mouse_press(mb_left, _focus))
					hold_visibility = !_vis[index];
					
				if(mouse_click(mb_left, _focus) && _vis[index] != hold_visibility) {
					_vis[@ index] = hold_visibility;
					doUpdate();
				}
			} else 
				draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _cy + lh / 2, 1, COLORS._main_icon, 0.5 + 0.5 * vis);
			
			_bx += 24 + 8;
			if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 12)) {
				draw_sprite_ui_uniform(THEME.cursor_select, sel, _bx, _cy + lh / 2, 1, c_white);
				
				if(mouse_press(mb_left, _focus))
					hold_select = !_sel[index];
					
				if(mouse_click(mb_left, _focus) && _sel[index] != hold_select)
					_sel[@ index] = hold_select;
			} else 
				draw_sprite_ui_uniform(THEME.cursor_select, sel, _bx, _cy + lh / 2, 1, COLORS._main_icon, 0.5 + 0.5 * sel);
			
			draw_set_color(COLORS.node_composite_bg);
			var _sx0 = _bx + 24;
			var _sx1 = _sx0 + ssh;
			var _sy0 = _cy + 3;
			var _sy1 = _sy0 + ssh;
			draw_rectangle(_sx0, _sy0, _sx1, _sy1, true);
			
			var _ssw = surface_get_width(_surf);
			var _ssh = surface_get_height(_surf);
			var _sss = min(ssh / _ssw, ssh / _ssh);
			draw_surface_ext_safe(_surf, _sx0, _sy0, _sss, _sss, 0, c_white, 1);
			
			draw_set_text(f_p1, fa_left, fa_center, hover? COLORS._main_text : COLORS._main_text);
			draw_set_alpha(aa);
			draw_text(_sx1 + 12, _cy + lh / 2, inputs[| i].name);
			draw_set_alpha(1);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _cy, _x + _w, _cy + lh)) {
				hoverIndex = index;
				if(layer_dragging != noone) {
					draw_set_color(COLORS._main_accent);
					if(layer_dragging > index)
						draw_line_width(_x + 16, _cy + lh + 2, _x + _w - 16, _cy + lh + 2, 2);
					else if(layer_dragging < index)
						draw_line_width(_x + 16, _cy - 2, _x + _w - 16, _cy - 2, 2);
				}
			}
			
			if(layer_dragging == noone || layer_dragging == index) {
				var _bx = _x + 24;
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 16)) {
					draw_sprite_ui_uniform(THEME.hamburger, 3, _bx, _cy + lh / 2, .75, c_white);
				
					if(mouse_press(mb_left, _focus))
						layer_dragging = index;
				} else 
					draw_sprite_ui_uniform(THEME.hamburger, 3, _bx, _cy + lh / 2, .75, COLORS._main_icon);
			}
		}
		
		if(layer_dragging != noone && mouse_release(mb_left)) {
			if(layer_dragging != hoverIndex && hoverIndex != noone) {
				var index = input_fix_len + layer_dragging * data_length;
				var targt = input_fix_len + hoverIndex * data_length;
				var _vis = attributes.layer_visible;
				var _sel = attributes.layer_selectable;
				
				var ext = [];
				var vis = _vis[layer_dragging];
				array_delete(_vis, layer_dragging, 1);
				array_insert(_vis, hoverIndex, vis);
				
				var sel = _sel[layer_dragging];
				array_delete(_sel, layer_dragging, 1);
				array_insert(_sel, hoverIndex, sel);
				
				for( var i = 0; i < data_length; i++ ) {
					ext[i] = inputs[| index];
					ds_list_delete(inputs, index);
				}
				
				for( var i = 0; i < data_length; i++ ) {
					ds_list_insert(inputs, targt + i, ext[i]);
				}
				
				doUpdate();
			}
			
			layer_dragging = noone;
		}
		
		layer_renderer.h = bh + ui(40) + sh;
		return layer_renderer.h;
	#endregion
	});
	
	input_display_list = [ 1, 
		["Output",	  true], 0,
		["Armature", false], layer_renderer,
		["Surfaces",  true], 
	];
	input_display_list_len = array_length(input_display_list);
	
	function deleteLayer(index) { #region 
		var idx = input_fix_len + index * data_length;
		for( var i = 0; i < data_length; i++ ) {
			ds_list_delete(inputs, idx);
			array_remove(input_display_list, idx + i);
		}
		
		for( var i = input_display_list_len; i < array_length(input_display_list); i++ ) {
			if(input_display_list[i] > idx)
				input_display_list[i] = input_display_list[i] - data_length;
		}
		doUpdate();
	#endregion
	}
	
	function createNewSurface() { #region 
		var index = ds_list_size(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		
		inputs[| index + 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
		inputs[| index + 0].surface_index = index;
		inputs[| index + 0].hover_effect  = 0;
		inputs[| index + 0].extra_data[0] = "";
		
		inputs[| index + 1] = nodeValue("Transform", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 1, 1 ] )
			.setDisplay(VALUE_DISPLAY.transform);
		
		array_push(input_display_list, index + 0);
		array_push(input_display_list, index + 1);
		
		while(_s >= array_length(attributes.layer_visible))
			array_push(attributes.layer_visible, true);
		while(_s >= array_length(attributes.layer_selectable))
			array_push(attributes.layer_selectable, true);
	#endregion
	}
	
	if(!LOADING && !APPENDING) createNewSurface();
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	
	surf_dragging = -1;
	drag_type = 0;
	dragging_sx = 0;
	dragging_sy = 0;
	dragging_mx = 0;
	dragging_my = 0;
	
	rot_anc_x = 0;
	rot_anc_y = 0;
	
	overlay_w = 0;
	overlay_h = 0;
	
	atlas_data = [];
	
	static getInputAmount = function() {
		return input_fix_len + (ds_list_size(inputs) - input_fix_len) / data_length;
	}
	
	static getInputIndex = function(index) {
		if(index < input_fix_len) return index;
		return input_fix_len + (index - input_fix_len) * data_length;
	}
	
	static setHeight = function() {
		var _hi = ui(32);
		var _ho = ui(32);
		
		for( var i = 0; i < getInputAmount(); i++ ) 
			if(inputs[| getInputIndex(i)].isVisible())	
				_hi += 24;
			
		for( var i = 0; i < ds_list_size(outputs); i++ ) 
			if(outputs[| i].isVisible()) 
				_ho += 24;
		
		h = max(min_h, (preview_surface && previewable)? 128 : 0, _hi, _ho);
	}
	
	static onValueFromUpdate = function(index) { #region
		if(LOADING || APPENDING) return;
		
		if(index + data_length >= ds_list_size(inputs))
			createNewSurface();
	#endregion
	}
	
	static setBone = function() { #region
		ds_map_clear(boneMap);
		
		var _b = inputs[| 1].getValue();
		if(_b == noone) return;
		
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _b);
		
		while(!ds_stack_empty(_bst)) {
			var __b = ds_stack_pop(_bst);
			
			for( var i = 0; i < array_length(__b.childs); i++ ) {
				boneMap[? __b.id] = __b;
				ds_stack_push(_bst, __b.childs[i]);
			}
		}
		
		ds_stack_destroy(_bst);
	#endregion
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var dim = inputs[| 0].getValue();
		var _b = inputs[| 1].getValue();
		
		if(attributes.display_bone == 1)
			_b.draw(active, _x, _y, _s, _mx, _my);
			
		var ww  = dim[0];
		var hh  = dim[1];
		
		var x0  = _x;
		var x1  = _x + ww * _s;
		var y0  = _y;
		var y1  = _y + hh * _s;
		
		if(surf_dragging > -1) {
			var input_dragging = surf_dragging + 1;
			var _surf = current_data[surf_dragging];
			var _tran = current_data[input_dragging];
			
			var _bone = inputs[| surf_dragging].extra_data[0];
			_bone = boneMap[? _bone];
			
			if(drag_type == NODE_COMPOSE_DRAG.move) {
				var _dx = (_mx - dragging_mx) / _s;
				var _dy = (_my - dragging_my) / _s;
				
				var _p  = point_rotate(_dx, _dy, 0, 0, -_bone.angle);
				
				var pos_x = dragging_sx + _p[0];
				var pos_y = dragging_sy + _p[1];
				
				_tran[TRANSFORM.pos_x] = pos_x;
				_tran[TRANSFORM.pos_y] = pos_y;
			} else if(drag_type == NODE_COMPOSE_DRAG.rotate) {
				var aa = point_direction(rot_anc_x, rot_anc_y, _mx, _my);
				var da = angle_difference(dragging_mx, aa);
				var sa;
				
				if(key_mod_press(CTRL)) 
					sa = round((dragging_sx - da) / 15) * 15;
				else 
					sa = dragging_sx - da;
				
				_tran[TRANSFORM.rot] = sa;
			} else if(drag_type == NODE_COMPOSE_DRAG.scale) {
				var _rot = _bone.angle + _tran[TRANSFORM.rot];
				var _sw = surface_get_width(_surf);
				var _sh = surface_get_height(_surf);
				
				var _p = point_rotate(_mx - dragging_mx, _my - dragging_my, 0, 0, -_rot);
				var sca_x = _p[0] / _s / _sw * 2;
				var sca_y = _p[1] / _s / _sh * 2;
				
				if(key_mod_press(SHIFT)) {
					sca_x = min(sca_x, sca_y);
					sca_y = sca_x;
				}
				
				_tran[TRANSFORM.sca_x] = sca_x;
				_tran[TRANSFORM.sca_y] = sca_y;
			}
			
			if(inputs[| input_dragging].setValue(_tran))
				UNDO_HOLDING = true;	
			
			if(mouse_release(mb_left)) {
				input_dragging = -1;
				UNDO_HOLDING = false;
			}
		}
		
		var hovering = -1;
		var hovering_type = 0;
		var _vis = attributes.layer_visible;
		var _sel = attributes.layer_selectable;
		
		var amo = (ds_list_size(inputs) - input_fix_len) / data_length;
		if(array_length(current_data) < input_fix_len + amo * data_length)
			return;
		
		for(var i = 0; i < amo; i++) {
			var vis = _vis[i];
			var sel = _sel[i];
			if(!vis) continue;
			
			var index = input_fix_len + i * data_length;
			var _surf = current_data[index + 0];
			
			var _bone = inputs[| index].extra_data[0];
			if(!ds_map_exists(boneMap, _bone)) continue;
			_bone = boneMap[? _bone];
			
			var _tran = current_data[index + 1];
			var _rot  = _bone.angle + _tran[TRANSFORM.rot];
			var _anc  = _bone.getPoint(_bone.length / 2, _bone.angle);
			var _pos  = point_rotate(_tran[TRANSFORM.pos_x], _tran[TRANSFORM.pos_y], _anc.x, _anc.y, _rot);
			var _sca  = [ _tran[TRANSFORM.sca_x], _tran[TRANSFORM.sca_y] ];
			
			if(!_surf || is_array(_surf)) continue;
			
			var _ww = surface_get_width(_surf);
			var _hh = surface_get_height(_surf);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var cx = _pos[0] + _ww / 2;
			var cy = _pos[1] + _hh / 2;
			
			var _d0 = point_rotate(cx - _sw / 2, cy - _sh / 2, cx, cy, _rot);
			var _d1 = point_rotate(cx - _sw / 2, cy + _sh / 2, cx, cy, _rot);
			var _d2 = point_rotate(cx + _sw / 2, cy - _sh / 2, cx, cy, _rot);
			var _d3 = point_rotate(cx + _sw / 2, cy + _sh / 2, cx, cy, _rot);
			var _rr = point_rotate(cx,  cy - _sh / 2 - 1,      cx, cy, _rot);
			
			_d0[0] = overlay_x(_d0[0], _x, _s); _d0[1] = overlay_y(_d0[1], _y, _s);
			_d1[0] = overlay_x(_d1[0], _x, _s); _d1[1] = overlay_y(_d1[1], _y, _s);
			_d2[0] = overlay_x(_d2[0], _x, _s); _d2[1] = overlay_y(_d2[1], _y, _s);
			_d3[0] = overlay_x(_d3[0], _x, _s); _d3[1] = overlay_y(_d3[1], _y, _s);
			_rr[0] = overlay_x(_rr[0], _x, _s); _rr[1] = overlay_y(_rr[1], _y, _s);
			
			var _borcol = COLORS.node_composite_overlay_border;
			
			var _ri = 0;
			var _si = 0;
			
			if(!sel) continue;
			
			if(point_in_circle(_mx, _my, _d3[0], _d3[1], 12)) {
				hovering = index;
				hovering_type = NODE_COMPOSE_DRAG.scale;
				_si = 1;
			} else if(point_in_rectangle_points(_mx, _my, _d0[0], _d0[1], _d1[0], _d1[1], _d2[0], _d2[1], _d3[0], _d3[1])) {
				hovering = index;
				hovering_type = NODE_COMPOSE_DRAG.move;
			} else if(point_in_circle(_mx, _my, _rr[0], _rr[1], 12)) {
				hovering = index;
				hovering_type = NODE_COMPOSE_DRAG.rotate;
				_ri = 1;
			}
			
			draw_sprite_colored(THEME.anchor_rotate, _ri, _rr[0], _rr[1],, _rot);
			draw_sprite_colored(THEME.anchor_scale,  _si, _d3[0], _d3[1],, _rot);
			
			draw_set_color(_borcol);
			draw_line(_d0[0], _d0[1], _d1[0], _d1[1]);
			draw_line(_d0[0], _d0[1], _d2[0], _d2[1]);
			draw_line(_d3[0], _d3[1], _d1[0], _d1[1]);
			draw_line(_d3[0], _d3[1], _d2[0], _d2[1]);
		}
		
		if(hovering != -1) {
			var _surf = current_data[hovering];
			var _bone = inputs[| hovering].extra_data[0];			
			_bone = boneMap[? _bone];
			
			var _tran = current_data[hovering + 1];
			var _rot  = _bone.angle + _tran[TRANSFORM.rot];
			var _anc  = _bone.getPoint(_bone.length / 2, _bone.angle);
			var _pos  = point_rotate(_tran[TRANSFORM.pos_x], _tran[TRANSFORM.pos_y], _anc.x, _anc.y, _rot);
			var _sca  = [ _tran[TRANSFORM.sca_x], _tran[TRANSFORM.sca_y] ];
			
			var _ww  = surface_get_width(_surf);
			var _hh  = surface_get_height(_surf);
			var _dx0 = _x + _pos[0] * _s;
			var _dy0 = _y + _pos[1] * _s;
			var _dx1 = _dx0 + _ww * _s;
			var _dy1 = _dy0 + _hh * _s;
			
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var cx = _pos[0] + _ww / 2;
			var cy = _pos[1] + _hh / 2;
			
			var _d0 = point_rotate(cx - _sw / 2, cy - _sh / 2, cx, cy, _rot);
			var _d1 = point_rotate(cx - _sw / 2, cy + _sh / 2, cx, cy, _rot);
			var _d2 = point_rotate(cx + _sw / 2, cy - _sh / 2, cx, cy, _rot);
			var _d3 = point_rotate(cx + _sw / 2, cy + _sh / 2, cx, cy, _rot);
			
			_d0[0] = overlay_x(_d0[0], _x, _s); _d0[1] = overlay_y(_d0[1], _y, _s);
			_d1[0] = overlay_x(_d1[0], _x, _s); _d1[1] = overlay_y(_d1[1], _y, _s);
			_d2[0] = overlay_x(_d2[0], _x, _s); _d2[1] = overlay_y(_d2[1], _y, _s);
			_d3[0] = overlay_x(_d3[0], _x, _s); _d3[1] = overlay_y(_d3[1], _y, _s);
			
			if(hovering_type == NODE_COMPOSE_DRAG.move) {
				draw_set_color(COLORS._main_accent);
				draw_line_round(_d0[0], _d0[1], _d1[0], _d1[1], 2);
				draw_line_round(_d0[0], _d0[1], _d2[0], _d2[1], 2);
				draw_line_round(_d3[0], _d3[1], _d1[0], _d1[1], 2);
				draw_line_round(_d3[0], _d3[1], _d2[0], _d2[1], 2);
				
				if(mouse_press(mb_left, active)) {
					surf_dragging	= hovering;
					drag_type	= hovering_type;
					dragging_sx = _pos[0];
					dragging_sy = _pos[1];
					dragging_mx = _mx;
					dragging_my = _my;
				}
			} else if(hovering_type == NODE_COMPOSE_DRAG.rotate) { //rot
				if(mouse_press(mb_left, active)) {
					surf_dragging	= hovering;
					drag_type	= hovering_type;
					dragging_sx = _rot;
					rot_anc_x	= _dx0 + _ww / 2 * _s;
					rot_anc_y	= _dy0 + _hh / 2 * _s;
					dragging_mx = point_direction(rot_anc_x, rot_anc_y, _mx, _my);
				}
			} else if(hovering_type == NODE_COMPOSE_DRAG.scale) { //sca
				if(mouse_press(mb_left, active)) {
					surf_dragging	= hovering;
					drag_type	= hovering_type;
					dragging_sx = _sca[0];
					dragging_sy = _sca[1];
					dragging_mx = _dx0 + _ww / 2 * _s;
					dragging_my = _dy0 + _hh / 2 * _s;
				}
			}
		}
		
		if(layer_remove > -1) {
			deleteLayer(layer_remove);
			layer_remove = -1;
		}
		
		if(attributes.display_bone == 0)
			_b.draw(active, _x, _y, _s, _mx, _my);
	#endregion
	}
	
	bone_prev = noone;
	static step = function() {
		var _b = inputs[| 1].getValue();
		if(bone_prev != _b) {
			setBone();
			bone_prev = _b;
		}
		
		var _dim_type = getSingleValue(1);
		inputs[| 2].setVisible(_dim_type == COMPOSE_OUTPUT_SCALING.constant);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 1) return atlas_data;
		if(_output_index == 0 && _array_index == 0) atlas_data = [];
		
		var _dim  = _data[0];
		var _bone = _data[1];
		var cDep	  = attrDepth();
		
		overlay_w = _dim[0];
		overlay_h = _dim[1];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], cDep);
		
		for(var i = 0; i < 2; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], surface_get_width(_outSurf), surface_get_height(_outSurf), cDep);
			
			surface_set_target(temp_surface[i]);
			DRAW_CLEAR
			surface_reset_target();
		}
		
		var res_index = 0, bg = 0;
		var imageAmo = (ds_list_size(inputs) - input_fix_len) / data_length;
		var _vis = attributes.layer_visible;
		
		surface_set_shader(_outSurf, sh_sample, true, BLEND.alphamulp);
		
		for(var i = 0; i < imageAmo; i++) {
			var vis  = _vis[i];
			if(!vis) continue;
			
			var startDataIndex = input_fix_len + i * data_length;
			var _s    = _data[startDataIndex];
			var _bone = inputs[| startDataIndex].extra_data[0];
			
			if(!ds_map_exists(boneMap, _bone)) continue;
			_bone = boneMap[? _bone];
			
			var _tran = _data[startDataIndex + 1];
			var _rot  = _bone.angle + _tran[TRANSFORM.rot];
			var _anc  = _bone.getPoint(_bone.length / 2, _bone.angle);
			var _pos  = point_rotate(_tran[TRANSFORM.pos_x], _tran[TRANSFORM.pos_y], _anc.x, _anc.y, _rot);
			var _sca  = [ _tran[TRANSFORM.sca_x], _tran[TRANSFORM.sca_y] ];
			
			if(!is_surface(_s)) continue;
			
			var _ww = surface_get_width(_s);
			var _hh = surface_get_height(_s);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var cx = _pos[0];
			var cy = _pos[1];
			
			var _d0 = point_rotate(cx - _sw / 2, cy - _sh / 2, cx, cy, _rot);
			
			shader_set_interpolation(_s);
			
			array_push(atlas_data, new SurfaceAtlas(_s, _d0, _rot, _sca));
			draw_surface_ext_safe(_s, _d0[0], _d0[1], _sca[0], _sca[1], _rot);
		}
		surface_reset_shader();
		
		return _outSurf;
	}
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for(var i = input_fix_len; i < array_length(_inputs); i += data_length)
			createNewSurface();
	}
	
	static attributeSerialize = function() {
		var att = {};
		att.layer_visible    = attributes.layer_visible;
		att.layer_selectable = attributes.layer_selectable;
		
		return att;
	}
	
	static attributeDeserialize = function(attr) {
		if(struct_has(attr, "layer_visible"))
			attributes.layer_visible = attr.layer_visible;
			
		if(struct_has(attr, "layer_selectable"))
			attributes.layer_selectable = attr.layer_selectable;
	}
}

