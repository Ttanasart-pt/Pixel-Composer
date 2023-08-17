function Node_3D_Light(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name   = "3D Light";
	
	if(!LOADING && !APPENDING)
		inputs[| 0].setValue([ 0, 0, 1 ]);
	
	inputs[| input_d3d_index + 0] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| input_d3d_index + 1] = nodeValue("Intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	input_light_index = ds_list_size(inputs);
	
	outputs[| 0] = nodeValue("Light", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Light, noone);
	
	#macro __d3d_input_list_light ["Light", false], input_d3d_index + 0, input_d3d_index + 1
	
	static setLight = function(light, _data) {
		var _col = _data[input_d3d_index + 0];
		var _int = _data[input_d3d_index + 1];
		
		light.color	    = _col;
		light.intensity = _int;
		
		return light;
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var object = new __3dLight();
		
		setTransform(object, _data);
		setLight(object, _data);
		
		return object;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}