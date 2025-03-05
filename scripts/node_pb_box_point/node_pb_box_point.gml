function Node_PB_Box_Point(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "PBBOX Get Point";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Pbbox("PBBOX", self, new __pbBox()));
	
	newInput(1, nodeValue_Anchor("Anchor", self));
	
	newInput(2, nodeValue_2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	newOutput(0, nodeValue_Output("Point", self, VALUE_TYPE.float, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pbbox = getSingleValue(0);
		if(is(_pbbox, __pbBox)) {
			draw_set_color(COLORS._main_icon);
			_pbbox.drawOverlayBBOX(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
		}
	}
	
	static getDimension = function() {
	    var _pbbox = getSingleValue(0);
	    var _bbox  = _pbbox.getBBOX();
	    return [ _bbox[2] - _bbox[0], _bbox[3] - _bbox[1] ];
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim   = group.dimension;
		var _pbbox = _data[0];
		var _anchr = _data[1];
		var _posit = _data[2];
		
		if(inputs[0].value_from == noone) _pbbox.base_bbox = [ 0, 0, _dim[0], _dim[1] ];
		var _bbox  = _pbbox.getBBOX();
		
		var x0 = lerp(_bbox[0], _bbox[2], _anchr[0]);
		var y0 = lerp(_bbox[1], _bbox[3], _anchr[1]);
		
		var _p = [ x0 + _posit[0], y0 + _posit[1] ];
		return _p;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_pb_box_bbox, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
}