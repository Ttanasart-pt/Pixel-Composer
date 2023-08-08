enum LOGIC_OPERATOR {
	land,
	lor,
	lnot,
	
	lnand,
	lnor,
	lxor
}

function Node_create_Logic(_x, _y, _group = noone, _param = "") {
	var node = new Node_Logic(_x, _y, _group);
	
	switch(_param) {
		case "and" :	node.inputs[| 0].setValue(LOGIC_OPERATOR.land); break;
		case "or" :		node.inputs[| 0].setValue(LOGIC_OPERATOR.lor); break;
		case "not" :	node.inputs[| 0].setValue(LOGIC_OPERATOR.lnot); break;
		case "nand" :	node.inputs[| 0].setValue(LOGIC_OPERATOR.lnand); break;
		case "nor" :	node.inputs[| 0].setValue(LOGIC_OPERATOR.lnor); break;
		case "xor" :	node.inputs[| 0].setValue(LOGIC_OPERATOR.lxor); break;
	}
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Logic(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Logic Opr";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ 
			/* 0 -  9*/ "And", "Or", "Not", "Nand", "Nor", "Xor" ])
		.rejectArray();
	
	inputs[| 1] = nodeValue("a", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(true, true);

	input_display_list = [
		0, 1, 
	]
		
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.boolean, false);
	
	setIsDynamicInput(1);
	
	static createNewInput = function()  {
		var index = ds_list_size(inputs);
		
		var jname = chr(ord("a") + index - 1);
		inputs[| index] = nodeValue(jname,  self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
			.setVisible(true, true);
		
		array_push(input_display_list, index);
		return inputs[| index];
	} 
	
	if!(LOADING || APPENDING) 
		createNewInput();
	
	static refreshDynamicInput = function() {
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(inputs[| i].value_from) {
				ds_list_add(_in, inputs[| i]);
				array_push(input_display_list, i);
			} else
				delete inputs[| i];
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ )
			_in[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		createNewInput();
	}
	
	static trimInputs = function(amo) {
		if(ds_list_size(inputs) < amo + 1) {
			while(ds_list_size(inputs) < amo + 1) 
				createNewInput();
		} else {
			while(ds_list_size(inputs) > amo + 1) 
				ds_list_delete(inputs, amo + 1);
		}
		array_resize(input_display_list, amo + 1);
	}
	
	static onValueUpdate = function(index) {
		if(index != 0) return;
		
		var mode = inputs[| 0].getValue();
		switch(mode) {
			case LOGIC_OPERATOR.lnot :  
				trimInputs(1);
				return;
			case LOGIC_OPERATOR.lnand :	
			case LOGIC_OPERATOR.lnor :	
			case LOGIC_OPERATOR.lxor :	
				trimInputs(2);
				return;
			
			case LOGIC_OPERATOR.land :	
			case LOGIC_OPERATOR.lor :	
				while(ds_list_size(inputs) < 3) 
					createNewInput();
				return;
		}
	}
	
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING) return;
		
		var mode = inputs[| 0].getValue();
		switch(mode) {
			case LOGIC_OPERATOR.lnot :  
				trimInputs(1);
				return;
			case LOGIC_OPERATOR.lnand :	
			case LOGIC_OPERATOR.lnor :	
			case LOGIC_OPERATOR.lxor :	
				trimInputs(2);
				return;
		}
		
		if(index < input_fix_len) return;
		
		refreshDynamicInput();
	}
	
	static _eval = function(mode, a, b) {
		switch(mode) {
			case LOGIC_OPERATOR.land :	return bool(a) && bool(b);
			case LOGIC_OPERATOR.lor :	return bool(a) || bool(b);   
			case LOGIC_OPERATOR.lnot :  return !bool(a);
											    
			case LOGIC_OPERATOR.lnand :	return !(bool(a) && bool(b));
			case LOGIC_OPERATOR.lnor :	return !(bool(a) || bool(b));
			case LOGIC_OPERATOR.lxor :	return  bool(a) ^^ bool(b);
		}
		return false;
	}
	
	static step = function() {
		var mode = inputs[| 0].getValue();
		
		//inputs[| 2].setVisible(mode != LOGIC_OPERATOR.lnot, mode != LOGIC_OPERATOR.lnot);
	}
	
	function evalLogicArray(mode, a, b = false) {
		var as = is_array(a);
		var bs = is_array(b);
		
		if(!as && !bs)
			return _eval(mode, a, b);
		
		var al = as? array_length(a) : 0;
		var bl = bs? array_length(b) : 0;
		
		var val = [];
		if(!as) a = [ a ];
		if(!bs) b = [ b ];
		
		for( var i = 0; i < max(al, bl, cl); i++ ) 
			val[i] = evalLogicArray(mode, 
				array_safe_get(a, i,, ARRAY_OVERFLOW.loop), 
				array_safe_get(b, i,, ARRAY_OVERFLOW.loop),
			);
		
		return val;
	}
	
	function update(frame = PROJECT.animator.current_frame) { 
		var mode = inputs[| 0].getValue();
		var a = inputs[| 1].getValue();
		var val;
		
		switch(mode) {
			case LOGIC_OPERATOR.lnot :  
				val = evalLogicArray(mode, a);
				break;
			case LOGIC_OPERATOR.lnand :	
			case LOGIC_OPERATOR.lnor :	
			case LOGIC_OPERATOR.lxor :	
				var b = inputs[| 2].getValue();
				val = evalLogicArray(mode, a, b);
				break;
			
			case LOGIC_OPERATOR.land :	
			case LOGIC_OPERATOR.lor :	
				var val = a;
				var to  = max(2, ds_list_size(inputs) - 1);
				for( var i = 2; i < to; i++ ) {
					var b = inputs[| i].getValue();
					val = evalLogicArray(mode, val, b);
				}
		}
		
		outputs[| 0].setValue(val);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
		var str = "";
		switch(inputs[| 0].getValue()) {
			case LOGIC_OPERATOR.land :	str = "And"; break;
			case LOGIC_OPERATOR.lor :	str = "Or"; break;
			case LOGIC_OPERATOR.lnot :  str = "Not"; break;
										
			case LOGIC_OPERATOR.lnand :	str = "Nand"; break;
			case LOGIC_OPERATOR.lnor :	str = "Nor"; break;
			case LOGIC_OPERATOR.lxor :	str = "Xor"; break;
			default: return;
		}
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}