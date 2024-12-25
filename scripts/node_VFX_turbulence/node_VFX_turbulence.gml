function Node_VFX_Turbulence(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Turbulence";
	node_draw_icon = s_node_vfx_turb;
	
	inputs[4].setVisible(false, false);
	
	newInput(effector_input_length + 0, nodeValue_Float("Turbulence scale", self, 1 ));
	
	newInput(effector_input_length + 1, nodeValue_Bool("Constant seed", self, false ));
		
	array_push(input_display_list, effector_input_length + 0, effector_input_length + 1);
	
	tscale = 1;
	conspd = false;
	
	static onVFXUpdate = function(frame = CURRENT_FRAME) {
		tscale = getInputData(effector_input_length + 0);
		conspd = getInputData(effector_input_length + 1);
	}
	
	function onAffect(part, str) {
		var _rot = random_range(rotateX, rotateY);
		var _scX = random_range(scaleX0, scaleX1);
		var _scY = random_range(scaleY0, scaleY1);
		
		var  pv   = part.getPivot();
		var _seed = conspd? seed : part.seed;
		
		var perx = (perlin_noise(pv[0] / tscale, pv[1] / tscale, 1, _seed)       - 0.5) * 2;
		var pery = (perlin_noise(pv[0] / tscale, pv[1] / tscale, 1, _seed + 100) - 0.5) * 2;
		
		part.x += perx * str * strength;
		part.y += pery * str * strength;
		
		part.rot += _rot * perx;
		
		var scx_s = _scX * str;
		var scy_s = _scY * str;
		
		if(scx_s < 0)		part.scx = lerp_linear(part.scx, 0, abs(scx_s));
		else if(scx_s > 0)	part.scx += sign(part.scx) * scx_s;
		
		if(scy_s < 0)		part.scy = lerp_linear(part.scy, 0, abs(scy_s));
		else if(scy_s > 0)	part.scy += sign(part.scy) * scy_s;
	}
}