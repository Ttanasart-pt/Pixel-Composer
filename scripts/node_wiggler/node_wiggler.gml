function Node_Wiggler(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name			= "Wiggler";
	update_on_frame = true;
	previewable     = false;
	
	w = 96;
	
	
	inputs[| 0] = nodeValue(0, "Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 1])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4 )
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 2] = nodeValue(2, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(9999999) );
	
	inputs[| 3] = nodeValue(3, "Display", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Number", "Graph"])
	
	outputs[| 0] = nodeValue(0, "Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	input_display_list = [
		["Display",	true],	3,
		["Wiggle",	false], 2, 0, 1,
	];
	
	random_value = array_create(64, 0);
	
	static onValueUpdate = function(index) {
		var ran = inputs[| 0].getValue();
		var fre = inputs[| 1].getValue();
		var sed = inputs[| 2].getValue();
		
		var step = ANIMATOR.frames_total / 64;
		for( var i = 0; i < 64; i++ ) {
			random_value[i] = getWiggle(ran[0], ran[1], ANIMATOR.frames_total / fre, step * i, sed, 0, ANIMATOR.frames_total);
		}
	}
	
	function process_data(_output, _data, index = 0) { 
		var ran = inputs[| 0].getValue();
		var fre = inputs[| 1].getValue();
		var sed = inputs[| 2].getValue();
		var time = ANIMATOR.current_frame;
		
		return getWiggle(ran[0], ran[1], ANIMATOR.frames_total / fre, time, sed, 0, ANIMATOR.frames_total);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var ran  = inputs[| 0].getValue();
		var fre  = inputs[| 1].getValue();
		var sed  = inputs[| 2].getValue();
		var disp = inputs[| 3].getValue();
		var time = ANIMATOR.current_frame;
		var total_time = ANIMATOR.frames_total;
		
		switch(disp) {
			case 0 :
				w = 96;
				
				draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
				var str	= getWiggle(ran[0], ran[1], ANIMATOR.frames_total / fre, time, sed, 0, ANIMATOR.frames_total);
				var ss	= string_scale(str, (w - 16) * _s, (h - 16) * _s - 20 * draw_name);
				draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, ss, ss, 0);
				break;
			case 1 :
				w = 128;
				min_h = 96;
				
				var _min = ran[0];
				var _max = ran[1];
				var val  = (_min + _max) / 2;
				var _ran = _max - _min;
				
				var x0 = xx + 8 * _s;
				var x1 = xx + (w - 8) * _s;
				var y0 = yy + 20 * draw_name + 8  * _s;
				var y1 = yy + (h - 8) * _s;
				var ww = x1 - x0;
				var hh = y1 - y0;
				
				var yc = (y0 + y1) / 2;
				draw_set_color(COLORS.node_wiggler_frame);
				draw_line(x0, yc, x1, yc);
				var _fx = x0 + (time / total_time * ww);
				draw_line(_fx, y0, _fx, y1);
				
				var lw = ww / (64 - 1);
				draw_set_color(COLORS.node_wiggler_frame);
				var ox, oy;
				for( var i = 0; i < 64; i++ ) {
					var _x = x0 + i * lw;
					var _y = yc - (random_value[i] - val) / _ran * hh;
					if(i)
						draw_line(ox, oy, _x, _y);
					
					ox = _x;
					oy = _y;
				}
				
				draw_set_color(COLORS.node_wiggler_frame);
				draw_rectangle(x0, y0, x1, y1, true);
				break;
		}
	}
}