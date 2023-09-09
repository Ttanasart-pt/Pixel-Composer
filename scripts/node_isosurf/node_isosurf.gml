function Node_IsoSurf(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "IsoSurf";
	
	inputs[| 0] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "4", "8" ]);
	
	inputs[| 1] = nodeValue("Surfaces", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(true, true)
		.setArrayDepth(1);
	
	inputs[| 2] = nodeValue("Angle Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	outputs[| 0] = nodeValue("IsoSurf", self, JUNCTION_CONNECT.output, VALUE_TYPE.dynaSurf, noone);
	
	input_display_list = [
		["Isometric", false], 0, 2, 
		["Surfaces",  false], 1, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _type  = _data[0];
		var _surf  = _data[1];
		var _angle = _data[2];
		var _amo   = _type == 0? 4 : 8;
		
		var _iso  = _type == 0? new dynaSurf_iso_4() : new dynaSurf_iso_8();
		for( var i = 0; i < _amo; i++ ) 
			_iso.surfaces[i] = array_safe_get(_surf, i, noone);
		_iso.angle = _angle;
		
		return _iso;
	}
}