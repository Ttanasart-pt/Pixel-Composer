function Node_String_Format(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Format Text";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text"))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Text", VALUE_TYPE.text, ""));
	
	attributes.size = 0;
	
	argument_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		argument_renderer.x = _x;
		argument_renderer.y = _y;
		argument_renderer.w = _w;
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		if(buttonTextIconInstant(true, THEME.button_hide_fill, _x, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.add, __txt("Add"), COLORS._main_value_positive) == 2) {
			attributes.size++;
			refreshDynamicInput();
			update();
		}
		
		var amo = attributes.size;
		if(buttonTextIconInstant(attributes.size > 0, THEME.button_hide_fill, _x + _w - bw, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.minus, __txt("Remove"), COLORS._main_value_negative) == 2) {
			attributes.size--;
			refreshDynamicInput();
			update();
		}
		
		var tx  = _x + ui(8);
		var ty  = _y + bh + ui(16);
		var hh  = bh + ui(16);
		var _th = TEXTBOX_HEIGHT;
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _h = 0;
			
			var _jName = inputs[i + 0];
			_jName.editWidget.setFocusHover(_focus, _hover);
			_jName.editWidget.draw(tx, ty, ui(128), _th, _jName.showValue(), _m, _jName.display_type);
			
			draw_set_text(f_p1, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_add(tx + ui(128 + 12), ty + ui(6), "=");
			
			var _jValue = inputs[i + 1];
			_jValue.editWidget.setFocusHover(_focus, _hover);
			_jValue.editWidget.draw(tx + ui(128 + 24), ty, _w - ui(128 + 24 + 16), _th, _jValue.showValue(), _m, _jValue.display_type);
			
			_h += _th + ui(6);
			hh += _h;
			ty += _h;
		}
		
		argument_renderer.h = hh;
		return hh;
	});
	
	argument_renderer.register = function(parent = noone) {
		for( var i = input_fix_len; i < array_length(inputs); i++ )
			inputs[i].editWidget.register(parent);
	}
	
	input_display_list = [ 
		["Function",	false], 0,
		["Arguments",	false], argument_renderer,
		["Inputs",		 true], 
	]
	
	static createNewInput = function(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index + 0, nodeValue_Text("Argument name"));
		
		newInput(index + 1, nodeValue_Text("Argument value"))
			.setVisible(true, true);
		
		return inputs[index + 0];
	} setDynamicInput(2, false);
	
	static refreshDynamicInput = function() {
		var _l  = [];
		var amo = attributes.size;
		
		for(var i = 0; i < input_fix_len; i++ )
			array_push(_l, inputs[i]);
		
		for(var i = 0; i < amo; i++ ) {
			var _i = input_fix_len + i * data_length;
			
			if(_i >= array_length(_l))
				createNewInput();
			
			for(var j = 0; j < data_length; j++) 
				array_push(_l, inputs[_i + j]);
		}
		
		input_display_list = array_clone(input_display_list_raw);
		
		for( var i = input_fix_len; i < array_length(_l); i++ ) {
			_l[i].index = i;
			array_push(input_display_list, i);
		}
		
		for( var i = input_fix_len; i < array_length(_l) - 1; i += 2 )
			inputs[i + 1].setName(inputs[i].getValue());
		

		inputs = _l;
		
		getJunctionList();
		setHeight();
	}
	
	static processData = function(_output, _data, _index = 0) { 
		var _text = _data[0];
		var _amo = getInputAmount();
		
		var _outT = _text;
		
		for( var i = 0; i < _amo; i++ ) {
		    var _in = input_fix_len + i * data_length;
		    
		    var _key = "{" + string(_data[_in]) + "}";
		    var _rep = _data[_in + 1];
		    
		    _outT = string_replace_all(_outT, _key, _rep);
		}
		
		return _outT;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str = outputs[0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}