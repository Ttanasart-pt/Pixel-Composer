function Node_Monitor_Capture(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Monitor Capture";
	update_on_frame = true;
	
	monitors = display_measure_all();
	
	newInput(0, nodeValue_Enum_Scroll("Mode",  0, [ "Monitor", "Region" ]));
	
	newInput(1, nodeValue_Enum_Scroll("Monitor",  0, array_create_ext(array_length(monitors), function(ind) /*=>*/ {return monitors[ind][9]})));
	
	newInput(2, nodeValue_Vec4("Region", [ 0, 0, display_get_width(), display_get_height() ]));
	
	newOutput(0, nodeValue_Output("GUI", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		0, 1, 2,
	];
	
	surface  = -1;
	
	static step = function() {
		LIVE_UPDATE = true;
		var _mode = getInputData(0);
		
		inputs[1].setVisible(_mode == 0);
		inputs[2].setVisible(_mode == 1);
	}
	
	static update = function() {
		var _mode = getInputData(0);
		var _moni = getInputData(1);
		var _regi = getInputData(2);
		
		var _reg = _mode == 0? monitors[_moni] : _regi;
		
		surface = surface_verify(surface, _reg[2], _reg[3]);
		display_capture_surface_part(_reg[0], _reg[1], _reg[2], _reg[3], surface);
		
		outputs[0].setValue(surface);
	}
}