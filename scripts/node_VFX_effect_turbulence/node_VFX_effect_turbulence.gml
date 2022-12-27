function Node_VFX_Turbulence(_x, _y, _group = -1) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Turbulence";
	node_draw_icon = s_node_vfx_turb;
	
	function onAffect(part, str) {
		var _vect = current_data[4];
		var _sten = current_data[5];
		var _rot_range = current_data[6];
		var _sca_range = current_data[7];
		var _rot = random_range(_rot_range[0], _rot_range[1]);
		var _sca = [ random_range(_sca_range[0], _sca_range[1]), random_range(_sca_range[2], _sca_range[3]) ];
		
		var pv = part.getPivot();
		
		var t_scale = current_data[10];
		var per = (perlin_noise(pv[0] / t_scale, pv[1] / t_scale, 4, part.seed) - 0.5) * 2;
		per *= str;
					
		part.x = part.x + _vect[0] * per;
		part.y = part.y + _vect[1] * per;
					
		part.rot += _rot * per;
		
		var scx_s = _sca[0] * str;
		var scy_s = _sca[1] * str;
		if(scx_s < 0)	part.scx = lerp_linear(part.scx, 0, abs(scx_s));
		else			part.scx += sign(part.scx) * scx_s;
		if(scy_s < 0)	part.scy = lerp_linear(part.scy, 0, abs(scy_s));
		else			part.scy += sign(part.scy) * scy_s;
	}
}