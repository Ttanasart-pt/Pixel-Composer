function Node_PB_Layer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "PB Layer";
	icon = THEME.pixel_builder;
	
	w = 128;
	h = 128;
	min_h = h;
	
	inputs[| 0] = nodeValue("Layer", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 );
	
	outputs[| 0] = nodeValue("pBox", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone );
	
	static update = function() {}
	
	static getPreviewValue = function() {
		return group.outputs[| 0];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s)
			.toSquare()
			.pad(8);
		
		draw_set_color(c_white);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 2);
	}
}