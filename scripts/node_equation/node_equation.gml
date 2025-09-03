function Node_create_Equation(_x, _y, _group = noone, _param = {}) {
	var query = struct_try_get(_param, "query", "");
	var node  = new Node_Equation(_x, _y, _group);
	node.skipDefault();
	
	if(query == "") return node;
	
	node.inputs[0].setValue(query);
	var ind  = 1;
	var amo  = string_length(query);
	var str  = "";
	var pres = global.EQUATION_PRES;
	var vars = [];
	
	for( var ind = 1; ind <= amo; ind++ ) {
		var ch = string_char_at(query, ind);
		if(ds_map_exists(pres, ch) || ch == "(" || ch == ")") {
			if(str != "" && str != toNumber(str)) 
				array_push_unique(vars, str);
			str = "";
		} else
			str += ch;
	}
	
	if(str != "" && str != toNumber(str)) 
		array_push_unique(vars, str);
	
	for( var i = 0, n = array_length(vars); i < n; i++ )
		node.inputs[1 + i * 2].setValue(vars[i]);
	
	return node;
}

function Node_Equation(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Equation";
	color		= COLORS.node_blend_number;
	draw_pad_w  = 10;
	
	setDimension(96, 48);
	ast = [];
	
	attributes.size = 0;
	
	newInput(0, nodeValue_Text("Equation"));
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.float, 0));
	
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
			_jValue.editWidget.draw(tx + ui(128 + 24), ty, _w - ui(128 + 24 + 16), _th, _jValue.showValue(), _m);
			
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
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index + 0, nodeValue_Text("Argument name"))
			.setDisplay(VALUE_DISPLAY.text_box);
		
		newInput(index + 1, nodeValue_Float("Argument value", 0 ))
			.setVisible(true, true);
							
		array_push(input_display_list, inAmo, inAmo + 1);
		return inputs[index + 0];
	} 
	
	setDynamicInput(2, false);
	
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
	
	static onValueUpdate = function(index = 0) {
		if(LOADING || APPENDING) return;
		
		if(safe_mod(index - input_fix_len, data_length) == 0) //Variable name
			inputs[index + 1].setName(inputs[index].getValue());
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var eq = _data[0];
		var params = {};
		
		for( var i = input_fix_len; i < array_length(_data); i += data_length ) {
			var _pName = _data[i + 0];
			var _pVal  = _data[i + 1];
			
			if(_pName != "")
				params[$ _pName] = _pVal;
		}
		
		var _tree = array_safe_get_fast(ast, _array_index, noone);
		if(_tree == noone || _tree.fx != eq) {
			ast[_array_index] = { fx: eq, tree: evaluateFunctionTree(eq) };
			_tree = ast[_array_index];
		}
		
		if(_tree == noone) return noone;
		return _tree.tree.eval(params);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = getInputData(0);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	 = string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
	
	static postApplyDeserialize = function() { refreshDynamicInput(); }
}