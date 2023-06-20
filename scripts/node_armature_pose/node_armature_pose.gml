function Node_Armature_Pose(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Pose";
	
	inputs[| 0] = nodeValue("Armature", self, JUNCTION_CONNECT.input, VALUE_TYPE.armature, noone);
	
	input_fix_len = ds_list_size(inputs);
	data_length = 1;
	
	outputs[| 0] = nodeValue("Armature", self, JUNCTION_CONNECT.output, VALUE_TYPE.armature, noone);
	
	tools = [
		
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		
	}
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for(var i = input_fix_len; i < array_length(_inputs); i += data_length)
			createBone();
	}
}

