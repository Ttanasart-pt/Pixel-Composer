function Node_Wave_Table(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name			= "Wave Table";
	update_on_frame = true;
	setDimension(96, 96);
	
	inputs[| 0] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 8, 0.01] });
	
	inputs[| 2] = nodeValue("Display", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Number", "Graph" ]);
	
	inputs[| 3] = nodeValue("Pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 3, 0.01] });
		
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	input_display_list = [
		["Display",	 true],	2,
		["Wave",	false], 3, 0, 1,
	];
	
	graph_display = array_create(64, 0);
	
	pattern   = 0;
	frequency = 0;
	range_min = 0;
	range_max = 0;
	disp_text = 0;
	
	function getPattern(_patt, _time) {
		switch(_patt % 3) {
			case 0 : return sin(_time * pi * 2);
			case 1 : return frac(_time) < 0.5? 1 : -1;
			case 2 : return frac(_time + 0.5) * 2 - 1;
		}
		
		return 0;
	}
	
	function __getWave(_time = 0) {
		var _p0 = floor(pattern);
		var _p1 = floor(pattern) + 1;
		var _fr = frac(pattern);
		
		var _v0  = getPattern(_p0, _time * frequency) * .5 + .5;
		var _v1  = getPattern(_p1, _time * frequency) * .5 + .5;
		var _lrp = lerp(_v0, _v1, _fr);
		
		return lerp(range_min, range_max, _lrp);
	}
	
	static onValueUpdate = function(index = 0) {
		var ran     = getSingleValue(0);
		range_min   = array_safe_get_fast(ran, 0);
		range_max   = array_safe_get_fast(ran, 1);
		
		frequency   = getSingleValue(1);
		pattern     = getSingleValue(3);
		
		for( var i = 0; i < 64; i++ )
			graph_display[i] = __getWave(i / 64);
	} 
	
	run_in(1, function() { onValueUpdate(); });
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var ran     = _data[0];
		range_min   = array_safe_get_fast(ran, 0);
		range_max   = array_safe_get_fast(ran, 1);
		
		frequency   = _data[1];
		pattern     = _data[3];
		
		var val = __getWave(CURRENT_FRAME / TOTAL_FRAMES);
		if(_output_index == 0) disp_text = val;
		
		return val;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		
		var ran  = array_safe_get_fast(current_data, 0);
		var disp = array_safe_get_fast(current_data, 2);
		var time = CURRENT_FRAME;
		var total_time = TOTAL_FRAMES;
		
		if(!is_array(ran)) return;
		
		switch(disp) {
			case 0 :
				draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
				draw_text_bbox(bbox, disp_text);
				break;
				
			case 1 :
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
				draw_set_alpha(0.5);
				draw_line(x0, yc, x1, yc);
				draw_set_alpha(1);
				
				draw_set_text(f_sdf, fa_right, fa_bottom, COLORS._main_text_sub);
				draw_text_transformed(x1 - 2 * _s, y1, disp_text, 0.3 * _s, 0.3 * _s, 0);
				
				var lw = ww / (64 - 1);
				var ox, oy;
				draw_set_color(c_white);
				for( var i = 0; i < 64; i++ ) {
					var _x = x0 + i * lw;
					var _y = yc - (graph_display[i] - val) / _ran * hh;
					if(i) draw_line(ox, oy, _x, _y);
					
					ox = _x;
					oy = _y;
				}
				draw_set_color(COLORS._main_accent);
				var _fx = x0 + (time / total_time * ww);
				draw_line(_fx, y0, _fx, y1);
				
				draw_set_color(COLORS.node_wiggler_frame);
				draw_rectangle(x0, y0, x1, y1, true);
				break;
		}
	} #endregion
	
	static doApplyDeserialize = function() { onValueUpdate(); }
}