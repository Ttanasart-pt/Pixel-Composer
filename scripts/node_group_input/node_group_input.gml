function Node_create_Group_Input(_x, _y) {
	if(!LOADING && !APPENDING && PANEL_GRAPH.getCurrentContext() == -1) return;
	var node = new Node_Group_Input(_x, _y, PANEL_GRAPH.getCurrentContext());
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Group_Input(_x, _y, _group) : Node(_x, _y) constructor {
	name  = "Input";
	color = c_ui_yellow;
	previewable = false;
	auto_height = false;
	input_index = -1;
	
	self.group = _group;
	
	w = 96;
	min_h = 0;
	h = 32 + 24;
	
	inputs[| 0] = nodeValue(0, "Display type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Default", "Range", "Enum Scroll", "Enum Button", "Rotation", "Rotation range", 
			"Slider", "Slider range", "Gradient", "Palette", "Padding", "Vector", "Vector range", "Area", "Curve" ])
		.setVisible(false);
	
	inputs[| 1] = nodeValue(1, "Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 1])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false, false);
	
	inputs[| 2] = nodeValue(2, "Input type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Integer", "Float", "Boolean", "Color", "Surface", "Path", "Curve", "Text", "Object", "Any" ])
		.setVisible(false);
	
	inputs[| 3] = nodeValue(3, "Enum label", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(false, false);
	
	inputs[| 4] = nodeValue(4, "Vector size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "2", "3", "4" ])
		.setVisible(false, false);
	
	input_display_list = [ 2, 0, 1, 3, 4 ];
	
	outputs[| 0] = nodeValue(0, "Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	function onValueUpdate(index) {
		var _dtype = inputs[| 0].getValue();
		var _range = inputs[| 1].getValue();
		var _val_type = inputs[| 2].getValue();
		var _enum_label = inputs[| 3].getValue();
		var _vec_size = inputs[| 4].getValue();
		
		_inParent.type = _val_type;
		outputs[| 0].type = _val_type;
		var _val = _inParent.getValue();
		
		switch(_dtype) {
			case VALUE_DISPLAY.range :
			case VALUE_DISPLAY.slider :
				_inParent.setDisplay(_dtype, [_range[0], _range[1], 0.01]);
				break;
				
			case VALUE_DISPLAY.slider_range :
				_inParent.setDisplay(_dtype, [_range[0], _range[1], 0.01]);
			case VALUE_DISPLAY.rotation_range :
				if(!is_array(_val) || array_length(_val) != 2) 
					_inParent.value = new animValue([0, 0], _inParent);
				break;
				
			case VALUE_DISPLAY.enum_button :
			case VALUE_DISPLAY.enum_scroll :
				_inParent.setDisplay(_dtype, string_splice(_enum_label, ","));
				break;
				
			case VALUE_DISPLAY.padding :
				if(!is_array(_val) || array_length(_val) != 4)
					_inParent.value = new animValue([0, 0, 0, 0], _inParent);
				break;
				
			case VALUE_DISPLAY.area :
				if(!is_array(_val) || array_length(_val) != 5)
					_inParent.value = new animValue([0, 0, 0, 0, 5], _inParent);
				break;
				
			case VALUE_DISPLAY.vector :
			case VALUE_DISPLAY.vector_range :
				switch(_vec_size) {
					case 0 : 
						if(!is_array(_val) || array_length(_val) != 2)
							_inParent.value = new animValue([0, 0], _inParent);
						break;
					case 1 : 
						if(!is_array(_val) || array_length(_val) != 3)
							_inParent.value = new animValue([0, 0, 0], _inParent);
						break;
					case 2 : 
						if(!is_array(_val) || array_length(_val) != 4)
							_inParent.value = new animValue([0, 0, 0, 0], _inParent);
						break;
				}
				
				_inParent.setDisplay(_dtype);
				break;
				
			case VALUE_DISPLAY.palette :
				if(!is_array(_val))
					_inParent.value = new animValue([c_black], _inParent);
				break;
				
			default :
				_inParent.setDisplay(_dtype);
				break;
		}
	}
	
	function createInput() {
		input_index = ds_list_size(group.inputs);
		_inParent = nodeValue(ds_list_size(group.inputs), "Value", group, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1);
		ds_list_add(group.inputs, _inParent);
		outputs[| 0].setFrom(_inParent, false, false);
		group.setHeight();
		
		onValueUpdate(0);
	}
	
	if(!LOADING && !APPENDING)
		createInput();
	
	dtype  = -1;
	range  = 0;
	
	function update() {
		_inParent.name = name;
		
		var _dtype = inputs[| 0].getValue();
		
		inputs[| 1].show_in_inspector = false;
		inputs[| 3].show_in_inspector = false;
		inputs[| 4].show_in_inspector = false;
		
		switch(_dtype) {
			case VALUE_DISPLAY.range :
			case VALUE_DISPLAY.slider :
			case VALUE_DISPLAY.slider_range :
				inputs[| 1].show_in_inspector = true;
				break;
			case VALUE_DISPLAY.enum_button :
			case VALUE_DISPLAY.enum_scroll :
				inputs[| 3].show_in_inspector = true;
				break;
			case VALUE_DISPLAY.vector :
			case VALUE_DISPLAY.vector_range :
				inputs[| 4].show_in_inspector = true;
				break;
		}
	}
	
	static preConnect = function() {
		createInput();
		onValueUpdate(0);
	}
	
	function onDestroy() {
		ds_list_remove(group.inputs, _inParent);
	}
}