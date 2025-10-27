#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Armature_Pose", "Move Selection",   "G");
		hotkeyCustom("Node_Armature_Pose", "Rotate Selection", "R");
		hotkeyCustom("Node_Armature_Pose", "Scale Selection",  "S");
	});
	
	function armature_pose_tool_move(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		origin_x = 0;
		origin_y = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		drag_points = [];
		
		drag_axis = -1;
		
		params = {
			lock_scale: false, 
			lock_unselected: true, 
		}
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			var _bones = node.bone_select;
			if(array_empty(_bones)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			drag_points    = node.bonePose.toPoints(true);
			
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
			
			params.lock_scale = false;
			params.lock_unselected = true;
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
			
			for( var i = 0, n = array_length(drag_points); i < n; i++ )
				drag_points[i].selected = false;
			
			for( var i = 0, n = array_length(_bones); i < n; i++ ) {
				var bne = drag_points[_bones[i]];
				if(!is(bne, __vec2)) { bne.selected = true; continue; }
				
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
			
			node.bonePose.fromPoints(drag_points, node, params);
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
				
			if(key_press(ord("C"))) {
				params.lock_scale = !params.lock_scale;
				KEYBOARD_STRING = "";
			}
			
			if(key_press(ord("U"))) {
				params.lock_unselected = !params.lock_unselected;
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
			
			_tooltipText += $": [C] Lock Scale {params.lock_scale? "On":"Off"}";
			_tooltipText += $": [U] Lock Unselected {params.lock_unselected? "On":"Off"}";
			
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
	function armature_pose_tool_rotate(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		rotate_acc  = 0;
		origin_x    = 0;
		origin_y    = 0;
		
		params = {
			lock_scale: false, 
			lock_unselected: true, 
		}
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			var _bones = node.bone_select;
			if(array_empty(_bones)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			drag_points    = node.bonePose.toPoints(true);
			
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
			
			params.lock_scale = false;
			params.lock_unselected = true;
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
			
			for( var i = 0, n = array_length(drag_points); i < n; i++ )
				drag_points[i].selected = false;
			
			for( var i = 0, n = array_length(_bones); i < n; i++ ) {
				var bne = drag_points[_bones[i]];
				if(!is(bne, __vec2)) { bne.selected = true; continue; }
				
				var dis = point_distance(  origin_x, origin_y, bne.sx, bne.sy );
				var dir = point_direction( origin_x, origin_y, bne.sx, bne.sy );
				
				bne.x = origin_x + lengthdir_x(dis, dir + rr);
				bne.y = origin_y + lengthdir_y(dis, dir + rr);
				
			}
			
			node.bonePose.fromPoints(drag_points, node, params);
			node.triggerRender();
			
			draw_set_color(COLORS._main_icon);
			draw_line_dashed(ox, oy, _mx, _my);
			
			if(key_press(ord("C"))) {
				params.lock_scale = !params.lock_scale;
				KEYBOARD_STRING = "";
			}
			
			if(key_press(ord("U"))) {
				params.lock_unselected = !params.lock_unselected;
				KEYBOARD_STRING = "";
			}
			
			if(mouse_press(mb_left) || key_press(vk_enter)) {
				activeKeyboard = false;
				UNDO_HOLDING   = false;
				PANEL_PREVIEW.resetTool();
			}
			
			var _tooltipText = "Rotating";
			
			_tooltipText += $": [C] Lock Scale {params.lock_scale? "On":"Off"}";
			_tooltipText += $": [U] Lock Unselected {params.lock_unselected? "On":"Off"}";
			
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
	function armature_pose_tool_scale(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		origin_x = 0;
		origin_y = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		params = {
			lock_scale: false, 
			lock_unselected: true, 
		}
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			var _bones = node.bone_select;
			if(array_empty(_bones)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			drag_points    = node.bonePose.toPoints(true);
			
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
			
			params.lock_scale = false;
			params.lock_unselected = true;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var _bones = node.bone_select;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var ox = _x + origin_x * _s;
			var oy = _y + origin_y * _s;
			
			var _ss = point_distance(_mx, _my, ox, oy) / point_distance(drag_pmx, drag_pmy, ox, oy);
			
			for( var i = 0, n = array_length(drag_points); i < n; i++ )
				drag_points[i].selected = false;
			
			for( var i = 0, n = array_length(_bones); i < n; i++ ) {
				var bne = drag_points[_bones[i]];
				if(!is(bne, __vec2)) { bne.selected = true; continue; }
				
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
			
			node.bonePose.fromPoints(drag_points, node, params);
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
				
			if(key_press(ord("C"))) {
				params.lock_scale = !params.lock_scale;
				KEYBOARD_STRING = "";
			}
			
			if(key_press(ord("U"))) {
				params.lock_unselected = !params.lock_unselected;
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
			
			_tooltipText += $": [C] Lock Scale {params.lock_scale? "On":"Off"}";
			_tooltipText += $": [U] Lock Unselected {params.lock_unselected? "On":"Off"}";
			
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
#endregion

function Node_Armature_Pose(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Pose";
	draw_padding = 8;
	preview_select_surface = false;
	setDimension(96, 96);
	
	newInput(0, nodeValue_Armature()).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 0 ]
	
	function createNewInput(index = array_length(inputs), bone = noone) {
		var inAmo = array_length(inputs);
		var _name = bone != noone? bone.name : "bone";
		
		newInput(index, nodeValue(_name, self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 0, 1 ] )).setDisplay(VALUE_DISPLAY.transform);
		inputs[index].attributes.bone_id = bone != noone? bone.ID : noone;
		
		if(bone != noone) boneMap[$ bone.ID] = inputs[index];
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	} 
	
	setDynamicInput(1, false);
	
	////- Bone
	
	boneHash    = "";
	bonePose    = noone;
	bone_bbox   = [0, 0, 1, 1, 1, 1];
	boneMap     = {};
	bone_array  = [];
	bone_points = [];
	
	bone_selected = false;
	bone_freeze   = 0;
	bone_select   = [];
	
	__node_bone_attributes();
	
	static setBone = function() {
		var _b = getInputData(0);
		if(!is(_b, __Bone)) { boneHash = ""; return; }
		
		var _h = _b.getHash();
		if(boneHash == _h) return;
		
		boneHash  = _h;
		bonePose  = _b.clone().connect();
		bone_array = bonePose.toArray();
		
		var _inputs = [ inputs[0] ];
		var _input_display_list = array_clone(input_display_list_raw, 1);
		
		for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
			var bone = bone_array[i];
			var _idx = array_length(_inputs);
			var _inp;
			
			array_push(_input_display_list, _idx);
			
			if(struct_exists(boneMap, bone.ID)) {
				_inp = boneMap[$ bone.ID];
				_inp.index = _idx;
				
			} else
				_inp = createNewInput(, bone);
			
			array_push(_inputs, _inp);
		}
		
		inputs = _inputs;
		input_display_list = _input_display_list;
	}
	
	tools = [
		new NodeTool( "Move Selection",   THEME.tools_2d_move   ).setVisible(false).setToolObject(new armature_pose_tool_move(self)),
		new NodeTool( "Rotate Selection", THEME.tools_2d_rotate ).setVisible(false).setToolObject(new armature_pose_tool_rotate(self)),
		new NodeTool( "Scale Selection",  THEME.tools_2d_scale  ).setVisible(false).setToolObject(new armature_pose_tool_scale(self)),
	];
	
	anchor_selecting = noone;
	posing_bone      = noone;
	posing_input     = 0;
	posing_type      = 0;
	pose_child_lock  = false;
	
	posing_sx = 0;
	posing_sy = 0;
	posing_mx = 0;
	posing_my = 0;
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _b = inputs[0].getValue();
		if(!is(_b, __Bone) || !is(bonePose, __Bone)) return;
		
		var _hov  = noone;
		var _bhov = anchor_selecting;
		var panel = _params[$ "panel"] ?? noone;
		var hovering = false;
		
		for( var i = 0, n = array_length(bonePose.constrains); i < n; i++ ) bonePose.constrains[i].drawBone(bonePose, _x, _y, _s);
		
		for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
			var _bne = bone_array[i];
			var _sel = false;
			var  cc  = c_white;
			
			if(struct_has(boneMap, _bne.ID)) {
				var _inp = boneMap[$ _bne.ID];
				_sel = _inp.value_from == noone || is(_inp.value_from.node, Node_Vector4);
				
				if(_bhov == noone && PANEL_INSPECTOR.prop_hover == _inp)
					_bhov = [ _bne, 2 ];
			}
			
			var _selectMask = isNotUsingTool()? _sel * active * 0b111 : false;
			
			var hh = _bne.drawBone(attributes, _selectMask, _x, _y, _s, _mx, _my, _bhov, posing_bone, cc, .5 + .5 * _sel);
			if(hh != noone && (_hov == noone || _bne.control)) _hov = hh;
		}
		
		anchor_selecting = _hov;
		bonePose.setControl(_x, _y, _s);
		bonePose.drawControl(attributes);
		
		if(anchor_selecting != noone) {
			hovering = true;
			var _bne = anchor_selecting[0];
			
			if(struct_has(boneMap, _bne.ID)) {
				var _inp = boneMap[$ _bne.ID];
				_inp.editWidget.temp_hovering = true;
			}
		}
		
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var smx = value_snap(mx, _snx);
		var smy = value_snap(my, _sny);
		
		if(posing_bone) {
			gpu_set_texfilter(true);
			var val = array_clone(posing_input.getValue());
			
			if(posing_type == 0) { //move
				var ang = posing_bone.pose_local_rotate; 
				var pp  = point_rotate(smx - posing_mx, smy - posing_my, 0, 0, -ang);
				var bx  = posing_sx + pp[0];
				var by  = posing_sy + pp[1];
				
				val[TRANSFORM.pos_x] = bx;
				val[TRANSFORM.pos_y] = by;
				
				orig = posing_bone.getHead();
				var _rx = _x + _s * orig.x;
				var _ry = _y + _s * orig.y;
				draw_sprite_ui(THEME.bone_move, 0, _rx, _ry, 1, 1, 0, COLORS._main_value_positive, 1);
				
			} else if(posing_type == 1) { //free move
				var _direction = point_direction(posing_sx, posing_sy, smx, smy);
				var _distance  = point_distance(posing_sx, posing_sy, smx, smy);
				
				var _orot = val[TRANSFORM.rot];
				var _osca = val[TRANSFORM.sca_x];
				var _nrot = _direction - (posing_bone.angle  + posing_bone.pose_local_rotate);
				var _nsca = _distance  / (posing_bone.length * posing_bone.pose_local_scale);
				
				val[TRANSFORM.rot]   = _nrot;
				val[TRANSFORM.sca_x] = _nsca;
				
				if(pose_child_lock) {
					var _dr = angle_difference(_nrot, _orot);
					var _ds = _nsca / _osca;
					
					for( var i = 0, n = array_length(posing_bone.childs); i < n; i++ ) {
						var _child = posing_bone.childs[i];
						
						var _input = boneMap[$ _child.ID];
						var _val   = array_clone(_input.getValue());
						if(_child.apply_rotation) _val[TRANSFORM.rot]   -= _dr;
						if(_child.apply_scale)    _val[TRANSFORM.sca_x] /= _ds;
						_input.setValue(_val);
					}
				}
				
				orig = posing_bone.getTail();
				var _rx = _x + _s * orig.x;
				var _ry = _y + _s * orig.y;
				draw_sprite_ui(THEME.bone_move, 0, _rx, _ry, 1, 1, 0, COLORS._main_value_positive, 1);
					
			} else if(posing_type == 2) { //rotate
				var ori = posing_bone.getHead();
				var ang = point_direction(ori.x, ori.y, mx, my);
				var rot = angle_difference(ang, posing_sy);
				posing_sy  = ang;
				posing_sx += rot;
				
				val[TRANSFORM.rot] = posing_sx;
				
				if(pose_child_lock && rot != 0)
				for( var i = 0, n = array_length(posing_bone.childs); i < n; i++ ) {
					var _child = posing_bone.childs[i];
					if(!_child.apply_rotation) continue;
					
					var _input = boneMap[$ _child.ID];
					var _val   = array_clone(_input.getValue());
					    _val[TRANSFORM.rot] -= rot;
					_input.setValue(_val);
				}
				
				orig = posing_bone.getHead();
				var _rx = _x + _s * orig.x;
				var _ry = _y + _s * orig.y;
				draw_sprite_ui(THEME.bone_rotate, 0, _rx, _ry, 1, 1, posing_bone.pose_angle, COLORS._main_value_positive, 1); 
				
			} else if(posing_type == 3) { //scale
				var ps = val[TRANSFORM.sca_x];
				var ss = point_distance(posing_mx, posing_my, smx, smy) / posing_sx;
				var ds = ss / ps;
				val[TRANSFORM.sca_x] = ss;
				
				if(pose_child_lock && ds != 1 && ds != 0)
				for( var i = 0, n = array_length(posing_bone.childs); i < n; i++ ) {
					var _child = posing_bone.childs[i];
					if(!_child.apply_scale) continue;
					
					var _input = boneMap[$ _child.ID];
					var _val   = array_clone(_input.getValue());
					    _val[TRANSFORM.sca_x] /= ds;
					_input.setValue(_val);
				}
				
				orig = posing_bone.getPoint(0.8);
				var _rx = _x + _s * orig.x;
				var _ry = _y + _s * orig.y;
				draw_sprite_ui(THEME.bone_scale,  0, _rx, _ry, 1, 1, posing_bone.pose_angle, COLORS._main_value_positive, 1);
			} 
			
			gpu_set_texfilter(false);
			
			if(posing_input.value_from == noone) {
				if(posing_input.setValue(val)) UNDO_HOLDING = true;
				
			} else if(is(posing_input.value_from.node, Node_Vector4)) {
				var _nod = posing_input.value_from.node;
				
				for( var i = 0; i < 4; i++ ) 
					if(_nod.inputs[i].setValue(val[i])) UNDO_HOLDING = true;
			}
			
			if(mouse_release(mb_left)) {
				posing_bone = noone;
				posing_type = noone;
				UNDO_HOLDING = false;
			}
			
		} else if(anchor_selecting != noone) {
			var _bne = anchor_selecting[0];
			var _typ = anchor_selecting[1];
			var _lck = key_mod_press(ALT);
			
			if(_bne.control) _typ = 0;
			
			gpu_set_texfilter(true);
			
			if(_typ == 0) { // free move
				var orig = _bne.getHead();
				draw_sprite_ui(THEME.bone_move, 0, _x + _s * orig.x, _y + _s * orig.y, 1, 1, 0, COLORS._main_accent, 1);
				
			} else if(_typ == 1) { // bone move
				var orig = _bne.getTail();
				draw_sprite_ui(THEME.bone_move, 0, _x + _s * orig.x, _y + _s * orig.y, 1, 1, 0, COLORS._main_accent, 1);
				
			} else if(_typ == 2) { // bone rotate
				var orig = _bne.getHead();
				var _rx = _x + _s * orig.x;
				var _ry = _y + _s * orig.y;
				
				var orig = _bne.getPoint(0.8);
				var _sx = _x + _s * orig.x;
				var _sy = _y + _s * orig.y;
				
				_typ = 2;
				if(point_in_circle(_mx, _my, _sx, _sy, 12)) _typ = 2;
				
				draw_sprite_ui(THEME.bone_scale,  0, _sx, _sy, 1, 1, _bne.pose_angle, _typ == 2? COLORS._main_accent : COLORS._main_icon, 1);
				draw_sprite_ui(THEME.bone_rotate, 0, _rx, _ry, 1, 1, _bne.pose_angle, _typ == 3? COLORS._main_accent : COLORS._main_icon, 1);
			}
			
			if(_lck) {
				for( var i = 0, n = array_length(_bne.childs); i < n; i++ ) {
					var _ch = _bne.childs[i];
					var _bc = _ch.getPoint(0.5);
					var _cx = _x + _s * _bc.x;
					var _cy = _y + _s * _bc.y;
					
					BLEND_SUBTRACT
					draw_set_color(c_white);
					draw_circle(_cx, _cy, 16, false);
					
					BLEND_NORMAL
					draw_sprite_ui(THEME.lock,  0, _cx, _cy, 1, 1, 0, COLORS._main_accent, 1);
				}
			}
			
			gpu_set_texfilter(false);
				
			if(mouse_press(mb_left, active)) {
				posing_bone     = _bne;
				posing_type     = _typ;
				pose_child_lock = _lck;
				
				if(!has(boneMap, _bne.ID)) setBone();
				posing_input = boneMap[$ _bne.ID];
				
				if(_typ == 0) { // move
					var val   = posing_input.getValue();
					var _p    = anchor_selecting[2];
					
					posing_sx = val[TRANSFORM.pos_x];
					posing_sy = val[TRANSFORM.pos_y];
					
					posing_mx = _p.x;
					posing_my = _p.y;
					
				} else if(_typ == 1) { // free move
					var orig  = _bne.getHead();
					
					posing_sx = orig.x;
					posing_sy = orig.y;
					
				} else if(_typ == 2) { // rotate
					var orig  = _bne.getHead();
					var val   = posing_input.getValue();
					
					posing_sx = val[TRANSFORM.rot];
					posing_sy = point_direction(orig.x, orig.y, mx, my);
					
					posing_mx = mx;
					posing_my = my;
					
				} else if(_typ == 3) { // scale
					var orig  = _bne.getHead();
					
					var _sca  = point_distance(orig.x, orig.y, mx, my) / _bne.pose_length;
					posing_sx = _bne.length * _bne.pose_local_scale * _sca;
					
					posing_mx = orig.x;
					posing_my = orig.y;
					
				} 
			}
		
		} 
		
		#region select drag	
			var _show_selecting = isNotUsingTool() && posing_bone == noone;
			
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
	
	////- Update
	
	static update = function(frame = CURRENT_FRAME) {
		setBone();
		if(!is(bonePose, __Bone)) return;
		
		var _b = getInputData(0);
		
		bonePose.resetPose().setPosition();
		bonePose.constrains = _b.constrains;
		
		outputs[0].setValue(bonePose);
		
		var bArrRaw = _b.toArray();
		var bArrPos = bonePose.toArray();
		
		for( var i = 0, n = array_length(bArrPos); i < n; i++ ) {
			var bRaw  = bArrRaw[i];
			var bPose = bArrPos[i];
			var _id   = bPose.ID;
			if(!struct_exists(boneMap, _id)) continue;
			
			var _inp  = boneMap[$ _id];
			var _trn  = _inp.getValue();
			_inp.updateName(bPose.name);
			
			bPose.angle         = bRaw.angle;
			bPose.length        = bRaw.length;
			bPose.direction     = bRaw.direction;
			bPose.distance      = bRaw.distance;
			
			bPose.pose_posit[0] = bRaw.pose_posit[0] + _trn[TRANSFORM.pos_x];
			bPose.pose_posit[1] = bRaw.pose_posit[1] + _trn[TRANSFORM.pos_y];
			bPose.pose_rotate   = bRaw.pose_rotate   + _trn[TRANSFORM.rot];
			bPose.pose_scale    = bRaw.pose_scale    * _trn[TRANSFORM.sca_x];
		}
		
		bonePose.setPose();
		bone_bbox   = bonePose.bbox();
		bone_points = bonePose.toPoints(true);
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() { return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3]); }
	
	static postApplyDeserialize = function() {
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var inp = inputs[i];
			var idx = LOADING_VERSION < 1_18_04_0? struct_try_get(inp.display_data, "bone_id", 0) : 
			                                       struct_try_get(inp.attributes,   "bone_id", 0);
			
			boneMap[$ idx] = inp;
			inp.attributes.bone_id = idx;
		}
		
		setBone();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(is(bonePose, __Bone)) {
			var _ss = _s * .5;
			draw_sprite_ext_filter(s_node_armature_pose, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
			bonePose.drawThumbnail(_s, bbox, bone_bbox);
			
		} else
			draw_sprite_bbox_uniform(s_node_armature_pose, 0, bbox, c_white, 1, true);
	}
}

