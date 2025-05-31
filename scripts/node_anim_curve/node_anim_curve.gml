function Node_Anim_Curve(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Evaluate Curve";
	update_on_frame = true;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Curve("Curve", CURVE_DEF_01));
	newInput(1, nodeValue_Slider("Progress", 0));
	
	newInput(2, nodeValue_Float("Minimum", 0));
	newInput(3, nodeValue_Float("Maximum", 1));
	
	newInput(4, nodeValue_Bool("Animated", false));
	
	newInput(5, nodeValue_Enum_Scroll("Display Type", 0, { data: [ "Number", "Curve" ], update_hover: false }));
	
	newOutput(0, nodeValue_Output("Curve", VALUE_TYPE.float, []));
	
	input_display_list = [ 0, 
		["X Axis",  false], 4, 1, 
		["Y Axis",  false], 2, 3, 
		["Display", false], 5, 
	];
	curveBox_obj = inputs[0].editWidget;
	
	disp_type = 0;
	disp_prog = 0;
	
	static processData = function(_output, _data, _array_index = 0) {  		
		var curve = _data[0];
		var _anim = _data[4];
		var time  = _anim? CURRENT_FRAME / (TOTAL_FRAMES - 1) : _data[1];
		var _min  = _data[2];
		var _max  = _data[3];
		var val   = eval_curve_x(curve, time) * (_max - _min) + _min;
		
		var _disp = _data[5];
		disp_type = _disp;
		disp_prog = time;
		
		var _ww = 96, _hh = 48;
		switch(_disp) {
			case 0 : _ww =  96; _hh =  48; break;
			case 1 : _ww = 128; _hh = 128; break;
		}
		setDimension(_ww, _hh);
		
		inputs[1].setVisible(!_anim);
		
		curveBox_obj.progress_draw = time;
		curveBox_obj.display_min   = _min;
		curveBox_obj.display_max   = _max;
		
		return val;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox  = drawGetBbox(xx, yy, _s);
		
		switch(disp_type) {
			case 0 :
				var val   = outputs[0].getValue();
				if(is_array(val)) val = array_safe_get(val, 0);
				
				draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
				draw_text_bbox(bbox, string_format(val, -1, 2));
				break;
				
			case 1 :
				var curve = inputs[0].getValue();
				
				var x0 = bbox.x0, x1 = bbox.x1;
				var y0 = bbox.y0, y1 = bbox.y1; 
				var ww = bbox.w,  hh = bbox.h; 
				var st = 0.1;
					
				draw_set_color(COLORS.widget_curve_line);
				draw_set_alpha(0.15);
				
				for( var i = st; i < 1; i += st ) {
					var _y0 = y0 + hh * (1 - i);
					draw_line(x0, _y0, x1, _y0);
					
					var _x0 = x0 + ww * i;
					draw_line(_x0, y0, _x0, y1);
				}
				
				draw_set_alpha(1);
				
				var _xx = lerp(x0, x1, clamp(disp_prog, 0, 1));
				draw_set_color(COLORS.widget_curve_outline);
				draw_line(_xx, y0, _xx, y1);
				
				draw_set_color(COLORS._main_accent);
				draw_curve(x0, y0, ww, hh, curve);
				
				draw_set_color(COLORS.widget_curve_outline);
				draw_rectangle(x0, y0, x1, y1, true);
				break;
		}
	}
}