function Node_3D_Light(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name   = "3D Light";
	
	if(!LOADING && !APPENDING)
		inputs[0].setValue([ 0, 0, 1 ]);
	
	newInput(in_d3d + 0, nodeValue_Bool("Active", true));
	
	newInput(in_d3d + 1, nodeValue_Color("Color", ca_white));
	
	newInput(in_d3d + 2, nodeValue_Slider("Intensity", 1));
	
	in_light = array_length(inputs);
	
	newOutput(0, nodeValue_Output("Light", VALUE_TYPE.d3Light, noone));
	
	#macro __d3d_input_list_light ["Light", false], in_d3d + 0, in_d3d + 1, in_d3d + 2
	
	static setLight = function(light, _data) {
		var _col = _data[in_d3d + 1];
		var _int = _data[in_d3d + 2];
		
		light.color	    = _col;
		light.intensity = _int;
		
		return light;
	}
	
	static processData = function(_output, _data, _array_index = 0) { }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		PROCESSOR_OVERLAY_CHECK
		
		var _colr = current_data[in_d3d + 1];
		var bbox  = drawGetBbox(xx, yy, _s);
		draw_set_color(_colr);
		
		draw_set_circle_precision(32);
		draw_circle(bbox.xc, bbox.yc,  8 * _s, false);
		draw_circle(bbox.xc, bbox.yc, 12 * _s, true);
	}
}