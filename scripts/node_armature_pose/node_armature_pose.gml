function Node_Armature_Pose(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Pose";
	
	w = 96;
	h = 72;
	min_h = h;
	
	inputs[| 0] = nodeValue("Armature", self, JUNCTION_CONNECT.input, VALUE_TYPE.armature, noone)
		.setVisible(true, true);
	
	input_display_list = [ 0,
		["Bones", false]
	]
	
	input_fix_len = ds_list_size(inputs);
	data_length = 1;
	
	outputs[| 0] = nodeValue("Armature", self, JUNCTION_CONNECT.output, VALUE_TYPE.armature, noone);
	
	boneMap = ds_map_create();
	
	attributes.display_name = true;
	array_push(attributeEditors, ["Display name", "display_name", 
		new checkBox(function() { 
			attributes.display_name = !attributes.display_name;
		})]);
	
	function createNewControl(bone = noone) {
		var index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue(bone != noone? bone.name : "bone", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 1 ] )
			.setDisplay(VALUE_DISPLAY.transform);
		inputs[| index].extra_data[0] = bone != noone? bone.id : noone;
		
		if(bone != noone)
			boneMap[? bone.id] = inputs[| index];
		
		array_push(input_display_list, index);
		
		return inputs[| index];
	}
	
	static setBone = function() { #region
		//print("Setting dem bones...");
		var _b = inputs[| 0].getValue();
		if(_b == noone) return;
		
		var _bones = [];
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _b);
		
		while(!ds_stack_empty(_bst)) {
			var __b = ds_stack_pop(_bst);
			
			for( var i = 0; i < array_length(__b.childs); i++ ) {
				array_push(_bones, __b.childs[i]);
				ds_stack_push(_bst, __b.childs[i]);
			}
		}
		
		ds_stack_destroy(_bst);
		//print($"Bone counts: {array_length(_bones)}");
		
		var _inputs = ds_list_create();
		_inputs[| 0] = inputs[| 0];
		
		var _input_display_list = [
			input_display_list[0],
			input_display_list[1]
		];
		
		for( var i = 0; i < array_length(_bones); i++ ) {
			var bone = _bones[i];
			var _idx = ds_list_size(_inputs);
			array_push(_input_display_list, _idx);
			//print($"  > Adding bone id: {bone.id}");
			
			if(ds_map_exists(boneMap, bone.id)) {
				var _inp = boneMap[? bone.id];
				
				_inp.index = _idx;
				ds_list_add(_inputs, _inp);
			} else {
				var _inp = createNewControl(bone);
				ds_list_add(_inputs, _inp);
			}
		}
		
		ds_list_destroy(inputs);
		inputs = _inputs;
		input_display_list = _input_display_list;
		
		//print(_input_display_list);
	#endregion
	}
	
	tools = [
		
	];
	
	anchor_selecting = noone;
	posing_bone  = noone;
	posing_input = 0;
	posing_type  = 0;
	posing_sx = 0;
	posing_sy = 0;
	posing_mx = 0;
	posing_my = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _b = outputs[| 0].getValue();
		if(_b == noone) return;
		
		anchor_selecting = _b.draw(active, _x, _y, _s, _mx, _my, true, anchor_selecting);
		
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		if(posing_bone) {
			if(posing_type == 0) { //move
				var bx = posing_sx + (mx - posing_mx);
				var by = posing_sy + (my - posing_my);
				
				var val = posing_input.getValue();
				val[TRANSFORM.pos_x] = bx;
				val[TRANSFORM.pos_y] = by;
				if(posing_input.setValue(val))
					UNDO_HOLDING = true;
				
			} else if(posing_type == 1) { //scale
				var ss  = point_distance(posing_mx, posing_my, mx, my) / posing_sx;
				var rot = point_direction(posing_mx, posing_my, mx, my) - posing_sy;
				
				var val = posing_input.getValue();
				val[TRANSFORM.sca_x] = ss;
				val[TRANSFORM.rot]   = rot;
				if(posing_input.setValue(val))
					UNDO_HOLDING = true;
				
			} else if(posing_type == 2) { //rotate
				var ori = posing_bone.getPoint(0);
				var ang = point_direction(ori.x, ori.y, mx, my);
				var rot = angle_difference(ang, posing_sy);
				posing_sy = ang;
				posing_sx += rot;
				
				var val = posing_input.getValue();
				val[TRANSFORM.rot] = posing_sx;
				if(posing_input.setValue(val))
					UNDO_HOLDING = true;
				
			}
			
			if(mouse_release(mb_left)) {
				posing_bone = noone;
				posing_type = noone;
				UNDO_HOLDING = false;
			}
		}
		
		if(anchor_selecting != noone && mouse_press(mb_left, active)) {
			if(anchor_selecting[1] == 0) { // move
				posing_bone = anchor_selecting[0];
				if(!ds_map_exists(boneMap, posing_bone.id))
					setBone();
				posing_input = boneMap[? posing_bone.id];
				posing_type = 0;
				
				var val = posing_input.getValue();
				posing_sx = val[TRANSFORM.pos_x];
				posing_sy = val[TRANSFORM.pos_y];
				
				posing_mx = mx;
				posing_my = my;
				
			} else if(anchor_selecting[1] == 1) { // scale
				posing_bone = anchor_selecting[0];
				if(!ds_map_exists(boneMap, posing_bone.id))
					setBone();
				posing_input = boneMap[? posing_bone.id];
				posing_type = 1;
				
				var val = posing_input.getValue();
				posing_sx = posing_bone.length / posing_bone.pose_scale;
				posing_sy = posing_bone.angle - posing_bone.pose_angle;
				
				var pnt = posing_bone.getPoint(0);
				posing_mx = pnt.x;
				posing_my = pnt.y;
				
			} else if(anchor_selecting[1] == 2) { // rotate
				posing_bone = anchor_selecting[0];
				if(!ds_map_exists(boneMap, posing_bone.id))
					setBone();
				posing_input = boneMap[? posing_bone.id];
				posing_type = 2;
				
				var ori = posing_bone.getPoint(0);
				var val = posing_input.getValue();
				posing_sx = val[TRANSFORM.rot];
				posing_sy = point_direction(ori.x, ori.y, mx, my);
				
				posing_mx = mx;
				posing_my = my;
				
			}
		}
	}
	
	bone_prev = noone;
	static step = function() {
		var _b = inputs[| 0].getValue();
		if(_b == noone) return;
		if(bone_prev != _b) {
			setBone();
			bone_prev = _b;
			return;
		}
		
		var _boneCount = ds_list_size(inputs) - input_fix_len;
		if(_boneCount != _b.childCount()) setBone();
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _b = inputs[| 0].getValue();
		if(_b == noone) return;
		
		var _bone_pose = _b.clone(attributes);
		_bone_pose.resetPose();
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _bone_pose);
		
		while(!ds_stack_empty(_bst)) {
			var bone = ds_stack_pop(_bst);
			var _id  = bone.id;
			
			if(ds_map_exists(boneMap, _id)) {
				var _inp  = boneMap[? _id];
				_inp.name = bone.name;
				_inp.updateName();
				
				var _trn  = _inp.getValue();
				
				bone.pose_posit = [ _trn[TRANSFORM.pos_x], _trn[TRANSFORM.pos_y] ];
				bone.pose_angle = _trn[TRANSFORM.rot];
				bone.pose_scale = _trn[TRANSFORM.sca_x];
			}
			
			for( var i = 0; i < array_length(bone.childs); i++ )
				ds_stack_push(_bst, bone.childs[i]);
		}
		
		ds_stack_destroy(_bst);
		_bone_pose.setPose();
		
		outputs[| 0].setValue(_bone_pose);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for( var i = input_fix_len; i < array_length(_inputs); i += data_length )
			createNewControl();
	}
	
	static doApplyDeserialize = function() {
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var inp = inputs[| i];
			var idx = array_safe_get(inp.extra_data, 0);
			
			boneMap[? idx] = inp;
		}
		
		setBone();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_armature_pose, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}

