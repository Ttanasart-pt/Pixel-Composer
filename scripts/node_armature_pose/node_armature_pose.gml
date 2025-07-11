function Node_Armature_Pose(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Pose";
	setDimension(96, 96);
	draw_padding = 8;
	
	newInput(0, nodeValue_Armature()).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 0 ]
	
	boneHash  = "";
	bonePose  = noone;
	bone_bbox = [0, 0, 1, 1, 1, 1];
	boneArray = [];
	boneMap   = {};
	
	__node_bone_attributes();
	
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
	
	static setBone = function() {
		var _b = getInputData(0);
		if(!is(_b, __Bone)) { boneHash = ""; return; }
		
		var _h = _b.getHash();
		if(boneHash == _h) return;
		
		boneHash  = _h;
		bonePose  = _b.clone().connect();
		boneArray = bonePose.toArray();
		bonePose.constrains = _b.constrains;
		
		var _inputs = [ inputs[0] ];
		var _input_display_list = array_clone(input_display_list_raw, 1);
		
		for( var i = 0, n = array_length(boneArray); i < n; i++ ) {
			var bone = boneArray[i];
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
	
	tools = [];
	
	anchor_selecting = noone;
	posing_bone      = noone;
	posing_input     = 0;
	posing_type      = 0;
	pose_child_lock  = false;
	
	posing_sx = 0;
	posing_sy = 0;
	posing_mx = 0;
	posing_my = 0;
	
	////- Preview
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _b = inputs[0].getValue();
		if(!is(_b, __Bone) || !is(bonePose, __Bone)) return;
		
		var _hov  = noone;
		var _bhov = anchor_selecting;
		
		for( var i = 0, n = array_length(boneArray); i < n; i++ ) {
			var _bne = boneArray[i];
			var _sel = false;
			var  cc  = c_white;
			
			if(struct_has(boneMap, _bne.ID)) {
				var _inp = boneMap[$ _bne.ID];
				_sel = _inp.value_from == noone || is(_inp.value_from.node, Node_Vector4);
				
				if(_bhov == noone && PANEL_INSPECTOR.prop_hover == _inp)
					_bhov = [ _bne, 2 ];
			}
			
			var hh = _bne.drawBone(attributes, _sel * active * 0b111, _x, _y, _s, _mx, _my, _bhov, posing_bone, cc, .5 + .5 * _sel);
			if(hh != noone && (_hov == noone || _bne.IKlength)) _hov = hh;
		}
		
		anchor_selecting = _hov;
		bonePose.setControl(_x, _y, _s);
		bonePose.drawControl(attributes);
		
		if(anchor_selecting != noone) {
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
			
			if(_bne.IKlength) _typ = 0;
			
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
				
				if(!struct_exists(boneMap, _bne.ID)) setBone();
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
	}
	
	////- Update
	
	static update = function(frame = CURRENT_FRAME) {
		setBone();
		var _b = getInputData(0);
		
		bonePose.resetPose().setPosition();
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
		bone_bbox = bonePose.bbox();
		
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
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

