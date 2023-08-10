function Node_PB_Draw(_x, _y, _group = noone) : Node_PB(_x, _y, _group) constructor {
	name = "PB Draw";
	
	inputs[| 0] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 2] = nodeValue("Apply Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	outputs[| 0] = nodeValue("pBox", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone);
	
	static getGraphPreviewSurface = function() {
		var _nbox = outputs[| 0].getValue();
		if(_nbox == noone) return noone;
		
		return _nbox.content;
	}
}

#macro PB_DRAW_CREATE_MASK _nbox.mask = surface_verify(_nbox.mask, _nbox.w, _nbox.h);								\
		surface_set_shader(_nbox.mask, sh_pb_to_mask);																\
			draw_surface(_nbox.content, -_pbox.x, -_pbox.y);														\
		surface_reset_shader();
		
#macro PB_DRAW_APPLY_MASK if(_mask) {																				\
				BLEND_MULTIPLY																						\
					if(is_surface(_pbox.mask)) 																		\
						draw_surface(_pbox.mask, 0, 0);																\
				BLEND_NORMAL																						\
			}