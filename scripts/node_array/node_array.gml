function Node_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array";
	setDimension(96, 32);
	
	newInput(0, nodeValue_Enum_Scroll("Type", 0, { data: [ "Any", "Surface", "Number", "Color", "Text" ], update_hover: false })).rejectArray();
	newInput(1, nodeValue_Bool("Spread array", false, "Unpack array and push the contents into the output one by one." )).rejectArray();
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.any, []));
	
	array_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = ui(48);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		var by = _y + ui(8);
		if(buttonTextIconInstant(true, THEME.button_hide_fill, _x, by, bw, bh, _m, _focus, _hover, "", THEME.add, __txt("Add"), COLORS._main_value_positive) == 2) {
			attributes.size = max(attributes.size, (array_length(inputs) - input_fix_len) / data_length ) + 1;
			onInputResize();
		}
		
		var bx = _x + _w - bw;
		var act = attributes.size > 0;
		if(buttonTextIconInstant(act, THEME.button_hide_fill, bx, by, bw, bh, _m, _focus, _hover, "", THEME.minus, __txt("Remove"), COLORS._main_value_negative) == 2) {
			attributes.size--;
			onInputResize();
		}
		
		return _h;
	});
	
	input_display_list = [ 0, 1, 
		["Contents", false], array_adjust_tool
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		var _typ  = getType();
		
		newInput(index, nodeValue("Input", self, CONNECT_TYPE.input, _typ, -1 )).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		return inputs[index];
		
	} setDynamicInput(1);
	
	////- =Nodes
	
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
		if(getInputAmount() <= 0) return;
		var _typ = getType();
		
		if(_typ == VALUE_TYPE.any && inputs[input_fix_len].value_from)
			outputs[0].setType(inputs[input_fix_len].value_from.type);
		else 
			outputs[0].setType(_typ);
		
		for( var i = array_length(inputs) - 1; i >= input_fix_len; i-- ) {
			if(resetVal) inputs[i].resetValue();
			var _ctyp = inputs[i].type;
			
			if(inputs[i].value_from == noone) {
				if(_ctyp != _typ) 
					inputs[i].setType(_typ);
				// inputs[i].resetDisplay();
				
			} else if (value_bit(inputs[i].value_from.type) & value_bit(_typ) != 0) {
				if(_ctyp != inputs[i].value_from.type) 
					inputs[i].setType(inputs[i].value_from.type);
				// inputs[i].resetDisplay();
				
			} else {
				inputs[i].removeFrom();
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
		if(index >= array_length(inputs)) return;
		
		inputs[index].setType(inputs[index].value_from? inputs[index].value_from.type : _typ);
		inputs[index].resetDisplay();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var spd = getInputData(1);
		var typ = getType();
		var res = [];
		var ind = 0;
		
		var _set  = typ == VALUE_TYPE.any;
		var _setT = VALUE_TYPE.any;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _idat = getInputData(i);
			if(spd) array_append( res, _idat );
			else    array_push(   res, _idat );
			
			if(inputs[i].value_from == noone) continue;
			
			var _fromT = inputs[i].value_from.type;
			inputs[i].type = _fromT;
			
			if(_set) {
				_setT = _fromT;
				_set  = false;
				
			} else if(_setT != _fromT)
				_setT = VALUE_TYPE.any;
		}
		
		if(typ == VALUE_TYPE.any) outputs[0].setType(_setT);
		
		outputs[0].setValue(res);
	}
	
	static postConnect = function() { updateType(false); }
	
	////- =Draw
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var jh   = (junction_draw_hei_y - 4) * _s;
		
		var x0 = bbox.x0 + 6 * _s;
		var ww = bbox.w - 12 * _s;
		
		for(var i = input_fix_len, n = array_length(inputs); i < n; i += data_length) {
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
					var _ss = min(_s * .4, string_scale(key, ww, junction_draw_hei_y * _s));
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