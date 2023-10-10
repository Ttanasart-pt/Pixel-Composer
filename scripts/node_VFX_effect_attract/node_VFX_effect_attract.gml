function Node_VFX_Attract(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Attract";
	node_draw_icon = s_node_vfx_attract;
	
	inputs[| 4].setVisible(false, false);
	
	function onAffect(part, str) {
		var _area      = getInputData(1);
		var _area_x    = _area[0];
		var _area_y    = _area[1];
		
		var _sten      = getInputData(5);
		var _rot_range = getInputData(6);
		var _sca_range = getInputData(7);
		var _rot       = random_range(_rot_range[0], _rot_range[1]);
		var _sca       = [ random_range(_sca_range[0], _sca_range[1]), random_range(_sca_range[2], _sca_range[3]) ];
		
		var pv   = part.getPivot();
		var dirr = point_direction(pv[0], pv[1], _area_x, _area_y);
		part.x   = part.x + lengthdir_x(_sten * str, dirr);
		part.y   = part.y + lengthdir_y(_sten * str, dirr);
					
		part.rot += _rot * str;
		
		var scx_s = _sca[0] * str;
		var scy_s = _sca[1] * str;
		
		if(scx_s < 0)	part.sc_sx =  lerp_linear(part.sc_sx, 0, abs(scx_s));
		else			part.sc_sx += sign(part.sc_sx) * scx_s;
		if(scy_s < 0)	part.sc_sy =  lerp_linear(part.sc_sy, 0, abs(scy_s));
		else			part.sc_sy += sign(part.sc_sy) * scy_s;
	}
	
	PATCH_STATIC
}