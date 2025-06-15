function dialogCall(_dia, _x = noone, _y = noone, param = {}, create = false) {
	if(_x == noone) _x = WIN_SW / 2;
	if(_y == noone) _y = WIN_SH / 2;
	
	var dia = (!create && instance_exists(_dia))? instance_find(_dia, 0) : instance_create_depth(_x, _y, 0, _dia, param);
	
	dia.x      = _x;
	dia.y      = _y;
	dia.xstart = _x;
	dia.ystart = _y;
	dia.resetPosition();
	
	var args = variable_struct_get_names(param);
	for( var i = 0, n = array_length(args); i < n; i++ )
		variable_instance_set(dia, args[i], variable_struct_get(param, args[i]));
	
	setFocus(dia.id, "Dialog");
	return dia;
}

function dialogPanelCall(_panel, _x = noone, _y = noone, params = {}) {
	if(_x == noone) _x = WIN_SW / 2;
	if(_y == noone) _y = WIN_SH / 2;
	
	var dia = instance_create_depth(_x, _y, 0, o_dialog_panel);
	variable_instance_set_struct(dia, params);
	dia.setContent(_panel);
	
	dia.x      = _x;
	dia.y      = _y;
	dia.xstart = _x;
	dia.ystart = _y;
	dia.anchor = params[$ "anchor"] ?? _panel.anchor;
	dia.resetPosition();
	
	if(struct_try_get(params, "focus", true))
		setFocus(dia.id, _panel.context_str);
	return dia;
}

function colorSelectorCall(defColor, onApply) {
	var dialog = dialogCall(o_dialog_color_selector)
					.setDefault(defColor)
					.setApply(onApply);
	
	return dialog;
}