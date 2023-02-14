function variable_editor(nodeVal) constructor {
	value = nodeVal;
	
	val_type = [ VALUE_TYPE.integer, VALUE_TYPE.float, VALUE_TYPE.boolean, VALUE_TYPE.color, VALUE_TYPE.path, VALUE_TYPE.curve, VALUE_TYPE.text ];
	display_list = [
		/*Integer*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area" ],
		/*Float*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area" ],
		/*Boolean*/	[ "Default" ],
		/*Color*/	[ "Default", "Gradient", "Palette" ],
		/*Path*/	[ "Default", ],
		/*Curve*/	[ "Default", ],
		/*Text*/	[ "Default", ],
	]
	
	tb_name = new textArea(TEXTBOX_INPUT.text, function(str) { value.name = str; });
	
	sc_type = new scrollBox([ "Integer", "Float", "Boolean", "Color", "Path", "Curve", "Text" ], function(val) {
		value.type = val_type[val];
		value.resetDisplay();
		
		sc_disp.data_list = display_list[val];
	} );
	
	sc_disp = new scrollBox(display_list[0], function(val) {
		switch(val) {
			case "Default" :		value.setDisplay(VALUE_DISPLAY._default);		break;
			case "Range" :			value.setDisplay(VALUE_DISPLAY.range);			break;
			case "Rotation" :		value.setDisplay(VALUE_DISPLAY.rotation);		break;
			case "Rotation range" : value.setDisplay(VALUE_DISPLAY.rotation_range);	break;
			case "Slider" :			
				value.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);		
				break;
			case "Slider range" :	
				value.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);	
				break;
			case "Padding" :		value.setDisplay(VALUE_DISPLAY.padding);		break;
			case "Vector" :			value.setDisplay(VALUE_DISPLAY.vector);			break;
			case "Vector range" :	value.setDisplay(VALUE_DISPLAY.vector_range);	break;
			case "Area" :			value.setDisplay(VALUE_DISPLAY.area);			break;
			case "Gradient" :		value.setDisplay(VALUE_DISPLAY.gradient);		break;
			case "Palette" :		value.setDisplay(VALUE_DISPLAY.palette);		break;
		}
	} );
	
	static refreshInput = function() {
		
	}
}

function Node_Global() constructor {
	name	= "Global variable";
	x = 0;
	y = 0;
	
	use_cache = false;
	inputs  = ds_list_create();
	outputs = ds_list_create();
	value = ds_map_create();
	input_display_list = -1;
	
	inputs[| 0] = nodeValue("Default Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 32, 32 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	static step = function() {
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			var val = inputs[| i].getValue();
			value[? inputs[| i].name] = val;
		}
	}
	
	static serialize = function() {
		var _map = ds_map_create();
		var _inputs = ds_list_create();
		for(var i = 0; i < ds_list_size(inputs); i++) {
			ds_list_add(_inputs, inputs[| i].serialize());	
			ds_list_mark_as_map(_inputs, i);
		}
		ds_map_add_list(_map, "inputs", _inputs);
		return _map;
	}
	
	static deserialize = function(_map) {
		var _inputs = _map[? "inputs"];
		
		if(!ds_list_empty(_inputs) && !ds_list_empty(inputs)) {
			var _siz = min(ds_list_size(_inputs), ds_list_size(inputs));
			for(var i = 0; i < _siz; i++) {
				inputs[| i].deserialize(_inputs[| i]);
			}
		}
	}
}