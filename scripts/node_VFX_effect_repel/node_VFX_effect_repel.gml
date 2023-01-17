function Node_VFX_Repel(_x, _y, _group = -1) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Repel";
	node_draw_icon = s_node_vfx_repel;
	
	inputs[| 4].setVisible(false, false);
	
	function onAffect(part, str) {
		var _area = current_data[1];
		var _area_x = _area[0];
		var _area_y = _area[1];
		
		var _sten = current_data[5];
		var _rot_range = current_data[6];
		var _sca_range = current_data[7];
		var _rot = random_range(_rot_range[0], _rot_range[1]);
		var _sca = [ random_range(_sca_range[0], _sca_range[1]), random_range(_sca_range[2], _sca_range[3]) ];
		
		var pv = part.getPivot();
		var dirr = point_direction(_area_x, _area_y, pv[0], pv[1]);
		part.x = part.x + lengthdir_x(_sten * str, dirr);
		part.y = part.y + lengthdir_y(_sten * str, dirr);
					
		part.rot += _rot * str;
		
		var scx_s = _sca[0] * str;
		var scy_s = _sca[1] * str;
		if(scx_s < 0)	part.scx = lerp_linear(part.scx, 0, abs(scx_s));
		else			part.scx += sign(part.scx) * scx_s;
		if(scy_s < 0)	part.scy = lerp_linear(part.scy, 0, abs(scy_s));
		else			part.scy += sign(part.scy) * scy_s;
	}
}