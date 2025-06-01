function Node_Switch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Switch";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text( "Index" )).setVisible(true, true).rejectArray();
	newInput(1, nodeValue( "Default value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )).setVisible(false, true);
	
	size_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = ui(48);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		if(buttonTextIconInstant(true, THEME.button_hide_fill, _x, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.add, __txt("Add"), COLORS._main_value_positive) == 2)
			addInput();
		
		var amo = attributes.size;
		if(buttonTextIconInstant(attributes.size > 0, THEME.button_hide_fill, _x + _w - bw, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.minus, __txt("Remove"), COLORS._main_value_negative) == 2)
			deleteInput(array_length(inputs) - data_length);
		
		return _h;
	});
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.any, 0));
	
	input_display_list = [ 0, 1, 
		["Cases",  false], size_adjust_tool
	]
	
	#region //////////////////////////////// Dynamic IO ////////////////////////////////
		
		static createNewInput = function(index = array_length(inputs)) {
			var bDel  = button(function() /*=>*/ {return node.deleteInput(index)})
				.setIcon(THEME.minus_16, 0, COLORS._main_icon);
			
			inputs[index + 0] = nodeValue_Text("Case")
				.setDisplay(VALUE_DISPLAY.text_box, { side_button : bDel })
				.setAnimable(false);
			bDel.setContext(inputs[index + 0]);
			
			inputs[index + 1] = nodeValue("value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )
				.setVisible(false, false);
			
			return inputs[index + 0];
		} 
		
		setDynamicInput(2, false);
		
		static addInput = function() {
			var index = array_length(inputs);
			
			attributes.size++;
			createNewInput();
			
			if(!UNDO_HOLDING) {
				var _inputs = array_create(data_length);
				for(var i = 0; i < data_length; i++)
					_inputs[i] = inputs[index + i];
				
				recordAction(ACTION_TYPE.custom, function(data, undo) {
					if(undo) deleteInput(data.index);
					else     insertInput(data.index, data.inputs);
				}, { index, inputs : _inputs });
			}
			
			onInputResize();
		}
		
		static deleteInput = function(index) {
			if(!UNDO_HOLDING) {
				var _inputs = array_create(data_length);
				for(var i = 0; i < data_length; i++)
					_inputs[i] = inputs[index + i];
				
				recordAction(ACTION_TYPE.custom, function(data, undo) {
					if(undo) insertInput(data.index, data.inputs);
					else     deleteInput(data.index);
				}, { index, inputs : _inputs });
			}
			
			attributes.size--;
			for(var i = data_length - 1; i >= 0; i--)
				array_delete(inputs, index + i, 1);
			
			onInputResize();
		}
		
		static insertInput = function(index, _inputs) {
			attributes.size++;
			
			for(var i = 0; i < data_length; i++)
				array_insert(inputs, index + i, _inputs[i]);
			
			onInputResize();
		}
		
		static refreshDynamicInput = function() {
			input_display_list = array_clone(input_display_list_raw);
			
			for( var i = input_fix_len; i < array_length(inputs); i++ ) {
				inputs[i].index = i;
				array_push(input_display_list, i);
			}
			
			getJunctionList();
		}
	
	#endregion //////////////////////////////// Dynamic IO ////////////////////////////////
		
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING) return;
		if(index < 0) return;
		
		inputs[1].setType(inputs[1].value_from? inputs[1].value_from.type : VALUE_TYPE.any);
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			inputs[i + 1].setType(VALUE_TYPE.any);
			if(inputs[i + 1].value_from != noone)
				inputs[i + 1].setType(inputs[i + 1].value_from.type);
		}
	}
	
	static onValueUpdate = function(index = 0) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		if(safe_mod(index - input_fix_len, data_length) == 0) {
			inputs[index + 1].setVisible(false, true);
			inputs[index + 1].name = $"{getInputData(index)} value";
		}
		
		refreshDynamicInput();
	}
	
	static step = function() {
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _inp = inputs[i + 1];
			if(_inp.value_from == noone) continue;
			
			_inp.setType(_inp.value_from.type);
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var sele = getInputData(0);
		var _res = getInputData(1);
		
		outputs[0].setType(inputs[1].value_from? inputs[1].value_from.type : VALUE_TYPE.any);
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _cas = getInputData(i + 0);
			var _val = getInputData(i + 1);
			
			if(sele == _cas) {
				_res = _val;
				var _typ = inputs[i + 1].value_from? inputs[i + 1].value_from.type : inputs[i + 1].type;
				outputs[0].setType(_typ);
			}
		}
		
		outputs[0].setValue(_res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var frm = inputs[1];
		var sele = getInputData(0);
		var _res = getInputData(1);
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _cas = getInputData(i + 0);
			if(sele == _cas) frm = inputs[i + 1]; 
		}
		
		var to  = outputs[0];
		var c0 = value_color(frm.type);
		
		draw_set_color(c0);
		draw_set_alpha(0.5);
		draw_line_width(frm.x, frm.y, to.x, to.y, _s * 4);
		draw_set_alpha(1);
		
		draw_set_text(f_sdf, fa_left, fa_center);
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(inputs[1].visible) {
			var str = string("default");
			var ss	= min(_s * 0.4 / UI_SCALE, string_scale(str, bbox.w - 16 * _s, 999));
			
			draw_set_color(value_color(inputs[1].type));
			draw_text_transformed(bbox.x0 + 8 * _s, inputs[1].y, str, ss, ss, 0);
		}
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			if(!inputs[i + 1].visible) continue;
			
			var str = string(getInputData(i, ""));
			if(str == "") continue;
			
			var ss	= min(_s * 0.4 / UI_SCALE, string_scale(str, bbox.w - 16 * _s, 999));
			
			draw_set_color(value_color(inputs[i + 1].type));
			draw_text_transformed(bbox.x0 + 8 * _s, inputs[i + 1].y, str, ss, ss, 0);
		}
	}
	
	static postApplyDeserialize = function() { refreshDynamicInput(); }
}