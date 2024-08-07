function __armature_bind_data(_surface, _bone, _tran, _aang, _pang, _asca, _psca) constructor {
	surface   =	new Surface(_surface);
	bone      = _bone.ID;
	transform =	_tran;
	applyRot  =	_aang;
	applyRotl =	_pang;
	applySca  =	_asca;
	applyScal = _psca;
}

function Node_Armature_Bind(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Armature Bind";
	batch_output = false;
	
	inputs[| 0] = nodeValue_Dimension(self);
	
	inputs[| 1] = nodeValue_Armature("Armature", self, noone)
		.setVisible(true, true)
		.rejectArray();
		
	inputs[| 2] = nodeValue_Struct("Bind data", self, noone)
		.setVisible(true, true)
		.setArrayDepth(1); 
		
	inputs[| 3] = nodeValue_Vector("Bone transform", self, [ 0, 0 ]);
		
	inputs[| 4] = nodeValue_Float("Bone scale", self, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0.1, 2, 0.01 ] });
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue_Output("Atlas data", self, VALUE_TYPE.surface, [])
		.rejectArrayProcess();
	
	outputs[| 2] = nodeValue_Output("Bind data", self, VALUE_TYPE.struct, [])
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
		var amo   = min(ds_list_size(inputs) - data_length, array_length(current_data));
		var _bind = getSingleValue(2);
		var use_data = _bind != noone;
		
		for(var i = input_fix_len; i < amo; i += data_length) {
			index++;
			var _surf = current_data[i];
			var _id   = inputs[| i].display_data.bone_id;
			if(_id == "") continue;
			
			if(ds_map_exists(surfMap, _id))
				array_push(surfMap[? _id], [ index, _surf ]);
			else
				surfMap[? _id] = [ [ index, _surf ] ];
		}
		
		#region draw bones
			var _b  = bone;
			if(_b == noone) return 0;
			var amo = _b.childCount();
			var _hh = ui(28);
			var bh  = ui(32 + 16) + amo * _hh;
			var ty  = _y;
			
			draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_x + ui(16), ty + ui(4), __txt("Bones"));
			
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
						var _sw = surface_get_width_safe(_surf);
						var _sh = surface_get_height_safe(_surf);
						var _ss = (_hh - 8) / _sh;
							
						draw_surface_ext_safe(_surf, _sx, _sy, _ss, _ss, 0, c_white, 1);
							
						if(_hover && point_in_rectangle(_m[0], _m[1], _sx, _sy, _sx + _sw * _ss, _sy + _sh * _ss)) {
							TOOLTIP = [ _surf, VALUE_TYPE.surface ];
							if(mouse_press(mb_left, _focus)) {
								layer_dragging = _sid;
								inputs[| input_fix_len + _sid * data_length].display_data.bone_id = "";
							}
								
							draw_set_color(COLORS._main_accent);
						} else 
							draw_set_color(COLORS.node_composite_bg);
						draw_rectangle(_sx, _sy, _sx + _sw * _ss, _sy + _sh * _ss, true);
							
						_sx += _sw * _ss + 4;
					}
				}
					
				if(point_in_rectangle(_m[0], _m[1], _x, ty, _x + _w, ty + _hh - 1)) {
					if(layer_dragging != noone) {
						draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, ty, _w, _hh, COLORS._main_accent, 1);
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
				inputs[| _lind].display_data.bone_id = hovering.ID;
				
				layer_dragging = noone;
				triggerRender();
			}
			
			if(layer_dragging != noone && !hovering)
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _ty, _w, bh - ui(32), COLORS._main_accent, 1);
		#endregion
		
		var amo = floor((ds_list_size(inputs) - input_fix_len) / data_length);
		if(array_length(current_data) != ds_list_size(inputs)) return 0;
		
		if(use_data) {
			layer_renderer.h = bh + ui(8);
			return layer_renderer.h;
		}
		
		var ty = _y + bh + ui(8);
		
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
		draw_text_add(_x + ui(16), ty + ui(4), __txt("Surfaces"));
			
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
			var index = amo;
			
			for(var i = 0; i < amo; i++) {
				var _inp  = input_fix_len + (amo - i - 1) * data_length;
				var _surf = current_data[_inp];
				
				index--;
				var _bx = _x + _w - 24;
				var _cy = ly + index * (lh + 4);
				
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 16)) {
					draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_value_negative);
				
					if(mouse_press(mb_left, _focus))
						layer_remove = index;
				} else 
					draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_icon);
				
				_bx -= 32;
				
				//if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, 16)) {
				//	draw_sprite_ui_uniform(THEME.reset_16, 3, _bx, _cy + lh / 2, 1, COLORS._main_value_negative);
				
				//	if(mouse_press(mb_left, _focus))
				//		resetTransform(i);
				//} else 
				//	draw_sprite_ui_uniform(THEME.reset_16, 3, _bx, _cy + lh / 2, 1, COLORS._main_icon);
				
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
						_vis[index] = hold_visibility;
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
						_sel[index] = hold_select;
				} else 
					draw_sprite_ui_uniform(THEME.cursor_select, sel, _bx, _cy + lh / 2, 1, COLORS._main_icon, 0.5 + 0.5 * sel);
			
				draw_set_color(COLORS.node_composite_bg);
				var _sx0 = _bx + 24;
				var _sx1 = _sx0 + ssh;
				var _sy0 = _cy + 3;
				var _sy1 = _sy0 + ssh;
				draw_rectangle(_sx0, _sy0, _sx1, _sy1, true);
			
				var _ssw = surface_get_width_safe(_surf);
				var _ssh = surface_get_height_safe(_surf);
				var _sss = min(ssh / _ssw, ssh / _ssh);
				draw_surface_ext_safe(_surf, _sx0, _sy0, _sss, _sss, 0, c_white, 1);
			
				draw_set_text(f_p1, fa_left, fa_center, hover? COLORS._main_text : COLORS._main_text);
				draw_set_alpha(aa);
				draw_text(_sx1 + 12, _cy + lh / 2, inputs[| _inp].name);
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
				
				var binded = inputs[| _inp].display_data.bone_id != "";
				
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
		
		if(layer_dragging != noone && mouse_release(mb_left)) { #region
			if(layer_dragging != hoverIndex && hoverIndex != noone) {
				var index = input_fix_len + layer_dragging * data_length;
				var targt = input_fix_len + hoverIndex * data_length;
				var _vis  = attributes.layer_visible;
				var _sel  = attributes.layer_selectable;
				
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
		} #endregion
		
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
		
		doUpdate();
	}
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		
		inputs[| index + 0] = nodeValue_Surface("Surface", self);
		inputs[| index + 0].surface_index = index;
		inputs[| index + 0].hover_effect  = 0;
		inputs[| index + 0].display_data.bone_id = "";
		
		inputs[| index + 1] = nodeValue_Float("Transform", self, [ 0, 0, 0, 1, 1 ] )
			.setDisplay(VALUE_DISPLAY.transform);
		inputs[| index + 2] = nodeValue_Bool("Inherit Rotation", self, true );
		inputs[| index + 3] = nodeValue_Bool("Apply Bone Rotation", self, false );
		
		inputs[| index + 4] = nodeValue_Bool("Inherit Scale", self, false );
		inputs[| index + 5] = nodeValue_Bool("Apply Bone Scale", self, false );
		
		for( var i = 0; i < data_length; i++ )
			array_push(input_display_list, index + i);
		
		while(_s >= array_length(attributes.layer_visible))
			array_push(attributes.layer_visible, true);
		while(_s >= array_length(attributes.layer_selectable))
			array_push(attributes.layer_selectable, true);
		
		return inputs[| index + 0];
	} setDynamicInput(6);
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	blend_temp_surface = temp_surface[2];
	
	surf_dragging = -1;
	drag_type   = 0;
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
	
	static getInputIndex = function(index) { #region
		if(index < input_fix_len) return index;
		return input_fix_len + (index - input_fix_len) * data_length;
	} #endregion
	
	static setBone = function() { #region
		ds_map_clear(boneMap);
		
		var _b = getInputData(1);
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
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var dim   = getInputData(0);
		var _bind = getInputData(2);
		
		var _dpos = getInputData(3);
		var _dsca = getInputData(4);
		
		if(bone == noone) return;
		
		bone.draw(attributes, false, _x + _dpos[0] * _s, _y + _dpos[1] * _s, _s * _dsca, _mx, _my, anchor_selecting);
		inputs[| 3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		//inputs[| 4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
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
		
		if(surf_dragging > -1) { #region
			var _surf = current_data[surf_dragging + 0];
			var _tran = current_data[surf_dragging + 1];
			var _aang = current_data[surf_dragging + 2];
			var _pang = current_data[surf_dragging + 3];
			var _asca = current_data[surf_dragging + 4];
			var _psca = current_data[surf_dragging + 5];
			
			_tran = array_clone(_tran);
			
			var _bone = inputs[| surf_dragging].display_data.bone_id;
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
				var _rot = _aang * (_pang? _bone.angle : _bone.pose_local_angle) + _tran[TRANSFORM.rot];
				var _sw = surface_get_width_safe(_surf);
				var _sh = surface_get_height_safe(_surf);
				
				var _p = point_rotate(_mx - dragging_mx, _my - dragging_my, 0, 0, -_rot);
				var sca_x = _p[0] / _s / _sw * 2;
				var sca_y = _p[1] / _s / _sh * 2;
				
				if(key_mod_press(SHIFT)) {
					sca_x = min(sca_x, sca_y);
					sca_y = sca_x;
				}
				
				if(_asca) {
					sca_x /= _psca? _bone.pose_scale : _bone.pose_local_scale;
					sca_y /= _psca? _bone.pose_scale : _bone.pose_local_scale;
				}
				
				_tran[TRANSFORM.sca_x] = sca_x;
				_tran[TRANSFORM.sca_y] = sca_y;
			}
			
			if(inputs[| surf_dragging + 1].setValue(_tran))
				UNDO_HOLDING = true;	
			
			if(mouse_release(mb_left)) {
				surf_dragging = -1;
				UNDO_HOLDING = false;
			}
		} #endregion
		
		var hovering = noone;
		var hovering_type = noone;
		var _vis = attributes.layer_visible;
		var _sel = attributes.layer_selectable;
		
		var amo = (ds_list_size(inputs) - input_fix_len) / data_length;
		var anchors = array_create(ds_list_size(inputs));
		
		for(var i = 0; i < amo; i++) { #region
			var index = input_fix_len + i * data_length;
			var _surf = array_safe_get_fast(current_data, index);
			if(!_surf || is_array(_surf)) continue;
			
			var _bone = inputs[| index].display_data.bone_id;
			if(!ds_map_exists(boneMap, _bone)) {
				//print($"Bone not found {_bone}");
				continue;
			}
			_bone = boneMap[? _bone];
			
			var _tran = current_data[index + 1];
			var _aang = current_data[index + 2];
			var _pang = current_data[index + 3];
			var _asca = current_data[index + 4];
			var _psca = current_data[index + 5];
			
			var _rot  = _aang * (_pang? _bone.angle : _bone.pose_local_angle) + _tran[TRANSFORM.rot];
			var _anc  = _bone.getPoint(0.5);
			var _mov  = point_rotate(_tran[TRANSFORM.pos_x], _tran[TRANSFORM.pos_y], 0, 0, _bone.angle);
			var _sca  = [ _tran[TRANSFORM.sca_x], _tran[TRANSFORM.sca_y] ];
			if(_asca) {
				_sca[0] *= _psca? _bone.pose_scale : _bone.pose_local_scale;
				_sca[1] *= _psca? _bone.pose_scale : _bone.pose_local_scale;
			}
			
			var _ww = surface_get_width_safe(_surf);
			var _hh = surface_get_height_safe(_surf);
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
		} #endregion
		
		for(var i = 0; i < amo; i++) { #region
			var vis = array_safe_get_fast(_vis, i);
			var sel = array_safe_get_fast(_sel, i);
			if(!vis) continue;
			if(!sel) continue;
			
			var index = input_fix_len + i * data_length;
			var _surf = array_safe_get_fast(current_data, index);
			if(!_surf || is_array(_surf)) continue;
			
			var _bone = inputs[| index].display_data.bone_id;
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
			} else if(point_in_rectangle_points(_mx, _my, a.d0[0], a.d0[1], a.d1[0], a.d1[1], a.d2[0], a.d2[1], a.d3[0], a.d3[1]) && 
				(surface_selecting != hovering || surface_selecting == noone)) {
				
				hovering = index;
				hovering_type = NODE_COMPOSE_DRAG.move;
			}
		} #endregion
		
		if(mouse_press(mb_left, active))
			surface_selecting = hovering;
		if(surface_selecting != noone) {
			var a = array_safe_get_fast(anchors, surface_selecting, noone);
			if(!is_struct(a)) surface_selecting = noone;
		}
		
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
		
		if(hovering != noone && hovering_type != noone && mouse_press(mb_left, active)) { #region
			var _tran = current_data[hovering + 1];
			var _aang = current_data[hovering + 2];
			var _asca = current_data[hovering + 3];
			
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
		} #endregion
		
		if(layer_remove > -1) {
			deleteLayer(layer_remove);
			layer_remove = -1;
		}
	} #endregion
	
	static step = function() { #region
		var _dim_type = getSingleValue(1);
		inputs[| 2].setVisible(_dim_type == COMPOSE_OUTPUT_SCALING.constant);
		
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i += data_length ) {
			inputs[| i + 3].setVisible(current_data[i + 2]);
			inputs[| i + 5].setVisible(current_data[i + 4]);
		}
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
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
		
		for(var i = 0; i < 3; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], cDep);
			surface_clear(temp_surface[i]);
		}
		
		var use_data  = _bind != noone;
		var res_index = 0;
		var bg		  = 0;
		var imageAmo  = use_data? array_length(_bind) : (ds_list_size(inputs) - input_fix_len) / data_length;
		var _vis	  = attributes.layer_visible;
		var _bg  = 0, _s;
		
		for(var i = 0; i < imageAmo; i++) {
			var vis  = array_safe_get_fast(_vis, i, true);
			if(!vis) continue;
			
			var datInd = input_fix_len + i * data_length;
			_s = noone;
			
			if(use_data) {
				var _bindData = array_safe_get(_bind, i);
				if(is_instanceof(_bindData, __armature_bind_data))
					_s = _bindData.surface.get();
					
			} else {
				_s = array_safe_get(_data, datInd);
			}
			
			if(!is_surface(_s)) continue;
			
			var _b = use_data? _bind[i].bone : inputs[| datInd].display_data.bone_id;
			
			if(!ds_map_exists(boneMap, _b))
				continue;
			
			_b = boneMap[? _b];
			
			var _tran = use_data? _bind[i].transform : _data[datInd + 1];
			var _aang = use_data? _bind[i].applyRot  : _data[datInd + 2];
			var _pang = use_data? _bind[i].applyRotl : _data[datInd + 3];
			var _asca = use_data? _bind[i].applySca  : _data[datInd + 4];
			var _psca = use_data? _bind[i].applyScal : _data[datInd + 5];
			
			var _rot  = _aang * (_pang? _b.angle : _b.pose_local_angle) + _tran[TRANSFORM.rot];
			var _anc  = _b.getPoint(0.5);
			var _mov  = point_rotate(_tran[TRANSFORM.pos_x], _tran[TRANSFORM.pos_y], 0, 0, _b.angle);
			var _sca  = [ _tran[TRANSFORM.sca_x], _tran[TRANSFORM.sca_y] ];
			if(_asca) {
				_sca[0] *= _psca? _b.pose_scale : _b.pose_local_scale;
				_sca[1] *= _psca? _b.pose_scale : _b.pose_local_scale;
			}
			
			var _ww = surface_get_width_safe(_s);
			var _hh = surface_get_height_safe(_s);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var _cen = point_rotate(-_sw / 2, -_sh / 2, 0, 0, _rot);
			var _pos  = [ 
				(_anc.x * _dsca) + _cen[0] + _mov[0] + _dpos[0], 
				(_anc.y * _dsca) + _cen[1] + _mov[1] + _dpos[1]
			];
			
			array_push(atlas_data, new SurfaceAtlas(_s, _pos[0], _pos[1], _rot, _sca[0], _sca[1]));
			array_push(bind_data,  new __armature_bind_data(_s, _b, _tran, _aang, _pang, _asca, _psca));
			
			surface_set_shader(temp_surface[_bg], sh_sample, true, BLEND.alphamulp);
				blend_temp_surface = temp_surface[2];
				draw_surface_blend_ext(temp_surface[!_bg], _s, _pos[0], _pos[1], _sca[0], _sca[1], _rot);
			surface_reset_shader();
			
			_bg = !_bg;
		}
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], cDep);
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
	
	static resetTransform = function(surfIndex) { #region
		var _bind = getInputData(2);
		var use_data = _bind != noone;
		
		var _surf = getInputData(surfIndex + 0);
		var _tran = getInputData(surfIndex + 1);
		var _arot = getInputData(surfIndex + 2);
		
		var _b = use_data? _bind[i].bone : inputs[| surfIndex].display_data.bone_id;
		if(!ds_map_exists(boneMap, _b)) return;
		
		_b = boneMap[? _b];
		
		var _cx  = surface_get_width_safe(_surf)  / 2;
		var _cy  = surface_get_height_safe(_surf) / 2;
		
		var _anc = _b.getPoint(0.5);
		var _rot = _arot? -_b.angle : 0;
		
		var _tr  = [ _cx - _anc.x, _cy - _anc.y, _rot, 1, 1 ];
		inputs[| surfIndex + 1].setValue(_tr);
	} #endregion
	
	static attributeSerialize = function() { #region
		var att = {};
		att.layer_visible    = attributes.layer_visible;
		att.layer_selectable = attributes.layer_selectable;
		
		return att;
	} #endregion
	
	static attributeDeserialize = function(attr) { #region
		struct_append(attributes, attr); 
		
		if(struct_has(attributes, "use_project_dimension") && !struct_has(attr, "use_project_dimension"))
			attributes.use_project_dimension = false;
			
		if(struct_has(attr, "layer_visible"))
			attributes.layer_visible = attr.layer_visible;
			
		if(struct_has(attr, "layer_selectable"))
			attributes.layer_selectable = attr.layer_selectable;
	} #endregion
	
	static doApplyDeserialize = function() { #region
		setBone();
	} #endregion
}

