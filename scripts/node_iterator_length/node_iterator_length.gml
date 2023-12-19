function Node_Iterator_Length(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Amount";
	color = COLORS.node_blend_loop;
	destroy_when_upgroup = true;
	
	w = 96;
	min_h = 80;
	
	outputs[| 0] = nodeValue("Length", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	static update = function(frame = CURRENT_FRAME) { #region
		var gr = is_instanceof(group, Node_Iterator)? group : noone;
		for( var i = 0, n = array_length(context_data); i < n; i++ ) 
			if(is_instanceof(context_data[i], Node_Iterate_Inline))
				gr = context_data[i];
		
		if(gr == noone) return;
		outputs[| 0].setValue(gr.getIterationCount());
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_iterator_length, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}