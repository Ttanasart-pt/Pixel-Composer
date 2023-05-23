function Node_FFT(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "FFT";
	previewable = false;
	
	w = 96;
	h = 72;
	min_h = h;
	
	inputs[| 0] = nodeValue("Data", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(1)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Preprocess Function", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "None", "Hann" ]);
		
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dat = _data[0];
		var _pre = _data[1];
		var _cmp = [];
		
		var N = array_length(_dat);
		
		for( var i = 0; i < N; i++ ) {
			var val = _dat[i];
			
			if(_pre == 1) val = 0.5 * (1 - cos(2 * pi * i / (N - 1)));
			
			_cmp[i] = new Complex(val);
		}
		
		var _res = FFT(_cmp);
		var _r = array_create(array_length(_res));
		
		for( var i = 0; i < array_length(_res); i++ )
			_r[i] = sqrt(sqr(_res[i].re) + sqr(_res[i].im));
		
		return _r;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_FFT, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}