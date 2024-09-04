function Node_Armature(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Create";
	setDimension(96, 72);
	
	//newInput(0, nodeValue_Int("Axis", self, 0));
	
	bone_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var _b  = attributes.bones;
		if(_b == noone) return 0;
		var amo = _b.childCount();
		var _hh = ui(28);
		var bh  = ui(32 + 16) + amo * _hh;
		var ty  = _y;
			
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
		draw_text_add(_x + ui(16), ty + ui(4), __txt("Bones"));
			
		ty += ui(32);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, bh - ui(32), COLORS.node_composite_bg_blend, 1);
		draw_set_color(COLORS.node_composite_separator);
		draw_line(_x + 16, ty + ui(8), _x + _w - 16, ty + ui(8));
		
		ty += ui(8);
		
		var hovering = noone;
		var _bst = ds_stack_create();
		ds_stack_push(_bst, [ _b, _x, _w ]);
		
		var bone_remove = noone;
		
		while(!ds_stack_empty(_bst)) {
			var _st  = ds_stack_pop(_bst);
			var bone = _st[0];
			var __x  = _st[1];
			var __w  = _st[2];
			
			for( var i = 0, n = array_length(bone.childs); i < n; i++ )
				ds_stack_push(_bst, [ bone.childs[i], __x + 16, __w - 16 ]);
				
			if(bone.is_main) continue;
			
			if(bone.parent_anchor) 
				draw_sprite_ui(THEME.bone, 1, __x + 12, ty + 14,,,, COLORS._main_icon);
			else if(bone.IKlength) 
				draw_sprite_ui(THEME.bone, 2, __x + 12, ty + 14,,,, COLORS._main_icon);
			else {
				if(_hover && point_in_circle(_m[0], _m[1], __x + 12, ty + 12, 12)) {
					draw_sprite_ui(THEME.bone, 0, __x + 12, ty + 14,,,, COLORS._main_icon_light);
					if(mouse_press(mb_left, _focus))
						bone_dragging = bone;
				} else 
					draw_sprite_ui(THEME.bone, 0, __x + 12, ty + 14,,,, COLORS._main_icon);
			}
				
			if(point_in_rectangle(_m[0], _m[1], __x + 24, ty + 3, __x + __w, ty + _hh - 3))
				anchor_selecting = [ bone, 2 ];
			
			var bx = __x + __w - 24;
			var by = ty + _hh / 2;
			
			if(point_in_circle(_m[0], _m[1], bx, by, 16)) {
				draw_sprite_ui_uniform(THEME.icon_delete, 3, bx, by, 1, COLORS._main_value_negative);
				
				if(mouse_press(mb_left, _focus))
					bone_remove = bone;
			} else 
				draw_sprite_ui_uniform(THEME.icon_delete, 3, bx, by, 1, COLORS._main_icon);
			
			draw_set_font(f_p2);
			var ww = string_width(bone.name);
			
			bone.tb_name.setFocusHover(_focus, _hover);
			bone.tb_name.draw(__x + 24, ty + 3, ww + 16, _hh - 6, bone.name, _m);
			
			var _x0 = __x + 24 + ww + 32;
			var _y0 = ty + 14;
			var cc  = bone.apply_scale? COLORS._main_icon : COLORS._main_value_negative;
			if(point_in_circle(_m[0], _m[1], _x0, _y0, 16)) {
				TOOLTIP = "Apply scale";
				draw_sprite_ui(THEME.bone, 3, _x0, _y0,,,, cc, 0.75);
				
				if(mouse_press(mb_left, _focus))
					bone.apply_scale = !bone.apply_scale;
			} else 
				draw_sprite_ui(THEME.bone, 3, _x0, _y0,,,, cc, 0.5);
			
			_x0 += 20;
			var cc  = bone.apply_rotation? COLORS._main_icon : COLORS._main_value_negative;
			if(point_in_circle(_m[0], _m[1], _x0, _y0, 16)) {
				TOOLTIP = "Apply rotation";
				draw_sprite_ui(THEME.bone, 4, _x0, _y0,,,, cc, 0.75);
				
				if(mouse_press(mb_left, _focus))
					bone.apply_rotation = !bone.apply_rotation;
			} else 
				draw_sprite_ui(THEME.bone, 4, _x0, _y0,,,, cc, 0.5);
			
			ty += _hh;
				
			draw_set_color(COLORS.node_composite_separator);
			draw_line(_x + 16, ty, _x + _w - 16, ty);
		}
		
		ds_stack_destroy(_bst);
		
		if(bone_dragging && mouse_release(mb_left))
			bone_dragging = noone;
			
		if(bone_remove != noone) {
			var _par = bone_remove.parent;
			recordAction(ACTION_TYPE.struct_modify, attributes.bones, attributes.bones.serialize());
			array_remove(_par.childs, bone_remove);
				
			for( var i = 0, n = array_length(bone_remove.childs); i < n; i++ ) {
				var _ch = bone_remove.childs[i];
				_par.addChild(_ch);
						
				_ch.parent_anchor = bone_remove.parent_anchor;
			}
		}
		
		return bh;
	}); #endregion
	
	input_display_list = [
		bone_renderer,
	];
	
	static createBone = function(parent, distance, direction) { #region
		recordAction(ACTION_TYPE.struct_modify, attributes.bones, attributes.bones.serialize());
		
		var bone  = new __Bone(parent, distance, direction,,, self);
		parent.addChild(bone);
		
		if(parent == attributes.bones) 
			bone.parent_anchor = false;
		return bone;
	} #endregion
	
	newOutput(0, nodeValue_Output("Armature", self, VALUE_TYPE.armature, noone));
	
	#region ++++ attributes ++++
	attributes.bones = new __Bone(,,,,, self);
	attributes.bones.name = "Main";
	attributes.bones.is_main = true;
	attributes.bones.node = self;
	
	attributes.display_name = true;
	attributes.display_bone = 0;
	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Display name", function() { return attributes.display_name; }, 
		new checkBox(function() { 
			attributes.display_name = !attributes.display_name;
		})]);
	array_push(attributeEditors, ["Display bone", function() { return attributes.display_bone; }, 
		new scrollBox(["Octahedral", "Stick"], function(ind) { 
			attributes.display_bone = ind;
		})]);
	#endregion
	
	tools = [
		new NodeTool( [ "Move", "Scale" ], [ THEME.bone_tool_move, THEME.bone_tool_scale ] ),
		new NodeTool( "Add bones", THEME.bone_tool_add ),
		new NodeTool( "Remove bones", THEME.bone_tool_remove ),
		new NodeTool( "Detach bones", THEME.bone_tool_detach ),
		new NodeTool( "IK", THEME.bone_tool_IK ),
	];
	
	anchor_selecting = noone;
	builder_bone = noone;
	builder_type = 0;
	builder_sx = 0;
	builder_sy = 0;
	builder_mx = 0;
	builder_my = 0;
	
	builder_moving  = false;
	builder_scaling = false;
	
	bone_dragging = noone;
	ik_dragging = noone;
	
	moving = false;
	scaling = false;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var smx = value_snap(mx, _snx);
		var smy = value_snap(my, _sny);
		
		var _b = attributes.bones;
		
		if(builder_bone != noone) { #region
			anchor_selecting = _b.draw(attributes, false, _x, _y, _s, _mx, _my, anchor_selecting);
			
			var dir = point_direction(builder_sx, builder_sy, smx, smy);
			var dis = point_distance(builder_sx, builder_sy, smx, smy);
			
			if(builder_type == 2) {
				var bx = builder_sx + (smx - builder_mx);
				var by = builder_sy + (smy - builder_my);
				
				if(!builder_bone.parent_anchor) {
					builder_bone.direction = point_direction(0, 0, bx, by);
					builder_bone.distance  = point_distance( 0, 0, bx, by);
				}
			} else if(key_mod_press(ALT)) {
				if(builder_type == 0) {
					var bo = builder_bone.getPoint(1);
					
					builder_bone.direction = dir;
					builder_bone.distance  = dis;
					
					var bn = builder_bone.getPoint(0);
					
					builder_bone.angle  = point_direction(bn.x, bn.y, bo.x, bo.y);
					builder_bone.length = point_distance( bn.x, bn.y, bo.x, bo.y);
				} else if(builder_type == 1) {
					var chs = [];
					for( var i = 0, n = array_length(builder_bone.childs); i < n; i++ ) {
						var ch = builder_bone.childs[i];
						chs[i] = ch.getPoint(1);
					}
				
					builder_bone.angle  = dir;
					builder_bone.length = dis;
					
					for( var i = 0, n = array_length(builder_bone.childs); i < n; i++ ) {
						var ch = builder_bone.childs[i];
						var c0 = ch.getPoint(0);
					
						ch.angle  = point_direction(c0.x, c0.y, chs[i].x, chs[i].y);
						ch.length = point_distance( c0.x, c0.y, chs[i].x, chs[i].y);
					}
				}
			} else {
				if(builder_type == 0) {
					builder_bone.direction = dir;
					builder_bone.distance  = dis;
					
					if(builder_bone.parent) {
						var par_anc = builder_bone.parent.getPoint(1);
						par_anc.x = _x + par_anc.x * _s;
						par_anc.y = _y + par_anc.y * _s;
						
						var inRange = point_in_circle(_mx, _my, par_anc.x, par_anc.y, 16) && mouse_release(mb_left);
						if(!builder_bone.parent.is_main && builder_bone.IKlength > 0 && inRange)
							builder_bone.parent_anchor = true;
					}
				} else if(builder_type == 1) {
					builder_bone.angle  = dir;
					builder_bone.length = dis;
				}
			}
			
			if(mouse_release(mb_left)) {
				builder_bone = noone;
				UNDO_HOLDING = false;
			}
			
			triggerRender();
		#endregion
		} else if(ik_dragging != noone) { #region
			anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting, ik_dragging);
			
			if(anchor_selecting != noone && anchor_selecting[1] == 2) {
				var anc = anchor_selecting[0];
				
				var reachable = false;
				var _bone = ik_dragging.parent;
				var len   = 0;
				
				while(_bone != noone) {
					if(_bone == anc.parent) {
						reachable = true;
						break;
					}
					
					len++;
					_bone = _bone.parent;
				}
				
				if(reachable && mouse_release(mb_left)) {
					var p1 = ik_dragging.getPoint(1);
					var p0 = anc.getPoint(0);
					
					var _len = point_distance(p0.x, p0.y, p1.x, p1.y);
					var _ang = point_direction(p0.x, p0.y, p1.x, p1.y);
					
					recordAction(ACTION_TYPE.struct_modify, attributes.bones, attributes.bones.serialize());
					
					var IKbone = new __Bone(anc, _len, _ang, ik_dragging.angle + 90, 0, self);
					anc.addChild(IKbone);
					IKbone.IKlength   = len;
					IKbone.IKTargetID = ik_dragging.ID;
					
					IKbone.name = "IK handle";
					IKbone.parent_anchor = false;
				}
			}
			
			if(mouse_release(mb_left)) {
				ik_dragging = noone;
				UNDO_HOLDING = false;
			}
			
			triggerRender();
		#endregion
		} 
		
		if(isUsingTool("Move")) { #region
			_b.draw(attributes, false, _x, _y, _s, _mx, _my);
			
			var bbox = _b.bbox();
			var x0 = _x + bbox[0] * _s;
			var y0 = _y + bbox[1] * _s;
			var x1 = _x + bbox[2] * _s;
			var y1 = _y + bbox[3] * _s;
			
			if(builder_moving) {
				var dx = (mx - builder_mx) / _s;
				var dy = (my - builder_my) / _s;
				
				builder_mx = mx;
				builder_my = my;
				
				var _bx = lengthdir_x(_b.distance, _b.direction) + dx;
				var _by = lengthdir_y(_b.distance, _b.direction) + dy;
				
				_b.distance  = point_distance(0, 0, _bx, _by);
				_b.direction = point_direction(0, 0, _bx, _by);
				
				if(mouse_release(mb_left)) {
					builder_moving = false;
					UNDO_HOLDING = false;
				}
					
				draw_set_color(COLORS._main_accent);
				draw_rectangle(x0, y0, x1, y1, true);
			} else {
				if(point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
					draw_set_color(COLORS._main_accent);
					if(mouse_press(mb_left, active)) {
						builder_moving = true;
						builder_mx = mx;
						builder_my = my;
						
						recordAction(ACTION_TYPE.struct_modify, attributes.bones, attributes.bones.serialize());
					}
				} else
					draw_set_color(c_white);
				
				draw_set_alpha(0.5);
				draw_rectangle(x0, y0, x1, y1, true);
				draw_set_alpha(1);
			}
		#endregion
		} else if(isUsingTool("Scale")) { #region
			_b.draw(attributes, false, _x, _y, _s, _mx, _my);
			
			var bbox = _b.bbox();
			var x0 = _x + bbox[0] * _s;
			var y0 = _y + bbox[1] * _s;
			var x1 = _x + bbox[2] * _s;
			var y1 = _y + bbox[3] * _s;
			
			draw_set_color(c_white);
			draw_set_alpha(0.5);
			draw_rectangle(x0, y0, x1, y1, true);
			draw_set_alpha(1);
			
			var cx  = (x0 + x1) / 2;
			var cy  = (y0 + y1) / 2;
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5 + builder_scaling * 0.5);
			draw_line(cx, cy, _mx, _my);
			draw_set_alpha(1);
			
			if(builder_scaling) {
				var _so = point_distance(cx, cy, builder_mx, builder_my);
				var _sn = point_distance(cx, cy, _mx, _my);
				var _ss = 1 + (_sn - _so) / max(_so, 8);
					
				builder_mx = _mx;
				builder_my = _my;
				
				var _bst = ds_stack_create();
				ds_stack_push(_bst, _b);
		
				while(!ds_stack_empty(_bst)) {
					var __b = ds_stack_pop(_bst);			
					for( var i = 0, n = array_length(__b.childs); i < n; i++ )
						ds_stack_push(_bst, __b.childs[i]);
						
					__b.distance *= _ss;
					__b.length   *= _ss;
				}
		
				ds_stack_destroy(_bst);
				
				var bbox_n	= _b.bbox();
				var _ox	= (bbox[0] + bbox[2]) / 2 - (bbox_n[0] + bbox_n[2]) / 2;
				var _oy	= (bbox[1] + bbox[3]) / 2 - (bbox_n[1] + bbox_n[3]) / 2;
				
				var _bx = lengthdir_x(_b.distance, _b.direction) + _ox;
				var _by = lengthdir_y(_b.distance, _b.direction) + _oy;
				
				_b.distance  = point_distance(0, 0, _bx, _by);
				_b.direction = point_direction(0, 0, _bx, _by);
					
				if(mouse_release(mb_left)) {
					builder_scaling = false;
				}
			} else {
				if(mouse_press(mb_left, active)) {
					builder_scaling = true;
					builder_mx = _mx;
					builder_my = _my;
					
					recordAction(ACTION_TYPE.struct_modify, attributes.bones, attributes.bones.serialize());
				}
			}
		#endregion
		} else if(isUsingTool("Add bones")) { #region // builder
			if(builder_bone == noone)
				anchor_selecting = _b.draw(attributes, active * 0b111, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(mouse_press(mb_left, active)) {
				if(anchor_selecting == noone) {
					builder_bone = createBone(attributes.bones, point_distance(0, 0, smx, smy), point_direction(0, 0, smx, smy));
					builder_type = 1;
					builder_sx = smx;
					builder_sy = smy;
					UNDO_HOLDING = true;
					
				} else if(anchor_selecting[1] == 1) {
					builder_bone = createBone(anchor_selecting[0], 0, 0);
					builder_type = 1;
					builder_sx = smx;
					builder_sy = smy;
					UNDO_HOLDING = true;
					
				} else if(anchor_selecting[1] == 2) {
					var _pr = anchor_selecting[0];
					recordAction(ACTION_TYPE.struct_modify, attributes.bones, attributes.bones.serialize());
					
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
				draw_sprite_ext(THEME.bone_tool_add, 1, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
			else if(anchor_selecting[1] == 1) {
				draw_sprite_ext(THEME.bone_tool_add, 0, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
				draw_sprite_ext(THEME.bone_tool_add, 1, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
			} else if(anchor_selecting[1] == 2)
				draw_sprite_ext(THEME.bone_tool_add, 0, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
		#endregion
		} else if(isUsingTool("Remove bones")) { #region //remover
			anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(anchor_selecting != noone && anchor_selecting[1] == 2 && anchor_selecting[0].parent != noone && mouse_press(mb_left, active)) {
				var _bone = anchor_selecting[0];
				var _par  = _bone.parent;
				
				array_remove(_par.childs, _bone);
				
				for( var i = 0, n = array_length(_bone.childs); i < n; i++ ) {
					var _ch = _bone.childs[i];
					_par.addChild(_ch);
						
					_ch.parent_anchor = _bone.parent_anchor;
				}
					
				triggerRender();
			}
			
			if(anchor_selecting != noone)
				draw_sprite_ext(THEME.bone_tool_remove, 1, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
		#endregion
		} else if(isUsingTool("Detach bones")) { #region //detach
			if(builder_bone == noone)
				anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(anchor_selecting != noone && anchor_selecting[1] == 2 && mouse_press(mb_left, active)) {
				builder_bone = anchor_selecting[0];
				builder_type = anchor_selecting[1];
				
				var par = builder_bone.parent;
				if(builder_bone.parent_anchor) {
					builder_bone.distance  = par.length;
					builder_bone.direction = par.angle;
				}
				builder_bone.parent_anchor = false;
				
				builder_sx = lengthdir_x(builder_bone.distance, builder_bone.direction);
				builder_sy = lengthdir_y(builder_bone.distance, builder_bone.direction);
				builder_mx = mx;
				builder_my = my;
				UNDO_HOLDING = true;
			}
		#endregion
		} else if(isUsingTool("IK")) { #region //IK
			if(ik_dragging == noone)
				anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(anchor_selecting != noone && anchor_selecting[1] == 2 && mouse_press(mb_left, active)) {
				ik_dragging = anchor_selecting[0];
			}
		#endregion
		} else { #region //mover
			if(builder_bone == noone)
				anchor_selecting = _b.draw(attributes, active * 0b111, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(anchor_selecting != noone && mouse_press(mb_left, active)) {
				builder_bone = anchor_selecting[0];
				builder_type = anchor_selecting[1];
				
				recordAction(ACTION_TYPE.struct_modify, attributes.bones, attributes.bones.serialize());
				
				if(builder_type == 0) {
					var orig = builder_bone.parent.getPoint(0);
					builder_sx = orig.x;
					builder_sy = orig.y;
				} else if(builder_type == 1) {
					var orig = builder_bone.getPoint(0);
					builder_sx = orig.x;
					builder_sy = orig.y;
				} else if(builder_type == 2) {
					if(builder_bone.parent_anchor) {
						builder_bone = noone;
					} else {
						var par = builder_bone.parent;
						builder_sx = lengthdir_x(builder_bone.distance, builder_bone.direction);
						builder_sy = lengthdir_y(builder_bone.distance, builder_bone.direction);
						builder_mx = mx;
						builder_my = my;
					}
				}
				
				UNDO_HOLDING = true;
			}
		#endregion
		}
	} #endregion
	
	static step = function() {}
	
	static update = function(frame = CURRENT_FRAME) { #region
		outputs[0].setValue(attributes.bones);
	} #endregion
	
	static getPreviewBoundingBox = function() { #region
		var minx =  9999999;
		var miny =  9999999;
		var maxx = -9999999;
		var maxy = -9999999;
		
		var _b = attributes.bones;
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _b);
		
		while(!ds_stack_empty(_bst)) {
			var __b = ds_stack_pop(_bst);
			
			for( var i = 0, n = array_length(__b.childs); i < n; i++ ) {
				var p0 = __b.childs[i].getPoint(0);
				var p1 = __b.childs[i].getPoint(1);
				
				minx = min(minx, p0.x); miny = min(miny, p0.y);
				maxx = max(maxx, p0.x); maxy = max(maxy, p0.y);
				
				minx = min(minx, p1.x); miny = min(miny, p1.y);
				maxx = max(maxx, p1.x); maxy = max(maxy, p1.y);
				
				ds_stack_push(_bst, __b.childs[i]);
			}
		}
		
		ds_stack_destroy(_bst);
		
		if(minx == 9999999) return noone;
		return BBOX().fromPoints(minx, miny, maxx, maxy);
	} #endregion
	
	static attributeSerialize = function() { return {}; }
	static attributeDeserialize = function(attr) {}
	
	static doSerialize = function(_map) { #region
		_map.bones = attributes.bones.serialize();
	} #endregion
	
	static postDeserialize = function() { #region
		if(!struct_has(load_map, "bones")) return;
		attributes.bones = new __Bone(,,,,, self);
		attributes.bones.deserialize(load_map.bones, self);
		attributes.bones.connect();
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_armature_create, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}

