function Node_VFX_Vortex(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Vortex";
	node_draw_icon = s_node_vfx_vortex;
	
	inputs[4].setVisible(false, false);
	
	newInput(effector_input_length + 0, nodeValue_Float("Attraction force", 2 ));
	
	newInput(effector_input_length + 1, nodeValue_Bool("Clockwise", true ));
	
	newInput(effector_input_length + 2, nodeValue_Bool("Destroy when reach middle", false ));
		
	array_push(input_display_list, effector_input_length + 0, effector_input_length + 1, effector_input_length + 2);
	
	attraction = 0;
	clockwise  = 0;
	destroydis = false;
	
	static onVFXUpdate = function(frame = CURRENT_FRAME) {
		attraction = getInputData(effector_input_length + 0);
		clockwise  = getInputData(effector_input_length + 1);
		destroydis = getInputData(effector_input_length + 2);
	}
	
	function onAffect(part, str) {
		var _rot = random_range(rotateX, rotateY);
		var _scX = random_range(scaleX0, scaleX1);
		var _scY = random_range(scaleY0, scaleY1);
		
		var pv = part.getPivot();
		
		var dirr = point_direction(area_x, area_y, pv[0], pv[1]) + (clockwise? 90 : -90);
		part.x += lengthdir_x(strength * str, dirr);
		part.y += lengthdir_y(strength * str, dirr);
		
		var dirr = point_direction(pv[0], pv[1], area_x, area_y);
		part.x += lengthdir_x(attraction * str, dirr);
		part.y += lengthdir_y(attraction * str, dirr);
		
		part.rot += _rot * str;
		
		var scx_s = _scX * str;
		var scy_s = _scY * str;
		
		if(scx_s < 0)	part.scx = lerp_linear(part.scx, 0, abs(scx_s));
		else			part.scx += sign(part.scx) * scx_s;
		
		if(scy_s < 0)	part.scy = lerp_linear(part.scy, 0, abs(scy_s));
		else			part.scy += sign(part.scy) * scy_s;
		
		if(destroydis && point_distance(pv[0], pv[1], area_x, area_y) <= 1)
			part.kill();
	}
}