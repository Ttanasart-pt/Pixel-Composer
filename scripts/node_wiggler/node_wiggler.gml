function Node_Wiggler(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name			= "Wiggler";
	update_on_frame = true;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 1])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 1] });
	
	inputs[| 2] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(9999999) );
	
	inputs[| 3] = nodeValue("Display", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Number", "Graph"])
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	input_display_list = [
		["Display",	true],	3,
		["Wiggle",	false], 2, 0, 1,
	];
	
	random_value = array_create(64, 0);
	
	static onValueUpdate = function(index = 0) {
		var ran = getSingleValue(0);
		var fre = getSingleValue(1);
		var sed = getSingleValue(2);
		
		var step = TOTAL_FRAMES / 64;
		for( var i = 0; i < 64; i++ )
			random_value[i] = getWiggle(array_safe_get(ran, 0), array_safe_get(ran, 1), TOTAL_FRAMES / fre, step * i, sed, 0, TOTAL_FRAMES);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var ran = _data[0];
		var fre = _data[1];
		var sed = _data[2];
		var time = CURRENT_FRAME;
		
		return getWiggle(array_safe_get(ran, 0), array_safe_get(ran, 1), TOTAL_FRAMES / fre, time, sed, 0, TOTAL_FRAMES);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var ran  = array_safe_get(current_data, 0);
		var fre  = array_safe_get(current_data, 1);
		var sed  = array_safe_get(current_data, 2);
		var disp = array_safe_get(current_data, 3);
		var time = CURRENT_FRAME;
		var total_time = TOTAL_FRAMES;
		
		if(!is_array(ran)) return;
		
		switch(disp) {
			case 0 :
				w = 96;
				
				draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
				var str	= getWiggle(ran[0], ran[1], TOTAL_FRAMES / fre, time, sed, 0, TOTAL_FRAMES);
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