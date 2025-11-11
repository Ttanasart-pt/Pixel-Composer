function Node_Fn(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name			= "Fn";
	time_based      = true;
	update_on_frame = true;
	setDimension(96, 96);
	
	newInput(0, nodeValue_Enum_Scroll("Display",  1 , [ "Number", "Graph" ]));
	
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.float, 0));
	
	inl = array_length(inputs);
	
	input_display_list = [
		["Display",	 true],	0, 
	];
	
	text_display      = 0;
	graph_res         = 64;
	graph_display     = array_create(graph_res, 0);
	graph_display_min = 0;
	graph_display_max = 0;
	
	static __fnEval = function(_x = 0) { return 0; }
	
	static refreshDisplay = function() { 
		graph_display_min = undefined;
		graph_display_max = undefined;
		
		for( var i = 0; i < graph_res; i++ ) {
			var _c = __fnEval(refreshDisplayX(i));
			graph_display[i] = _c;
			graph_display_min = graph_display_min == undefined? _c : min(graph_display_min, _c);
			graph_display_max = graph_display_max == undefined? _c : max(graph_display_max, _c);
		}
	}
	
	static refreshDisplayX = function(i) { return i / graph_res; }
	static getDisplayX     = function(i) { return graph_display[i]; }
	
	static postPostProcess = function() { if(!IS_PLAYING) refreshDisplay(); }
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) { }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = draw_bbox;
		
		var disp = array_safe_get_fast(current_data, 0);
		var time = CURRENT_FRAME;
		var total_time = TOTAL_FRAMES;
		
		switch(disp) {
			case 0 :
				draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
				draw_text_bbox(bbox, text_display);
				break;
				
			case 1 :
				var _min = graph_display_min;
				var _max = graph_display_max;
				var val  = (_min + _max) / 2;
				var _ran = _max - _min;
				
				var x0 = bbox.x0;
				var x1 = bbox.x1;
				var y0 = bbox.y0;
				var y1 = bbox.y1;
				var ww = bbox.w;
				var hh = bbox.h;
				
				var yc = (y0 + y1) / 2;
				draw_set_color(COLORS.node_wiggler_frame);
				draw_set_alpha(0.5);
				draw_line(x0, yc, x1, yc);
				draw_set_alpha(1);
				
				draw_set_text(f_sdf, fa_right, fa_bottom, COLORS._main_text_sub);
				draw_text_transformed(x1 - 2 * _s, y1, text_display, 0.3 * _s, 0.3 * _s, 0);
				
				var lw = ww / (graph_res - 1);
				var ox, oy;
				draw_set_color(c_white);
				for( var i = 0; i < graph_res; i++ ) {
					var _x = x0 + i * lw;
					var _y = yc - (graph_display[i] - val) / _ran * hh;
					if(i) draw_line(ox, oy, _x, _y);
					
					ox = _x;
					oy = _y;
				}
				
				if(time_based) {
					draw_set_color(COLORS._main_accent);
					var _fx = x0 + (time / total_time * ww);
					draw_line(_fx, y0, _fx, y1);
				}
				
				draw_set_color(COLORS.node_wiggler_frame);
				draw_rectangle(x0, y0, x1, y1, true);
				break;
		}
	} #endregion
}