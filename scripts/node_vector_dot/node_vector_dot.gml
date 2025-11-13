function Node_Vector_Dot(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Dot Product";
	color = COLORS.node_blend_number;
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Float("Point 1", [ 0, 0 ]))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Point 2", [ 0, 0 ]))
		.setArrayDepth(1)
		.setVisible(true, true);
		
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.float, 0 ));
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _pnt1 = _data[0];
		var _pnt2 = _data[1];
		
		if(array_length(_pnt1) == 2) {
			inputs[0].editWidget.size = 2;
			inputs[1].editWidget.size = 2;
			
			return dot_product(array_safe_get_fast(_pnt1, 0), array_safe_get_fast(_pnt1, 1), 
							   array_safe_get_fast(_pnt2, 0), array_safe_get_fast(_pnt2, 1));
							   
		} else if(array_length(_pnt1) == 3) {
			inputs[0].editWidget.size = 3;
			inputs[1].editWidget.size = 3;
			
			return dot_product_3d(array_safe_get_fast(_pnt1, 0), array_safe_get_fast(_pnt1, 1), array_safe_get_fast(_pnt1, 2), 
							      array_safe_get_fast(_pnt2, 0), array_safe_get_fast(_pnt2, 1), array_safe_get_fast(_pnt2, 2), );
		}
		
		return 0;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = "Dot";
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}