function Node_PB_Layer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "PB Layer";
	icon = THEME.pixel_builder;
	
	inputs[| 0] = nodeValue_Int("Layer", self, 0 );
	
	outputs[| 0] = nodeValue_Output("pBox", self, VALUE_TYPE.pbBox, noone );
	
	static update = function() {
		var _dim = group.getInputData(0);
		
		var _box = new __pbBox();
		_box.layer	 = getInputData(0);
		_box.w		 = array_safe_get_fast(_dim, 0, 1);
		_box.h		 = array_safe_get_fast(_dim, 1, 1);
		_box.layer_w = array_safe_get_fast(_dim, 0, 1);
		_box.layer_h = array_safe_get_fast(_dim, 1, 1);
			
		outputs[| 0].setValue(_box);
	}
	
	static getPreviewValues = function() { return group.outputs[| 0].getValue(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s)
			.toSquare()
			.pad(8);
		
		draw_set_color(c_white);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 2);
	}
}