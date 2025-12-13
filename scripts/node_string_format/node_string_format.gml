function Node_String_Format(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Format Text";
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text")).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Text", VALUE_TYPE.text, ""));
	
	argument_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
		argument_renderer.x = _x;
		argument_renderer.y = _y;
		argument_renderer.w = _w;
		
		var bw = _w / 2 - ui(4);
		var bh = ui(32);
		var bb = THEME.button_hide_fill;
		
		var bx = _x;
		var by = _y;
		var bt = __txt("Add");
		var bc = COLORS._main_value_positive;
		if(buttonTextIconInstant(true, bb, bx, by, bw, bh, _m, _focus, _hover, "", THEME.add, bt, bc) == 2) {
			attributes.size++;
			refreshDynamicInput();
			update();
		}
		
		var bx = _x + _w - bw;
		var bt = __txt("Remove");
		var bc = COLORS._main_value_negative;
		var amo = attributes.size;
		if(buttonTextIconInstant(amo > 0, bb, bx, _y, bw, bh, _m, _focus, _hover, "", THEME.minus, bt, bc) == 2) {
			attributes.size--;
			refreshDynamicInput();
			update();
		}
		
		var font = _panel != noone && _panel.viewMode == INSP_VIEW_MODE.compact? f_p3 : f_p2;
		var tx = _x + ui(8);
		var ty = _y + bh + ui(16);
		var hh = bh + ui(16);
		var th = line_get_height(font);
		
		var w1 = ui(128);
		var w2 = _w - w1 - ui(24 + 16);
		var _wh;
		
		var _jNam, _jVal;
		var _wNam, _wVal;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var _h  = 0;
			var _th = th;
			
			_jNam = inputs[i + 0];
			_jVal = inputs[i + 1];
			
			_wNam = has(_jNam, "__inspWidget")? _jNam.__inspWidget : _jNam.editWidget.clone();
			_wVal = has(_jVal, "__inspWidget")? _jVal.__inspWidget : _jVal.editWidget.clone();
			
			_jNam.__inspWidget = _wNam;
			_jVal.__inspWidget = _wVal;
			
			_wNam.setFocusHover(_focus, _hover);
			_wNam.setFont(font);
			_wh = _wNam.draw(tx, ty, w1, th, _jNam.showValue(), _m, _jNam.display_type);
			_th = max(_th, _wh);
			
			draw_set_text(font, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_add(tx + w1 + ui(12), ty + ui(6), "=");
			
			_wVal.setFocusHover(_focus, _hover);
			_wVal.setFont(font);
			_wh = _wVal.draw(tx + w1 + ui(24), ty, w2, th, _jVal.showValue(), _m, _jVal.display_type);
			_th = max(_th, _wh);
			
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
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index + 0, nodeValue_Text( "Argument Name"  ));
		newInput(index + 1, nodeValue_Text( "Argument value" )).setVisible(true, true);
		
		return inputs[index + 0];
	} setDynamicInput(2, false);
	
	////- Nodes
	
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
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}