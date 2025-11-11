function Node_Iterator_Length(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Amount";
	color = COLORS.node_blend_loop;
	destroy_when_upgroup = true;
	manual_ungroupable	 = false;
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Length", VALUE_TYPE.integer, 0));
	
	static update = function(frame = CURRENT_FRAME) { #region
		var gr = is_instanceof(group, Node_Iterator)? group : noone;
		if(inline_context != noone) gr = inline_context;
			
		if(gr == noone) return;
		outputs[0].setValue(gr.getIterationCount());
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = draw_bbox;
		draw_sprite_fit(s_node_iterator_length, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}