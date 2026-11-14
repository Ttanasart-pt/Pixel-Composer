function Node_Switch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Switch";
	reactive_on_hover = true;
	setDimension(96, 48);
	
	////- =Switch
	newInput( 2, nodeValue_EButton( "Selector Type", 1, [ "Number", "Text" ] )).rejectArray();
	newInput( 3, nodeValue_Float( "Index" )).setVisible(true, true).rejectArray();
	newInput( 0, nodeValue_Text(  "Index" )).setVisible(true, true).rejectArray();
	
	newInput( 1, nodeValue( "Default value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )).setVisible(false, true);
	// 4
	
	size_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = ui(48);
		
		var bx = _x;
		var by = _y + ui(8);
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		var bc = COLORS._main_value_positive;
		
		if(buttonTextIconInstant(true, THEME.button_hide_fill, bx, by, bw, bh, _m, _hover, _focus, "", THEME.add, __txt("Add"), bc) == 2)
			addInput();
		
		var bx = _x + _w - bw;
		var by = _y + ui(8);
		var bc = COLORS._main_value_negative;
		var amo = attributes.size;
		var act = attributes.size > 0;
		
		if(buttonTextIconInstant(act, THEME.button_hide_fill, bx, by, bw, bh, _m, _hover, _focus, "", THEME.minus, __txt("Remove"), bc) == 2)
			deleteInput(array_length(inputs) - data_length);
		
		return _h;
	});
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.any, 0));
	
	input_display_list = [ 
		[ "Switch", false ],  2,  3,  0,  1, 
		[ "Cases",  false ], size_adjust_tool
	]
	
	input_selecting = noone;
	
	////- Dynamic IO

	function createNewInput(index = array_length(inputs)) {
		var bDel = button(function() /*=>*/ {return node.deleteInput(index)}).setIcon(THEME.minus_16, 0, COLORS._main_icon);
		
		inputs[index + 0] = nodeValue_Text("Case").setDisplay(VALUE_DISPLAY.text_box, { side_button : bDel }).setAnimable(false);
		bDel.setContext(inputs[index + 0]);
		
		inputs[index + 1] = nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 ).setVisible(false, false);
		
		postCreateNewInput(index);
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
				
			}, { index, inputs : _inputs }).setRef(self);
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
				
			}, { index, inputs : _inputs }).setRef(self);
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
	
	////- Nodes
	
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
		var _inp = inputs[1];
		if(_inp.value_from != noone) _inp.setType(_inp.value_from.type);
			
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _inp = inputs[i + 1];
			if(_inp.value_from != noone) _inp.setType(_inp.value_from.type);
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _sType = getInputData( 2);
			var _sNum  = getInputData( 3);
			var _sTxt  = getInputData( 0);
			var _res   = getInputData( 1);
			
			var _typ = inputs[1].value_from? inputs[1].value_from.type : VALUE_TYPE.any;
			
			inputs[ 3].setVisible(_sType == 0, _sType == 0);
			inputs[ 0].setVisible(_sType == 1, _sType == 1);
		#endregion
		
		var _sel = _sTxt; 
		switch(_sType) {
			case 0 : _sel = _sNum; break;
			case 1 : _sel = _sTxt; break;
		}
		
		input_selecting = inputs[1];
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _cas = getInputData(i + 0);
			var _val = getInputData(i + 1);
			
			if(_cas == "") continue;
			if(_sel == _cas) {
				input_selecting = inputs[i + 1];
				_res = _val;
				_typ = inputs[i + 1].value_from? inputs[i + 1].value_from.type : inputs[i + 1].type;
			}
		}
		
		outputs[0].setType(_typ);
		outputs[0].setValue(_res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var _frm = input_selecting;
		if(!is(_frm, NodeValue)) return;
		
		var to = outputs[0];
		var c0 = value_color(_frm.type);
		
		draw_set_color(c0);
		draw_set_alpha(0.5);
		draw_line_width(_frm.x, _frm.y, to.x, to.y, _s * ui(2));
		draw_set_alpha(1);
		
		draw_set_text(f_sdf, fa_left, fa_center);
		var bbox = draw_bbox;
		
		var _sw = bbox.w - 16 * _s;
		var _sh = junction_draw_hei_y * _s;
		var selAble = inputs[0].value_from == noone;
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var val = getInputData(i);
			var str = string(val);
			if(str == "") continue;
			
			var ss = min(_s * 0.4 / UI_SCALE, string_scale(str, _sw, _sh));
			var sw = string_width(str) * ss;
			var sh = string_height(str) * ss;
			
			var sx = bbox.x0 + 8 * _s;
			var sy = inputs[i+1].y;
			
			if(selAble) {
				var lw = bbox.w - 8 * _s;
				var lh = sh;
				
				var lx = sx - 4 * _s;
				var ly = sy - lh/2;
				
				var hv = _hover && point_in_rectangle(_mx, _my, lx, ly, lx + lw, ly + lh);
				
				if(hv) {
					draw_sprite_stretched_ext(THEME.box_r5_clr, 0, lx, ly, lw, lh, COLORS._main_icon, 1);
					if(mouse_lpress(_focus)) {
						var _sType = getInputData( 2);
						
						     if(_sType == 0) inputs[3].setValue(toNumber(val));
						else if(_sType == 1) inputs[0].setValue(val);
					}
				}
				
			}
			
			draw_set_color(value_color(inputs[i].type));
			draw_text_transformed(sx, sy, str, ss, ss, 0);
			
		}
	}
	
	////- Serialize
	
	static postApplyDeserialize = function() { refreshDynamicInput(); }
}