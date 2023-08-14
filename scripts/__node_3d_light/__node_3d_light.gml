function Node_3D_Light(_x, _y, _group = noone) : Node_3DObject(_x, _y, _group) constructor {
	name   = "3D Light";
	object = new __3dLight();
	
	if(!LOADING && !APPENDING) {
		inputs[| 0].setValue([ 0, 0, 1 ]);
	}
	
	inputs[| input_d3d_index + 0] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| input_d3d_index + 1] = nodeValue("Intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	input_light_index = ds_list_size(inputs);
	
	outputs[| 0] = nodeValue("Light", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Light, object);
	
	#macro __d3d_input_list_light ["Light", false], input_d3d_index + 0, input_d3d_index + 1
	
	static setLight = function() {
		var _col = inputs[| input_d3d_index + 0].getValue();
		var _int = inputs[| input_d3d_index + 1].getValue();
		
		object.color		= _col;
		object.intensity	= _int;
		
		outputs[| 0].setValue(object);
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		setTransform();
		setLight();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}