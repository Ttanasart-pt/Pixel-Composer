function Node_Struct(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Struct";
	previewable = false;
	
	w = 96;
	
	outputs[| 0] = nodeValue("Struct", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Key", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue("value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
			.setVisible(false, false);
	}
	
	input_fix_len	  = ds_list_size(inputs);
	data_length		  = 2;
	
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(inputs[| i].getValue() != "") {
				ds_list_add(_in, inputs[| i + 0]);
				ds_list_add(_in, inputs[| i + 1].setVisible(false, true));
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
	
	static onValueUpdate = function(index = 0) {
		if(LOADING || APPENDING) return;
		
		if(safe_mod(index - input_fix_len, data_length) == 0) { //Variable name
			inputs[| index + 1].name = inputs[| index].getValue() + " value";
		}
		
		refreshDynamicInput();
	}
	
	function step() { 
		for(var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length) {
			var inp  = inputs[| i + 1];
			var typ  = inp.value_from == noone? VALUE_TYPE.any : inp.value_from.type;
			inp.type = typ;
		}
	}
	
	function update() { 
		var str = {};
		
		for(var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length) {
			var key = inputs[| i + 0].getValue();
			var val = inputs[| i + 1].getValue();
			
			str[$ key] = val;
		}
		
		outputs[| 0].setValue(str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text);
		
		for(var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length) {
			var key = inputs[| i + 0].getValue();
			var val = inputs[| i + 1];
			
			draw_set_color(value_color(val.type));
			draw_text_transformed(bbox.x0 + 6 * _s, inputs[| i + 0].y - 1 * _s, key, _s, _s, 0);
		}
		
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