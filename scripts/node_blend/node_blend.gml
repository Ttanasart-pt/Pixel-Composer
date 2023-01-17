function Node_create_Blend(_x, _y, _group = -1, _param = "") {
	var node = new Node_Blend(_x, _y, _group);
	
	switch(_param) {
	    case "normal" :			node.inputs[| 2].setValue(BLEND_MODE.normal)			break;
	    case "add"	:			node.inputs[| 2].setValue(BLEND_MODE.add);				break;
	    case "subtract" :		node.inputs[| 2].setValue(BLEND_MODE.subtract);			break;
	    case "multiply" :		node.inputs[| 2].setValue(BLEND_MODE.multiply);			break;
	    case "overlay" :		node.inputs[| 2].setValue(BLEND_MODE.overlay);			break;
	    case "screen" :			node.inputs[| 2].setValue(BLEND_MODE.screen);			break;
	    case "maxx" :			node.inputs[| 2].setValue(BLEND_MODE.maxx);				break;
	    case "minn" :			node.inputs[| 2].setValue(BLEND_MODE.minn);				break;
	}
	return node;
}

function Node_Blend(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend";
	
	inputs[| 0] = nodeValue(0, "Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, DEF_SURFACE);
	inputs[| 1] = nodeValue(1, "Foreground", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, DEF_SURFACE);
	
	inputs[| 2] = nodeValue(2, "Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, BLEND_TYPES );
	
	inputs[| 3] = nodeValue(3, "Opacity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 4] = nodeValue(4, "Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 5] = nodeValue(5, "Tiling", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Stretch", "Tile" ]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Surfaces",	 true],	0, 1, 4,
		["Blend",		false], 2, 3, 
		["Transform",	false], 5, 
	]
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _back	 = _data[0];
		var _fore	 = _data[1];
		var _type	 = _data[2];
		var _opacity = _data[3];
		var _mask	 = _data[4];
		var _tile	 = _data[5];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		draw_surface_blend(_back, _fore, _type, _opacity, _mask, _tile);
		surface_reset_target();
		
		return _outSurf;
	}
}