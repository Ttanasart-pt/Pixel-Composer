function Node_Group_Input(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name  = "Input";
	color = COLORS.node_blend_collection;
	previewable = false;
	auto_height = false;
	input_fix_len = -1;
	
	inParent = undefined;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	display_list = [
		/*Integer*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area", "Enum button", "Menu scroll" ],
		/*Float*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area" ],
		/*Boolean*/	[ "Default" ],
		/*Color*/	[ "Default", "Gradient", "Palette" ],
		/*Surface*/	[ "Default", ],
		/*Path*/	[ "Default", ],
		/*Curve*/	[ "Default", ],
		/*Text*/	[ "Default", ],
		/*Object*/	[ "Default", ],
		/*Node*/	[ "Default", ],
		/*3D*/		[ "Default", ],
		/*Any*/		[ "Default", ],
	]
	
	inputs[| 0] = nodeValue(0, "Display type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, display_list[0]);
	
	inputs[| 1] = nodeValue(1, "Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 1])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	inputs[| 2] = nodeValue(2, "Input type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Integer", "Float", "Boolean", "Color", "Surface", "Path", "Curve", "Text", "Object", "Node", "3D object", "Any" ]);
	
	inputs[| 3] = nodeValue(3, "Enum label", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(false);
	
	inputs[| 4] = nodeValue(4, "Vector size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "2", "3", "4" ])
		.setVisible(false);
	
	inputs[| 5] = nodeValue(5, "Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 6] = nodeValue(6, "Display gizmo", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	input_display_list = [ 
		["Display", false], 5, 6, 
		["Data",	false], 2, 0, 4, 1, 3,
	];
	
	outputs[| 0] = nodeValue(0, "Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(inParent.isArray()) return;
		inParent.drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
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
			
			inputs[| 0].editWidget.data_list = display_list[_val_type];
			inputs[| 0].setValue(0);
			_dtype = 0;
		}
		
		_dtype = display_list[_val_type][_dtype];
		
		inParent.type = _val_type;
		outputs[| 0].type = _val_type;
		var _val = inParent.getValue();
		
		switch(_dtype) {
			case "Range" :	inParent.setDisplay(VALUE_DISPLAY.range, [_range[0], _range[1], 0.01]);		break;
			
			case "Slider" :	inParent.setDisplay(VALUE_DISPLAY.slider, [_range[0], _range[1], 0.01]);	break;
			case "Slider range" :	inParent.setDisplay(VALUE_DISPLAY.slider_range, [_range[0], _range[1], 0.01]);	break;
				
			case "Rotation" : inParent.setDisplay(VALUE_DISPLAY.rotation);	break;
			case "Rotation range" :
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
				inParent.setDisplay(VALUE_DISPLAY.rotation_range);
				break;
				
			case "Padding" :
				if(!is_array(_val) || array_length(_val) != 4)
					inParent.animator = new valueAnimator([0, 0, 0, 0], inParent);
				inParent.setDisplay(VALUE_DISPLAY.padding);
				break;
				
			case "Area" :
				if(!is_array(_val) || array_length(_val) != 5)
					inParent.animator = new valueAnimator([0, 0, 0, 0, 5], inParent);
				inParent.setDisplay(VALUE_DISPLAY.area);
				break;
				
			case "Vector" :
			case "Vector range" :
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
				if(_dtype == "Vector")				inParent.setDisplay(VALUE_DISPLAY.vector);
				else if(_dtype == "Vector range")	inParent.setDisplay(VALUE_DISPLAY.vector_range);
				break;
			
			case "Enum button" : inParent.setDisplay(VALUE_DISPLAY.enum_button, string_splice(_enum_label, ",")); break;
			case "Menu scroll" : inParent.setDisplay(VALUE_DISPLAY.enum_scroll, string_splice(_enum_label, ",")); break;
			
			case "Palette" :
				if(!is_array(_val))
					inParent.animator = new valueAnimator([c_black], inParent);
				inParent.setDisplay(VALUE_DISPLAY.palette);
				break;
				
			case "Gradient":	inParent.setDisplay(VALUE_DISPLAY.gradient);	break;
			default:			inParent.setDisplay(VALUE_DISPLAY._default);	break;
		}
		
		if(index == 5)
			group.sortIO();
	}
	
	static createInput = function(override_order = true) {
		if(group == noone || !is_struct(group)) return noone;
			
		if(override_order) {
			input_fix_len = ds_list_size(group.inputs);
			inputs[| 5].setValue(input_fix_len);
		} else {
			input_fix_len = inputs[| 5].getValue();
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
	
	if(!LOADING && !APPENDING) createInput();
	
	dtype  = -1;
	range  = 0;
	
	static step = function() {
		if(is_undefined(inParent)) return;
		
		inParent.name = name;
	}
	
	static update = function() {
		if(is_undefined(inParent)) return;
		
		var _dtype = inputs[| 0].getValue();
		var _data  = inputs[| 2].getValue();
		_dtype = display_list[_data][_dtype];
		
		inputs[| 1].setVisible(false);
		inputs[| 3].setVisible(false);
		inputs[| 4].setVisible(false);
		
		switch(_dtype) {
			case "Range" :
			case "Slider" :
			case "Slider range" :
				inputs[| 1].setVisible(true);
				break;
			case "Enum button" :
			case "Menu scroll" :
				inputs[| 3].setVisible(true);
				break;
			case "Vector" :
			case "Vector range" :
				inputs[| 4].setVisible(true);
				break;
		}
	}
	
	static postDeserialize = function() {
		createInput(false);
		var _inputs = load_map[? "inputs"];
		inputs[| 5].applyDeserialize(_inputs[| 5], load_scale);
		
		inputs[| 2].applyDeserialize(_inputs[| 2], load_scale);
		onValueUpdate(2);
	}
	
	static applyDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		var amo = min(ds_list_size(_inputs), ds_list_size(inputs));
		
		for(var i = 0; i < amo; i++) {
			if(i == 2 || i == 5) continue;
			inputs[| i].applyDeserialize(_inputs[| i], load_scale);
			var raw_val = _inputs[| i][? "raw value"];
		}
		
		if(LOADING_VERSION < 1060) {
			var _dtype = inputs[| 0].getValue();
			switch(_dtype) {
				case VALUE_DISPLAY.range :			inputs[| 0].setValue( 1); break;
				case VALUE_DISPLAY.rotation :		inputs[| 0].setValue( 2); break;
				case VALUE_DISPLAY.rotation_range :	inputs[| 0].setValue( 3); break;
				case VALUE_DISPLAY.slider :			inputs[| 0].setValue( 4); break;
				case VALUE_DISPLAY.slider_range :	inputs[| 0].setValue( 5); break;
				case VALUE_DISPLAY.padding :		inputs[| 0].setValue( 6); break;
				case VALUE_DISPLAY.vector :			inputs[| 0].setValue( 7); break;
				case VALUE_DISPLAY.vector_range :	inputs[| 0].setValue( 8); break;
				case VALUE_DISPLAY.area :			inputs[| 0].setValue( 9); break;
				case VALUE_DISPLAY.enum_button :	inputs[| 0].setValue(10); break;
				case VALUE_DISPLAY.enum_scroll :	inputs[| 0].setValue(11); break;
				
				case VALUE_DISPLAY.gradient :		inputs[| 0].setValue( 1); break;
				case VALUE_DISPLAY.palette :		inputs[| 0].setValue( 2); break;
				
				default : inputs[| 0].setValue( 0); break;
			}
		}
		
		inParent.name = name;
		onValueUpdate(0);
	}
	
	static onDestroy = function() {
		if(is_undefined(inParent)) return;
		
		ds_list_remove(group.inputs, inParent);
	}
}