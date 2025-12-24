function Node_PB_Box_BBOX(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "PBBOX Convert";
	color = COLORS.node_blend_feedback;
	setDimension(96, 48);
	setDrawIcon(s_node_pb_box_bbox);
	
	newInput(0, nodeValue_Pbbox());
	
	newOutput(0, nodeValue_Output("BBOX", VALUE_TYPE.float, [ 0, 0, 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	newOutput(1, nodeValue_Output("Area", VALUE_TYPE.float, [ 0, 0, 0, 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.area);
	
	newOutput(2, nodeValue_Output("Width", VALUE_TYPE.float, 0))
		.setVisible(false)
	
	newOutput(3, nodeValue_Output("Height", VALUE_TYPE.float, 0))
		.setVisible(false)
	
	newOutput(4, nodeValue_Output("Dimension", VALUE_TYPE.float, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false)
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pbase = getInputSingle(0);
		
		if(is(_pbase, __pbBox)) {
			draw_set_color(COLORS._main_icon);
			_pbase.drawOverlayBBOX(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
		}
		
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim   = group.dimension;
		var _pbbox = _data[0];
		
		var _bbox = _pbbox.getBBOX();
		var _x0 = _bbox[0];
		var _y0 = _bbox[1];
		var _x1 = _bbox[2];
		var _y1 = _bbox[3];
		var _w  = _x1 - _x0;
		var _h  = _y1 - _y0;
		
		var _area = [ (_x0 + _x1) / 2, (_y0 + _y1) / 2, _w / 2, _h / 2, 0 ];
		
		return [ _bbox, _area, _w, _h, [_w, _h] ];
	}
	
}