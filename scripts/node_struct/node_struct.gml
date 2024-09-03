function Node_Struct(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Struct";
	
	setDimension(96, 48);
	
	size_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = ui(48);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		if(buttonTextIconInstant(true, THEME.button_hide, _x, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.add, __txt("Add"), COLORS._main_value_positive) == 2)
			addInput();
		
		var amo = attributes.size;
		if(buttonTextIconInstant(attributes.size > 0, THEME.button_hide, _x + _w - bw, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.minus, __txt("Remove"), COLORS._main_value_negative) == 2)
			deleteInput(array_length(inputs) - data_length);
		
		return _h;
	});
	
	input_display_list = [ size_adjust_tool, ];
	
	outputs[0] = nodeValue_Output("Struct", self, VALUE_TYPE.struct, {});
	
	#region //////////////////////////////// Dynamic IO ////////////////////////////////
	
		static createNewInput = function(list = inputs) {
			var index = array_length(list);
			var bDel  = button(function() { node.deleteInput(index); })
					.setIcon(THEME.minus_16, 0, COLORS._main_icon);
			
			list[index + 0] = nodeValue_Text("Key", self, "" )
				.setDisplay(VALUE_DISPLAY.text_box, { side_button : bDel })
				.setAnimable(false);
			bDel.setContext(list[index + 0]);
			
			list[index + 1] = nodeValue("value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )
				.setVisible(false, false);
				
			return list[index + 0];
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
			
			for( var i = 0; i < array_length(inputs); i++ ) {
				inputs[i].index = i;
				array_push(input_display_list, i);
			}
			
			getJunctionList();
		}
	
	#endregion //////////////////////////////// Dynamic IO ////////////////////////////////
		
	static onValueUpdate = function(index = 0) {
		if(LOADING || APPENDING) return;
		if(index < 0) return;
		
		if(safe_mod(index - input_fix_len, data_length) == 0) {
			inputs[index + 1].setVisible(false, true);
			inputs[index + 1].name = $"{getInputData(index)} value";
		}
	}
	
	static step = function() { 
		for(var i = input_fix_len; i < array_length(inputs); i += data_length) {
			var inp  = inputs[i + 1];
			var typ  = inp.value_from == noone? VALUE_TYPE.any : inp.value_from.type;
			inp.setType(typ);
		}
	}
	
	static update = function() { 
		var str = {};
		
		for(var i = input_fix_len; i < array_length(inputs); i += data_length) {
			var key = getInputData(i + 0);
			var val = getInputData(i + 1);
			var frm = inputs[i + 1].value_from;
			
			if(key == "") continue;
			
			if(frm != noone && frm.type == VALUE_TYPE.surface)
				str[$ key] = new Surface(val);
			else if(frm != noone && frm.type == VALUE_TYPE.buffer)
				str[$ key] = new Buffer(val);
			else
				str[$ key] = val;
		}
		
		outputs[0].setValue(str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_left, fa_center, COLORS._main_text);
		
		for(var i = input_fix_len; i < array_length(inputs); i += data_length) {
			var key = getInputData(i, "");
			var val = inputs[i + 1];
			if(!val.visible) continue;
			
			var _ss = min(_s * .4, string_scale(key, bbox.w - 12 * _s, 9999));
			
			draw_set_color(value_color(val.type));
			draw_text_transformed(bbox.x0 + 6 * _s, val.y, key, _ss, _ss, 0);
		}
	}
	
	static doApplyDeserialize = function() {
		refreshDynamicInput();
	}
}