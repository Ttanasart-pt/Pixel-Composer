function Node_VFX_Vortex(_x, _y, _group = -1) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Vortex";
	node_draw_icon = s_node_vfx_vortex;
	
	inputs[| 4].setVisible(false, false);
	
	inputs[| 8] = nodeValue(8, "Attraction force", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2 );
	
	inputs[| 9] = nodeValue(9, "Clockwise", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
		
	array_push(input_display_list, 8, 9);
	
	function onAffect(part, str) {
		var _area = current_data[1];
		var _area_x = _area[0];
		var _area_y = _area[1];
		
		var _sten = current_data[5];
		var _rot_range = current_data[6];
		var _sca_range = current_data[7];
		var _attr = current_data[8];
		var _clkw = current_data[9];
		
		var _rot = random_range(_rot_range[0], _rot_range[1]);
		var _sca = [ random_range(_sca_range[0], _sca_range[1]), random_range(_sca_range[2], _sca_range[3]) ];
		
		var pv = part.getPivot();
		
		var dirr = point_direction(_area_x, _area_y, pv[0], pv[1]) + (_clkw? 90 : -90);
		part.x += lengthdir_x(_sten * str, dirr);
		part.y += lengthdir_y(_sten * str, dirr);
		
		var dirr = point_direction(pv[0], pv[1], _area_x, _area_y);
		part.x += lengthdir_x(_attr * str, dirr);
		part.y += lengthdir_y(_attr * str, dirr);
		
		part.rot += _rot * str;
		
		var scx_s = _sca[0] * str;
		var scy_s = _sca[1] * str;
		if(scx_s < 0)	part.scx = lerp_linear(part.scx, 0, abs(scx_s));
		else			part.scx += sign(part.scx) * scx_s;
		if(scy_s < 0)	part.scy = lerp_linear(part.scy, 0, abs(scy_s));
		else			part.scy += sign(part.scy) * scy_s;
	}
}