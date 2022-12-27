function Node_Counter(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Counter";
	update_on_frame = true;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Start", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	inputs[| 1] = nodeValue(1, "Speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	inputs[| 2] = nodeValue(2, "Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Frame count", "Animation progress"]);
	
	outputs[| 0] = nodeValue(0, "Counter", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	input_display_list = [
		2, 0, 1
	];
	
	static step = function() {
		var mode = inputs[| 2].getValue();
		inputs[| 0].setVisible(mode == 0);
	}
	
	function process_data(_output, _data, index = 0) { 
		var time = ANIMATOR.current_frame;
		var mode = inputs[| 2].getValue();
		var val;
		
		switch(mode) {
			case 0 : val = _data[0] + time * _data[1]; break;
			case 1 : val = time / (ANIMATOR.frames_total - 1) * _data[1]; break;
		}
		
		return val;
	}
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, outputs[| 0].getValue(), _s, _s, 0);
	}
}