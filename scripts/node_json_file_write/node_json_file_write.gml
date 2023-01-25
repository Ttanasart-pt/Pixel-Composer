function Node_Json_File_Write(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "JSON File Out";
	color = COLORS.node_blend_input;
	previewable = false;
	
	w = 128;
	
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_save, ["*.json", ""]);
		
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue( index + 0, "Key", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue( index + 1, "value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
			.setVisible(false, true);
		
		array_push(input_display_list, index + 0);
		array_push(input_display_list, index + 1);
	}
	
	input_display_list = [ 0,
		["Inputs", false],
	]
	
	input_fix_len	  = ds_list_size(inputs);
	input_display_len = array_length(input_display_list);
	data_length		  = 2;
	
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(inputs[| i].getValue() != "") {
				ds_list_add(_in, inputs[| i + 0]);
				ds_list_add(_in, inputs[| i + 1]);
				
				array_push(input_display_list, i + 0);
				array_push(input_display_list, i + 1);
			} else {
				delete inputs[| i + 0];
				delete inputs[| i + 1];
			}
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ )
			_in[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		createNewInput();
	}
	
	static onValueUpdate = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		if((index - input_fix_len) % data_length == 0) { //Variable name
			inputs[| index + 1].name = inputs[| index].getValue() + " value";
		}
		
		refreshDynamicInput();
	}
	
	static update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		if(filename_ext(path) != ".json")
			path += ".json";
			
		var cont = {};
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var _key = inputs[| i + 0].getValue();
			var _val = inputs[| i + 1].getValue();
			
			inputs[| i + 1].type = inputs[| i + 1].value_from? inputs[| i + 1].value_from.type : VALUE_TYPE.any;
			
			variable_struct_set(cont, _key, _val);
		}
		
		json_save_struct(path, cont);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(inputs[| 0].getValue());
		if(filename_ext(str) != ".json")
			str += ".json";
			
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
	
	static doApplyDeserialize = function() {
		refreshDynamicInput();
	}
}