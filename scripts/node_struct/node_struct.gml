function Node_Struct(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Struct";
	
	setDimension(96, 80);
	
	outputs[| 0] = nodeValue("Struct", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Key", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue("value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
			.setVisible(false, false);
	}

	setIsDynamicInput(2);
	
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(getInputData(i) != "") {
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
		
		refreshDynamicInput();
		
		if(index < 0) return;
		if(safe_mod(index - input_fix_len, data_length) == 0)
			inputs[| index + 1].name = getInputData(index) + " value";
	}
	
	static step = function() { 
		for(var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length) {
			var inp  = inputs[| i + 1];
			var typ  = inp.isLeaf()? VALUE_TYPE.any : inp.value_from.type;
			inp.setType(typ);
		}
	}
	
	static update = function() { 
		var str = {};
		
		for(var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length) {
			var key = getInputData(i + 0);
			var val = getInputData(i + 1);
			var frm = inputs[| i + 1].value_from;
			
			if(frm != noone && frm.type == VALUE_TYPE.surface)
				str[$ key] = new Surface(val);
			else if(frm != noone && frm.type == VALUE_TYPE.buffer)
				str[$ key] = new Buffer(val);
			else
				str[$ key] = val;
		}
		
		outputs[| 0].setValue(str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_left, fa_center, COLORS._main_text);
		
		for(var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length) {
			var key = getInputData(i + 0);
			var val = inputs[| i + 1];
			var _ss = min(_s * 0.5, string_scale(key, bbox.w - 12 * _s, 9999));
			
			draw_set_color(value_color(val.type));
			draw_text_transformed(bbox.x0 + 6 * _s, inputs[| i + 0].y, key, _ss, _ss, 0);
		}
		
	}
	
	static doApplyDeserialize = function() {
		refreshDynamicInput();
	}
}