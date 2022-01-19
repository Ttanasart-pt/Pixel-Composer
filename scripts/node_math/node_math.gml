function Node_create_Math(_x, _y) {
	var node = new Node_Math(_x, _y);
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
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Add", "Subtract", "Multiply", "Divide", "Power", "Root", "Sin", "Cos", "Tan" ]);
	
	inputs[| 1] = nodeValue(1, "a", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 2] = nodeValue(2, "b", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Math", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_value_data(_data, index = 0) { 
		switch(_data[0]) {
			case 0 :
			case 1 :
			case 2 :
			case 3 :
			case 4 :
			case 5 :	
				inputs[| 2].show_in_inspector = true;
				break;
			case 6 :
			case 7 :
			case 8 :
				inputs[| 2].show_in_inspector = false;
				break;
		}
		
		switch(_data[0]) {
			case 0 : return _data[1] + _data[2]; break;
			case 1 : return _data[1] - _data[2]; break;
			case 2 : return _data[1] * _data[2]; break;
			case 3 : return _data[1] / _data[2]; break;
			case 4 : return power(_data[1], _data[2]); break;
			case 5 : return power(_data[1], 1 / _data[2]); break;
			
			case 6 : return sin(_data[1]); break;
			case 7 : return cos(_data[1]); break;
			case 8 : return tan(_data[1]); break;
		}
		
		return _data[1]; 
	}
	
	doUpdate();
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, c_white);
		var str;
		switch(inputs[| 0].getValue()) {
			case 0 : str = "+"; break;
			case 1 : str = "-"; break;
			case 2 : str = "*"; break;
			case 3 : str = "/"; break;
			case 4 : str = "pow";; break;
			case 5 : str = "root"; break;
			
			case 6 : str = "sin"; break;
			case 7 : str = "cos"; break;
			case 8 : str = "tan"; break;
		}
		
		var _ss = min((w - 8) * _s / string_width(str), (h - 8) * _s / string_height(str));
		
		draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, _ss, _ss, 0);
	}
}