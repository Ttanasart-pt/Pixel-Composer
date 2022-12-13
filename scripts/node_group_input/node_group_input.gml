function Node_Group_Input(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name  = "Input";
	color = COLORS.node_blend_collection;
	previewable = false;
	auto_height = false;
	input_index = -1;
	
	group = _group;
	inParent = undefined;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue(0, "Display type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Default", "Range", "Enum Scroll", "Enum Button", "Rotation", "Rotation range", 
			"Slider", "Slider range", "Gradient", "Palette", "Padding", "Vector", "Vector range", "Area", "Curve" ]);
	
	inputs[| 1] = nodeValue(1, "Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 1])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	inputs[| 2] = nodeValue(2, "Input type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Integer", "Float", "Boolean", "Color", "Surface", "Path", "Curve", "Text", "Object", "Any" ]);
	
	inputs[| 3] = nodeValue(3, "Enum label", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(false);
	
	inputs[| 4] = nodeValue(4, "Vector size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "2", "3", "4" ])
		.setVisible(false);
	
	inputs[| 5] = nodeValue(5, "Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	input_display_list = [ 
		["Display", false], 5, 
		["Data",	false], 2, 0, 4, 1, 3,
	];
	
	outputs[| 0] = nodeValue(0, "Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static onValueUpdate = function(index) {
		if(is_undefined(inParent)) return;
		
		var _dtype = inputs[| 0].getValue();
		var _range = inputs[| 1].getValue();
		var _val_type = inputs[| 2].getValue();
		var _enum_label = inputs[| 3].getValue();
		var _vec_size = inputs[| 4].getValue();
		
		if(index == 2) {
			var _o = outputs[| 0];
			for(var j = 0; j < ds_list_size(_o.value_to); j++) {
				var _to = _o.value_to[| j];
				if(_to.value_from == _o)
					_to.removeFrom();
			}
		}
		
		inParent.type = _val_type;
		outputs[| 0].type = _val_type;
		var _val = inParent.getValue();
		
		switch(_dtype) {
			case VALUE_DISPLAY.range :
			case VALUE_DISPLAY.slider :
				inParent.setDisplay(_dtype, [_range[0], _range[1], 0.01]);
				break;
				
			case VALUE_DISPLAY.slider_range :
				inParent.setDisplay(_dtype, [_range[0], _range[1], 0.01]);
				break;
				
			case VALUE_DISPLAY.rotation_range :
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
				inParent.setDisplay(_dtype);
				break;
				
			case VALUE_DISPLAY.enum_button :
			case VALUE_DISPLAY.enum_scroll :
				inParent.setDisplay(_dtype, string_splice(_enum_label, ","));
				break;
				
			case VALUE_DISPLAY.padding :
				if(!is_array(_val) || array_length(_val) != 4)
					inParent.animator = new valueAnimator([0, 0, 0, 0], inParent);
				inParent.setDisplay(_dtype);
				break;
				
			case VALUE_DISPLAY.area :
				if(!is_array(_val) || array_length(_val) != 5)
					inParent.animator = new valueAnimator([0, 0, 0, 0, 5], inParent);
				inParent.setDisplay(_dtype);
				break;
				
			case VALUE_DISPLAY.vector :
			case VALUE_DISPLAY.vector_range :
				switch(_vec_size) {
					case 0 : 
						if(!is_array(_val) || array_length(_val) != 2)
							inParent.animator = new valueAnimator([0, 0], inParent);
						break;
					case 1 : 
						if(!is_array(_val) || array_length(_val) != 3)
							inParent.animator = new valueAnimator([0, 0, 0], inParent);
						break;
					case 2 : 
						if(!is_array(_val) || array_length(_val) != 4)
							inParent.animator = new valueAnimator([0, 0, 0, 0], inParent);
						break;
				}
				
				inParent.setDisplay(_dtype);
				break;
				
			case VALUE_DISPLAY.palette :
				if(!is_array(_val))
					inParent.animator = new valueAnimator([c_black], inParent);
				inParent.setDisplay(_dtype);
				break;
				
			default :
				inParent.setDisplay(_dtype);
				break;
		}
		
		if(index == 5)
			group.sortIO();
	}
	
	static createInput = function(override_order = true) {
		if(group == noone || !is_struct(group)) return noone;
			
		if(override_order) {
			input_index = ds_list_size(group.inputs);
			inputs[| 5].setValue(input_index);
		} else {
			input_index = inputs[| 5].getValue();
		}
			
		inParent = nodeValue(ds_list_size(group.inputs), "Value", group, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1)
			.setVisible(true, true);
		inParent.from = self;
			
		ds_list_add(group.inputs, inParent);
		outputs[| 0].setFrom(inParent, false, false);
		group.setHeight();
		group.sortIO();
			
		onValueUpdate(0);
		
		return inParent;
	}
	
	if(!LOADING && !APPENDING)
		createInput();
	
	dtype  = -1;
	range  = 0;
	
	static step = function() {
		if(is_undefined(inParent)) return;
		
		inParent.name = name;	
	}
	
	static update = function() {
		if(is_undefined(inParent)) return;
		
		var _dtype = inputs[| 0].getValue();
		
		inputs[| 1].setVisible(false);
		inputs[| 3].setVisible(false);
		inputs[| 4].setVisible(false);
		
		switch(_dtype) {
			case VALUE_DISPLAY.range :
			case VALUE_DISPLAY.slider :
			case VALUE_DISPLAY.slider_range :
				inputs[| 1].setVisible(true);
				break;
			case VALUE_DISPLAY.enum_button :
			case VALUE_DISPLAY.enum_scroll :
				inputs[| 3].setVisible(true);
				break;
			case VALUE_DISPLAY.vector :
			case VALUE_DISPLAY.vector_range :
				inputs[| 4].setVisible(true);
				break;
		}
	}
	
	static postDeserialize = function() {
		createInput(false);
		onValueUpdate(0);
	}
	
	static onDestroy = function() {
		if(is_undefined(inParent)) return;
		
		ds_list_remove(group.inputs, inParent);
	}
}