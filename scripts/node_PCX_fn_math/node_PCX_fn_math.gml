function Node_PCX_fn_Math(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Math";
	
	inputs[0] = nodeValue_Enum_Scroll("Operator", self,  0, [ "Add",   "Subtract", "Multiply", "Divide", "Power",  "Modulo", "Absolute", -1, 
												 "Round", "Floor",    "Ceil",      -1, 
												 "Sin",   "Cos",      "Tan",      "Arcsin", "Arccos", "Arctan", -1, 
												 "Min",   "Max",      "Clamp",    -1, 
												 "Lerp" ]);
	
	newInput(1, nodeValue("x", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(2, nodeValue("y", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(3, nodeValue("z", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone));
	
	outputs[0] = nodeValue_Output("PCX", self, VALUE_TYPE.PCXnode, noone);
	
	static update = function() {
		static syms = [ "+", "-", "*", "/", "$", "%", "abs", -1, "round", "floor", "ceil", 
						-1, "sin", "cos", "tan", "arcsin", "arccos", "arctan", -1, "min", "max", "clamp", -1, "lerp" ];
		
		var _opr = getInputData(0);
		var _x   = getInputData(1);
		var _y   = getInputData(2);
		var _z   = getInputData(3);
		var _sym = syms[_opr];
		
		switch(_sym) {
			case "abs"		:
			case "round"	:
			case "floor"	:
			case "ceil"		:
			case "sin"		:
			case "cos"		:
			case "tan"		:
			case "arcsin" 	:
			case "arccos"	:
			case "arctan"	:
				inputs[2].setVisible(false, false);
				break;
			default: inputs[2].setVisible(true, true);
		}
		
		switch(_sym) {
			case "clamp"	:
			case "lerp" 	:
				inputs[3].setVisible(true, true);
				break;
			default: inputs[3].setVisible(false, false);
		}
		
		switch(_sym) {
			case "abs"		:
			case "round"	:
			case "floor"	:
			case "ceil"		:
			case "sin"		:
			case "cos"		:
			case "tan"		:
			case "arcsin" 	:
			case "arccos"	:
			case "arctan"	:
			case "min"	    :
			case "max"	    :
			case "clamp"    :
			case "lerp"	    :
				outputs[0].setValue(new __funcTree(_sym, [ _x, _y, _z ]));
				break;
			default:
				outputs[0].setValue(new __funcTree(_sym, _x, _y));
		}
		
		
	}
}