function Node_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array";
	setDimension(96, 32);
	
	attributes.spread_value = false;
	
	newInput(0, nodeValue_Enum_Scroll("Type", self, 0, { data: [ "Any", "Surface", "Number", "Color", "Text" ], update_hover: false }))
		.rejectArray();
	
	newInput(1, nodeValue_Bool("Spread array", self, false, "Unpack array and push the contents into the output one by one." ))
		.rejectArray();
	
	array_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = ui(48);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		if(buttonTextIconInstant(true, THEME.button_hide, _x, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.add, __txt("Add"), COLORS._main_value_positive) == 2) {
			attributes.size = max(attributes.size, (array_length(inputs) - input_fix_len) / data_length ) + 1;
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
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, []));
	
	static createNewInput = function() {
		var index = array_length(inputs);
		var _typ  = getType();
		
		newInput(index, nodeValue("Input", self, CONNECT_TYPE.input, _typ, -1 ))
			.setVisible(true, true);
		array_push(input_display_list, index);
		
		return inputs[index];
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
		var _l  = [];
		var amo = attributes.size;
		
		for( var i = 0; i < array_length(inputs); i++ ) {
			var _inp = inputs[i];
			
			if(i < input_fix_len + amo || _inp.hasJunctionFrom())
				array_push(_l, _inp);
		}
		
		var _add = amo - getInputAmount();
		repeat(_add) array_push(_l, createNewInput());
		
		input_display_list = array_clone(input_display_list_raw);
		
		for( var i = input_fix_len; i < array_length(_l); i++ ) {
			_l[i].index = i;
			array_push(input_display_list, i);
		}
		

		inputs = _l;
		
		getJunctionList();
		setHeight();
		
	}
	
	static updateType = function(resetVal = false) {
		var _typ = getType();
		if(getInputAmount() <= 0) return;
		
		if(_typ == VALUE_TYPE.any && inputs[input_fix_len].value_from)
			outputs[0].setType(inputs[input_fix_len].value_from.type);
		else 
			outputs[0].setType(_typ);
		
		for( var i = array_length(inputs) - 1; i >= input_fix_len; i-- ) {
			if(resetVal) inputs[i].resetValue();
			
			if(inputs[i].value_from == noone) {
				inputs[i].setType(_typ);
				inputs[i].resetDisplay();
				
			} else if (value_bit(inputs[i].value_from.type) & value_bit(_typ) != 0) {
				inputs[i].setType(inputs[i].value_from.type);
				inputs[i].resetDisplay();
				
			} else {
				inputs[i].removeFrom();
			}
		}
		
		// w = _typ == VALUE_TYPE.surface? 128 : 96;
		
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
		if(index >= array_length(inputs)) return;
		
		inputs[index].setType(inputs[index].value_from? inputs[index].value_from.type : _typ);
		inputs[index].resetDisplay();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var spd  = getInputData(1);
		var _typ = getType();
		var res  = [];
		var ind  = 0;
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			var val = getInputData(i);
			
			if(is_array(val) && spd) array_append(res, val);
			else                     array_push(res, val);
			
			if(_typ == VALUE_TYPE.any && inputs[i].value_from)
				outputs[0].setType(inputs[i].value_from.type);
		}
		
		outputs[0].setValue(res);
	}
	
	static postConnect = function() { updateType(false); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var jh   = (junction_draw_hei_y - 4) * _s;
		
		var x0 = bbox.x0 + 6 * _s;
		var ww = bbox.w - 12 * _s;
		
		for(var i = input_fix_len; i < array_length(inputs); i += data_length) {
			var val = inputs[i];
			if(!val.isVisible()) continue;
			
			var key = getInputData(i, "");
			
			switch(val.type) {
				case VALUE_TYPE.integer :
				case VALUE_TYPE.float :
				case VALUE_TYPE.boolean :
				case VALUE_TYPE.text :
				case VALUE_TYPE.path :
					draw_set_text(f_sdf, fa_left, fa_center, value_color(val.type));
					var _ss = min(_s * .4, string_scale(key, ww, 9999));
					draw_text_transformed(x0, val.y, key, _ss, _ss, 0);
					break;
				
				case VALUE_TYPE.color :
					if(is_array(key))	drawPalette(key, x0, val.y - jh / 2, ww, jh);
					else				drawColor(key, x0, val.y - jh / 2, ww, jh);
					break;
					
				case VALUE_TYPE.gradient :
					if(is(key, gradientObject))
						key.draw(key, x0, val.y - jh / 2, ww, jh);
					break;
			}
		}
	}
}