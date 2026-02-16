function Node_Armature_Sample(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Sample";
	setDimension(96, 72);
	setDrawIcon(s_node_armature_sample);
	
	newInput(0, nodeValue_Armature()).setVisible(true, true).rejectArray();
	newInput(1, nodeValue_Bone( "Bone", function() /*=>*/ {return toggleBoneTarget()} ));
	newInput(2, nodeValue_Slider("Sample point", 0));
	
	newOutput(0, nodeValue_Output("Position", VALUE_TYPE.integer, [ 0, 0 ])).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [
		0, 1, 2, 
	];
	
	__node_bone_attributes();
	
	bone_targeting = false;
	bone_array       = [];
	
	static toggleBoneTarget = function() /*=>*/ { bone_targeting = !bone_targeting; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		inputs[1].setSelecting(bone_targeting);
		
		var _b = getInputData(0);
		if(!is(_b, __Bone)) return;
		
		_b.draw(attributes, false, _x, _y, _s, _mx, _my);
	}
	
	static update = function() {
		var _bone = getInputData(0);
		var _name = getInputData(1);
		var _prog = getInputData(2);
		
		if(!is(_bone, __Bone)) return;
		
		bone_array = _bone.toArray();
		_name    = string_trim(_name);
		
		var _b = _bone.findBoneByName(_name);
		if(_b == noone) {
			outputs[0].setValue([0, 0]);
			return;
		}
		
		var _p = _b.getPoint(_prog);
		
		outputs[0].setValue([_p.x, _p.y]);
	}
}