function Node_3D_Light(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name   = "3D Light";
	
	if(!LOADING && !APPENDING)
		inputs[| 0].setValue([ 0, 0, 1 ]);
	
	inputs[| in_d3d + 0] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| in_d3d + 1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| in_d3d + 2] = nodeValue("Intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	in_light = ds_list_size(inputs);
	
	outputs[| 0] = nodeValue("Light", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Light, noone);
	
	#macro __d3d_input_list_light ["Light", false], in_d3d + 0, in_d3d + 1, in_d3d + 2
	
	static setLight = function(light, _data) { #region
		var _col = _data[in_d3d + 1];
		var _int = _data[in_d3d + 2];
		
		light.color	    = _col;
		light.intensity = _int;
		
		return light;
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var _colr = current_data[in_d3d + 1];
		var bbox  = drawGetBbox(xx, yy, _s);
		draw_set_color(_colr);
		
		draw_set_circle_precision(32);
		draw_circle(bbox.xc, bbox.yc,  8 * _s, false);
		draw_circle(bbox.xc, bbox.yc, 12 * _s, true);
	} #endregion
}