function Node_VFX_Destroy(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Destroy";
	setDrawIcon(s_node_vfx_destroy);
	
	inputs[4].setVisible(false, false);
	inputs[6].setVisible(false, false);
	inputs[7].setVisible(false, false);
	
	function onAffect(part, str) {
		if(random(1) < str * strength) part.kill();
	}
}