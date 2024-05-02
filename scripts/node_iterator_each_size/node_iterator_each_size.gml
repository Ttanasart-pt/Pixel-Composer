function Node_Iterator_Each_Length(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Array Length";
	color = COLORS.node_blend_loop;
	destroy_when_upgroup = true;
	
	setDimension(96, 48);
	
	outputs[| 0] = nodeValue("Length", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	static update = function(frame = CURRENT_FRAME) { 
		if(!variable_struct_exists(group, "iterated")) return;
		var val = group.getInputData(0);
		outputs[| 0].setValue(array_length(val));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_iterator_amount, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static onLoadGroup = function() { #region
		if(group == noone) destroy();
	} #endregion
}