function Node_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array";
	
	attributes.spread_value = false;
	
	inputs[| 0] = nodeValue_Enum_Scroll("Type", self, 0, { data: [ "Any", "Surface", "Number", "Color", "Text" ], update_hover: false })
		.rejectArray();
	
	inputs[| 1] = nodeValue_Bool("Spread array", self, false, "Unpack array and push the contents into the output one by one." )
		.rejectArray();
	
	array_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = ui(48);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		if(buttonTextIconInstant(true, THEME.button_hide, _x, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.add, __txt("Add"), COLORS._main_value_positive) == 2) {
			attributes.size = max(attributes.size, (ds_list_size(inputs) - input_fix_len) / data_length ) + 1;
			onInputResize();
		}
		
		var act = attributes.size > 0;
		if(buttonTextIconInstant(act, THEME.button_hide, _x + _w - bw, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.minus, __txt("Remove"), COLORS._main_value_negative) == 2) {
			attributes.size--;
			onInputResize();
		}
		
		return _h;
	});
	
	input_display_list = [ 0, 1, ["Contents", false], array_adjust_tool, ];
	
	outputs[| 0] = nodeValue_Output("Array", self, VALUE_TYPE.any, []);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		var _typ  = getType();
		
		inputs[| index] = nodeValue("Input", self, JUNCTION_CONNECT.input, _typ, -1 )
			.setVisible(true, true);
		array_push(input_display_list, index);
		
		return inputs[| index];
	}
	
	setDynamicInput(1);
	
	static getType = function() {
		var _type = getInputData(0);
		
		switch(_type) {
			case 1 :  return VALUE_TYPE.surface; 
			case 2 :  return VALUE_TYPE.float;
			case 3 :  return VALUE_TYPE.color;
			case 4 :  return VALUE_TYPE.text; 
			default : return VALUE_TYPE.any;
		}
	}
	
	static refreshDynamicInput = function() {
		var _l  = ds_list_create();
		var amo = attributes.size;
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			var _inp = inputs[| i];
			
			if(i < input_fix_len + amo || _inp.hasJunctionFrom())
				ds_list_add(_l, _inp);
		}
		
		var _add = amo - getInputAmount();
		repeat(_add) ds_list_add(_l, createNewInput());
		
		input_display_list = array_clone(input_display_list_raw);
		
		for( var i = input_fix_len; i < ds_list_size(_l); i++ ) {
			_l[| i].index = i;
			array_push(input_display_list, i);
		}
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		getJunctionList();
		setHeight();
		
	}
	
	static updateType = function(resetVal = false) {
		var _typ = getType();
		if(getInputAmount() <= 0) return;
		
		if(_typ == VALUE_TYPE.any && inputs[| input_fix_len].value_from)
			outputs[| 0].setType(inputs[| input_fix_len].value_from.type);
		else 
			outputs[| 0].setType(_typ);
		
		for( var i = ds_list_size(inputs) - 1; i >= input_fix_len; i-- ) {
			if(resetVal) inputs[| i].resetValue();
			
			if(inputs[| i].value_from == noone) {
				inputs[| i].setType(_typ);
				inputs[| i].resetDisplay();
				
			} else if (value_bit(inputs[| i].value_from.type) & value_bit(_typ) != 0) {
				inputs[| i].setType(inputs[| i].value_from.type);
				inputs[| i].resetDisplay();
				
			} else {
				inputs[| i].removeFrom();
			}
		}
		
		refreshDynamicInput();
	}
	
	static onValueUpdate = function(index = 0) {
		if(LOADING || APPENDING) return;
		
		if(index == 0) { updateType(true); return; }
		if(index == 1) return;
		
		refreshDynamicInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
		
		var _typ = getType();
		if(_typ != VALUE_TYPE.any) return;
		if(index >= ds_list_size(inputs)) return;
		
		inputs[| index].setType(inputs[| index].value_from? inputs[| index].value_from.type : _typ);
		inputs[| index].resetDisplay();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _typ = getType();
		var res  = [];
		var ind  = 0;
		var spd  = getInputData(1);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
			var val = getInputData(i);
			
			if(is_array(val) && spd) array_append(res, val);
			else                     array_push(res, val);
			
			if(_typ == VALUE_TYPE.any && inputs[| i].value_from)
				outputs[| 0].setType(inputs[| i].value_from.type);
		}
		
		outputs[| 0].setValue(res);
	}
	
	static postConnect = function() { updateType(false); }
}