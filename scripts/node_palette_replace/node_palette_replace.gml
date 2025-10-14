function Node_Palette_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette Replace";
	setDimension(96);
	
	newInput(0, nodeValue_Palette( "Palette in" )).setVisible(true, true);
	newInput(1, nodeValue_Palette( "Palette from" ));
	newInput(2, nodeValue_Palette( "Palette to" ));
	newInput(3, nodeValue_Slider(  "Threshold",     .1));
	
	input_display_list = [ 0, 
		["Palette", false], 1, 2, 3, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.color, [ ] ))
		.setDisplay(VALUE_DISPLAY.palette);
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var pal = _data[0];
		var pfr = _data[1];
		var pto = _data[2];
		var thr = _data[3];
		var palo = [];
		
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			var c = pal[i];
			
			var fromValue = 999;
			var fromIndex = -1;
			for( var j = 0; j < array_length(pfr); j++ ) {
				var fr = pfr[j];
				
				var dist = color_diff(c, fr);
				if(dist <= thr && dist < fromValue) {
					fromValue = dist;
					fromIndex = j;
				}
			}
			
			palo[i] = fromIndex == -1? c : array_safe_get_fast(pto, fromIndex, c, ARRAY_OVERFLOW.loop);
		}
		
		return palo;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[0].getValue();
		if(array_empty(pal)) return;
		if(!is_array(pal[0])) pal = [ pal ];
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(pal);
			
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			drawPalette(pal[i], bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
	}
}