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
	
	argument_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
		argument_renderer.x = _x;
		argument_renderer.y = _y;
		argument_renderer.w = _w;
		
		var tx = _x + ui(8);
		var ty = _y + ui(8);
		var hh = ui(8);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(32);
		var bb = THEME.button_hide_fill;
		
		var bx = _x;
		var by = ty;
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
		
		ty += bh + ui(8);
		hh += bh + ui(8);
		
		var font = _panel != noone && _panel.viewMode == INSP_VIEW_MODE.compact? f_p3 : f_p2;
		var th   = line_get_height(font, 6);
		
		var w1 = ui(128);
		var w2 = _w - w1 - ui(24 + 16);
		var _wh;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var _th = th;
			
			var _jNam = inputs[i + 0];
			var _jVal = inputs[i + 1];
			
			var _wNam = has(_jNam, "__inspWidget")? _jNam.__inspWidget : _jNam.editWidget.clone(); _jNam.__inspWidget = _wNam;
			var _wVal = has(_jVal, "__inspWidget")? _jVal.__inspWidget : _jVal.editWidget.clone(); _jVal.__inspWidget = _wVal;
			
			_wNam.setFocusHover(_focus, _hover);
			_wVal.setFocusHover(_focus, _hover);
			
			_wNam.setFont(font);
			_wVal.setFont(font);
			
			_wh = _wNam.draw(tx, ty, w1, th, _jNam.showValue(), _m, _jNam.display_type);
			_th = max(_th, _wh);
			
			draw_set_text(font, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_add(tx + w1 + ui(12), ty + ui(6), "=");
			
			_wh = _wVal.draw(tx + w1 + ui(24), ty, w2, th, _jVal.showValue(), _m, _jVal.display_type);
			_th = max(_th, _wh);
			
			hh += _th + ui(6);
			ty += _th + ui(6);
		}
		
		argument_renderer.h = hh;
		return hh;
	});
	
	argument_renderer.register = function(parent = noone) {
		for( var i = input_fix_len; i < array_length(inputs); i++ )
			inputs[i].editWidget.register(parent);
	}
	
	input_display_list = [ 
		[ "Function",  false ], 0,
		[ "Arguments", false ], argument_renderer,
		[ "Inputs",     true ], 
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
		
		var bbox = draw_bbox;
		var ss	 = string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
	
	static postApplyDeserialize = function() { refreshDynamicInput(); }
}