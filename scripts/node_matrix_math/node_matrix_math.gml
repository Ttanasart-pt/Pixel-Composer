function Node_Matrix_Math(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Math";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix 1", new Matrix(3)))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Matrix("Matrix 2", new Matrix(3)))
		.setVisible(true, true);
	
	operation_scroll = [
		new scrollItem("Add",             s_node_math_operators, 0),
		new scrollItem("Subtract",        s_node_math_operators, 1),
		new scrollItem("Multiply Scalar", s_node_math_operators, 2),
		new scrollItem("Divide Scalar",   s_node_math_operators, 3),
		-1,
		new scrollItem("Multiply Matrix", s_node_math_operators, 2),
	];
	
	newInput(2, nodeValue_Enum_Scroll("Operation", 0, operation_scroll));
	
	newInput(3, nodeValue_Float("Scala", 0));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue("Matrix", self, CONNECT_TYPE.output, VALUE_TYPE.float, new Matrix(3)))
		.setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 2, 0, 1, 3 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat1 = _data[0];
		var _mat2 = _data[1];
		var _opr  = _data[2];
		var _sca  = _data[3];
		var _res;
		
		inputs[1].setVisible(false);
		inputs[3].setVisible(false);
		
		switch(operation_scroll[_opr].name) {
			case "Add" : 
				inputs[1].setVisible(true);
				return _mat1.add(_mat2);
				
			case "Subtract" : 
				inputs[1].setVisible(true);
				return _mat1.subtract(_mat2);
				
			case "Multiply Scalar" : 
				inputs[3].setVisible(true);
				return _mat1.multiplyScalar(_sca);
				
			case "Divide Scalar" : 
				inputs[3].setVisible(true);
				return _mat1.divideScalar(_sca);
				
			case "Multiply Matrix" : 
				inputs[1].setVisible(true);
				return _mat1.multiplyMatrix(_mat2);
		}
		
		return _mat1;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var opr  = getSingleValue(2);
		var str  = "";
		
		switch(operation_scroll[opr].name) {
			case "Add"             : str = "+"; break;
			case "Subtract"        : str = "-"; break;
			case "Multiply Scalar" : str = "*"; break;
			case "Divide Scalar"   : str = "/"; break;
			
			case "Multiply Matrix" : str = "*"; break;
		}
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}