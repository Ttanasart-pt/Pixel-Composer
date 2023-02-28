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
		
	inputs[| 2] = nodeValue("b", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(true, true);
		
	input_display_list = [
		0, 1, 2, 
	]
		
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.boolean, false);
	
	static _eval = function(mode, a, b) {
		switch(mode) {
			case LOGIC_OPERATOR.land :	return bool(a) && bool(b);
			case LOGIC_OPERATOR.lor :	return bool(a) || bool(b);   
			case LOGIC_OPERATOR.lnot :  return !bool(a);
											    
			case LOGIC_OPERATOR.lnand :	return !(bool(a) && bool(b));
			case LOGIC_OPERATOR.lnor :	return !(bool(a) || bool(b));
			case LOGIC_OPERATOR.lxor :	return bool(a) ^^ bool(b);
		}
		return false;
	}
	
	static step = function() {
		var mode = inputs[| 0].getValue();
		
		inputs[| 2].setVisible(mode != LOGIC_OPERATOR.lnot, mode != LOGIC_OPERATOR.lnot);
	}
	
	function evalLogicArray(mode, a, b) {
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
	
	function update(frame = ANIMATOR.current_frame) { 
		var mode = inputs[| 0].getValue();
		var a = inputs[| 1].getValue();
		var b = inputs[| 2].getValue();
		var val = evalLogicArray(mode, a, b);
		outputs[| 0].setValue(val);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
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