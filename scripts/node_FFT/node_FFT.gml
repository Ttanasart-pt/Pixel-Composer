function Node_FFT(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "FFT";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Data", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(1)
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dat = _data[0];
		var _cmp = [];
		
		for( var i = 0; i < array_length(_dat); i++ ) 
			_cmp[i] = new Complex(_dat[i]);
		
		var _res = FFT(_cmp);
		var _r = [];
		
		for( var i = 0; i < array_length(_res); i++ )
			_r[i] = _res[i].re;
		
		return _r;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_reverse, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}