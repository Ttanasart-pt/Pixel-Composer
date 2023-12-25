function Node_Monitor_Capture(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Monitor Capture";
	update_on_frame = true;
	
	monitors = display_measure_all();
	
	inputs[| 0] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Monitor", "Region" ]);
	
	inputs[| 1] = nodeValue("Monitor", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, array_create_ext(array_length(monitors), function(ind) { return monitors[ind][9]; }));
	
	inputs[| 2] = nodeValue("Region", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, display_get_width(), display_get_height() ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue("GUI", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		0, 1, 2,
	];
	
	surface  = -1;
	
	static step = function() { #region
		LIVE_UPDATE = true;
		
		var _mode = getInputData(0);
		
		inputs[| 1].setVisible(_mode == 0);
		inputs[| 2].setVisible(_mode == 1);
	} #endregion
	
	static update = function() { #region
		var _mode = getInputData(0);
		var _moni = getInputData(1);
		var _regi = getInputData(2);
		
		switch(_mode) {
			case 0 :
				var _mon = monitors[_moni];
				surface = display_capture_surface_part(_mon[0], _mon[1], _mon[2], _mon[3], surface);
				break;
			case 1 :
				surface = display_capture_surface_part(_regi[0], _regi[1], _regi[2], _regi[3], surface);
				break;
		}
		
		outputs[| 0].setValue(surface);
	} #endregion
}