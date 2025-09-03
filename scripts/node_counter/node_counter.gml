function Node_Counter(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Frame Index";
	update_on_frame = true;
	
	setDimension(96, 48);
	
	////- =Settings
	newInput(2, nodeValue_Enum_Scroll( "Mode",  0, ["Frame count", "Animation progress"])).rejectArray()
		.setTooltip(@"Counting mode
- Frame count: Count value up/down per frame.
- Animation progress: Count from 0 (first frame) to 1 (last frame).");
	newInput(0, nodeValue_Float( "Start", 1 ));
	newInput(1, nodeValue_Float( "Speed", 1 ));
	
	////- =Async
	newInput(3, nodeValue_Bool(    "Async", false ));
	newInput(4, nodeValue_Trigger( "Reset" ));
	// input 5
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.float, 0));
	
	input_display_list = [
		[ "Settings", false ], 2, 0, 1, 
		[ "Async",    false, 3 ], 4, 
	];
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _time = CURRENT_FRAME;
		var _mode = _data[2];
		var _star = _data[0];
		var _sped = _data[1];
		
		var _asyn = _data[3];
		var _rest = _data[4];
		
		inputs[0].setVisible( _mode == 0 );
		inputs[2].setVisible(!_asyn);
		inputs[4].setVisible( true, _asyn);
		
		if(_asyn) {
			if(IS_FIRST_FRAME || _rest) return _star;
			return _output + _sped;
		}
		
		var val = 0;
		switch(_mode) {
			case 0 : val = _star + _time * _sped;              break;
			case 1 : val = _time / (TOTAL_FRAMES - 1) * _sped; break;
		}
		
		return val;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var str  = outputs[0].getValue();
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}