#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Armature_Bind", "Pose", "P");		
		
		hotkeyCustom("Node_Armature_Bind", "Move Selection",   "G");		
		hotkeyCustom("Node_Armature_Bind", "Rotate Selection", "R");		
		hotkeyCustom("Node_Armature_Bind", "Scale Selection",  "S");		
	});
	
	function armature_bind_tool_move(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		surface_selecting = noone;
		
		drag_trans = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			if(node.surface_selecting == noone) return;
			
			surface_selecting = node.surface_selecting;
			activeKeyboard = true;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			var _val   = node.inputs[surface_selecting + 1].getValue();
			drag_trans = array_clone(_val);
			drag_axis  = -1;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var  val  = array_clone(drag_trans);
			var _bone = array_safe_get(node.boneIDMap, (surface_selecting - node.input_fix_len) / node.data_length, "");
			    _bone = node.boneMap[$ _bone];
			    
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
		    var _dx = KEYBOARD_NUMBER ?? (_mx - drag_pmx);
			var _dy = KEYBOARD_NUMBER ?? (_my - drag_pmy);
			
			var _p  = point_rotate(_dx, _dy, 0, 0, -_bone.pose_angle);
			
			if(drag_axis == 0 || drag_axis == -1) val[0] = drag_trans[0] + _p[0] / PANEL_PREVIEW.canvas_s;
			if(drag_axis == 1 || drag_axis == -1) val[1] = drag_trans[1] + _p[1] / PANEL_PREVIEW.canvas_s;
			
			// draw_set_color(COLORS._main_icon);
			// if(drag_axis == 0) draw_line_dashed(0, _y + drag_trans[1] * _s, WIN_H, _y + drag_trans[1] * _s);
			// if(drag_axis == 1) draw_line_dashed(_x + drag_trans[0] * _s, 0, _x + drag_trans[0] * _s, WIN_W);
			
			if(node.inputs[surface_selecting + 1].setValue(val))
				UNDO_HOLDING = true;
			
			if(key_press(ord("X"))) {
				drag_axis = drag_axis == 0? -1 : 0;
				KEYBOARD_STRING = "";
			}
			
			if(key_press(ord("Y"))) {
				drag_axis = drag_axis == 1? -1 : 1;
				KEYBOARD_STRING = "";
			}
				
			if(mouse_press(mb_left) || key_press(vk_enter)) {
				activeKeyboard = false;
				UNDO_HOLDING   = false;
				PANEL_PREVIEW.resetTool();
			}
			
			var _tooltipText = "Dragging";
			switch(drag_axis) {
				case 0 : _tooltipText += " X"; break;
				case 1 : _tooltipText += " Y"; break;
			}
			
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
	function armature_bind_tool_rotate(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		surface_selecting = noone;
		
		drag_trans = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis  = -1;
		rotate_acc = 0;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			if(node.surface_selecting == noone) return;
			
			surface_selecting = node.surface_selecting;
			activeKeyboard = true;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			var _val   = node.inputs[surface_selecting + 1].getValue();
			drag_trans = array_clone(_val);
			drag_axis  = -1;
			rotate_acc = 0;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var  val  = array_clone(drag_trans);
			var _bone = array_safe_get(node.boneIDMap, (surface_selecting - node.input_fix_len) / node.data_length, "");
			    _bone = node.boneMap[$ _bone];
			    
			var _data = node.draw_data[surface_selecting];
			var _px = _x + _data.cx * _s;
			var _py = _y + _data.cy * _s;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var _d0 = point_direction(_px, _py, drag_pmx, drag_pmy);
			var _d1 = point_direction(_px, _py, _mx, _my);
			
			drag_pmx = _mx;
			drag_pmy = _my;
			
			rotate_acc += angle_difference(_d1, _d0);
			var _rr = drag_trans[TRANSFORM.rot] + (KEYBOARD_NUMBER ?? rotate_acc);
			val[TRANSFORM.rot] = _rr;
			
			draw_set_color(COLORS._main_icon);
			draw_circle_prec(_px, _py, ui(64), true);
			
			if(node.inputs[surface_selecting + 1].setValue(val))
				UNDO_HOLDING = true;
			
			if(mouse_press(mb_left) || key_press(vk_enter)) {
				activeKeyboard = false;
				UNDO_HOLDING   = false;
				PANEL_PREVIEW.resetTool();
			}
			
			var _tooltipText = "Rotating";
			
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
	function armature_bind_tool_scale(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		surface_selecting = noone;
		
		drag_trans = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			if(node.surface_selecting == noone) return;
			
			surface_selecting = node.surface_selecting;
			activeKeyboard = true;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			var _val   = node.inputs[surface_selecting + 1].getValue();
			drag_trans = array_clone(_val);
			drag_axis  = -1;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var  val  = array_clone(drag_trans);
			var _bone = array_safe_get(node.boneIDMap, (surface_selecting - node.input_fix_len) / node.data_length, "");
			    _bone = node.boneMap[$ _bone];
			    
			var _data = node.draw_data[surface_selecting];
			var _px = _x + _data.cx * _s;
			var _py = _y + _data.cy * _s;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
		    var _ss = point_distance(_mx, _my, _px, _py) / point_distance(drag_pmx, drag_pmy, _px, _py);
			var _sx = KEYBOARD_NUMBER ?? (key_mod_press(SHIFT)? (_mx - _px) / (drag_pmx - _px) : _ss);
			var _sy = KEYBOARD_NUMBER ?? (key_mod_press(SHIFT)? (_my - _py) / (drag_pmy - _py) : _ss);
			
			if(drag_axis == 0 || drag_axis == -1) val[TRANSFORM.sca_x] = drag_trans[TRANSFORM.sca_x] * _sx;
			if(drag_axis == 1 || drag_axis == -1) val[TRANSFORM.sca_y] = drag_trans[TRANSFORM.sca_y] * _sy;
			
			// draw_set_color(COLORS._main_icon);
			// if(drag_axis == 0) draw_line_dashed(0, _y + drag_trans[1] * _s, WIN_H, _y + drag_trans[1] * _s);
			// if(drag_axis == 1) draw_line_dashed(_x + drag_trans[0] * _s, 0, _x + drag_trans[0] * _s, WIN_W);
			
			if(node.inputs[surface_selecting + 1].setValue(val))
				UNDO_HOLDING = true;
			
			if(key_press(ord("X"))) {
				drag_axis = drag_axis == 0? -1 : 0;
				KEYBOARD_STRING = "";
			}
			
			if(key_press(ord("Y"))) {
				drag_axis = drag_axis == 1? -1 : 1;
				KEYBOARD_STRING = "";
			}
				
			if(mouse_press(mb_left) || key_press(vk_enter)) {
				activeKeyboard = false;
				UNDO_HOLDING   = false;
				PANEL_PREVIEW.resetTool();
			}
			
			var _tooltipText = "Dragging";
			switch(drag_axis) {
				case 0 : _tooltipText += " X"; break;
				case 1 : _tooltipText += " Y"; break;
			}
			
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
#endregion

function __armature_bind_data(_surface, _bone = noone, _tran = 0, _aang = 0, _pang = 0, _asca = 0, _psca = 0) constructor {
	surface   =	is_struct(_surface)? _surface : new Surface(_surface);
	bone      = _bone == noone? noone : _bone.ID;
	transform =	_tran;
	applyRot  =	_aang;
	applyRotl =	_pang;
	applySca  =	_asca;
	applyScal = _psca;
}

function Node_Armature_Bind(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Armature Bind";
	preview_select_surface = false;
	
	newInput(1, nodeValue_Armature()).setVisible(true, true).rejectArray();
	newInput(2, nodeValue_Struct("Bind data", noone)).setVisible(true, true).shortenDisplay().setArrayDepth(1); 
	
	////- =Output
	newInput(0, nodeValue_Dimension());
	
	////- =Armature
	newInput(3, nodeValue_Vec2(   "Bone transform", [0,0] ));
	newInput(4, nodeValue_Slider( "Bone scale",      1, [.1,2,.01] ));
	// inputs 5
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Atlas data",  VALUE_TYPE.atlas,   []    )).rejectArrayProcess();
	newOutput(2, nodeValue_Output( "Bind data",   VALUE_TYPE.struct,  []    )).shortenDisplay().setArrayDepth(1);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	////- Layers
	
	attributes.layer_visible	= [];
	attributes.layer_selectable = [];
	
	__node_bone_attributes();
	
	hold_visibility = true;
	hold_select		= true;
	_layer_dragging	= noone;
	_layer_drag_y	= noone;
	layer_dragging	= noone;
	layer_remove	= -1;
	
	hoverIndex      = noone;
	
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		surfMap = {};
		
		var amo      = min(array_length(inputs) - data_length, array_length(current_data));
		var _bind    = getSingleValue(2);
		var use_data = _bind != noone;
		var _surfAmo = getInputAmount();
		
		for(var i = 0; i < _surfAmo; i++) {
			var _surf = getInputData(input_fix_len + i * data_length);
			var _id   = array_safe_get(boneIDMap, i, "");
			if(_id == "") continue;
			
			if(!struct_exists(surfMap, _id)) surfMap[$ _id] = [];
			array_push(surfMap[$ _id], [ i, _surf ]);
		}
		
		#region draw bones
			if(!is(bone, __Bone)) return 0;
			
			var _b  = bone;
			var amo = _b.childCount();
			var _hh = ui(28);
			var bh  = ui(32 + 16) + amo * _hh;
			var ty  = _y;
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_x + ui(16), ty + ui(4), __txt("Bones"));
			ty += ui(28);
		
			var _ty = ty;
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, bh - ui(32), COLORS.node_composite_bg_blend, 1);
			
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
					ds_stack_push(_bst, [ _bone.childs[i], __x + ui(16), __w - ui(16) ]);
					
				if(_bone.is_main) continue;
				
				draw_sprite_ui(THEME.bone, _bone.getSpriteIndex(), __x + ui(12), ty + ui(14),,,, COLORS._main_icon);
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(__x + ui(24), ty + ui(12), _bone.name);
				
				if(struct_exists(surfMap, _bone.ID)) {
					var _sdata = surfMap[$ _bone.ID];
						
					var _sx = __x + ui(24) + string_width(_bone.name) + ui(8);
					var _sy = ty + ui(4);
						
					for( var i = 0, n = array_length(_sdata); i < n; i++ ) {
						var _sid  = _sdata[i][0];
						var _surf = _sdata[i][1];
						var _sw = surface_get_width_safe(_surf);
						var _sh = surface_get_height_safe(_surf);
						var _ss = (_hh - ui(8)) / _sh;
							
						draw_surface_ext_safe(_surf, _sx, _sy, _ss, _ss, 0, c_white, 1);
							
						if(_hover && point_in_rectangle(_m[0], _m[1], _sx, _sy, _sx + _sw * _ss, _sy + _sh * _ss)) {
							TOOLTIP = [ _surf, VALUE_TYPE.surface ];
							if(mouse_press(mb_left, _focus)) {
								layer_dragging  = _sid;
								boneIDMap[_sid] = "";
							}
								
							draw_set_color(COLORS._main_accent);
							draw_sprite_stretched_add(THEME.box_r2, 1, _sx, _sy, _sw * _ss, _sh * _ss, COLORS._main_accent, 1);
							
						} else {
							draw_set_color(COLORS.node_composite_bg);
							draw_sprite_stretched_add(THEME.box_r2, 1, _sx, _sy, _sw * _ss, _sh * _ss, COLORS._main_icon, .3);
						}
				
						_sx += _sw * _ss + ui(4);
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
				
				if(!ds_stack_empty(_bst)) {
					draw_set_color(COLORS.node_composite_separator);
					draw_line(_x + ui(16), ty, _x + _w - ui(16), ty);
				}
			}
			
			ds_stack_destroy(_bst);
			
			if(layer_dragging != noone && hovering && mouse_release(mb_left)) {
				boneIDMap[layer_dragging] = hovering.ID;
				layer_dragging = noone;
				triggerRender();
			}
			
			if(layer_dragging != noone && !hovering)
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _ty, _w, bh - ui(32), COLORS._main_accent, 1);
		#endregion
		
		var amo = floor((array_length(inputs) - input_fix_len) / data_length);
		if(array_length(current_data) != array_length(inputs)) return 0;
		
		if(use_data) {
			layer_renderer.h = bh + ui(8);
			return layer_renderer.h;
		}
		
		var ty = _y + bh;
		
		draw_sprite_ui(THEME.arrow, 1, _x + _w / 2, ty + ui(6), 1, 1, 0, COLORS._main_icon);
		ty += ui(16);
		
		#region draw surface
			var lh = ui(28);
			var sh = ui(4) + max(1, amo) * (lh + ui(4)) + ui(4);
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, sh, COLORS.node_composite_bg_blend, 1);
			
			var _vis = attributes.layer_visible;
			var _sel = attributes.layer_selectable;
			var ly   = ty + ui(6);
			var ssh  = lh - ui(6);
			hoverIndex = noone;
			
			layer_remove = -1;
			
			for(var i = 0; i < amo; i++) {
				var _ind   = amo - i - 1;
				var _inp   = input_fix_len + _ind * data_length;
				var _surf  = current_data[_inp];
				var _mesh  = is(_surf, RiggedMeshedSurface); 
				
				if(_mesh) _surf = _surf.getSurface();
				
				var binded = array_safe_get(boneIDMap, _ind, "") != "";
				
				var _bx = _x + _w - ui(24);
				var _cy = ly + _ind * (lh + ui(4));
				
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, ui(16))) {
					draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_value_negative);
				
					if(mouse_press(mb_left, _focus))
						layer_remove = _ind;
				} else 
					draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_icon);
				
				_bx -= ui(32);
				
				if(binded) {
					if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, ui(16))) {
						draw_sprite_ui_uniform(THEME.reset_16, 3, _bx, _cy + lh / 2, 1, COLORS._main_value_negative);
					
						if(mouse_press(mb_left, _focus))
							resetTransform(_ind);
					} else 
						draw_sprite_ui_uniform(THEME.reset_16, 3, _bx, _cy + lh / 2, 1, COLORS._main_icon);
				}
				
				if(!is_surface(_surf)) continue;
				
				var aa  = (_ind != layer_dragging || layer_dragging == noone)? 1 : 0.5;
				var vis = _vis[_ind];
				var sel = _sel[_ind];
				var hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _cy, _x + _w, _cy + lh);
				
				var _bx = _x + ui(24);
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, ui(12))) {
					draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _cy + lh / 2, 1, c_white);
				
					if(mouse_press(mb_left, _focus))
						hold_visibility = !_vis[_ind];
					
					if(mouse_click(mb_left, _focus) && _vis[_ind] != hold_visibility) {
						_vis[_ind] = hold_visibility;
						doUpdate();
					}
				} else 
					draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _cy + lh / 2, 1, COLORS._main_icon, 0.5 + 0.5 * vis);
				
				_bx += ui(24 + 1);
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, ui(12))) {
					draw_sprite_ui_uniform(THEME.cursor_select, sel, _bx, _cy + lh / 2, 1, c_white);
				
					if(mouse_press(mb_left, _focus))
						hold_select = !_sel[_ind];
					
					if(mouse_click(mb_left, _focus) && _sel[_ind] != hold_select)
						_sel[_ind] = hold_select;
				} else 
					draw_sprite_ui_uniform(THEME.cursor_select, sel, _bx, _cy + lh / 2, 1, COLORS._main_icon, 0.5 + 0.5 * sel);
				
				draw_set_color(COLORS.node_composite_bg);
				var _sx0 = _bx + ui(18);
				var _sx1 = _sx0 + ssh;
				var _sy0 = _cy + ui(3);
				var _sy1 = _sy0 + ssh;
				
				var _ssw = surface_get_width_safe(_surf);
				var _ssh = surface_get_height_safe(_surf);
				var _sss = min(ssh / _ssw, ssh / _ssh);
				var _ins = _ind == dynamic_input_inspecting;
				
				draw_surface_ext_safe(_surf, _sx0, _sy0, _sss, _sss, 0, c_white, 1);
				if(_ins) draw_sprite_stretched_add(THEME.box_r2, 1, _sx0, _sy0, ssh, ssh, COLORS._main_text_accent, 1);
				else     draw_sprite_stretched_add(THEME.box_r2, 1, _sx0, _sy0, ssh, ssh, COLORS._main_icon, .3);
				
				var tc = _ins? COLORS._main_text_accent : COLORS._main_icon;
				if(hov) tc = COLORS._main_text;
				
				var _tx = _sx1 + ui(12);
				var _ty = _cy + lh / 2;
				
				if(_mesh) {
					var _mshx = _tx + 6;
					var _mshy = _ty;
					
					draw_sprite_ext(s_node_armature_mesh, 0, _mshx, _mshy, 1, 1, 0, COLORS._main_icon, 1);
					
					_tx += ui(22);
				}
				
				var _nam = inputs[_inp].name;
				if(inputs[_inp].value_from != noone)
					_nam = inputs[_inp].value_from.node.getDisplayName();
				
				draw_set_text(f_p2, fa_left, fa_center, tc, aa);
				draw_text_add(_tx, _ty, _nam);
				draw_set_alpha(1);
				
				if(_hover && point_in_rectangle(_m[0], _m[1], _x, _cy, _x + _w, _cy + lh)) {
					hoverIndex = _ind;
					
					if(!_mesh && mouse_press(mb_left, _focus)) {
						_layer_dragging = _ind;
						_layer_drag_y	= _m[1];
						
						dynamic_input_inspecting = _ind;
						refreshDynamicDisplay();
					}
					
					if(layer_dragging != noone) {
						draw_set_color(COLORS._main_accent);
							 if(layer_dragging < _ind) draw_line_width(_x + ui(16), _cy + lh + 2, _x + _w - ui(16), _cy + lh + 2, 2);
						else if(layer_dragging > _ind) draw_line_width(_x + ui(16), _cy - 2,      _x + _w - ui(16), _cy - 2,      2);
					}
				}
			}
			
			if(_layer_dragging != noone) {
				if(abs(_m[1] - _layer_drag_y) > 4)
					layer_dragging = _layer_dragging;
			}
		#endregion
		
		if(mouse_release(mb_left)) _layer_dragging = noone;
			
		if(layer_dragging != noone && mouse_release(mb_left)) {
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
					ext[i] = inputs[index];
					array_delete(inputs, index, 1);
				}
				
				for( var i = 0; i < data_length; i++ ) {
					array_insert(inputs, targt + i, ext[i]);
				}
				
				doUpdate();
			}
			
			layer_dragging = noone;
		}
		
		layer_renderer.h = bh + ui(16) + sh;
		return layer_renderer.h;

	});
	
	input_display_list = [ 1, 2, 
		["Output",	  true], 0,
		["Armature", false], 3, 4, layer_renderer,
	];
	
	function deleteLayer(index) {
		var idx = input_fix_len + index * data_length;
		for( var i = 0; i < data_length; i++ ) {
			array_delete(inputs, idx, 1);
			array_remove(input_display_list, idx + i);
		}
		
		doUpdate();
	}
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		if(!LOADING && !APPENDING) boneIDMap = array_verify(boneIDMap, max(array_length(boneIDMap), _s + 1));
		
		newInput(index + 0, nodeValue_Surface( "Surface" ));
		newInput(index + 1, nodeValue_Float(   "Transform",     [0,0,0,1,1] )).setDisplay(VALUE_DISPLAY.transform);
		newInput(index + 2, nodeValue_Bool(    "Inherit Rotation",    true  ));
		newInput(index + 3, nodeValue_Bool(    "Apply Bone Rotation", false ));
		newInput(index + 4, nodeValue_Bool(    "Inherit Scale",       false ));
		newInput(index + 5, nodeValue_Bool(    "Apply Bone Scale",    false ));
		
		inputs[index + 0].surface_index = index;
		inputs[index + 0].hover_effect  = 0;
		
		while(_s >= array_length(attributes.layer_visible))    array_push(attributes.layer_visible,    true);
		while(_s >= array_length(attributes.layer_selectable)) array_push(attributes.layer_selectable, true);
		
		refreshDynamicDisplay();
		return inputs[index + 0];
	} 
	
	input_display_dynamic = [ 
		["Surface data", false], 0, 1, 2, 3, 4, 5, 
	];
	
	setDynamicInput(6, true, VALUE_TYPE.surface);
	
	////- Bones
	
	anchor_selecting = noone;
	selection_freeze = 0;
	
	boneMap   = {};
	surfMap   = {};
	boneIDMap = [];
	
	////- Nodes
	
	#region ---- tools ----
		tools = [
			new NodeTool( "Pose", THEME.bone_tool_pose ), 
			-1,
			new NodeTool( "Move Selection",   THEME.tools_2d_move   ).setVisible(false).setToolObject(new armature_bind_tool_move(self)),
			new NodeTool( "Rotate Selection", THEME.tools_2d_rotate ).setVisible(false).setToolObject(new armature_bind_tool_rotate(self)),
			new NodeTool( "Scale Selection",  THEME.tools_2d_scale  ).setVisible(false).setToolObject(new armature_bind_tool_scale(self)),
		]
		
		temp_surface = [ noone, noone, noone ];
		blend_temp_surface = temp_surface[2];
		
		surf_dragging = -1;
		drag_type   = 0;
		dragging_sx = 0; dragging_sy = 0;
		dragging_px = 0; dragging_py = 0;
		dragging_mx = 0; dragging_my = 0;
		dragging_ax = 0; dragging_ay = 0;
		
		rot_anc_x = 0;
		rot_anc_y = 0;
		
		overlay_w = 0;
		overlay_h = 0;
		
		draw_data  = [];
		atlas_data = [];
		bind_data  = [];
		
		__p   = [ 0, 0 ];
		__mov = [ 0, 0 ];
		__cen = [ 0, 0 ];
	
		bone = noone;
		surface_selecting = noone;
		selection_surf    = noone;
		selection_sampler = new Surface_sampler();
	#endregion
	
	attributes.select_object = false;
	array_push(attributeEditors, "Selection");
	array_push(attributeEditors, ["Content-Based", function() /*=>*/ {return attributes.select_object}, new checkBox(function() /*=>*/ {return toggleAttribute("select_object", true)})]);
	
	static getInputIndex = function(index) {
		if(index < input_fix_len) return index;
		return input_fix_len + (index - input_fix_len) * data_length;
	}
	
	static setBone = function() {
		boneMap = {};
		
		var _b = getInputData(1);
		bone = _b;
		if(!is(_b, __Bone)) return;
		
		var _bst = ds_stack_create();
		ds_stack_push(_bst, bone);
		
		while(!ds_stack_empty(_bst)) {
			var _bone = ds_stack_pop(_bst);
			
			for( var i = 0, n = array_length(_bone.childs); i < n; i++ ) {
				var child_bone = _bone.childs[i];
				boneMap[$ child_bone.ID] = child_bone;
				ds_stack_push(_bst, child_bone);
			}
		}
		
		ds_stack_destroy(_bst);
	}
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var dim   = getInputData(0);
		var panel = _params.panel;
		
		if(isUsingTool("Pose")) { 
			var _x0 = _x;
			var _y0 = _y;
			var _x1 = _x + dim[0] * _s;
			var _y1 = _y + dim[1] * _s;
			
			draw_set_color_alpha(COLORS.panel_bg_clear, .5);
				draw_rectangle(0, 0, panel.w, panel.h, false);
			draw_set_alpha(1);
			
			var _arm = inputs[1].value_from;
			return _arm != noone? _arm.node.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) : false;
		}
		
		if(!is(bone, __Bone)) return;
		
		var _bind = getInputData(2);
		var _dpos = getInputData(3);
		var _dsca = getInputData(4);
		
		bone.draw(attributes, false, _x + _dpos[0] * _s, _y + _dpos[1] * _s, _s * _dsca, _mx, _my, anchor_selecting);
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		if(_bind != noone) return w_hovering;
			
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var smx = value_snap(mx, _snx);
		var smy = value_snap(my, _sny);
		
		var ww  = dim[0];
		var hh  = dim[1];
		
		var x0 = _x, x1 = _x + ww * _s;
		var y0 = _y, y1 = _y + hh * _s;
		
		if(surf_dragging > -1) {
			hoveringWid = true;
			var _surf = current_data[surf_dragging + 0];
			var _tran = current_data[surf_dragging + 1];
			var _aang = current_data[surf_dragging + 2];
			var _pang = current_data[surf_dragging + 3];
			var _asca = current_data[surf_dragging + 4];
			var _psca = current_data[surf_dragging + 5];
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			
			_tran = array_clone(_tran);
			var _bone = array_safe_get(boneIDMap, (surf_dragging - input_fix_len) / data_length, "");
			    _bone = boneMap[$ _bone];
			
			if(drag_type == NODE_COMPOSE_DRAG.move) {
				var _dx = smx - dragging_mx;
				var _dy = smy - dragging_my;
				
				var _p  = point_rotate(_dx, _dy, 0, 0, -_bone.pose_angle);
				
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
				var _rot  = _aang * (_pang? _bone.pose_angle : _bone.pose_apply_rotate) + _tran[TRANSFORM.rot];
				var _pmx  = (smx - dragging_mx) / .5;
				var _pmy  = (smy - dragging_my) / .5;
				var _p    = point_rotate(_pmx, _pmy, 0, 0, -_rot, __p);
				var sca_x = (dragging_sx + _p[0]) / _sw;
				var sca_y = (dragging_sy + _p[1]) / _sh;
				
				if(key_mod_press(SHIFT)) {
					sca_x = min(sca_x, sca_y);
					sca_y = sca_x;
				}
				
				if(_asca) {
					sca_x /= _psca? _bone.pose_scale : _bone.pose_apply_scale;
					sca_y /= _psca? _bone.pose_scale : _bone.pose_apply_scale;
				}
				
				_tran[TRANSFORM.sca_x] = sca_x;
				_tran[TRANSFORM.sca_y] = sca_y;
				
			} else if(drag_type == NODE_COMPOSE_DRAG.box) {
				var _rot  = _aang * (_pang? _bone.pose_angle : _bone.pose_apply_rotate) + _tran[TRANSFORM.rot];
				var pos_x = _tran[TRANSFORM.pos_x];
				var pos_y = _tran[TRANSFORM.pos_y];
				var sca_x = _tran[TRANSFORM.sca_x];
				var sca_y = _tran[TRANSFORM.sca_y];
				
				var _mmx = _mx;
				var _mmy = _my;
				
				if(key_mod_press(SHIFT)) {
					var _aax = dragging_ax;
					var _aay = dragging_ay;
					
					var _dax = _mmx - _aax;
					var _day = _mmy - _aay;
					var _p = point_rotate_origin(_dax, _day, -_rot, __p);
					
					_dax = _p[0];
					_day = _p[1];
					
					var _scd = min(abs(_dax / _sw), abs(_day / _sh));
					var _p = point_rotate_origin(_sw * sign(_dax), _sh * sign(_day), _rot, __p);
					
					_mmx = _aax + _scd * _p[0];
					_mmy = _aay + _scd * _p[1];
				}
				
				_mmx = value_snap((_mmx - _x) / _s, _snx);
				_mmy = value_snap((_mmy - _y) / _s, _sny);
		
				var _dmx  = _mmx - dragging_mx;
				var _dmy  = _mmy - dragging_my;
				
				point_rotate(_dmx, _dmy, 0, 0, -_bone.pose_angle, __p);
				
				pos_x = dragging_px + __p[0] * .5;
				pos_y = dragging_py + __p[1] * .5;
				
				point_rotate(_dmx, _dmy, 0, 0, -_rot, __p);
				
				sca_x = (dragging_sx + __p[0] * (bool(drag_anchor & 0b10) * 2 - 1)) / _sw;
		        sca_y = (dragging_sy + __p[1] * (bool(drag_anchor & 0b01) * 2 - 1)) / _sh;
				
				_tran[TRANSFORM.pos_x] = pos_x;
				_tran[TRANSFORM.pos_y] = pos_y;
				_tran[TRANSFORM.sca_x] = sca_x;
				_tran[TRANSFORM.sca_y] = sca_y;
				
			}
			
			if(inputs[surf_dragging + 1].setValue(_tran))
				UNDO_HOLDING = true;	
			
			if(mouse_release(mb_left)) {
				surf_dragging = -1;
				UNDO_HOLDING = false;
			}
		}
		
		var hoveringWid   = false;
		var hovering      = noone;
		var hovering_type = noone;
		var hovering_anc  = noone;
		var hovering_ai   = noone;
		
		var _vis = attributes.layer_visible;
		var _sel = attributes.layer_selectable;
		
		var amo = (array_length(inputs) - input_fix_len) / data_length;
		var anchors = array_create(array_length(inputs));
		
		for(var i = 0; i < amo; i++) {
			var index = input_fix_len + i * data_length;
			var _surf = array_safe_get_fast(current_data, index);
			
			if(!array_safe_get_fast(_vis, i)) continue;
			
			if(is(_surf, RiggedMeshedSurface)) {
				if(i != hoverIndex) continue;
				
				var _mesh = _surf.mesh;
				for(var j = 0; j < array_length(_mesh.links); j++)
					_mesh.links[j].draw(_x, _y, _s);
				continue;
			}
			
			if(!_surf || is_array(_surf)) continue;
			
			var _bone = array_safe_get(boneIDMap, i, "");
			if(!struct_exists(boneMap, _bone)) continue;
			
			_bone = boneMap[$ _bone];
			
			var _tran = current_data[index + 1];
			var _aang = current_data[index + 2];
			var _pang = current_data[index + 3];
			var _asca = current_data[index + 4];
			var _psca = current_data[index + 5];
			
			var _rot  = _aang * (_pang? _bone.pose_angle : _bone.pose_apply_rotate) + _tran[TRANSFORM.rot];
			var _anc  = _bone.getPoint(0.5);
			var _mov  = point_rotate(_tran[TRANSFORM.pos_x], _tran[TRANSFORM.pos_y], 0, 0, _bone.pose_angle);
			var _sca  = [ _tran[TRANSFORM.sca_x], _tran[TRANSFORM.sca_y] ];
			if(_asca) {
				_sca[0] *= _psca? _bone.pose_scale : _bone.pose_apply_scale;
				_sca[1] *= _psca? _bone.pose_scale : _bone.pose_apply_scale;
			}
			
			var _ww = surface_get_width_safe(_surf);
			var _hh = surface_get_height_safe(_surf);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			var _siz = [ _sw, _sh ];
			
			var _cx = (_anc.x * _dsca) + _mov[0] + _dpos[0];
			var _cy = (_anc.y * _dsca) + _mov[1] + _dpos[1];
			
			var _c0x = _cx - _sw / 2;
			var _c0y = _cy - _sh / 2;
			var _c1x = _cx + _sw / 2;
			var _c1y = _cy + _sh / 2;
			
			point_rotate(_c0x, _c0y, _cx, _cy, _rot, __p);
			var _d0 = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_c0x, _c1y, _cx, _cy, _rot, __p);
			var _d1 = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_c1x, _c0y, _cx, _cy, _rot, __p);
			var _d2 = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_c1x, _c1y, _cx, _cy, _rot, __p);
			var _d3 = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_cx,  _c0y - (24 / _s) * sign(_sca[1]), _cx, _cy, _rot, __p);
			var _rr = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_cx, _c0y, _cx, _cy, _rot, __p);
			var _rc = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_c1x + (16 / _s) * sign(_sca[0]), _c1y + (16 / _s) * sign(_sca[1]), _cx, _cy, _rot, __p);
			var _ss = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			anchors[index] = {
				cx: _cx, cy: _cy,
				d0: _d0, d1: _d1, d2: _d2, d3: _d3,
				rr: _rr,
				
				rot: _rot,
				siz: _siz,
			}
			
			if(!array_safe_get_fast(_sel, i)) continue;
			
			var p0x = _d0[0], p0y = _d0[1];
			var p1x = _d1[0], p1y = _d1[1];
			var p2x = _d2[0], p2y = _d2[1];
			var p3x = _d3[0], p3y = _d3[1];
			var rcx = _rc[0], rcy = _rc[1];
			var  rx = _rr[0],  ry = _rr[1];
			var  sx = _ss[0],  sy = _ss[1];
			
			var _hov = point_in_rectangle_points(_mx, _my, p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y);
			
			if(surface_selecting == index) {
				var _ri = 0;
				var _si = 0;
				var _ai = 0;
				var _bi = noone;
			
				if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, p0x, p0y, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.box;
					hovering_anc  = _d3;
					hovering_ai   = 0;
					hovering      = index; _bi = 0;
					
				} else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, p1x, p1y, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.box;
					hovering_anc  = _d2;
					hovering_ai   = 1;
					hovering      = index; _bi = 1;
					
				} else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, p2x, p2y, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.box;
					hovering_anc  = _d1;
					hovering_ai   = 2;
					hovering      = index; _bi = 2;
					
				} else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, p3x, p3y, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.box;
					hovering_anc  = _d0;
					hovering_ai   = 3;
					hovering      = index; _bi = 3;
					
				} else if((isNotUsingTool() || isUsingTool("Move")) && _hov) {
					hovering_type = NODE_COMPOSE_DRAG.move; 
					hovering      = index;
					
				} else if((isNotUsingTool() || isUsingTool("Rotate")) && point_in_circle(_mx, _my, rx, ry, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.rotate;
					hovering      = index; _ri = 1;
					
				} else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, sx, sy, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.scale;
					hovering      = index; _si = 1;
				}
				
				draw_set_color(COLORS._main_accent);
				draw_line_width(p0x, p0y, p1x, p1y, 2);
				draw_line_width(p0x, p0y, p2x, p2y, 2);
				draw_line_width(p3x, p3y, p1x, p1y, 2);
				draw_line_width(p3x, p3y, p2x, p2y, 2);
				
				if(isNotUsingTool() || isUsingTool("Rotate")) {
					draw_line_width(rcx, rcy, rx,  ry,  2);
					
					draw_anchor(_ri,      rx,  ry,  ui(8), 1);
				}
				
				if(isNotUsingTool() || isUsingTool("Scale")) {
					draw_line_width(p3x, p3y, sx,  sy,  2);
					
					draw_anchor(_si,      sx,  sy,  ui(8), 1);
					draw_anchor(_bi == 0, p0x, p0y, ui(8), 2);
					draw_anchor(_bi == 1, p1x, p1y, ui(8), 2);
					draw_anchor(_bi == 2, p2x, p2y, ui(8), 2);
					draw_anchor(_bi == 3, p3x, p3y, ui(8), 2);
				}
				
			} else if(!attributes.select_object && _hov && (surface_selecting != hovering || surface_selecting == noone)) {
				hovering = index;
				hovering_type = NODE_COMPOSE_DRAG.move;
				
			}
		}
		draw_data = anchors;
		
		if(attributes.select_object && selection_sampler.active) {
			var _msx = floor((_mx - _x) / _s);
			var _msy = floor((_my - _y) / _s);
			var _ind = selection_sampler.getPixel(_msx, _msy);
			
			if(_ind) {
				var index = input_fix_len + (_ind - 1) * data_length;
				hovering  = index;
				hovering_type = NODE_COMPOSE_DRAG.move;
			}
		}
		
		if(isUsingTool()) {
			var _currTool = PANEL_PREVIEW.tool_current;
			var _tool     = _currTool.getToolObject();
			
			if(_tool != noone) {
				_tool.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				if(mouse_lclick()) selection_freeze = 1;
			}
		}
		
		if(selection_freeze == 0 && mouse_press(mb_left, active)) surface_selecting = hovering;
			
		if(surface_selecting != noone) {
			var a = array_safe_get_fast(anchors, surface_selecting, noone);
			if(!is_struct(a)) surface_selecting = noone;
		}
		
		if(mouse_lrelease()) selection_freeze = 0;
		
		if(hovering != noone) {
			hoveringWid = true;
			var a = anchors[hovering];
			
			if(surface_selecting != hovering) {
				draw_set_color(COLORS.node_composite_overlay_border);
				draw_line(a.d0[0], a.d0[1], a.d1[0], a.d1[1]);
				draw_line(a.d0[0], a.d0[1], a.d2[0], a.d2[1]);
				draw_line(a.d3[0], a.d3[1], a.d1[0], a.d1[1]);
				draw_line(a.d3[0], a.d3[1], a.d2[0], a.d2[1]);
			}
			
			if(mouse_press(mb_left, active && hovering_type != noone)) {
				var _tran = current_data[hovering + 1];
				var _aang = current_data[hovering + 2];
				var _asca = current_data[hovering + 3];
				
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
					dragging_sx		= a.siz[0];
					dragging_sy		= a.siz[1];
					dragging_ax		= a.d0[0];
					dragging_ay		= a.d0[1];
					dragging_mx		= mx;
					dragging_my		= my;
					
				} else if(hovering_type == NODE_COMPOSE_DRAG.box) {
					surf_dragging	= hovering;
					drag_type		= hovering_type;
					
					drag_anchor     = hovering_ai;
					dragging_sx		= a.siz[0];
					dragging_sy		= a.siz[1];
					dragging_px		= _tran[TRANSFORM.pos_x];
					dragging_py		= _tran[TRANSFORM.pos_y];
					dragging_ax		= hovering_anc[0];
					dragging_ay		= hovering_anc[1];
					dragging_mx		= mx;
					dragging_my		= my;
					
				} 
			}
		}
		
		if(layer_remove > -1) { deleteLayer(layer_remove); layer_remove = -1; }
		
		return hoveringWid;
	}
	
	////- Update
	
	static processData_prebatch = function() {
		var _dim_type = getSingleValue(1);
		inputs[2].setVisible(_dim_type == COMPOSE_OUTPUT_SCALING.constant);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			inputs[i + 3].setVisible(getInputData(i + 2));
			inputs[i + 5].setVisible(getInputData(i + 4));
		}
	}
	
	static meshBind = function(_s, _bg) {
		_mesh = _s.mesh;
		_rmap = _s.rigMap;
		_surf = _s.getSurface();
		if(!is_surface(_surf)) return;
		
		_rbon  = _s.boneMap == noone? boneMap : _s.boneMap;
		_rbid  = struct_get_names(_rmap);
		_rbidL = array_length(_rbid);
		_ar    = [ 0, 0 ];
		
		array_foreach(_mesh.points, function(_p, i) /*=>*/ {
			if(!is(_p, MeshedPoint)) return;
			
			var _px = _p.sx;
			var _py = _p.sy;
			
			for( var j = 0; j < _rbidL; j++ ) {
				var _rBoneID = _rbid[j];
				if(!struct_exists(boneMap, _rBoneID)) continue;
				
				var _rmapp   = _rmap[$ _rBoneID];
				var _weight  = array_safe_get_fast(_rmapp, i, 0);
				if(_weight == 0) continue;
				
				var _bf = _rbon[$ _rBoneID];
				var _bt = boneMap[$ _rBoneID];
				
				var _ax = _p.sx - _bf.bone_head_pose.x;
				var _ay = _p.sy - _bf.bone_head_pose.y;
				
				point_rotate_origin(_ax, _ay, _bt.pose_angle - _bf.pose_angle, _ar);
				var _nx = _bt.bone_head_pose.x + _ar[0] * _bt.pose_apply_scale / _bf.pose_apply_scale;
				var _ny = _bt.bone_head_pose.y + _ar[1] * _bt.pose_apply_scale / _bf.pose_apply_scale;
				
				_px += (_nx - _p.sx) * _weight;
				_py += (_ny - _p.sy) * _weight;
			}
			
			_p.x = _px;
			_p.y = _py;
		});
		
		surface_set_shader(temp_surface[!_bg], sh_sample, false, BLEND.alphamulp);
			draw_set_color(c_white);
			draw_set_alpha(1);
			
			array_foreach(_mesh.tris, function(_t) /*=>*/ { _t.drawSurface(_surf); });
		surface_reset_shader();
		
		surface_set_shader(temp_surface[_bg], noone, true, BLEND.over);
			draw_surface(temp_surface[!_bg], 0, 0);
		surface_reset_shader();
	}
	
	static processData = function(_outData, _data, _array_index) {
		atlas_data = [];
		bind_data  = [];
		
		var _dim  = _data[0];
		var _bone = _data[1];
		var _bind = _data[2];
		var _dpos = _data[3];
		var _dsca = _data[4];
		var cDep  = attrDepth();
		var use_data  = _bind != noone;
		
		setBone();
		
		//////////////////////////////////////////
		
		if(!use_data && getInputAmount() == 0) return _outData;
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		
		overlay_w = _dim[0];
		overlay_h = _dim[1];
		
		for(var i = 0; i < 3; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], cDep);
			surface_clear(temp_surface[i]);
		}
		
		var imageAmo  = use_data? array_length(_bind) : (array_length(inputs) - input_fix_len) / data_length;
		var _vis	  = attributes.layer_visible;
		var _bg = 0, _s, _i;
		
		var _selDarw  = _array_index == preview_index && attributes.select_object;
		if(_selDarw) {
			selection_surf = surface_verify(selection_surf, _dim[0], _dim[1], surface_r16float);
			surface_clear(selection_surf);
		}
		
		for(var i = 0; i < imageAmo; i++) {
			if(!array_safe_get_fast(_vis, i, true)) continue;
			
			_i = input_fix_len + i * data_length;
			_s = noone;
			
			if(use_data) {
				var _bdat = array_safe_get_fast(_bind, i);
				if(is(_bdat, __armature_bind_data))
					_s = _bdat.surface;
					
				if(is(_s, Surface)) 
					_s = _s.get();
				
			} else
				_s = array_safe_get_fast(_data, _i);
			
			if(is(_s, RiggedMeshedSurface)) {
				meshBind(_s, _bg);
				array_push(bind_data, new __armature_bind_data(_s));
				continue;
			}
			
			if(!is_surface(_s)) continue;
			
			var _b = use_data? _bind[i].bone : array_safe_get(boneIDMap, i, "");
			if(!struct_exists(boneMap, _b)) continue;
			
			_b = boneMap[$ _b];
			
			var _tran = use_data? _bind[i].transform : _data[_i + 1];
			var _aang = use_data? _bind[i].applyRot  : _data[_i + 2]; // inherit rotation
			var _pang = use_data? _bind[i].applyRotl : _data[_i + 3]; // apply bone rotation
			var _asca = use_data? _bind[i].applySca  : _data[_i + 4]; // inherit scale
			var _psca = use_data? _bind[i].applyScal : _data[_i + 5]; // apply bone scale
			
			var _rot  = _aang * (_pang? _b.pose_angle : _b.pose_apply_rotate) + _tran[TRANSFORM.rot];
			var _anc  = _b.getPoint(0.5);
			var _mov  = point_rotate(_tran[TRANSFORM.pos_x], _tran[TRANSFORM.pos_y], 0, 0, _b.pose_angle, __mov);
			var _sca  = [ _tran[TRANSFORM.sca_x], _tran[TRANSFORM.sca_y] ];
			if(_asca) {
				_sca[0] *= _psca? _b.pose_scale : _b.pose_apply_scale;
				_sca[1] *= _psca? _b.pose_scale : _b.pose_apply_scale;
			}
			
			var _ww = surface_get_width_safe(_s);
			var _hh = surface_get_height_safe(_s);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var _cen = point_rotate(-_sw / 2, -_sh / 2, 0, 0, _rot, __cen);
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
			
			surface_set_shader(selection_surf, sh_selection_mask, false, BLEND.maximum);
				shader_set_f("index", i + 1);
				draw_surface_ext(_s, _pos[0], _pos[1], _sca[0], _sca[1], _rot, c_white, 1);
			surface_reset_shader();
			
			_bg = !_bg;
		}
		
		if(_selDarw) selection_sampler.setSurface(selection_surf);
		
		var _outSurf = surface_verify(_outData[0], _dim[0], _dim[1], cDep);
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		return [ _outSurf, atlas_data, bind_data ];
	}
	
	static resetTransform = function(surfIndex) {
		var _bind    = getInputData(2);
		var use_data = _bind != noone;
		
		var _surf = getInputData(surfIndex + 0);
		var _tran = getInputData(surfIndex + 1);
		var _arot = getInputData(surfIndex + 2);
		
		var _b = use_data? _bind[i].bone : array_safe_get(boneIDMap, (surfIndex - input_fix_len) / data_length, "");
		if(!struct_exists(boneMap, _b)) return;
		
		_b = boneMap[$ _b];
		
		var _cx  = surface_get_width_safe(_surf)  / 2;
		var _cy  = surface_get_height_safe(_surf) / 2;
		
		var _anc = _b.getPoint(0.5);
		var _rot = _arot? -_b.pose_angle : 0;
		
		var _tr  = [ _cx - _anc.x, _cy - _anc.y, _rot, 1, 1 ];
		inputs[surfIndex + 1].setValue(_tr);
	}
	
	////- Serialize
	
	static attributeSerialize = function() {
		var att = { boneIDMap };
		return att;
	}
	
	static attributeDeserialize = function(attr) {
		struct_append(attributes, attr);
		boneIDMap = struct_try_get(attr, "boneIDMap", boneIDMap);
	}
	
	static postApplyDeserialize = function() {
		setBone();
	}
}

