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
}

function Node_create_Math(_x, _y, _param = "") {
	var node = new Node_Math(_x, _y);
	
	switch(_param) {
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
	}
	
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Math(_x, _y) : Node_Value_Processor(_x, _y) constructor {
	name		= "Math";
	color		= c_ui_cyan;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ 
			/* 0 -  9*/ "Add", "Subtract", "Multiply", "Divide", "Power", "Root", "Sin", "Cos", "Tan", "Modulo", 
			/*10 - 12*/ "Floor", "Ceil", "Round" ]);
	
	inputs[| 1] = nodeValue(1, "a", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 2] = nodeValue(2, "b", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Math", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_value_data(_data, index = 0) { 
		switch(_data[0]) {
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
				inputs[| 2].setVisible(false);
				break;
		}
		
		switch(_data[0]) {
			case MATH_OPERATOR.add :		return _data[1] + _data[2]; break;
			case MATH_OPERATOR.subtract :	return _data[1] - _data[2]; break;
			case MATH_OPERATOR.multiply :	return _data[1] * _data[2]; break;
			case MATH_OPERATOR.divide :		return _data[1] / _data[2]; break;
			case MATH_OPERATOR.power :		return power(_data[1], _data[2]); break;
			case MATH_OPERATOR.root :		return power(_data[1], 1 / _data[2]); break;
			
			case MATH_OPERATOR.sin :		return sin(_data[1]) * _data[2]; break;
			case MATH_OPERATOR.cos :		return cos(_data[1]) * _data[2]; break;
			case MATH_OPERATOR.tan :		return tan(_data[1]) * _data[2]; break;
			case MATH_OPERATOR.modulo :		return safe_mod(_data[1], _data[2]); break;
			
			case MATH_OPERATOR.floor :		return floor(_data[1]); break;
			case MATH_OPERATOR.ceiling :	return ceil(_data[1]); break;
			case MATH_OPERATOR.round :		return round(_data[1]); break;
		}
		
		return _data[1]; 
	}
	
	doUpdate();
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h3, fa_center, fa_center, c_white);
		var str = "";
		switch(inputs[| 0].getValue()) {
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
		}
		
		var _ss = min((w - 16) * _s / string_width(str), (h - 18) * _s / string_height(str));
		
		if(_s * w > 48)
			draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, _ss, _ss, 0);
		else 
			draw_text_transformed(xx + w / 2 * _s, yy + h / 2 * _s, str, _ss, _ss, 0);
	}
}