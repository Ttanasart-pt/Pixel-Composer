function Node_Armature_Pose(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Pose";
	
	inputs[| 0] = nodeValue("Armature", self, JUNCTION_CONNECT.input, VALUE_TYPE.armature, noone);
	
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
	}
	
	function setBone() {
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
		
		var _inputs = ds_list_create();
		_inputs[| 0] = inputs[| 0];
		
		var _input_display_list = [
			input_display_list[0],
			input_display_list[1]
		];
		
		for( var i = 0; i < array_length(_bones); i++ ) {
			var bone = _bones[i];
			if(ds_map_exists(boneMap, bone.id)) {
				var _inp = boneMap[? bone.id];
				var _idx = ds_list_size(_inputs);
				
				_inp.index = _idx;
				array_append(_input_display_list, _idx);
				ds_list_add(_inputs, _inp);
			} else
				createNewControl(bone);
		}
		
		ds_list_destroy(inputs);
		inputs = _inputs;
		input_display_list = _input_display_list;
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
			if(posing_bone == 0) { //move
				var bx = posing_sx + (mx - posing_mx);
				var by = posing_sy + (my - posing_my);
				
				var val = posing_input.getValue();
				val[TRANSFORM.pos_x] = bx;
				val[TRANSFORM.pos_y] = by;
				if(posing_input.setValue(val))
					UNDO_HOLDING = true;
				
			} else if(posing_bone == 1) { //scale
				var ss = point_distance(posing_mx, posing_my, mx, my) / posing_sx;
				
				var val = posing_input.getValue();
				val[TRANSFORM.sca_x] = ss;
				if(posing_input.setValue(val))
					UNDO_HOLDING = true;
				
			} else if(posing_bone == 2) { //rotate
				var ori = posing_bone.getPoint(0, 0);
				var rot = angle_difference(point_direction(ori.x, ori.y, mx, my), posing_bone.angle);
				
				var val = posing_input.getValue();
				val[TRANSFORM.rot] = rot;
				if(posing_input.setValue(val))
					UNDO_HOLDING = true;
				
			}
			
			if(mouse_release(mb_left)) {
				posing_bone = noone;
				UNDO_HOLDING = false;
			}
		}
		
		if(anchor_selecting != noone && mouse_click(mb_left, active)) {
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
				posing_sx = val[TRANSFORM.sca_x];
				
				posing_mx = mx;
				posing_my = my;
				
			} else if(anchor_selecting[1] == 2) { // rotate
				posing_bone = anchor_selecting[0];
				if(!ds_map_exists(boneMap, posing_bone.id))
					setBone();
				posing_input = boneMap[? posing_bone.id];
				posing_type = 2;
				
				var val = posing_input.getValue();
				posing_sx = posing_bone.angle;
				
				posing_mx = mx;
				posing_my = my;
				
			}
		}
	}
	
	static step = function() {
		var _b = inputs[| 0].getValue();
		if(_b == noone) return;
		
		var _boneCount = ds_list_size(inputs) - input_fix_len;
		if(_boneCount != _b.childCount()) setBone();
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _b = inputs[| 0].getValue();
		if(_b == noone) return;
		
		var _bone_pose = _b.clone();
		
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
				
				var px  = _trn[0];
				var py  = _trn[1];
				var rot = _trn[2];
				var sca = _trn[3];
				
				var _x = lengthdir_x(bone.distance, bone.direction);
				var _y = lengthdir_y(bone.distance, bone.direction);
				
				_x += px;
				_y += py;
				
				bone.distance  = point_distance(0, 0, _x, _y);
				bone.direction = point_direction(0, 0, _x, _y);
				
				bone.angle  += rot;
				bone.length *= sca;
			}
			
			for( var i = 0; i < array_length(bone.childs); i++ ) {
				ds_stack_push(_bst, bone.childs[i]);
			}
		}
		
		ds_stack_destroy(_bst);
		
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
	}
}

