function Node_Gradient_Sample(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sample Gradient";
	setDimension(96);
	
	////- =Gradient
	newInput( 0, nodeValue_Gradient( "Gradient", gra_black_white) ).setVisible(true, true);
	newInput( 2, nodeValue_Slider(   "Shift",    0, [-1, 1, 0.01] ));
	
	////- =Sampling
	newInput( 3, nodeValue_EButton(  "Type",     0, [ "Step", "Ratio" ] ));
	newInput( 1, nodeValue_Int(      "Step",     16 ));
	newInput( 4, nodeValue_Slider(   "Ratio",    0  )).setArrayDepth(1);
	// 5
	
	newOutput(0, nodeValue_Output("Colors", VALUE_TYPE.color, [ c_black ])).setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [
		[ "Gradient", false ], 0, 2, 
		[ "Sampling", false ], 3, 1, 4, 
	]
	
	////- Node
	
	_pal = -1;
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var grad = _data[0];
			var shf  = _data[2];
			
			var typ  = _data[3];
			var stp  = _data[1];
			var rat  = _data[4];
			
			inputs[1].setVisible(typ == 0);
			inputs[4].setVisible(typ == 1);
		#endregion
		
		if(typ == 0) {
			_outSurf = array_verify(_outSurf, stp);
			for( var i = 0; i < stp; i++ ) {
				var _t = frac(shf + i / stp);
				_outSurf[i] = grad.eval(_t);
			}
			
		} else if(typ == 1) {
			if(is_real(rat)) rat = [rat];
			if(!is_array(rat)) return _outSurf;
			
			var _amo = array_length(rat);
			_outSurf = array_verify(_outSurf, _amo);
			
			for( var i = 0; i < _amo; i++ ) {
				var _t = frac(shf + rat[i]);
				_outSurf[i] = grad.eval(_t);
			}
			
		}
		
		return _outSurf;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
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