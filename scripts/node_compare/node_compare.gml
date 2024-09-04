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
		var node  = new Node_Compare(_x, _y, _group).skipDefault();
		var ind   = -1;
		
		switch(query) {
			default : ind = array_find(global.node_compare_keys, query);
		}
		
		if(ind >= 0) node.inputs[0].setValue(ind);
		
		return node;
	}
#endregion

function Node_Compare(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Compare";
	color		= COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Enum_Scroll("Type", self,  0, [ new scrollItem("Equal",            s_node_condition_type, 0), 
												          new scrollItem("Not equal",        s_node_condition_type, 1), 
												          new scrollItem("Greater ",         s_node_condition_type, 4), 
												          new scrollItem("Greater or equal", s_node_condition_type, 5), 
												          new scrollItem("Lesser",           s_node_condition_type, 2), 
												          new scrollItem("Lesser or equal",  s_node_condition_type, 3), ]));
	
	newInput(1, nodeValue_Float("a", self, 0))
		.setVisible(true, true);
		
	newInput(2, nodeValue_Float("b", self, 0))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Result", self, VALUE_TYPE.boolean, false));
	
	static _compare = function(mode, a, b) {
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
	
	static evalArray = function(mode, a, b) {
		var _as = is_array(a);
		var _bs = is_array(b);
		var al  = _as? array_length(a) : 0;
		var bl  = _bs? array_length(b) : 0;
		
		var val = 0;
		
		if(!_as && !_bs)
			val = _compare(mode, a, b);
			
		else if(!_as && _bs) {
			for( var i = 0; i < bl; i++ )
				val[i] = evalArray(mode, a, b[i]);
				
		} else if(_as && !_bs) {
			for( var i = 0; i < al; i++ )
				val[i] = evalArray(mode, a[i], b);
				
		} else {
			for( var i = 0; i < max(al, bl); i++ ) 
				val[i] = evalArray(mode, array_safe_get_fast(a, i), array_safe_get_fast(b, i));
		}
		
		return val;
	}
	
	static update = function(frame = CURRENT_FRAME) { 
		var mode = getInputData(0);
		var a    = getInputData(1);
		var b    = getInputData(2);
		var val  = evalArray(mode, a, b);
		
		outputs[0].setValue(val);
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