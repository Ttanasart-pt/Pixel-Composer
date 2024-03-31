enum COMPARE_OPERATOR {
	equal,
	nonEqual,
	
	greater,
	greaterEqual,
	
	lesser,
	lesserEqual,
}

#region create
	global.node_compare_keys = ["equal", "not equal", "greater", "greater equal", "lesser", "lesser equal"];

	function Node_create_Compare(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Compare(_x, _y, _group);
		var ind   = -1;
		
		switch(query) {
			default : ind = array_find(global.node_compare_keys, query);
		}
		
		if(ind >= 0) node.inputs[| 0].setValue(ind);
		
		return node;
	}
#endregion

function Node_Compare(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Compare";
	color		= COLORS.node_blend_number;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Equal",			s_node_condition_type, 0), 
												 new scrollItem("Not equal",		s_node_condition_type, 1), 
												 new scrollItem("Greater ",			s_node_condition_type, 4), 
												 new scrollItem("Greater or equal", s_node_condition_type, 5), 
												 new scrollItem("Lesser",			s_node_condition_type, 2), 
												 new scrollItem("Lesser or equal",	s_node_condition_type, 3), ]);
	
	inputs[| 1] = nodeValue("a", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("b", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.boolean, false);
	
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
	
	static update = function(frame = CURRENT_FRAME) { 
		var mode = getInputData(0);
		var a    = getInputData(1);
		var b    = getInputData(2);
		
		//print($"compare node | Comparing {mode}: {a}, {b}.");
		
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
				val[i] = _eval(mode, array_safe_get_fast(a, i), array_safe_get_fast(b, i));
		}
		
		outputs[| 0].setValue(val);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = "";
		switch(getInputData(0)) {
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