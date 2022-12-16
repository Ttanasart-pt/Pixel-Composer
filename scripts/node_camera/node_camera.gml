function Node_Camera(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Camera";
	preview_alpha = 0.5;
	
	inputs[| 0] = nodeValue(0, "Scene", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Focus area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static getPreviewValue = function() { return inputs[| 0]; }
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		var _out = outputs[| 0].getValue();
		var _area = current_data[1];
		var _px = _x + (_area[0] - _area[2]) * _s;
		var _py = _y + (_area[1] - _area[3]) * _s;
		
		draw_surface_ext_safe(_out, _px, _py, _s, _s);
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _area = _data[1];
		
		var _dw = surface_valid_size(_area[2]) * 2;
		var _dh = surface_valid_size(_area[3]) * 2;
		surface_size_to(_outSurf, _dw, _dh);
		
		var _px = _area[0] - _dw / 2;
		var _py = _area[1] - _dh / 2;
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		draw_surface_safe(_data[0], -_px, -_py);
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}