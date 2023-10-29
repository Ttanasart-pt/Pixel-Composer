function Node_VFX_Accelerate(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Accelerate";
	node_draw_icon = s_node_vfx_accel;
	
	function onAffect(part, str) {
		var _vect      = getInputData(4);
		var _sten      = getInputData(5);
		var _rot_range = getInputData(6);
		var _sca_range = getInputData(7);
		var _rot       = random_range(_rot_range[0], _rot_range[1]);
		var _sca       = [ random_range(_sca_range[0], _sca_range[1]), random_range(_sca_range[2], _sca_range[3]) ];
		
		part.speedx = part.speedx + _vect[0] * str * _sten;
		part.speedy = part.speedy + _vect[1] * str * _sten;
					
		part.rot += _rot * str;
		
		var scx_s = _sca[0] * str;
		var scy_s = _sca[1] * str;
		if(scx_s < 0)	part.scx = lerp_linear(part.scx, 0, abs(scx_s));
		else			part.scx += sign(part.scx) * scx_s;
		if(scy_s < 0)	part.scy = lerp_linear(part.scy, 0, abs(scy_s));
		else			part.scy += sign(part.scy) * scy_s;
	}
	
	PATCH_STATIC
}