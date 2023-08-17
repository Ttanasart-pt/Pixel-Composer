function Node_PB_Box_Transform(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Transform";
	
	inputs[| 1] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("Translate", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
		
	outputs[| 0] = nodeValue("pBox", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone );
	
	input_display_list = [ 0, 1,
		["Translate",	false], 2, 
	]
		
	static drawOverlayPB = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _layr = _data[0];
		var _pbox = _data[1];
		var _tran = _data[2];
		
		if(_pbox == noone) return noone;
		
		_pbox = _pbox.clone();
		_pbox.layer += _layr;
		
		_pbox.x += _tran[0];
		_pbox.y += _tran[1];
		
		return _pbox;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s)
			.toSquare()
			.pad(8);
		
		draw_set_color(c_white);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 2);
		
	}
}