function Node_Armature_Bind(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Armature Bind";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Armature", self, JUNCTION_CONNECT.input, VALUE_TYPE.armature, noone)
		.setVisible(true, true)
		.rejectArray();
		
	inputs[| 2] = nodeValue("Bind data", self, JUNCTION_CONNECT.input, VALUE_TYPE.struct, noone)
		.setVisible(true, true)
		.setArrayDepth(1); 
		
	inputs[| 3] = nodeValue("Bone transform", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 4] = nodeValue("Bone scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0.1, 2, 0.01 ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Atlas data", self, JUNCTION_CONNECT.output, VALUE_TYPE.atlas, [])
		.rejectArrayProcess();
	
	outputs[| 2] = nodeValue("Bind data", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, [])
		.setArrayDepth(1);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	attributes.layer_visible	= [];
	attributes.layer_selectable = [];
	
	attributes.display_name = true;
	attributes.display_bone = 0;
	
	anchor_selecting = noone;
	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Display name", function() { return attributes.display_name; }, 
		new checkBox(function() { 
			attributes.display_name = !attributes.display_name;
		})]);
	array_push(attributeEditors, ["Display bone", function() { return attributes.display_bone; }, 
		new scrollBox(["Octahedral", "Stick"], function(ind) { 
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
		
		var index = -1;
		for(var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length) {
			index++;
			var _surf = current_data[i];
			var _id = inputs[| i].extra_data.bone_id;
			if(_id == "") continue;
			
			if(ds_map_exists(surfMap, _id))
				array_push(surfMap[? _id], [ index, _surf ]);
			else
				surfMap[? _id] = [ [ index, _surf ] ];
				
			//print($"Add {_surf} to {_id}");
		}
		
		#region draw bones
			var _b  = bone;
			if(_b == noone) return 0;
			var amo = _b.childCount();
			var _hh = ui(28);
			var bh  = ui(32 + 16) + amo * _hh;
			var ty  = _y;
			
			draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_x + ui(16), ty + ui(4), "Bones");
			
			ty += ui(32);
		
			var _ty = ty;
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, bh - ui(32), COLORS.node_composite_bg_blend, 1);
						
			draw_set_color(COLORS.node_composite_separator);
			draw_line(_x + 16, ty + ui(8), _x + _w - 16, ty + ui(8));
		
			ty += ui(8);
		
			var hovering = noone;
			var _bst = ds_stack_create();
			ds_stack_push(_bst, [ _b, _x, _w ]);
			
			anchor_selecting = noone;
			
			while(!ds_stack_empty(_bst)) {
				var _st   = ds_stack_pop(_bst);
				var _bone = _st[0];
				var __x   = _st[1];
				var __w   = _st[2];
				
				for( var i = 0, n = array_length(_bone.childs); i < n; i++ )
					ds_stack_push(_bst, [ _bone.childs[i], __x + 16, __w - 16 ]);
					
				if(_bone.is_main) continue;
				
				if(_bone.parent_anchor) 
					draw_sprite_ui(THEME.bone, 1, __x + 12, ty + 14,,,, COLORS._main_icon);
				else if(_bone.IKlength) 
					draw_sprite_ui(THEME.bone, 2, __x + 12, ty + 14,,,, COLORS._main_icon);
				else
					draw_sprite_ui(THEME.bone, 0, __x + 12, ty + 14,,,, COLORS._main_icon);
						
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text(__x + 24, ty + 12, _bone.name);
					
				if(ds_map_exists(surfMap, _bone.ID)) {
					var _sdata = surfMap[? _bone.ID];
						
					var _sx = __x + 24 + string_width(_bone.name) + 8;
					var _sy = ty + 4;
						
					for( var i = 0, n = array_length(_sdata); i < n; i++ ) {
						var _sid  = _sdata[i][0];
						var _surf = _sdata[i][1];
						var _sw = surface_get_width(_surf);
						var _sh = surface_get_height(_surf);
						var _ss = (_hh - 8) / _sh;
							
						draw_surface_ext_safe(_surf, _sx, _sy, _ss, _ss, 0, c_white, 1);
							
						if(_hover && point_in_rectangle(_m[0], _m[1], _sx, _sy, _sx + _sw * _ss, _sy + _sh * _ss)) {
							if(mouse_press(mb_left, _focus)) {
								layer_dragging = _sid;
								inputs[| input_fix_len + _sid * data_length].extra_data.bone_id = "";
							}
								
							draw_set_color(COLORS._main_accent);
						} else 
							draw_set_color(COLORS.node_composite_bg);
						draw_rectangle(_sx, _sy, _sx + _sw * _ss, _sy + _sh * _ss, true);
							
						_sy += _sh * _ss + 4;
					}
				}
					
				if(point_in_rectangle(_m[0], _m[1], _x, ty, _x + _w, ty + _hh - 1)) {
					if(layer_dragging != noone) {
						draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, ty, _w, _hh, COLORS._main_accent, 1);
						hovering = _bone;
					}
						                                         
					anchor_selecting = [ _bone, 2 ];
				}
					
				ty += _hh;
				
				draw_set_color(COLORS.node_composite_separator);
				draw_line(_x + 16, ty, _x + _w - 16, ty);
			}
			
			ds_stack_destroy(_bst);
			
			if(layer_dragging != noone && hovering && mouse_release(mb_left)) {
				var _lind = input_fix_len + layer_dragging * data_length;
				inputs[| _lind].extra_data.bone_id = hovering.ID;
				
				layer_dragging = noone;
				triggerRender();
			}
			
			if(layer_dragging != noone && !hovering)
				draw_sprite_stretched_ext(THEME.ui_panel_active, 0, _x, _ty, _w, bh - ui(32), COLORS._main_accent, 1);
		#endregion
		
		var amo = (ds_list_size(inputs) - input_fix_len) / data_length - 1;
		if(array_length(current_data) != ds_list_size(inputs)) return 0;
		
		var ty = _y + bh + ui(8);
		
		//draw_set_color(COLORS.node_composite_separator);
		//draw_line(_x + 16, ty - ui(4), _x + _w - 16, ty - ui(4));
		
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
		draw_text_add(_x + ui(16), ty + ui(4), "Surfaces");
			
		ty += ui(32);
		
		#region draw surface
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
				
				var binded = inputs[| i].extra_data.bone_id != "";
				
				if(layer_dragging == noone || layer_dragging == index) {
					var _bx = _x + 24;
					if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 16)) {
						draw_sprite_ui_uniform(THEME.hamburger_s, 3, _bx, _cy + lh / 2, 1, c_white);
				
						if(mouse_press(mb_left, _focus))
							layer_dragging = index;
					} else {
						if(!binded) {
							var cc = merge_color(COLORS._main_icon, COLORS._main_accent, 0.5 + 0.5 * (sin(current_time / 100) * 0.5 + 0.5));
							draw_sprite_ui_uniform(THEME.hamburger_s, 3, _bx, _cy + lh / 2, 1, cc);
						} else
							draw_sprite_ui_uniform(THEME.hamburger_s, 3, _bx, _cy + lh / 2, 1, COLORS._main_icon);
					}
				}
			}
		#endregion
		
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
	
	input_display_list = [ 1, 2, 
		["Output",	  true], 0,
		["Armature", false], 3, 4, layer_renderer,
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
		
		if(ds_list_size(inputs) == input_fix_len)
			createNewSurface();
		doUpdate();
	#endregion
	}
	
	function createNewSurface() { #region 
		var index = ds_list_size(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		
		inputs[| index + 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
		inputs[| index + 0].surface_index = index;
		inputs[| index + 0].hover_effect  = 0;
		inputs[| index + 0].extra_data.bone_id = "";
		
		inputs[| index + 1] = nodeValue("Transform", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 1, 1 ] )
			.setDisplay(VALUE_DISPLAY.transform);
		
		inputs[| index + 2] = nodeValue("Inherit Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
		
		for( var i = 0; i < data_length; i++ )
			array_push(input_display_list, index + i);
		
		while(_s >= array_length(attributes.layer_visible))
			array_push(attributes.layer_visible, true);
		while(_s >= array_length(attributes.layer_selectable))
			array_push(attributes.layer_selectable, true);
	#endregion
	}
	
	input_fix_len	= ds_list_size(inputs);
	data_length		= 3;
	
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
	bind_data  = [];
	
	bone = noone;
	surface_selecting = noone;
	
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
		bone = _b;
		if(bone == noone) return;
		
		var _bst = ds_stack_create();
		ds_stack_push(_bst, bone);
		
		while(!ds_stack_empty(_bst)) {
			var _bone = ds_stack_pop(_bst);
			
			for( var i = 0, n = array_length(_bone.childs); i < n; i++ ) {
				var child_bone = _bone.childs[i];
				boneMap[? child_bone.ID] = child_bone;
				ds_stack_push(_bst, child_bone);
			}
		}
		
		ds_stack_destroy(_bst);
	#endregion
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var dim   = inputs[| 0].getValue();
		var _bind = inputs[| 2].getValue();
		
		var _dpos = inputs[| 3].getValue();
		var _dsca = inputs[| 4].getValue();
		
		if(bone == noone) return;
		
		bone.draw(attributes, false, _x + _dpos[0] * _s, _y + _dpos[1] * _s, _s * _dsca, _mx, _my, anchor_selecting);
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		//inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var smx = value_snap(mx, _snx);
		var smy = value_snap(my, _sny);
		
		if(_bind != noone)
			return;
			
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
			
			var _bone = inputs[| surf_dragging].extra_data.bone_id;
			_bone = boneMap[? _bone];
			
			if(drag_type == NODE_COMPOSE_DRAG.move) {
				var _dx = smx - dragging_mx;
				var _dy = smy - dragging_my;
				
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
				var _rot = _ang * _bone.angle + _tran[TRANSFORM.rot];
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
				surf_dragging = -1;
				UNDO_HOLDING = false;
			}
		}
		
		var hovering = noone;
		var hovering_type = noone;
		var _vis = attributes.layer_visible;
		var _sel = attributes.layer_selectable;
		
		var amo = (ds_list_size(inputs) - input_fix_len) / data_length;
		var anchors = array_create(ds_list_size(inputs));
		
		for(var i = 0; i < amo; i++) {
			var index = input_fix_len + i * data_length;
			var _surf = array_safe_get(current_data, index);
			if(!_surf || is_array(_surf)) continue;
			
			var _bone = inputs[| index].extra_data.bone_id;
			if(!ds_map_exists(boneMap, _bone)) {
				//print($"Bone not found {_bone}");
				continue;
			}
			_bone = boneMap[? _bone];
			
			var _tran = current_data[index + 1];
			var _aang = current_data[index + 2];
			var _asca = current_data[index + 3];
			
			var _rot  = _aang * _bone.angle + _tran[TRANSFORM.rot];
			var _anc  = _bone.getPoint(0.5);
			var _mov  = point_rotate(_tran[TRANSFORM.pos_x], _tran[TRANSFORM.pos_y], 0, 0, _bone.angle);
			var _sca  = [ _tran[TRANSFORM.sca_x], _tran[TRANSFORM.sca_y] ];
			
			var _ww = surface_get_width(_surf);
			var _hh = surface_get_height(_surf);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var _cx = (_anc.x * _dsca) + _mov[0] + _dpos[0];
			var _cy = (_anc.y * _dsca) + _mov[1] + _dpos[1];
			
			var _d0 = point_rotate(_cx - _sw / 2, _cy - _sh / 2, _cx, _cy, _rot);
			var _d1 = point_rotate(_cx - _sw / 2, _cy + _sh / 2, _cx, _cy, _rot);
			var _d2 = point_rotate(_cx + _sw / 2, _cy - _sh / 2, _cx, _cy, _rot);
			var _d3 = point_rotate(_cx + _sw / 2, _cy + _sh / 2, _cx, _cy, _rot);
			var _rr = point_rotate(_cx,  _cy - _sh / 2 - 4,      _cx, _cy, _rot);
			
			_d0[0] = overlay_x(_d0[0], _x, _s); _d0[1] = overlay_y(_d0[1], _y, _s);
			_d1[0] = overlay_x(_d1[0], _x, _s); _d1[1] = overlay_y(_d1[1], _y, _s);
			_d2[0] = overlay_x(_d2[0], _x, _s); _d2[1] = overlay_y(_d2[1], _y, _s);
			_d3[0] = overlay_x(_d3[0], _x, _s); _d3[1] = overlay_y(_d3[1], _y, _s);
			_rr[0] = overlay_x(_rr[0], _x, _s); _rr[1] = overlay_y(_rr[1], _y, _s);
			
			anchors[index] = {
				cx: _cx,
				cy: _cy,
				d0: _d0,
				d1: _d1,
				d2: _d2,
				d3: _d3,
				rr: _rr,
				
				rot: _rot,
			}
		}
		
		for(var i = 0; i < amo; i++) {
			var vis = array_safe_get(_vis, i);
			var sel = array_safe_get(_sel, i);
			if(!vis) continue;
			if(!sel) continue;
			
			var index = input_fix_len + i * data_length;
			var _surf = array_safe_get(current_data, index);
			if(!_surf || is_array(_surf)) continue;
			
			var _bone = inputs[| index].extra_data.bone_id;
			if(!ds_map_exists(boneMap, _bone))
				continue;
			
			var a = anchors[index];
			
			if(surface_selecting == index) {
				var _ri = 0;
				var _si = 0;
				
				if(point_in_circle(_mx, _my, a.d3[0], a.d3[1], 12)) {
					hovering = index;
					hovering_type = NODE_COMPOSE_DRAG.scale;
					_si = 1;
				} else if(point_in_rectangle_points(_mx, _my, a.d0[0], a.d0[1], a.d1[0], a.d1[1], a.d2[0], a.d2[1], a.d3[0], a.d3[1])) {
					hovering = index;
					hovering_type = NODE_COMPOSE_DRAG.move;
				} else if(point_in_circle(_mx, _my, a.rr[0], a.rr[1], 12)) {
					hovering = index;
					hovering_type = NODE_COMPOSE_DRAG.rotate;
					_ri = 1;
				}
				
				draw_sprite_colored(THEME.anchor_rotate, _ri, a.rr[0], a.rr[1],, a.rot);
				draw_sprite_colored(THEME.anchor_scale,  _si, a.d3[0], a.d3[1],, a.rot);
			} else if(point_in_rectangle_points(_mx, _my, a.d0[0], a.d0[1], a.d1[0], a.d1[1], a.d2[0], a.d2[1], a.d3[0], a.d3[1])) {
				hovering = index;
				hovering_type = NODE_COMPOSE_DRAG.move;
			}
		}
		
		if(mouse_press(mb_left, active))
			surface_selecting = hovering;
				
		if(hovering != noone) {
			var a = anchors[hovering];
			
			draw_set_color(COLORS.node_composite_overlay_border);
			draw_line(a.d0[0], a.d0[1], a.d1[0], a.d1[1]);
			draw_line(a.d0[0], a.d0[1], a.d2[0], a.d2[1]);
			draw_line(a.d3[0], a.d3[1], a.d1[0], a.d1[1]);
			draw_line(a.d3[0], a.d3[1], a.d2[0], a.d2[1]);
		}
				
		if(surface_selecting != noone) {
			var a = anchors[surface_selecting];
			
			draw_set_color(COLORS._main_accent);
			draw_line(a.d0[0], a.d0[1], a.d1[0], a.d1[1]);
			draw_line(a.d0[0], a.d0[1], a.d2[0], a.d2[1]);
			draw_line(a.d3[0], a.d3[1], a.d1[0], a.d1[1]);
			draw_line(a.d3[0], a.d3[1], a.d2[0], a.d2[1]);
		}
		
		if(hovering != noone && hovering_type != noone && mouse_press(mb_left, active)) {
			var a = anchors[hovering];
			
			if(hovering_type == NODE_COMPOSE_DRAG.move) { //move
				surf_dragging	= hovering;
				drag_type		= hovering_type;
				dragging_sx		= _tran[TRANSFORM.pos_x];
				dragging_sy		= _tran[TRANSFORM.pos_y];
				dragging_mx		= mx;
				dragging_my		= my;
			} else if(hovering_type == NODE_COMPOSE_DRAG.rotate) { //rot
				surf_dragging	= hovering;
				drag_type		= hovering_type;
				dragging_sx		= _tran[TRANSFORM.rot];
				rot_anc_x		= overlay_x(a.cx, _x, _s);
				rot_anc_y		= overlay_y(a.cy, _y, _s);
				dragging_mx		= point_direction(rot_anc_x, rot_anc_y, _mx, _my);
			} else if(hovering_type == NODE_COMPOSE_DRAG.scale) { //sca
				surf_dragging	= hovering;
				drag_type		= hovering_type;
				dragging_mx		= (a.d0[0] + a.d3[0]) / 2;
				dragging_my		= (a.d0[1] + a.d3[1]) / 2;
			}
		}
		
		if(layer_remove > -1) {
			deleteLayer(layer_remove);
			layer_remove = -1;
		}
	#endregion
	}
	
	static step = function() {
		var _dim_type = getSingleValue(1);
		inputs[| 2].setVisible(_dim_type == COMPOSE_OUTPUT_SCALING.constant);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 1) return atlas_data;
		if(_output_index == 2) return bind_data;
		if(_output_index == 0 && _array_index == 0) {
			atlas_data = [];
			bind_data  = [];
		}
		
		var _dim  = _data[0];
		var _bone = _data[1];
		var _bind = _data[2];
		
		var _dpos = _data[3];
		var _dsca = _data[4];
		var cDep  = attrDepth();
		
		setBone();
		
		//////////////////////////////////////////
		
		overlay_w = _dim[0];
		overlay_h = _dim[1];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], cDep);
		
		for(var i = 0; i < 2; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], surface_get_width(_outSurf), surface_get_height(_outSurf), cDep);
			
			surface_set_target(temp_surface[i]);
			DRAW_CLEAR
			surface_reset_target();
		}
		
		var use_data  = _bind != noone;
		var res_index = 0;
		var bg		  = 0;
		var imageAmo  = use_data? array_length(_bind) : (ds_list_size(inputs) - input_fix_len) / data_length;
		var _vis	  = attributes.layer_visible;
		
		surface_set_shader(_outSurf, sh_sample, true, BLEND.alphamulp);
		
		for(var i = 0; i < imageAmo; i++) {
			var vis  = array_safe_get(_vis, i, true);
			if(!vis) continue;
			
			var datInd = input_fix_len + i * data_length;
			var _s     = use_data? _bind[i].surface.get() : _data[datInd];
			if(!is_surface(_s)) continue;
			
			var _b = use_data? _bind[i].bone : inputs[| datInd].extra_data.bone_id;
			
			if(!ds_map_exists(boneMap, _b)) {
				//print($"Bone not exist {_bone} from map {ds_map_size(boneMap)}")
				continue;
			}
			_b = boneMap[? _b];
			
			var _tran = use_data? _bind[i].transform : _data[datInd + 1];
			var _aang = _data[datInd + 2];
			var _rot  = _aang * _b.angle + _tran[TRANSFORM.rot];
			var _anc  = _b.getPoint(0.5);
			var _mov  = point_rotate(_tran[TRANSFORM.pos_x], _tran[TRANSFORM.pos_y], 0, 0, _b.angle);
			var _sca  = [ _tran[TRANSFORM.sca_x], _tran[TRANSFORM.sca_y] ];
			
			var _ww = surface_get_width(_s);
			var _hh = surface_get_height(_s);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var _cen = point_rotate(-_sw / 2, -_sh / 2, 0, 0, _rot);
			var _pos  = [ 
				(_anc.x * _dsca) + _cen[0] + _mov[0] + _dpos[0], 
				(_anc.y * _dsca) + _cen[1] + _mov[1] + _dpos[1]
			];
			
			shader_set_interpolation(_s);
			
			array_push(atlas_data, new SurfaceAtlas(_s, _pos, _rot, _sca));
			array_push(bind_data, {
				surface: new Surface(_s),
				bone: _b.ID,
				transform: _tran
			});
			draw_surface_ext_safe(_s, _pos[0], _pos[1], _sca[0], _sca[1], _rot);
		}
		
		surface_reset_shader();
		
		return _outSurf;
	}
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		var load_fix_len = input_fix_len;
		var amo = (array_length(_inputs) - load_fix_len) / data_length;
		
		if(PROJECT.version < 11481) {
			var _idx = [];
			for( var i = load_fix_len, n = array_length(_inputs); i < n; i += 2 )
				array_append(_idx, i + 3);
			
			for( var i = array_length(_idx) - 1; i >= 0; i++ ) 
				array_insert(load_map.inputs, _idx[i], noone);
		}
		
		if(PROJECT.version < 11470) {
			array_insert(load_map.inputs, 3, noone);
			array_insert(load_map.inputs, 4, noone);
			load_fix_len = 3;
		}
		
		repeat(amo) createNewSurface();
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
	
	static doApplyDeserialize = function() {
		setBone();
	}
}

