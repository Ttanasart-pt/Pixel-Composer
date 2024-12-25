function Node_VFX_Oscillate(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Oscillate";
	node_draw_icon = s_node_vfx_osc;
	
	inputs[4].setVisible(false, false);
	inputs[6].setVisible(false, false);
	inputs[7].setVisible(false, false);
	
	newInput(effector_input_length + 0, nodeValue_Float("Amplitude", self, 2 ));
	
	newInput(effector_input_length + 1, nodeValue_Float("Frequency", self, 0.2 ));
	
	newInput(effector_input_length + 2, nodeValue_Bool("Multiply by speed", self, false ));
	
	array_push(input_display_list, effector_input_length + 0, effector_input_length + 1, effector_input_length + 2);
	
	amplitude = 0;
	frequency = 0;
	mulpSpd   = false;
	
	static onVFXUpdate = function(frame = CURRENT_FRAME) {
		amplitude = getInputData(effector_input_length + 0);
		frequency = getInputData(effector_input_length + 1);
		mulpSpd   = getInputData(effector_input_length + 2);
	}
	
	function onAffect(part, str) {
		var _lif = part.life;
		var _dir = part.spVec[1] + 90;
		
		var _aamp = sin(part.seed + _lif * frequency) * amplitude;
		if(mulpSpd) _aamp *= part.spVec[0];
		
		part.drawx += lengthdir_x(_aamp, _dir);
		part.drawy += lengthdir_y(_aamp, _dir);
	}
}