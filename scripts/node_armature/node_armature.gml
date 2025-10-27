#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Armature", "Move",         "V");
		hotkeyCustom("Node_Armature", "Scale",        "S");
		hotkeyCustom("Node_Armature", "Transform",    "T");
		hotkeyCustom("Node_Armature", "Add Bone",     "A");
		hotkeyCustom("Node_Armature", "Remove Bone",  "E");
		hotkeyCustom("Node_Armature", "Detach Bone",  "D");
		hotkeyCustom("Node_Armature", "IK",           "K");
		
		hotkeyCustom("Node_Armature", "Move Selection",   "G");
		hotkeyCustom("Node_Armature", "Rotate Selection", "R");
		hotkeyCustom("Node_Armature", "Scale Selection",  "S");
	});
	
	enum ARMATURE_DRAG_TYPE {
		move,
		moveTail,
		rotate,
		scale, 
	}
	
	function __node_bone_attributes() {
		attributes.display_name = true;
		attributes.display_bone = 0;
		
		array_push(attributeEditors,  "Display" );
		array_push(attributeEditors, ["Display name", function() /*=>*/ {return attributes.display_name}, new checkBox(function() /*=>*/ {return toggleAttribute("display_name")})]);
		array_push(attributeEditors, ["Display bone", function() /*=>*/ {return attributes.display_bone}, new scrollBox(__txts(["Octahedral", "Stick"]), function(i) /*=>*/ {return setAttribute("display_bone", i)})]);
	}
	
	function armature_tool_move(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		origin_x = 0;
		origin_y = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		drag_points = [];
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			var _bones = node.bone_select;
			if(array_empty(_bones)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			drag_points    = node.bones.toPoints();
			
			drag_axis = -1;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			origin_x = 0;
			origin_y = 0;
			var cnt  = 0;
			
			for( var i = 0, n = array_length(_bones); i < n; i++ ) {
				var bne = drag_points[_bones[i]];
				if(is(bne, __vec2)) {
					origin_x += bne.x;
					origin_y += bne.y;
					
					bne.sx = bne.x;
					bne.sy = bne.y;
					
					cnt++;
				}
			}
			
			if(cnt) {
				origin_x /= cnt;
				origin_y /= cnt;
			}
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var _bones = node.bone_select;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var ox = _x + origin_x * _s;
			var oy = _y + origin_y * _s;
			
			var dx = KEYBOARD_NUMBER == undefined? (_mx - drag_pmx) / _s : KEYBOARD_NUMBER;
			var dy = KEYBOARD_NUMBER == undefined? (_my - drag_pmy) / _s : KEYBOARD_NUMBER;
			
			for( var i = 0, n = array_length(_bones); i < n; i++ ) {
				var bne = drag_points[_bones[i]];
				if(!is(bne, __vec2)) continue;
				
				bne.x = bne.sx;
				bne.y = bne.sy;

				if(drag_axis == -1) {
					bne.x = bne.sx + dx;
					bne.y = bne.sy + dy;
					
				} else {
					if(drag_axis == 0) bne.x = bne.sx + dx;
					if(drag_axis == 1) bne.y = bne.sy + dy; 
				}
				
			}
			
			node.bones.fromPoints(drag_points);
			node.triggerRender();
			
			draw_set_color(COLORS._main_icon);
			switch(drag_axis) {
				case  0: draw_line_dashed( 0, oy, 9999, oy); break;
				case  1: draw_line_dashed(ox,  0, ox, 9999); break;
			}
			
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
	
	function armature_tool_rotate(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		rotate_acc  = 0;
		
		origin_x = 0;
		origin_y = 0;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			var _bones = node.bone_select;
			if(array_empty(_bones)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			drag_points    = node.bones.toPoints();
			
			rotate_acc = 0;
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			origin_x = 0;
			origin_y = 0;
			var cnt  = 0;
			
			for( var i = 0, n = array_length(_bones); i < n; i++ ) {
				var bne = drag_points[_bones[i]];
				if(is(bne, __vec2)) {
					origin_x += bne.x;
					origin_y += bne.y;
					
					bne.sx = bne.x;
					bne.sy = bne.y;
					
					cnt++;
				}
			}
			
			if(cnt) {
				origin_x /= cnt;
				origin_y /= cnt;
			}
			
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var _bones = node.bone_select;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var ox = _x + origin_x * _s;
			var oy = _y + origin_y * _s;
			
			var _d0 = point_direction(ox, oy, drag_pmx, drag_pmy);
			var _d1 = point_direction(ox, oy, _mx, _my);
			
			drag_pmx = _mx;
			drag_pmy = _my;
			
			rotate_acc += angle_difference(_d1, _d0);
			var rr = KEYBOARD_NUMBER ?? rotate_acc;
			
			for( var i = 0, n = array_length(_bones); i < n; i++ ) {
				var bne = drag_points[_bones[i]];
				if(!is(bne, __vec2)) continue;
				
				var dis = point_distance(  origin_x, origin_y, bne.sx, bne.sy );
				var dir = point_direction( origin_x, origin_y, bne.sx, bne.sy );
				
				bne.x = origin_x + lengthdir_x(dis, dir + rr);
				bne.y = origin_y + lengthdir_y(dis, dir + rr);
				
			}
			
			node.bones.fromPoints(drag_points);
			node.triggerRender();
			
			draw_set_color(COLORS._main_icon);
			draw_line_dashed(ox, oy, _mx, _my);
			
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
	
	function armature_tool_scale(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		origin_x = 0;
		origin_y = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			var _bones = node.bone_select;
			if(array_empty(_bones)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			drag_points    = node.bones.toPoints();
			
			drag_axis = -1;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			origin_x = 0;
			origin_y = 0;
			var cnt  = 0;
			
			for( var i = 0, n = array_length(_bones); i < n; i++ ) {
				var bne = drag_points[_bones[i]];
				if(is(bne, __vec2)) {
					origin_x += bne.x;
					origin_y += bne.y;
					
					bne.sx = bne.x;
					bne.sy = bne.y;
					
					cnt++;
				}
			}
			
			if(cnt) {
				origin_x /= cnt;
				origin_y /= cnt;
			}
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var _bones = node.bone_select;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var ox = _x + origin_x * _s;
			var oy = _y + origin_y * _s;
			
			var _ss = point_distance(_mx, _my, ox, oy) / point_distance(drag_pmx, drag_pmy, ox, oy);
			
			for( var i = 0, n = array_length(_bones); i < n; i++ ) {
				var bne = drag_points[_bones[i]];
				if(!is(bne, __vec2)) continue;
				
				bne.x = bne.sx;
				bne.y = bne.sy;
				
				if(drag_axis == -1) {
					bne.x = origin_x + (bne.sx - origin_x) * _ss;
					bne.y = origin_y + (bne.sy - origin_y) * _ss;
					
				} else {
					if(KEYBOARD_NUMBER == undefined) {
						if(drag_axis == 0) bne.x = origin_x + (bne.sx - origin_x) * _ss;
						if(drag_axis == 1) bne.y = origin_y + (bne.sy - origin_y) * _ss;
							
					} else {
						if(drag_axis == 0) bne.x = origin_x + (bne.sx - origin_x) * KEYBOARD_NUMBER;
						if(drag_axis == 1) bne.y = origin_y + (bne.sy - origin_y) * KEYBOARD_NUMBER;
							
					}
				}
				
			}
			
			node.bones.fromPoints(drag_points);
			node.triggerRender();
			
			draw_set_color(COLORS._main_icon);
			switch(drag_axis) {
				case -1: draw_line_dashed(ox, oy, _mx, _my); break;
				case  0: draw_line_dashed( 0, oy, 9999, oy); break;
				case  1: draw_line_dashed(ox,  0, ox, 9999); break;
			}
			
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

function Node_Armature(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Create";
	draw_padding = 8;
	preview_select_surface = false;
	setDimension(96, 96);
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	#region ++++ attributes ++++
		bones         = new __Bone(,,,,, self);
		bones.name    = "Main";
		bones.is_main = true;
		bones.node    = self;
		
		__node_bone_attributes();
	#endregion
		
	#region ---- tool ----
		tools = [
			new NodeTool( "Transform",    THEME.bone_tool_move   ),
			new NodeTool( [ "Add Bone", "Add Control Bone"], [ THEME.bone_tool_add, THEME.bone_tool_add_control ]),
			new NodeTool( "Remove Bone",  THEME.bone_tool_remove ),
			new NodeTool( "Mirror Bones", THEME.bone_tool_mirror ),
			new NodeTool( "Detach Bone",  THEME.bone_tool_detach ),
			new NodeTool( "IK",           THEME.bone_tool_IK     ),
			-1, 
			new NodeTool( "Move Selection",   THEME.tools_2d_move   ).setVisible(false).setToolObject(new armature_tool_move(self)),
			new NodeTool( "Rotate Selection", THEME.tools_2d_rotate ).setVisible(false).setToolObject(new armature_tool_rotate(self)),
			new NodeTool( "Scale Selection",  THEME.tools_2d_scale  ).setVisible(false).setToolObject(new armature_tool_scale(self)),
		];
		
		anchor_selecting = noone;
		builder_bone = noone;
		builder_type = 0;
		builder_sv   = 0;
		builder_sx   = 0;
		builder_sy   = 0;
		builder_mx   = 0;
		builder_my   = 0;
		
		bone_dragging = noone;
		ik_dragging   = noone;
		
		moving  = false;
		scaling = false;
		
		bone_point_maps = [];
		bone_point_mape = [];
		
		bone_bbox = undefined;
		bone_transform_bbox = -1;
		bone_transform_type = -1;
		
		mirroring_bone = noone;
	#endregion
	
	////- Bone
	
	bone_array    = [];
	bone_points   = [];
	bone_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		var _b  = bones;
		if(_b == noone) return 0;
		var amo = _b.childCount();
		var _hh = ui(28);
		var bh  = ui(16) + amo * _hh;
		var ty  = _y;
			
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, bh, COLORS.node_composite_bg_blend, 1);
		ty += ui(8);
		
		var hovering = noone;
		var _bst = ds_stack_create();
		ds_stack_push(_bst, [ _b, _x, _w ]);
		
		var bone_remove      = noone;
		var bone_constrained = {};
		for( var i = 0, n = array_length(bones.constrains); i < n; i++ ) {
			var _con = bones.constrains[i];
			if(_con.bone_id == "") continue;
			bone_constrained[$ _con.bone_id] = 1;
		}
		
		while(!ds_stack_empty(_bst)) {
			var _st  = ds_stack_pop(_bst);
			var bone = _st[0];
			var __x  = _st[1];
			var __w  = _st[2];
			
			for( var i = 0, n = array_length(bone.childs); i < n; i++ )
				ds_stack_push(_bst, [ bone.childs[i], __x + ui(16), __w - ui(16) ]);
				
			if(bone.is_main) continue;
			
			var bne_c = COLORS._main_icon;
			if(_hover && point_in_circle(_m[0], _m[1], __x + ui(12), ty + ui(12), ui(12))) {
				bne_c = COLORS._main_icon_light;
				if(mouse_press(mb_left, _focus))
					bone_dragging = bone;
			}
			
			draw_sprite_ui(THEME.bone, bone.getSpriteIndex(), __x + ui(12), ty + ui(14),,,, bne_c);
				
			if(point_in_rectangle(_m[0], _m[1], __x + ui(24), ty + ui(3), __x + __w, ty + _hh - ui(3)))
				anchor_selecting = [ bone, 2 ];
			
			var bx = __x + __w - ui(24);
			var by = ty + _hh / 2;
			
			if(point_in_circle(_m[0], _m[1], bx, by, ui(16))) {
				draw_sprite_ui_uniform(THEME.icon_delete, 3, bx, by, 1, COLORS._main_value_negative);
				
				if(mouse_press(mb_left, _focus))
					bone_remove = bone;
			} else 
				draw_sprite_ui_uniform(THEME.icon_delete, 3, bx, by, 1, COLORS._main_icon);
			
			draw_set_font(f_p2);
			var ww = string_width(bone.name);
			
			bone.tb_name.setFocusHover(_focus, _hover);
			bone.tb_name.draw(__x + ui(24), ty + ui(3), ww + ui(16), _hh - ui(6), bone.name, _m);
			
			var _x0 = bx - ui(24);
			var _y0 = by;
			var cc  = bone.apply_scale? COLORS._main_icon : COLORS._main_value_negative;
			if(_hover && point_in_circle(_m[0], _m[1], _x0, _y0, ui(10))) {
				TOOLTIP = "Apply Scale";
				draw_sprite_ui(THEME.bone, 3, _x0, _y0,,,, cc, 0.75);
				
				if(mouse_press(mb_left, _focus))
					bone.apply_scale = !bone.apply_scale;
			} else 
				draw_sprite_ui(THEME.bone, 3, _x0, _y0,,,, cc, 0.5);
			
			_x0 -= ui(20);
			var cc  = bone.apply_rotation? COLORS._main_icon : COLORS._main_value_negative;
			if(_hover && point_in_circle(_m[0], _m[1], _x0, _y0, ui(10))) {
				TOOLTIP = "Apply Rotation";
				draw_sprite_ui(THEME.bone, 4, _x0, _y0,,,, cc, 0.75);
				
				if(mouse_press(mb_left, _focus))
					bone.apply_rotation = !bone.apply_rotation;
			} else 
				draw_sprite_ui(THEME.bone, 4, _x0, _y0,,,, cc, 0.5);
			
			_x0 -= ui(20);
			var cc = has(bone_constrained, bone.ID)? COLORS._main_accent : COLORS._main_icon;
			if(_hover && point_in_circle(_m[0], _m[1], _x0, _y0, ui(10))) {
				TOOLTIP = "Add Constrains";
				draw_sprite_ui(THEME.bone, 5, _x0, _y0,,,, cc, .75);
				
				if(mouse_press(mb_left, _focus)) {
					bone_constrain_adding = bone;
					menuCall("bone_constrain_add", bone_constrain_menu);
				}
			} else 
				draw_sprite_ui(THEME.bone, 5, _x0, _y0,,,, cc, .5);
			
			ty += _hh;
				
			if(!ds_stack_empty(_bst)) {
				draw_set_color(COLORS.node_composite_separator);
				draw_line(_x + ui(16), ty, _x + _w - ui(16), ty);
			}
		}
		
		ds_stack_destroy(_bst);
		
		if(bone_dragging && mouse_release(mb_left))
			bone_dragging = noone;
			
		if(bone_remove != noone) {
			var _par = bone_remove.parent;
			recordAction(ACTION_TYPE.struct_modify, bones)
				.setName($"Remove bone [{bone_remove.name}]")
				.setRef(self);
			array_remove(_par.childs, bone_remove);
				
			for( var i = 0, n = array_length(bone_remove.childs); i < n; i++ ) {
				var _ch = bone_remove.childs[i];
				_par.addChild(_ch);
						
				_ch.parent_anchor = bone_remove.parent_anchor;
			}
		}
		
		return bh;
	}); 
	
	bone_selected = false;
	bone_freeze   = 0;
	bone_select   = [];
	
	static createBone = function(parent, distance, direction) { 
		recordAction(ACTION_TYPE.struct_modify, bones)
			.setName("Create bone")
			.setRef(self);
		
		var amoo  = bones.childCount();
		var bone  = new __Bone(parent, distance, direction, 0, 0, self);
		bone.name = $"Bone {amoo}";
		
		parent.addChild(bone);
		
		if(parent == bones) bone.parent_anchor = false;
		
		bone.distance      = distance;
		bone.direction     = direction;
		
		return bone;
	} 
	
	////- Constrain
	
	bone_constrain_adding = noone;
	bone_constrain_menu   = [
		new MenuItem("Copy Bone Position",  function() /*=>*/ { addConstain("__Bone_Constrain_Copy_Position")    }, [ s_bone_constrain, 0, 1, c_white ]),
		new MenuItem("Copy Bone Rotation",  function() /*=>*/ { addConstain("__Bone_Constrain_Copy_Rotation")    }, [ s_bone_constrain, 1, 1, c_white ]),
		new MenuItem("Copy Bone Scale",     function() /*=>*/ { addConstain("__Bone_Constrain_Copy_Scale")       }, [ s_bone_constrain, 2, 1, c_white ]),
		-1,
		new MenuItem("Look At Bone",        function() /*=>*/ { addConstain("__Bone_Constrain_Look_At")          }, [ s_bone_constrain, 3, 1, c_white ]),
		new MenuItem("Move To Bone",        function() /*=>*/ { addConstain("__Bone_Constrain_Move_To")          }, [ s_bone_constrain, 4, 1, c_white ]),
		new MenuItem("Stretch To Bone",     function() /*=>*/ { addConstain("__Bone_Constrain_Stretch_To")       }, [ s_bone_constrain, 5, 1, c_white ]),
		// -1, 
		// new MenuItem("Look At Point",       () => { addConstain("__Bone_Constrain_Look_At_Point")    }, [ s_bone_constrain, 3, 1, c_white ]),
		// new MenuItem("Move To Point",       () => { addConstain("__Bone_Constrain_Move_To_Point")    }, [ s_bone_constrain, 4, 1, c_white ]),
		// new MenuItem("Stretch To Point",    () => { addConstain("__Bone_Constrain_Stretch_To_Point") }, [ s_bone_constrain, 5, 1, c_white ]),
		-1, 
		new MenuItem("Limit Position",      function() /*=>*/ { addConstain("__Bone_Constrain_Limit_Position")   }, [ s_bone_constrain, 6, 1, c_white ]),
		new MenuItem("Limit Rotation",      function() /*=>*/ { addConstain("__Bone_Constrain_Limit_Rotation")   }, [ s_bone_constrain, 7, 1, c_white ]),
		new MenuItem("Limit Scale",         function() /*=>*/ { addConstain("__Bone_Constrain_Limit_Scale")      }, [ s_bone_constrain, 8, 1, c_white ]),
		new MenuItem("Limit Distance",      function() /*=>*/ { addConstain("__Bone_Constrain_Limit_Distance")   }, [ s_bone_constrain, 9, 1, c_white ]),
	];
	
	constrains_h = 0;
	constrains_dragging = noone;
	constrain_renderer  = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		var _b = bones;
		var hh = 0;
		if(_b == noone) return 0;
		
		constrains_h   = 0;
		var constrains = _b.constrains;
		var _drawParam = {
			rx: constrain_renderer.rx, 
			ry: constrain_renderer.ry,
			
			selecting:  anchor_selecting,
			bone_array: bone_array,
			
			panel: constrain_renderer.parent, 
		}
		
		var ty   = _y;
		var _del = -1;
		var _hovering = noone;
		var _hoverInd = 0;
		var _hoverY   = ty;
		
		for( var i = 0, n = array_length(constrains); i < n; i++ ) {
			var _con = constrains[i];
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], 0, ty, _w - ui(32), ty + ui(32));
			if(_hov) {
				_hovering = _con;
				_hoverInd = i;
				_hoverY   = ty;
			}
			
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, _con.draw_height + ui(32), COLORS.node_composite_bg_blend, 1);
			draw_sprite_ext(s_bone_constrain, _con.sindex, _x + ui(4 + 16), ty + ui(16), UI_SCALE / 2, UI_SCALE / 2);
			
			draw_set_text(f_p2, fa_left, fa_top, _hov? COLORS._main_text : COLORS._main_text_sub);
			draw_text_add(_x + ui(4 + 32), ty + ui(6), _con.name);
			
			var bx = _x + _w - ui(16);
			var by = ty + ui(16);
			
			if(point_in_circle(_m[0], _m[1], bx, by, 16)) {
				draw_sprite_ui_uniform(THEME.icon_delete, 3, bx, by, 1, COLORS._main_value_negative);
				if(mouse_press(mb_left, _focus)) _del = i;
				
			} else 
				draw_sprite_ui_uniform(THEME.icon_delete, 3, bx, by, 1, COLORS._main_icon);
			
			_con.node = self;
			var _h = _con.drawInspector(_x, ty + ui(32), _w, _m, _hover, _focus, _drawParam);
			
			_con.draw_height = _h;
			constrains_h += _h + ui(32 + 4);
			ty += _h + ui(32 + 4);
			
			if(_m[1] > ty) {
				_hoverInd = i + 1;
				_hoverY   = ty;
			}
		}
		
		if(_hovering != noone && mouse_lpress(_focus)) {
			constrains_dragging = _hovering;
			array_remove(constrains, constrains_dragging);
		}
		
		if(constrains_dragging != noone) {
			draw_set_color(COLORS._main_accent);
			draw_line_round(ui(8), _hoverY, _w - ui(16), _hoverY, 2);
			
			if(mouse_lrelease()) {
				array_insert(constrains, _hoverInd, constrains_dragging);
				constrains_dragging = noone;
			}
		}
		
		if(_del != -1) {
			array_delete(constrains, _del, 1);
			triggerRender();
		}
		
		hh += constrains_h;
		return hh;
	}); 
	
	function addConstain(_c) {
		if(bone_constrain_adding == noone) return;
		array_push(bones.constrains, new __Bone_Constrain(bones).build(_c, bone_constrain_adding.ID));
		triggerRender();
	}
	
	////- Draw
	
	input_display_list = [
		["Bones",      false], bone_renderer,
		["Constrains", false], constrain_renderer, 
	];
	
	static selectClear = function() { bone_select = []; }
	static selectAll   = function() { bone_select = array_create_ext(array_length(bone_points), function(i) /*=>*/ {return i}); }
	
	static drawOverlay_Transform = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		var _b = _params.bone;
		
		_b.draw(attributes, false, _x, _y, _s, _mx, _my);
		
		var bbox = _b.bbox();
		if(!is_array(bbox)) return;
		
		var x0 = _x + bbox[0] * _s;
		var y0 = _y + bbox[1] * _s;
		
		var x1 = _x + bbox[2] * _s;
		var y1 = _y + bbox[3] * _s;
		
		if(bone_transform_type >= 0) {
			var dx = mx - builder_mx;
			var dy = my - builder_my;
			
			var ox0 = bone_transform_bbox[0], oy0 = bone_transform_bbox[1];
			var ox1 = bone_transform_bbox[2], oy1 = bone_transform_bbox[3];
			var ow  = ox1 - ox0;
			var oh  = oy1 - oy0;
			
			var nx0 = ox0, ny0 = oy0;
			var nx1 = ox1, ny1 = oy1;
			
			switch(bone_transform_type) { // transform
				case 0 : nx0 = ox0 + dx; 
					     ny0 = oy0 + dy; break;
				
				case 1 : nx1 = ox1 + dx;
					     ny0 = oy0 + dy; break;
					
				case 2 : nx0 = ox0 + dx;
					     ny1 = oy1 + dy; break;
					
				case 3 : nx1 = ox1 + dx;
					     ny1 = oy1 + dy; break;
				
				case 4 : nx0 = ox0 + dx;
					     ny0 = oy0 + dy;
					     nx1 = ox1 + dx;
					     ny1 = oy1 + dy; break;
			}
			
			var nw  = nx1 - nx0;
			var nh  = ny1 - ny0;
			
			for( var i = 0, n = array_length(bone_point_maps); i < n; i++ ) {
				var _bmap = bone_point_maps[i];
				var _emap = bone_point_mape[i];
				
				_emap[0].x = (_bmap[0].x - ox0) / ow * nw + nx0;
				_emap[0].y = (_bmap[0].y - oy0) / oh * nh + ny0;
				
				_emap[1].x = (_bmap[1].x - ox0) / ow * nw + nx0;
				_emap[1].y = (_bmap[1].y - oy0) / oh * nh + ny0;
			}
			
			for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
				var _bone = bone_array[i];
				var _emap = bone_point_mape[i];
				
				var _h = _emap[0];
				var _t = _emap[1];
				
				if(!_bone.parent_anchor) {
					var _ox = 0;
					var _oy = 0;
					
					if(_bone.parent) {
						var _ph = _bone.parent.getHead();
						_ox = _ph.x;
						_oy = _ph.y;
					}
					
					_bone.distance  = point_distance(  _ox, _oy, _h.x, _h.y );
					_bone.direction = point_direction( _ox, _oy, _h.x, _h.y );
				}
				
				_bone.length    = point_distance(_h.x, _h.y, _t.x, _t.y);
				_bone.angle     = point_direction(_h.x, _h.y, _t.x, _t.y);
				
				_bone.__setPosition();
			}
			
			if(mouse_release(mb_left)) {
				bone_transform_type = -1;
				UNDO_HOLDING = false;
			}
			
			triggerRender();
			
			draw_set_color(COLORS._main_accent);
			draw_rectangle(x0, y0, x1, y1, true);
			
		} else {
			var _hov_type = -1;
			var _r = ui(8);
			
				 if(point_in_circle(_mx, _my, x0, y0, _r + 2))    _hov_type = 0;
			else if(point_in_circle(_mx, _my, x1, y0, _r + 2))    _hov_type = 1;
			else if(point_in_circle(_mx, _my, x0, y1, _r + 2))    _hov_type = 2;
			else if(point_in_circle(_mx, _my, x1, y1, _r + 2))    _hov_type = 3;
			else if(point_in_rectangle(_mx, _my, x0, y0, x1, y1)) _hov_type = 4;
			
			draw_set_color(_hov_type == 4? COLORS._main_accent : c_white);
			draw_set_alpha(0.5);
			draw_rectangle(x0, y0, x1, y1, true);
			draw_set_alpha(1);
			
			draw_anchor(_hov_type == 0, x0, y0, _r, 2);
			draw_anchor(_hov_type == 1, x1, y0, _r, 2);
			draw_anchor(_hov_type == 2, x0, y1, _r, 2);
			draw_anchor(_hov_type == 3, x1, y1, _r, 2);
			
			if(_hov_type >= -1) hovering = true;
			
			if(_hov_type >= -1 && mouse_press(mb_left, active)) {
				bone_array = _b.toArray();
				for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
					var _h = bone_array[i].getHead(); 
					var _t = bone_array[i].getTail();
					
					bone_point_maps[i] = [ _h, _t ];
					bone_point_mape[i] = [ _h.clone(), _t.clone() ];
				}
				
				bone_transform_type = _hov_type;
				bone_transform_bbox = _b.bbox(); 
				builder_mx = mx;
				builder_my = my;
				
				recordAction(ACTION_TYPE.struct_modify, bones).setName("Transform bones").setRef(self);
			}
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var smx = value_snap(mx, _snx);
		var smy = value_snap(my, _sny);
		var panel = _params[$ "panel"] ?? noone;
		
		var _b = bones;
		var hovering = false;
		_params.bone = _b;
		
		if(builder_bone != noone) {
			gpu_set_texfilter(true);
				
			anchor_selecting = _b.draw(attributes, false, _x, _y, _s, _mx, _my, anchor_selecting, builder_bone);
			_b.drawControl(attributes);
			
			var dir = point_direction(builder_sx, builder_sy, smx, smy);
			var dis = point_distance(builder_sx, builder_sy, smx, smy);
			
			if(builder_type == ARMATURE_DRAG_TYPE.rotate) {
				var an = point_direction(builder_sx, builder_sy, mx, my);
				builder_bone.angle += angle_difference(an, builder_sv);
				builder_sv = an;
				
				var _rx = _x + _s * builder_sx;
				var _ry = _y + _s * builder_sy;
				draw_sprite_ui(THEME.bone_rotate, 0, _rx, _ry, 1, 1, builder_bone.angle, COLORS._main_value_positive, 1);
			
			} else if(builder_type == ARMATURE_DRAG_TYPE.scale) {
				
				builder_bone.length = point_distance(builder_sx, builder_sy, mx, my) / builder_sv;
				
				orig = builder_bone.getPoint(0.8);
				var _rx = _x + _s * orig.x;
				var _ry = _y + _s * orig.y;
				draw_sprite_ui(THEME.bone_scale,  0, _rx, _ry, 1, 1, builder_bone.angle, COLORS._main_value_positive, 1);
			
			} else if(key_mod_press(ALT)) {
				if(builder_type == ARMATURE_DRAG_TYPE.move) {
					var bo = builder_bone.getTail();
					
					builder_bone.direction = dir;
					builder_bone.distance  = dis;
					
					var bn = builder_bone.getHead();
					
					builder_bone.angle  = point_direction(bn.x, bn.y, bo.x, bo.y);
					builder_bone.length = point_distance( bn.x, bn.y, bo.x, bo.y);
					
				} else if(builder_type == ARMATURE_DRAG_TYPE.moveTail) {
					var chs = [];
					for( var i = 0, n = array_length(builder_bone.childs); i < n; i++ ) {
						var ch = builder_bone.childs[i];
						chs[i] = ch.getTail();
					}
				
					builder_bone.angle  = dir;
					builder_bone.length = dis;
					
					for( var i = 0, n = array_length(builder_bone.childs); i < n; i++ ) {
						var ch = builder_bone.childs[i];
						var c0 = ch.getHead();
					
						ch.angle  = point_direction(c0.x, c0.y, chs[i].x, chs[i].y);
						ch.length = point_distance( c0.x, c0.y, chs[i].x, chs[i].y);
					}
				}
			} else {
				if(builder_type == ARMATURE_DRAG_TYPE.move) {
					builder_bone.direction = dir;
					builder_bone.distance  = dis;
					
					orig = builder_bone.getHead();
					var _rx = _x + _s * orig.x;
					var _ry = _y + _s * orig.y;
					var  cc = COLORS._main_value_positive;
					
					if(isUsingTool("Detach bones") && builder_bone.parent) { // re-attach
						var par_anc = builder_bone.parent.getTail();
						var pardist = point_distance(orig.x, orig.y, par_anc.x, par_anc.y) * _s;
						var inRange = pardist < 8 && !builder_bone.parent.is_main;
						
						if(inRange) {
							cc = COLORS._main_accent;
							if(mouse_release(mb_left)) 
								builder_bone.parent_anchor = true;
						}
					}
					
					draw_sprite_ui(THEME.bone_move, 0, _rx, _ry, 1, 1, 0, cc, 1);
					
				} else if(builder_type == ARMATURE_DRAG_TYPE.moveTail) {
					builder_bone.angle  = dir;
					builder_bone.length = dis;
					
					orig = builder_bone.getTail();
					var _rx = _x + _s * orig.x;
					var _ry = _y + _s * orig.y;
					draw_sprite_ui(THEME.bone_move, 0, _rx, _ry, 1, 1, 0, COLORS._main_value_positive, 1);
				}
			}
			
			if(mouse_release(mb_left)) {
				builder_bone = noone;
				UNDO_HOLDING = false;
			}
			
			gpu_set_texfilter(false);
			triggerRender();
				
		}
		
		var _tool = getUsingToolName();
		
		switch(_tool) {
			case "Transform" : 
				drawOverlay_Transform(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
				return true;
				
			case "Add Bone" : 
				hovering = true;
				if(builder_bone == noone) {
					anchor_selecting = _b.draw(attributes, active * 0b111, _x, _y, _s, _mx, _my, anchor_selecting);
					_b.drawControl(attributes);
				}
				
				if(mouse_press(mb_left, active)) {
					
					if(anchor_selecting == noone) {
						builder_bone = createBone(bones, point_distance(0, 0, smx, smy), point_direction(0, 0, smx, smy));
						builder_type = ARMATURE_DRAG_TYPE.moveTail;
						
						builder_sx   = smx;
						builder_sy   = smy;
						UNDO_HOLDING = true;
						bones.setPosition();
						
					} else if(anchor_selecting[1] == 1) {
						builder_bone = createBone(anchor_selecting[0], 0, 0);
						builder_type = ARMATURE_DRAG_TYPE.moveTail;
						
						builder_sx   = smx;
						builder_sy   = smy;
						UNDO_HOLDING = true;
						bones.setPosition();
						
					} else if(anchor_selecting[1] == 2) {
						var _pr = anchor_selecting[0];
						recordAction(ACTION_TYPE.struct_modify, bones)
							.setName("Add bone");
						
						var _md = new __Bone(noone, 0, 0, _pr.angle, _pr.length / 2, self);
						_pr.length = _md.length;
						
						for( var i = 0, n = array_length(_pr.childs); i < n; i++ )
							_md.addChild(_pr.childs[i]);
						
						_pr.childs = [];
						_pr.addChild(_md);
						
						UNDO_HOLDING = true;
						triggerRender();
					}
				}
				
				if(anchor_selecting == noone)
					draw_sprite_ui(THEME.bone_tool_add, 1, _mx + 16, _my + 16, 1, 1, 0, c_white, 1);
					
				else if(anchor_selecting[1] == 1) {
					draw_sprite_ui(THEME.bone_tool_add, 0, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
					draw_sprite_ui(THEME.bone_tool_add, 1, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
					
				} else if(anchor_selecting[1] == 2)
					draw_sprite_ui(THEME.bone_tool_add, 0, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
				break;
				
			case "Add Control Bone" : 
				hovering = true;
				_b.draw(attributes, false, _x, _y, _s, _mx, _my);
				
				if(mouse_press(mb_left, active)) {
					builder_bone = createBone(bones, point_distance(0, 0, smx, smy), point_direction(0, 0, smx, smy));
					builder_bone.control = true;
				}
				
				draw_sprite_ui(THEME.bone_tool_add_control, 0, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
				break;
				
			case "Remove Bone" : 
				anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
				
				if(anchor_selecting != noone && anchor_selecting[1] == 2 && anchor_selecting[0].parent != noone && mouse_press(mb_left, active)) {
					var _bone = anchor_selecting[0];
					var _par  = _bone.parent;
					
					recordAction(ACTION_TYPE.struct_modify, bones)
						.setName($"Remove bone [{_bone.name}]");
							
					array_remove(_par.childs, _bone);
					
					for( var i = 0, n = array_length(_bone.childs); i < n; i++ ) {
						var _ch = _bone.childs[i];
						_par.addChild(_ch);
						
						_ch.parent_anchor = _bone.parent_anchor;
					}
						
					triggerRender();
				}
				
				if(anchor_selecting != noone) 
					draw_sprite_ui(THEME.bone_tool_remove, 1, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
				break;
				
			case "Detach Bone" : 
				if(builder_bone == noone)
					anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
				
				if(anchor_selecting != noone && anchor_selecting[1] == 2 && mouse_press(mb_left, active)) {
					var detach_bone = anchor_selecting[0];
					
					recordAction(ACTION_TYPE.struct_modify, bones)
						.setName($"Detach bone [{detach_bone.name}]");
						
					var par = detach_bone.parent;
					if(detach_bone.parent_anchor) {
						detach_bone.distance  = par.length;
						detach_bone.direction = par.angle;
					}
					detach_bone.parent_anchor = false;
					
					builder_bone = detach_bone;
					builder_type = ARMATURE_DRAG_TYPE.move;
					
					var head = par.getHead();
					builder_sx   = head.x;
					builder_sy   = head.y;
					builder_mx   = mx;
					builder_my   = my;
					UNDO_HOLDING = true;
				}
				break;
				
			case "IK" : 
				if(ik_dragging == noone)
					anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
				else {
					anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting, ik_dragging);
					_b.drawControl(attributes);
					
					var _bone = ik_dragging;
					var p1    = ik_dragging.getTail();
					var p1x   = _x + p1.x * _s;
					var p1y   = _y + p1.y * _s;
						
					if(anchor_selecting != noone && anchor_selecting[1] == 2) {
						var anc    = anchor_selecting[0];
						var bne    = anc;
						var _reach = false;
						var _blen  = 0;
						
						while(_bone != noone) {
							_blen++;
							_bone = _bone.parent;
							
							if(_bone == anc.parent) {
								_reach = true;
								bne    = anc;
								anc    = anc.parent;
								break;
							}
						}
						
						if(_reach) {
							var  p0 = anc.getHead();
							var p0t = bne.getHead();
							var _px = _x + p0t.x * _s;
							var _py = _y + p0t.y * _s;
							draw_line_dashed(_px, _py, p1x, p1y, 2, 8);
							draw_sprite_ui(THEME.preview_bone_IK, 1, _px, _py, 1, 1, 0, COLORS._main_accent, 1);
							
							if(mouse_release(mb_left)) {
								var _len = point_distance(p0.x, p0.y, p1.x, p1.y);
								var _ang = point_direction(p0.x, p0.y, p1.x, p1.y);
								
								recordAction(ACTION_TYPE.struct_modify, bones)
									.setName("Adjust bone IK")
									.setRef(self);
								
								var IKbone = new __Bone(anc, _len, _ang, ik_dragging.angle + 90, 0, self);
								anc.addChild(IKbone);
								
								IKbone.direction  = _ang;
								IKbone.distance   = _len;
								IKbone.control    = true;
								IKbone.IKlength   = _blen;
								IKbone.IKTargetID = ik_dragging.ID;
								
								IKbone.name = "IK handle";
								IKbone.parent_anchor = false;
								
								bones.setPosition();
							}
						}
						
						draw_sprite_ui(THEME.preview_bone_IK, 0, p1x, p1y, 1, 1, 0, _reach? COLORS._main_value_positive : COLORS._main_accent, 1);
						
					} else
						draw_sprite_ui(THEME.preview_bone_IK, 0, p1x, p1y, 1, 1, 0, COLORS._main_accent, 0.5);
					
					if(mouse_release(mb_left)) {
						ik_dragging  = noone;
						UNDO_HOLDING = false;
						bones.setPosition();
					}
					
					triggerRender();
				}
				
				if(anchor_selecting != noone && anchor_selecting[1] == 2 && mouse_press(mb_left, active))
					ik_dragging = anchor_selecting[0];
				break;
				
			case "Mirror Bones" : 
				if(builder_bone == noone)
					anchor_selecting = _b.draw(attributes, active * 0b111, _x, _y, _s, _mx, _my, anchor_selecting);
				
				if(mirroring_bone != noone) {
					var _maxis = anchor_selecting == noone || anchor_selecting[0] == mirroring_bone? mirroring_bone.parent.angle : anchor_selecting[0].angle;
					var _ori   = mirroring_bone.getHead();
					
					var _ox = _x + _ori.x * _s;
					var _oy = _y + _ori.y * _s;
					
					var _x0 = _ox + lengthdir_x(64, _maxis);
					var _y0 = _oy + lengthdir_y(64, _maxis);
					var _x1 = _ox - lengthdir_x(64, _maxis);
					var _y1 = _oy - lengthdir_y(64, _maxis);
					
					BLEND_ADD
					draw_set_color(COLORS._main_accent);
					draw_line_dashed(_x0, _y0, _x1, _y1, 3);
					BLEND_NORMAL
					
					if(mouse_release(mb_left)) {
						var _mirrored = mirroring_bone.clone();
						var _mirArr   = _mirrored.toArray();
						
						for( var i = 0, n = array_length(_mirArr); i < n; i++ ) {
							var _bm = _mirArr[i];
						    _bm.ID  = UUID_generate();
							
								 if(string_pos(" L", _bm.name)) _bm.name = string_replace(_bm.name, " L", " R");
							else if(string_pos(" R", _bm.name)) _bm.name = string_replace(_bm.name, " R", " L");
							
							_bm.angle = _maxis + angle_difference(_maxis, _bm.angle);
						}
						
						mirroring_bone.parent.addChild(_mirrored);
						mirroring_bone = noone;
						
						triggerRender();
					}
					
				} else if(anchor_selecting != noone) {
					var _bne = anchor_selecting[0];
					var _typ = anchor_selecting[1];
					
					if(_bne.parent && mouse_press(mb_left, active)) {
						recordAction(ACTION_TYPE.struct_modify, bones)
							.setName($"Mirror bone")
							.setRef(self);
						
						mirroring_bone = _bne;
					}
				}
				break;
				
			default : // move bones
				if(anchor_selecting != noone) {
					var _bne = anchor_selecting[0];
					var _typ = anchor_selecting[1];
					
					if(_bne.control) _typ = ARMATURE_DRAG_TYPE.move;
					
					gpu_set_texfilter(true);
					
					if(_typ == ARMATURE_DRAG_TYPE.move) { // free move
						var orig = _bne.getHead();
						draw_sprite_ui(THEME.bone_move, 0, _x + _s * orig.x, _y + _s * orig.y, 1, 1, 0, COLORS._main_accent, 1);
						
					} else if(_typ == ARMATURE_DRAG_TYPE.moveTail) { // bone move
						var orig = _bne.getTail();
						draw_sprite_ui(THEME.bone_move, 0, _x + _s * orig.x, _y + _s * orig.y, 1, 1, 0, COLORS._main_accent, 1);
						
					} else if(_typ == ARMATURE_DRAG_TYPE.rotate) { // bone rotate
						var orig = _bne.getHead();
						var _rx = _x + _s * orig.x;
						var _ry = _y + _s * orig.y;
						
						var orig = _bne.getPoint(0.8);
						var _sx = _x + _s * orig.x;
						var _sy = _y + _s * orig.y;
						
						if(point_in_circle(_mx, _my, _sx, _sy, 12)) {
							draw_sprite_ui(THEME.bone_scale,  0, _sx, _sy, 1, 1, _bne.angle, COLORS._main_accent, 1);
							draw_sprite_ui(THEME.bone_rotate, 0, _rx, _ry, 1, 1, _bne.angle, c_white, 1);
							_typ = ARMATURE_DRAG_TYPE.rotate;
							
						} else {
							draw_sprite_ui(THEME.bone_scale,  0, _sx, _sy, 1, 1, _bne.angle, c_white, 1);
							draw_sprite_ui(THEME.bone_rotate, 0, _rx, _ry, 1, 1, _bne.angle, COLORS._main_accent, 1);
							_typ = ARMATURE_DRAG_TYPE.rotate;
						}
					}
					
					gpu_set_texfilter(false);
					
					if(mouse_press(mb_left, active)) {
						builder_bone = _bne;
						builder_type = _typ;
						
						bone_select   = [];
						bone_selected = false;
						
						recordAction(ACTION_TYPE.struct_modify, bones).setName($"Modify bone [{_bne.name}]").setRef(self);
						
						if(_typ == ARMATURE_DRAG_TYPE.move) {
							var orig = _bne.parent.getHead();
							builder_sx = orig.x;
							builder_sy = orig.y;
							
						} else if(_typ == ARMATURE_DRAG_TYPE.moveTail) {
							var orig = _bne.getHead();
							builder_sx = orig.x;
							builder_sy = orig.y;
							
						} else if(_typ == ARMATURE_DRAG_TYPE.rotate) {
							var orig = _bne.getHead();
							builder_sv = point_direction(orig.x, orig.y, mx, my);
							builder_sx = orig.x;
							builder_sy = orig.y;
							builder_mx = mx;
							builder_my = my;
							
						} else if(_typ == ARMATURE_DRAG_TYPE.scale) {
							var orig = _bne.getHead();
							builder_sv = point_distance(orig.x, orig.y, mx, my) / _bne.length;
							builder_sx = orig.x;
							builder_sy = orig.y;
						} 
						
						UNDO_HOLDING = true;
					}
				}
				break;
		}
		
		#region select drag
			var _show_selecting = isNotUsingTool() && builder_bone == noone;
			
			if(isUsingTool()) {
				var _currTool = PANEL_PREVIEW.tool_current;
				var _tool     = _currTool.getToolObject();
				
				if(_tool != noone) {
					_tool.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
					if(mouse_lclick()) bone_freeze = 1;
					_show_selecting = true;
				}
			}
			
			if(_show_selecting) {
				anchor_selecting = _b.draw(attributes, active * 0b111, _x, _y, _s, _mx, _my, anchor_selecting);
				_b.drawControl(attributes);
				
				if(bone_freeze == 0 && panel.selection_selecting) {
					var sx0 = panel.selection_x0;
					var sy0 = panel.selection_y0;
					var sx1 = panel.selection_x1;
					var sy1 = panel.selection_y1;
					
					bone_select   = [];
					bone_selected = false;
					
					for( var i = 0, n = array_length(bone_points); i < n; i += 3 ) {
						var _bone = bone_points[i + 0];
						var _h    = bone_points[i + 1];
						var _t    = bone_points[i + 2];
						
						var _inh = point_in_rectangle(_h.x, _h.y, sx0, sy0, sx1, sy1);
						var _int = point_in_rectangle(_t.x, _t.y, sx0, sy0, sx1, sy1);
						
						if(_inh && _int) array_push(bone_select, i + 0);
						if(_inh) array_push(bone_select, i + 1);
						if(_int) array_push(bone_select, i + 2);
					}
				}
				
				if(mouse_lrelease()) {
					bone_freeze = 0;
					array_unique_ext(bone_select);
					if(!array_empty(bone_select))
						bone_selected = true;
				}
				
				for( var i = 0, n = array_length(bone_select); i < n; i++ ) {
					var _bone = bone_points[bone_select[i]];
					
					if(is(_bone, __Bone)) _bone.drawSimple(attributes, _x, _y, _s, _mx, _my, c_white);
					if(is(_bone, __vec2)) draw_anchor(0, _x + _bone.x * _s, _y + _bone.y * _s, ui(8), 2); 
				}
				
			} else {
				bone_select   = [];
				bone_selected = false;
			}
		#endregion
		
		if(anchor_selecting != noone) hovering = true;
		return hovering;
	} 
	
	static getPreviewBoundingBox = function() { 
		var minx =  9999999;
		var miny =  9999999;
		var maxx = -9999999;
		var maxy = -9999999;
		
		var _b = bones;
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _b);
		
		while(!ds_stack_empty(_bst)) {
			var __b = ds_stack_pop(_bst);
			
			for( var i = 0, n = array_length(__b.childs); i < n; i++ ) {
				var p0 = __b.childs[i].getHead();
				var p1 = __b.childs[i].getTail();
				
				minx = min(minx, p0.x); miny = min(miny, p0.y);
				maxx = max(maxx, p0.x); maxy = max(maxy, p0.y);
				
				minx = min(minx, p1.x); miny = min(miny, p1.y);
				maxx = max(maxx, p1.x); maxy = max(maxy, p1.y);
				
				ds_stack_push(_bst, __b.childs[i]);
			}
		}
		
		ds_stack_destroy(_bst);
		
		if(minx == 9999999) return noone;
		if(abs(maxx - minx) < 1) maxx = minx + 1;
		if(abs(maxy - miny) < 1) maxy = miny + 1;
		
		return BBOX().fromPoints(minx, miny, maxx, maxy);
	} 
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { 
		var bbox = drawGetBbox(xx, yy, _s);
		
		var _ss = _s * .5;
		draw_sprite_ext_filter(s_node_armature, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
		
		bones.drawThumbnail(_s, bbox, bone_bbox);
	} 
	
	////- Action
	
	static step = function() {}
	
	static update = function(frame = CURRENT_FRAME) { 
		array_foreach(bones.constrains, function(c) /*=>*/ { c.bone = bones; c.init(); });
		
		bones.resetPose().setPosition();
		outputs[0].setValue(bones);
		
		bone_bbox   = bones.bbox();
		bone_array  = bones.toArray();
		bone_points = bones.toPoints();
	} 
	
	////- Serialize
	
	static doSerialize = function(_map) { 
		_map.bones = bones.serialize();
	} 
	
	static postDeserialize = function() { 
		if(struct_has(attributes, "bones")) struct_remove(attributes, "bones");
		if(!struct_has(load_map, "bones")) return;
		
		bones = new __Bone(,,,,, self);
		bones.deserialize(load_map.bones, self);
		bones.connect();
		
		bone_array = bones.toArray();
	} 
	
	////- Actions
	
	static boneSelector = function(fn) {
		__bone_fn = fn;
		menuCall("", array_map(bone_array, function(b) /*=>*/ {return new MenuItem(b.name, __bone_fn, [ THEME.bone, b.getSpriteIndex(), 1 ]).setParam({ bone: b })}) );
	}
}

