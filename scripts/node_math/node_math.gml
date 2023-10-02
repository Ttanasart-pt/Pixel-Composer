enum MATH_OPERATOR {
	add,
	subtract,
	multiply,
	divide,
	power,
	root,
		
	sin,
	cos,
	tan,
		
	modulo,
		
	floor,
	ceiling,
	round,
	
	lerp,
	abs
}

function Node_create_Math(_x, _y, _group = noone, _param = {}) {
	var query = struct_try_get(_param, "query", "");
	var node  = new Node_Math(_x, _y, _group);
	
	switch(query) {
		case "add" :		node.inputs[| 0].setValue(MATH_OPERATOR.add); break;
		case "subtract" :	node.inputs[| 0].setValue(MATH_OPERATOR.subtract); break;
		case "multiply" :	node.inputs[| 0].setValue(MATH_OPERATOR.multiply); break;
		case "divide" :		node.inputs[| 0].setValue(MATH_OPERATOR.divide); break;
		case "power" :		node.inputs[| 0].setValue(MATH_OPERATOR.power); break;
		case "root" :		node.inputs[| 0].setValue(MATH_OPERATOR.root); break;
		
		case "sin" :		node.inputs[| 0].setValue(MATH_OPERATOR.sin); break;
		case "cos" :		node.inputs[| 0].setValue(MATH_OPERATOR.cos); break;
		case "tan" :		node.inputs[| 0].setValue(MATH_OPERATOR.tan); break;
		
		case "modulo" :		node.inputs[| 0].setValue(MATH_OPERATOR.modulo); break;
		
		case "floor" :		node.inputs[| 0].setValue(MATH_OPERATOR.floor); break;
		case "ceiling" :	node.inputs[| 0].setValue(MATH_OPERATOR.ceiling); break;
		case "round" :		node.inputs[| 0].setValue(MATH_OPERATOR.round); break;
		
		case "lerp" :		node.inputs[| 0].setValue(MATH_OPERATOR.lerp); break;
		case "abs" :		node.inputs[| 0].setValue(MATH_OPERATOR.abs); break;
	}
	
	return node;
}

function Node_Math(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Math";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ 
			/* 0 -  9*/ "Add", "Subtract", "Multiply", "Divide", "Power", "Root", "Sin", "Cos", "Tan", "Modulo", 
			/*10 - 20*/ "Floor", "Ceil", "Round", "Lerp", "Abs" ])
		.rejectArray();
	
	inputs[| 1] = nodeValue("a", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("b", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 3] = nodeValue("Degree angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 4] = nodeValue("To integer", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 5] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	input_display_list = [
		0, 1, 2, 5, 3, 4,
	]
		
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	use_mod = 0;
	use_deg = false;
	
	static _eval = function(a, b, c = 0) {
		switch(use_mod) {
			case MATH_OPERATOR.add :		return a + b;    
			case MATH_OPERATOR.subtract :	return a - b;
			case MATH_OPERATOR.multiply :	return a * b;
			case MATH_OPERATOR.divide :		return b == 0? 0 : a / b;
				
			case MATH_OPERATOR.power :		return power(a, b);
			case MATH_OPERATOR.root :		return b == 0? 0 : power(a, 1 / b);
			
			case MATH_OPERATOR.sin :		return sin(use_deg? degtorad(a) : a) * b;
			case MATH_OPERATOR.cos :		return cos(use_deg? degtorad(a) : a) * b;
			case MATH_OPERATOR.tan :		return tan(use_deg? degtorad(a) : a) * b;
			case MATH_OPERATOR.modulo :		return safe_mod(a, b);
			
			case MATH_OPERATOR.floor :		return floor(a);
			case MATH_OPERATOR.ceiling :	return ceil(a);
			case MATH_OPERATOR.round :		return round(a);
			
			case MATH_OPERATOR.lerp :		return lerp(a, b, c);
			case MATH_OPERATOR.abs :		return abs(a);
		}
		return 0;
	}
	
	static step = function() {
		var mode = getInputData(0);
		
		switch(mode) {
			case MATH_OPERATOR.sin :
			case MATH_OPERATOR.cos :
			case MATH_OPERATOR.tan :
				inputs[| 3].setVisible(true);
				break;
			default:
				inputs[| 3].setVisible(false);
				break;
		}
		
		switch(mode) {
			case MATH_OPERATOR.round :
			case MATH_OPERATOR.floor :
			case MATH_OPERATOR.ceiling :
				inputs[| 4].setVisible(true);
				
				var int = getInputData(4);
				if(int) outputs[| 0].type = VALUE_TYPE.integer;
				else	outputs[| 0].type = VALUE_TYPE.float;
				break;
			default:
				inputs[| 4].setVisible(false);
				
				outputs[| 0].type = VALUE_TYPE.float;
				break;
		}
		
		inputs[| 2].name = "b";
		inputs[| 5].setVisible(false);
		
		switch(mode) {
			case MATH_OPERATOR.add :
			case MATH_OPERATOR.subtract :
			case MATH_OPERATOR.multiply :
			case MATH_OPERATOR.divide :
			case MATH_OPERATOR.power :
			case MATH_OPERATOR.root :	
			case MATH_OPERATOR.modulo :	
				inputs[| 2].setVisible(true);
				break;
			case MATH_OPERATOR.sin :
			case MATH_OPERATOR.cos :
			case MATH_OPERATOR.tan :
				inputs[| 2].setVisible(true);
				inputs[| 2].name = "Amplitude";
				break;
			case MATH_OPERATOR.floor :
			case MATH_OPERATOR.ceiling :
			case MATH_OPERATOR.round :
			case MATH_OPERATOR.abs :
				inputs[| 2].setVisible(false);
				break;
			case MATH_OPERATOR.lerp :
				inputs[| 2].setVisible(true);
				inputs[| 5].setVisible(true);
				break;
			default: return;
		}
	}
	
	function evalArray(a, b, c = 0) {
		var as = is_array(a);
		var bs = is_array(b);
		var cs = is_array(c);
		
		if(!as && !bs && !cs)
			return _eval(a, b, c);
		
		if(!as) a = [ a ];
		if(!bs) b = [ b ];
		if(!cs) c = [ c ];
		
		var al = array_length(a);
		var bl = array_length(b);
		var cl = array_length(c);
		
		var amo = max(al, bl, cl);
		var val = array_create(amo);
		
		for( var i = 0; i < amo; i++ ) 
			val[i] = evalArray( 
				array_safe_get(a, i,, ARRAY_OVERFLOW.loop), 
				array_safe_get(b, i,, ARRAY_OVERFLOW.loop),
				array_safe_get(c, i,, ARRAY_OVERFLOW.loop),
			);
		
		return val;
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		use_mod = getInputData(0);
		var a	= getInputData(1);
		var b	= getInputData(2);
		use_deg = getInputData(3);
		var c	= getInputData(5);
		
		var val = evalArray(a, b, c);
		outputs[| 0].setValue(val);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
		var str = "";
		switch(getInputData(0)) {
			case MATH_OPERATOR.add :		str = "+"; break;
			case MATH_OPERATOR.subtract :	str = "-"; break;
			case MATH_OPERATOR.multiply :	str = "*"; break;
			case MATH_OPERATOR.divide :		str = "/"; break;
			case MATH_OPERATOR.power :		str = "pow"; break;
			case MATH_OPERATOR.root :		str = "root"; break;
			
			case MATH_OPERATOR.sin :		str = "sin"; break;
			case MATH_OPERATOR.cos :		str = "cos"; break;
			case MATH_OPERATOR.tan :		str = "tan"; break;
			case MATH_OPERATOR.modulo :		str = "mod"; break;
			
			case MATH_OPERATOR.floor :		str = "floor"; break;
			case MATH_OPERATOR.ceiling :	str = "ceil"; break;
			case MATH_OPERATOR.round :		str = "round"; break;
			
			case MATH_OPERATOR.lerp :		str = "lerp"; break;
			case MATH_OPERATOR.abs :		str = "abs"; break;
			default: return;
		}
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}