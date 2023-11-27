function Node_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, { data: [ "Any", "Surface", "Number", "Color", "Text" ], update_hover: false })
		.rejectArray();
	
	inputs[| 1] = nodeValue("Spread array", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Unpack array and push the contents into the output one by one." )
		.rejectArray();
	
	array_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var _h = ui(48);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		var bx = _x;
		var by = _y + ui(8);
		if(buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, _focus, _hover) == 2) {
			var amo = ds_list_size(inputs) - input_fix_len;
			attributes.size = amo + 1;
			refreshDynamicInput();
			update();
		}
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_icon_light);
		var bxc = bx + bw / 2 - (string_width("Add") + ui(64)) / 2;
		var byc = by + bh / 2;
		draw_sprite_ui(THEME.add, 0, bxc + ui(24), byc,,,, COLORS._main_icon_light);
		draw_text(bxc + ui(48), byc, __txt("Add"));
		
		var bx = _x + bw + ui(8);
		var amo = attributes.size;
		if(amo > 1 && buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, _focus, _hover) == 2) {
			var amo = ds_list_size(inputs) - input_fix_len;
			attributes.size = max(amo - 1, 1);
			refreshDynamicInput();
			update();
		}
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_icon_light);
		var bxc = bx + bw / 2 - (string_width("Remove") + ui(64)) / 2;
		var byc = by + bh / 2;
		draw_sprite_ui(THEME.minus, 0, bxc + ui(24), byc,,,, COLORS._main_icon_light, (amo > 1) * 0.5 + 0.5);
		draw_set_alpha((amo > 1) * 0.5 + 0.5);
		draw_text(bxc + ui(48), byc, __txt("Remove"));
		draw_set_alpha(1);
		
		return _h;
	}); #endregion
	
	input_display_list = [ 0, array_adjust_tool, 1 ];
	
	setIsDynamicInput(1);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	
	attributes.size = 1;
	attributes.spread_value = false;
	
	static getType = function() { #region
		var _type = getInputData(0);
		
		switch(_type) {
			case 1 :  return VALUE_TYPE.surface; 
			case 2 :  return VALUE_TYPE.float;
			case 3 :  return VALUE_TYPE.color;
			case 4 :  return VALUE_TYPE.text; 
			default : return VALUE_TYPE.any;
		}
	} #endregion
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		var _typ  = getType();
		
		inputs[| index] = nodeValue("Input", self, JUNCTION_CONNECT.input, _typ, -1 )
			.setVisible(true, true);
		array_push(input_display_list, index);
		
		return inputs[| index];
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
	
	static refreshDynamicInput = function() { #region
		var _l       = ds_list_create();
		var amo      = attributes.size;
		var extra    = true;
		var lastNode = noone;
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			
			if(i < input_fix_len || i < amo || inputs[| i].value_from)
				ds_list_add(_l, inputs[| i]);
		}
		
		var _add = amo - (ds_list_size(_l) - input_fix_len);
		repeat(_add) {
			lastNode = createNewInput();
			ds_list_add(_l, lastNode);
		}
		
		input_display_list = [];
		for( var i = 0; i < ds_list_size(_l); i++ ) {
			_l[| i].index = i;
			array_push(input_display_list, i);
			
			if(i >= input_fix_len && _l[| i].isLeaf())
				extra = false;
		}
		array_insert(input_display_list, 1, array_adjust_tool);
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		if(extra) lastNode = createNewInput();
	} #endregion
	
	static updateType = function(resetVal = false) { #region
		var _typ = getType();
		outputs[| 0].setType(_typ);
		
		for( var i = ds_list_size(inputs) - 1; i >= input_fix_len; i-- ) {
			if(resetVal) inputs[| i].resetValue();
			
			if(inputs[| i].value_from == noone || (value_bit(inputs[| i].value_from.type) & value_bit(_typ) != 0)) {
				inputs[| i].setType(inputs[| i].value_from? inputs[| i].value_from.type : _typ);
				inputs[| i].resetDisplay();
			} else {
				inputs[| i].removeFrom();
			}
		}
		
		refreshDynamicInput();
	} #endregion
	
	static onValueUpdate = function(index = 0) { #region
		if(LOADING || APPENDING) return;
		
		if(index == 0) { updateType(true); return; }
		if(index == 1) return;
		
		refreshDynamicInput();
	} #endregion
	
	static onValueFromUpdate = function(index) { #region
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
		
		var _typ = getType();
		if(_typ != VALUE_TYPE.any) return;
		
		inputs[| index].setType(inputs[| index].value_from? inputs[| index].value_from.type : _typ);
		inputs[| index].resetDisplay();
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _typ = getType();
		var res  = [];
		var ind  = 0;
		var spd  = getInputData(1);
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
			var val = getInputData(i);
			
			if(is_array(val) && spd) array_append(res, val);
			else                     array_push(res, val);
		}
		
		if(_typ == VALUE_TYPE.any && inputs[| input_fix_len].value_from)
			outputs[| 0].setType(inputs[| input_fix_len].value_from.type);
		outputs[| 0].setValue(res);
		
		if(outputs[| 0].type == VALUE_TYPE.surface) {
			w = 128;
			previewable = true;
		} else {
			w = 96;
			previewable = false;
		}
	} #endregion
	
	static postConnect = function() { #region
		updateType(false);
	} #endregion
}