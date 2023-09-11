function Node_PCX_fn_Math(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Math";
	
	inputs[| 0] = nodeValue("Operator", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Add", "Subtract", "Multiply", "Divide", "Power", "Modulo", "Absolute", -1, "Round", "Floor", "Ceil",
												 -1, "Sin", "Cos", "Tan", "Arcsin", "Arccos", "Arctan", -1, "Min", "Max", "Clamp", -1, "Lerp" ]);
	
	inputs[| 1] = nodeValue("x", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	inputs[| 2] = nodeValue("y", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	inputs[| 3] = nodeValue("z", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	outputs[| 0] = nodeValue("PCX", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone);
	
	static update = function() {
		static syms = [ "+", "-", "*", "/", "$", "%", "abs", -1, "round", "floor", "ceil", 
						-1, "sin", "cos", "tan", "arcsin", "arccos", "arctan", -1, "min", "max", "clamp", -1, "lerp" ];
		
		var _opr = inputs[| 0].getValue();
		var _x   = inputs[| 1].getValue();
		var _y   = inputs[| 2].getValue();
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
				inputs[| 2].setVisible(false, false);
				break;
			default: inputs[| 2].setVisible(true, true);
		}
		
		switch(_sym) {
			case "clamp"	:
			case "lerp" 	:
				inputs[| 3].setVisible(true, true);
				break;
			default: inputs[| 3].setVisible(false, false);
		}
		
		outputs[| 0].setValue(new __funcTree(_sym, _x, _y));
	}
}