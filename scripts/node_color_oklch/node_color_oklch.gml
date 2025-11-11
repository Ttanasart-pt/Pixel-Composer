function Node_Color_OKLCH(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "OKLCH Color";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Slider("Lightness", .5))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Slider("Chroma", .2, [ 0, .37, .01] ))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Float("Hue", 0))
		.setDisplay(VALUE_DISPLAY.rotation)
		.setVisible(true, true);
	
	newInput(3, nodeValue_Slider("Alpha", 1));
	
	newInput(4, nodeValue_Enum_Scroll("Gamut clipping", 0, [ "Chroma", "50% grey", "Adaptive grey", "RGB (Naive)" ]))
	
	newOutput(0, nodeValue_Output("Color", VALUE_TYPE.color, c_white));
	
	newOutput(1, nodeValue_Output("Raw RGB", VALUE_TYPE.float, [ 0, 0, 0 ]))	
		.setDisplay(VALUE_DISPLAY.vector);
	 
	inspector_info = new Inspector_Label();
	
	input_display_list = [ 
		0, 1, 2, 3, 
		["Gamut clipping", false], inspector_info, 4, 
	];
	
	static processData = function(_outSurf, _data, _array_index) {
		var l   = _data[0];
		var c   = _data[1];
		var h   = _data[2];
		var alp = _data[3];
		var clp = _data[4];
		
		var rgb = oklch2rgb([ l, c, h ]);
		
		var _inrange = rgb[0] >= 0 && rgb[0] <= 1 &&
		               rgb[1] >= 0 && rgb[1] <= 1 && 
		               rgb[2] >= 0 && rgb[2] <= 1;
		
		if(_inrange) {
			var col = make_color_rgba(
				clamp(round(rgb[0] * 255), 0, 255),
				clamp(round(rgb[1] * 255), 0, 255),
				clamp(round(rgb[2] * 255), 0, 255),
				clamp(      alp    * 255,  0, 255),
			);
			
		} else {
			switch(clp) {
				case 0 : rgb = gamut_clip_preserve_chroma(rgb); break;
				case 1 : rgb = gamut_clip_project_to_0_5(rgb);  break;
				case 2 : rgb = gamut_clip_adaptive_L0_0_5(rgb); break;
				case 3 : 
					rgb[0] = clamp(rgb[0], 0, 1);
					rgb[1] = clamp(rgb[1], 0, 1);
					rgb[2] = clamp(rgb[2], 0, 1);
					break;
			}
			
			rgb[0] = is_nan(rgb[0])? 0 : rgb[0];
			rgb[1] = is_nan(rgb[1])? 0 : rgb[1];
			rgb[2] = is_nan(rgb[2])? 0 : rgb[2];
			
			var col = make_color_rgba(
				clamp(round(rgb[0] * 255), 0, 255),
				clamp(round(rgb[1] * 255), 0, 255),
				clamp(round(rgb[2] * 255), 0, 255),
				clamp(      alp    * 255,  0, 255),
			);
		}
		
		inspector_info.text = _inrange? "" : "Color(s) is outside the 8-bit rgb range\nOutput will not be accurate.";
		
		return [ col, rgb ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		var col = outputs[0].getValue();
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		drawColor(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}