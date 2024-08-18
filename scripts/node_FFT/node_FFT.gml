function Node_FFT(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "FFT";
	setDimension(96, 72);
	
	inputs[0] = nodeValue_Float("Data", self, [])
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Scroll("Preprocess Function", self,  0, [ "None", "Hann" ]));
		
	outputs[0] = nodeValue_Output("Array", self, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
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
		
		for( var i = 0, n = array_length(_res); i < n; i++ )
			_r[i] = sqrt(sqr(_res[i].re) + sqr(_res[i].im));
		
		return _r;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_FFT, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}