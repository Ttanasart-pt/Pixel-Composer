enum LOGIC_OPERATOR {
	land,
	lor,
	lnot,
	
	lnand,
	lnor,
	lxor
}

#region create
	global.node_logic_keys = [ "and", "or", "not", "nand", "nor" , "xor" ];
	
	function Node_create_Logic(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Logic(_x, _y, _group).skipDefault();
		var ind   = -1;
		
		switch(query) {
			default : ind = array_find(global.node_logic_keys, query);
		}
		
		if(ind >= 0) node.inputs[0].setValue(ind);
		
		return node;
	}
#endregion

function Node_Logic(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Logic Opr";
	color		= COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Enum_Scroll("Type", self,  0, [ new scrollItem("And",   s_node_logic, 0), 
												          new scrollItem("Or",    s_node_logic, 1), 
												          new scrollItem("Not",   s_node_logic, 2), 
												          new scrollItem("Nand",  s_node_logic, 3), 
												          new scrollItem("Nor",   s_node_logic, 4), 
												          new scrollItem("Xor",   s_node_logic, 5), ]))
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Result", self, VALUE_TYPE.boolean, false));
	
	static createNewInput = function()  {
		var index = array_length(inputs);
		
		var jname = chr(ord("a") + index - 1);
		newInput(index, nodeValue_Bool(jname,  self, false ))
			.setVisible(true, true);
		
		return inputs[index];
	} setDynamicInput(1, true, VALUE_TYPE.boolean);
	
	static trimInputs = function(amo) {
		if(array_length(inputs) < amo + 1) {
			while(array_length(inputs) < amo + 1) 
				createNewInput();
		} else {
			while(array_length(inputs) > amo + 1) 
				array_delete(inputs, amo + 1, 1);
		}
	}
	
	static onValueUpdate = function(index) {
		if(index != 0) return;
		
		var mode = getInputData(0);
		switch(mode) {
			case LOGIC_OPERATOR.lnot :  
				trimInputs(1);
				auto_input = false;
				return;
				
			case LOGIC_OPERATOR.lnand :	
			case LOGIC_OPERATOR.lnor :	
			case LOGIC_OPERATOR.lxor :	
				trimInputs(2);
				auto_input = false;
				return;
			
			case LOGIC_OPERATOR.land :	
			case LOGIC_OPERATOR.lor :	
				auto_input = true;
				return;
		}
	}
	
	static _eval = function(mode, a, b) {
		switch(mode) {
			case LOGIC_OPERATOR.land :	return  bool(a) && bool(b);
			case LOGIC_OPERATOR.lor :	return  bool(a) || bool(b);   
			case LOGIC_OPERATOR.lnot :  return !bool(a);
											    
			case LOGIC_OPERATOR.lnand :	return !(bool(a) && bool(b));
			case LOGIC_OPERATOR.lnor :	return !(bool(a) || bool(b));
			case LOGIC_OPERATOR.lxor :	return   bool(a) ^^ bool(b);
		}
		return false;
	}
	
	function evalLogicArray(mode, a, b = false) {
		var _as = is_array(a);
		var _bs = is_array(b);
		
		if(!_as && !_bs)
			return _eval(mode, a, b);
		
		var al = _as? array_length(a) : 0;
		var bl = _bs? array_length(b) : 0;
		
		var val = [];
		if(!_as) a = [ a ];
		if(!_bs) b = [ b ];
		
		for( var i = 0; i < max(al, bl, cl); i++ ) 
			val[i] = evalLogicArray(mode, 
				array_safe_get(a, i,, ARRAY_OVERFLOW.loop), 
				array_safe_get(b, i,, ARRAY_OVERFLOW.loop),
			);
		
		return val;
	}
	
	static update = function(frame = CURRENT_FRAME) { 
		var mode = getInputData(0);
		var a = getInputData(1);
		var val;
		
		switch(mode) {
			case LOGIC_OPERATOR.lnot :  
				val = evalLogicArray(mode, a);
				break;
			case LOGIC_OPERATOR.lnand :	
			case LOGIC_OPERATOR.lnor :	
			case LOGIC_OPERATOR.lxor :	
				var b = getInputData(2);
				val = evalLogicArray(mode, a, b);
				break;
			
			case LOGIC_OPERATOR.land :	
			case LOGIC_OPERATOR.lor :	
				var val = a;
				var to  = array_length(inputs);
				
				for( var i = 2; i < to; i++ ) {
					var b = getInputData(i);
					val = evalLogicArray(mode, val, b);
				}
		}
		
		outputs[0].setValue(val);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = "";
		switch(getInputData(0)) {
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