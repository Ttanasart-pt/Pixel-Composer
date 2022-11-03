/// @description init
event_inherited();

#region data
	dialog_w = ui(360);
	dialog_h = ui(360);
	
	destroy_on_click_out = true;
	
	value_target = noone;
#endregion

#region data
	function setValueTarget(value) {
		value_target = value;
	}
	
	editWidget = new curveBox(
		function(_modified) { value_target.inter_curve = _modified; });
#endregion