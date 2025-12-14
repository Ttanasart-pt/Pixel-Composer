function Node_VFX_Attract(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Attract";
	setDrawIcon(s_node_vfx_attract);
	
	inputs[4].setVisible(false, false);
	
	newInput(effector_input_length + 0, nodeValue_Bool("Destroy when reach middle", false ));
		
	array_push(input_display_list, effector_input_length + 0);
	
	destroyMiddle = false;
	
	static onVFXUpdate = function(frame = CURRENT_FRAME) {
		destroyMiddle = getInputData(effector_input_length + 0);
	}
	
	function onAffect(part, str) {
		var _rot = random_range(rotateX, rotateY);
		var _scX = random_range(scaleX0, scaleX1);
		var _scY = random_range(scaleY0, scaleY1);
		
		var pv    = part.getPivot();
		var dirr  = point_direction(pv[0], pv[1], area_x, area_y);
		part.x    = part.x + lengthdir_x(strength * str, dirr);
		part.y    = part.y + lengthdir_y(strength * str, dirr);
		part.rot += _rot * str;
		
		var scx_s = _scX * str;
		var scy_s = _scY * str;
		
		if(scx_s < 0)	part.sc_sx =  lerp_linear(part.sc_sx, 0, abs(scx_s));
		else			part.sc_sx += sign(part.sc_sx) * scx_s;
		
		if(scy_s < 0)	part.sc_sy =  lerp_linear(part.sc_sy, 0, abs(scy_s));
		else			part.sc_sy += sign(part.sc_sy) * scy_s;
		
		if(!destroyMiddle) return;
		if(point_distance(part.x, part.y, area_x, area_y) <= strength)
			part.kill();
	}
}