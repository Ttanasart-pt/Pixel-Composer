function Node_create_Wrap_Area(_x, _y) {
	var node = new Node_Wrap_Area(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Wrap_Area(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Area wrap";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		inputs[| 1].drawOverlay(_active, _x, _y, _s, _mx, _my);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		print("update")
		var _inSurf	= _data[0];
		var _area	= _data[1];
		
		var cx = _area[0];
		var cy = _area[1];
		var cw = _area[2];
		var ch = _area[3];
		
		var ww = cw / surface_get_width(_inSurf) * 2;
		var hh = ch / surface_get_height(_inSurf) * 2;
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			draw_surface_ext_safe(_inSurf, cx - cw, cy - ch, ww, hh, 0, c_white, 1);
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}