function Node_VFX_Turbulence(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Turbulence";
	node_draw_icon = s_node_vfx_turb;
	
	inputs[4].setVisible(false, false);
	
	newInput(effector_input_length + 0, nodeValue_Float("Turbulence scale", self, 1 ));
	
	newInput(effector_input_length + 1, nodeValue_Bool("Constant seed", self, false ));
		
	array_push(input_display_list, effector_input_length + 0, effector_input_length + 1);
	
	function onAffect(part, str) {
		var _sten      = getInputData(5);
		var _rot_range = getInputData(6);
		var _sca_range = getInputData(7);
		var _rot       = random_range(_rot_range[0], _rot_range[1]);
		var _sca       = [ random_range(_sca_range[0], _sca_range[1]), random_range(_sca_range[2], _sca_range[3]) ];
		
		var pv = part.getPivot();
		
		var t_scale = getInputData(effector_input_length + 0);
		var con_sed = getInputData(effector_input_length + 1);
		
		var _seed = con_sed? seed : part.seed;
		
		var perx    = (perlin_noise(pv[0] / t_scale, pv[1] / t_scale, 1, _seed)       - 0.5) * 2;
		var pery    = (perlin_noise(pv[0] / t_scale, pv[1] / t_scale, 1, _seed + 100) - 0.5) * 2;
		
		part.x += perx * str * _sten;
		part.y += pery * str * _sten;
		
		part.rot += _rot * perx;
		
		var scx_s = _sca[0] * str;
		var scy_s = _sca[1] * str;
		
		if(scx_s < 0)		part.scx = lerp_linear(part.scx, 0, abs(scx_s));
		else if(scx_s > 0)	part.scx += sign(part.scx) * scx_s;
		
		if(scy_s < 0)		part.scy = lerp_linear(part.scy, 0, abs(scy_s));
		else if(scy_s > 0)	part.scy += sign(part.scy) * scy_s;
	}
}