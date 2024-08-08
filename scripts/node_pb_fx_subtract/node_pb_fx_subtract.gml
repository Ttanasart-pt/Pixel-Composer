function Node_PB_Fx_Subtract(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Subtract";
	
	inputs[1] = nodeValue_Surface("Surface", self)
		.setVisible(true, true);
		
	input_display_list = [ 0, 
		["Effect",	false], 1,
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _box1 = _data[0];
		var _box2 = _data[1];
		
		if(_box1 == noone || _box2 == noone) return noone;
		
		var _nbox = new __pbBox();
		
		_nbox.layer_w = _box1.layer_w;
		_nbox.layer_h = _box1.layer_h;
		
		var x0 = min(_box1.x, _box2.x);
		var y0 = min(_box1.y, _box2.y);
		
		var x1 = max(_box1.x + _box1.w, _box2.x + _box2.w);
		var y1 = max(_box1.y + _box1.h, _box2.y + _box2.h);
		
		_nbox.x = x0;
		_nbox.y = y0;
		
		_nbox.w = x1 - x0;
		_nbox.h = y1 - y0;
		
		_nbox.content = surface_create(_box1.layer_w, _box1.layer_h);
		
		surface_set_shader(_nbox.content);
			draw_surface_safe(_box1.content);
			
			BLEND_SUBTRACT
				draw_surface_safe(_box2.content);
			BLEND_NORMAL
		surface_reset_shader();
		
		return _nbox;
	}
}