function Node_Switch(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Switch";
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue( 0, "Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue( 1, "Default value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(false, true);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue( index + 0, "Case", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue( index + 1, "value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
			.setVisible(false, true);
		
		array_push(input_display_list, index + 0);
		array_push(input_display_list, index + 1);
	}
	
	outputs[| 0] = nodeValue(0, "Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	input_display_list = [ 0,
		["Inputs", false], 1
	]
	
	input_fix_len	  = ds_list_size(inputs);
	input_display_len = array_length(input_display_list);
	data_length		  = 2;
	
	if(!LOADING && !APPENDING) createNewInput();
	
	static updateValueFrom = function(index) {
		if(LOADING || APPENDING) return;
		
		inputs[| 1].type = inputs[| 1].value_from? inputs[| 1].value_from.type : VALUE_TYPE.any;
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			inputs[| i + 1].type = VALUE_TYPE.any;
			if(inputs[| i + 1].value_from != noone)
				inputs[| i + 1].type = inputs[| i + 1].value_from.type;
		}
	}
	
	static updateValue = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		if((index - input_fix_len) % data_length == 0) { //Variable name
			inputs[| index + 1].name = inputs[| index].getValue() + " value";
		}
		
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
	
	static update = function() {
		var sele = inputs[| 0].getValue();
		var _res = inputs[| 1].getValue();
		
		outputs[| 0].type = inputs[| 1].value_from? inputs[| 1].value_from.type : VALUE_TYPE.any;
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var _cas = inputs[| i + 0].getValue();
			var _val = inputs[| i + 1].getValue();
			
			if(sele == _cas) {
				_res = _val;
				outputs[| 0].type = inputs[| i + 1].type;
			}
		}
		
		outputs[| 0].setValue(_res);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		var frm = inputs[| 1];
		var sele = inputs[| 0].getValue();
		var _res = inputs[| 1].getValue();
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var _cas = inputs[| i + 0].getValue();
			if(sele == _cas) frm = inputs[| i + 1]; 
		}
		
		var to  = outputs[| 0];
		var c0 = value_color(frm.type);
		
		draw_set_color(c0);
		draw_set_alpha(0.5);
		draw_line_width(frm.x, frm.y, to.x, to.y, _s * 4);
		draw_set_alpha(1);
	}
}