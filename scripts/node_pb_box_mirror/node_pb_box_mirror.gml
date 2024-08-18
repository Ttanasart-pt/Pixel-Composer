function Node_PB_Box_Mirror(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Mirror";
	
	inputs[1] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
		
	newInput(2, nodeValue_Bool("Horizontal", self, false ));
		
	newInput(3, nodeValue_Bool("Vertical", self, false ));
		
	outputs[0] = nodeValue_Output("pBox", self, VALUE_TYPE.pbBox, noone );
	
	input_display_list = [ 0, 1,
		["Mirror",	false], 2, 3, 
	]
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _layr = _data[0];
		var _pbox = _data[1];
		var _hori = _data[2];
		var _vert = _data[3];
		
		if(_pbox == noone) return noone;
		
		_pbox = _pbox.clone();
		_pbox.layer += _layr;
		
		if(_hori) {
			_pbox.mirror_h = !_pbox.mirror_h;
			_pbox.mask	  = surface_mirror(_pbox.mask, true, false);
			_pbox.content = surface_mirror(_pbox.content, true, false);
		}
		
		if(_vert) {
			_pbox.mirror_v = !_pbox.mirror_v;
			_pbox.mask	  = surface_mirror(_pbox.mask, false, true);
			_pbox.content = surface_mirror(_pbox.content, false, true);
		}
		
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