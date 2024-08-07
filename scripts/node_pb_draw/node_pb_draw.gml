function Node_PB_Draw(_x, _y, _group = noone) : Node_PB(_x, _y, _group) constructor {
	name = "PB Draw";
	
	inputs[| 0] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue_Color("Color", self, c_white );
	
	inputs[| 2] = nodeValue_Bool("Apply Mask", self, true );
	
	outputs[| 0] = nodeValue_Output("pBox", self, VALUE_TYPE.pbBox, noone);
	
	static getGraphPreviewSurface = function() {
		var _nbox = outputs[| 0].getValue();
		if(_nbox == noone) return noone;
		if(is_array(_nbox)) {
			if(array_empty(_nbox)) return noone;
			_nbox = _nbox[0];
		}
		
		return _nbox.content;
	}
}

#macro PB_DRAW_CREATE_MASK _nbox.mask = surface_verify(_nbox.mask, _nbox.w, _nbox.h);								\
		surface_set_shader(_nbox.mask, sh_pb_to_mask);																\
			draw_surface_safe(_nbox.content);																	\
		surface_reset_shader();
		
#macro PB_DRAW_APPLY_MASK if(_mask) {																				\
				BLEND_MULTIPLY																						\
					if(is_surface(_pbox.mask)) 																		\
						draw_surface_safe(_pbox.mask);														\
				BLEND_NORMAL																						\
			}