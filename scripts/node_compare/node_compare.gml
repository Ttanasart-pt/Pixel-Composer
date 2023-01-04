enum COMPARE_OPERATOR {
	equal,
	nonEqual,
	
	greater,
	greaterEqual,
	
	lesser,
	lesserEqual,
}

function Node_create_Compare(_x, _y, _group = -1, _param = "") {
	var node = new Node_Compare(_x, _y, _group);
	
	switch(_param) {
		case "equal" :		node.inputs[| 0].setValue(COMPARE_OPERATOR.equal); break;
		case "greater" :	node.inputs[| 0].setValue(COMPARE_OPERATOR.greater); break;
		case "lesser" :		node.inputs[| 0].setValue(COMPARE_OPERATOR.lesser); break;
	}
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Compare(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Compare";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Equal", "Not equal", "Greater", "Greater or equal", "Lesser", "Lesser or equal" ]);
	
	inputs[| 1] = nodeValue(1, "a", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue(2, "b", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.boolean, false);
	
	static _eval = function(mode, a, b) {
		switch(mode) {
			case COMPARE_OPERATOR.equal :		 return a == b;
			case COMPARE_OPERATOR.nonEqual :	 return a != b;
			
			case COMPARE_OPERATOR.greater :		 return a > b;
			case COMPARE_OPERATOR.greaterEqual : return a >= b;
			
			case COMPARE_OPERATOR.lesser :		 return a < b;
			case COMPARE_OPERATOR.lesserEqual :  return a <= b;
		}
		return 0;
	}
	
	function update() { 
		var mode = inputs[| 0].getValue();
		var a = inputs[| 1].getValue();
		var b = inputs[| 2].getValue();
		
		var as = is_array(a);
		var bs = is_array(b);
		var al = as? array_length(a) : 0;
		var bl = bs? array_length(b) : 0;
		
		var val = 0;
		if(!as && !bs)
			val = _eval(mode, a, b);
		else if(!as && bs) {
			for( var i = 0; i < bl; i++ )
				val[i] = _eval(mode, a, b[i]);
		} else if(as && !bs) {
			for( var i = 0; i < al; i++ )
				val[i] = _eval(mode, a[i], b);
		} else {
			for( var i = 0; i < max(al, bl); i++ ) 
				val[i] = _eval(mode, array_safe_get(a, i), array_safe_get(b, i));
		}
		
		outputs[| 0].setValue(val);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
		var str = "";
		switch(inputs[| 0].getValue()) {
			case COMPARE_OPERATOR.equal :		 str = "=";		break;
			case COMPARE_OPERATOR.nonEqual :	 str = "!=";	break;
			
			case COMPARE_OPERATOR.greater :		 str = ">";		break;
			case COMPARE_OPERATOR.greaterEqual : str = ">=";	break;
												 
			case COMPARE_OPERATOR.lesser :		 str = "<";		break;
			case COMPARE_OPERATOR.lesserEqual :  str = "<=";	break;
			default: return;
		}
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}