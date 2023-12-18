function Node_VFX_Oscillate(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Oscillate";
	node_draw_icon = s_node_vfx_osc;
	
	inputs[| 4].setVisible(false, false);
	inputs[| 6].setVisible(false, false);
	inputs[| 7].setVisible(false, false);
	
	inputs[| effector_input_length + 0] = nodeValue("Amplitude", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2 );
	
	inputs[| effector_input_length + 1] = nodeValue("Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2 );
	
	inputs[| effector_input_length + 2] = nodeValue("Multiply by speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	array_push(input_display_list, effector_input_length + 0, effector_input_length + 1, effector_input_length + 2);
	
	function onAffect(part, str) {
		var _sten = getInputData(5);
		
		var _amp = getInputData(effector_input_length + 0);
		var _fre = getInputData(effector_input_length + 1);
		var _mls = getInputData(effector_input_length + 2);
		
		var _lif = part.life;
		var _dir = part.spVec[1] + 90;
		
		var _aamp = sin(part.seed + _lif * _fre) * _amp;
		if(_mls) _aamp *= part.spVec[0];
		
		var _dx   = lengthdir_x(_aamp, _dir);
		var _dy   = lengthdir_y(_aamp, _dir);
		
		part.drawx += _dx;
		part.drawy += _dy;
	}
}