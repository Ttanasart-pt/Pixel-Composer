function Node_Switch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Switch";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
		.setVisible(true, true)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Default value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(false, true);
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Case", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue("value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
			.setVisible(false, false);
		
		array_push(input_display_list, index + 0);
		array_push(input_display_list, index + 1);
	} #endregion
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	input_display_list = [ 0,
		["Inputs", false], 1
	]
	
	setIsDynamicInput(2);
	
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() { #region
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(getInputData(i) != "") {
				ds_list_add(_in, inputs[| i + 0]);
				ds_list_add(_in, inputs[| i + 1]);
				inputs[| i + 1].setVisible(false, true);
				
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
	} #endregion
	
	static onValueFromUpdate = function(index) { #region
		if(LOADING || APPENDING) return;
		
		inputs[| 1].setType(inputs[| 1].value_from? inputs[| 1].value_from.type : VALUE_TYPE.any);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			inputs[| i + 1].setType(VALUE_TYPE.any);
			if(inputs[| i + 1].value_from != noone)
				inputs[| i + 1].setType(inputs[| i + 1].value_from.type);
		}
	} #endregion
	
	static onValueUpdate = function(index = 0) { #region
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		if(safe_mod(index - input_fix_len, data_length) == 0) //Variable name
			inputs[| index + 1].name = getInputData(index) + " value";
		
		refreshDynamicInput();
	} #endregion
	
	static step = function() { #region
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _inp = inputs[| i + 1];
			if(_inp.isLeaf()) continue;
			
			_inp.setType(_inp.value_from.type);
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var sele = getInputData(0);
		var _res = getInputData(1);
		
		outputs[| 0].setType(inputs[| 1].value_from? inputs[| 1].value_from.type : VALUE_TYPE.any);
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var _cas = getInputData(i + 0);
			var _val = getInputData(i + 1);
			
			if(sele == _cas) {
				_res = _val;
				var _typ = inputs[| i + 1].value_from? inputs[| i + 1].value_from.type : inputs[| i + 1].type;
				outputs[| 0].setType(_typ);
			}
		}
		
		outputs[| 0].setValue(_res);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var frm = inputs[| 1];
		var sele = getInputData(0);
		var _res = getInputData(1);
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var _cas = getInputData(i + 0);
			if(sele == _cas) frm = inputs[| i + 1]; 
		}
		
		var to  = outputs[| 0];
		var c0 = value_color(frm.type);
		
		draw_set_color(c0);
		draw_set_alpha(0.5);
		draw_line_width(frm.x, frm.y, to.x, to.y, _s * 4);
		draw_set_alpha(1);
		
		draw_set_text(f_sdf, fa_left, fa_center);
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(inputs[| 1].visible) {
			var str = string("default");
			var ss	= min(_s * 0.4, string_scale(str, bbox.w - 16 * _s, 999));
			draw_set_color(value_color(inputs[| 1].type));
			draw_text_transformed(bbox.x0 + 8 * _s, inputs[| 1].y, str, ss, ss, 0);
		}
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			if(!inputs[| i + 1].visible) continue;
			
			var str = string(getInputData(i));
			var ss	= min(_s * 0.4, string_scale(str, bbox.w - 16 * _s, 999));
			draw_set_color(value_color(inputs[| i + 1].type));
			draw_text_transformed(bbox.x0 + 8 * _s, inputs[| i + 1].y, str, ss, ss, 0);
		}
	} #endregion
	
	static doApplyDeserialize = function() { refreshDynamicInput(); }
}