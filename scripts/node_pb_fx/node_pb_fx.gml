function Node_PB_Fx(_x, _y, _group = noone) : Node_PB(_x, _y, _group) constructor {
	name = "PB FX";
	
	inputs[| 0] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("pBox", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone);
}

#macro PB_FX_PBOX if(_output_index == 1) {																		\
			var _surf = outputs[| 0].getValue();																\
			if(is_array(_surf)) _surf = array_safe_get(_surf, _array_index);									\
			if(!is_surface(_surf)) return noone;																\
																												\
			var _pbox = new __pbBox();																			\
																												\
			_pbox.w = surface_get_width_safe(_surf);																	\
			_pbox.h = surface_get_height_safe(_surf);																\
																												\
			_pbox.layer_w = surface_get_width_safe(_surf);															\
			_pbox.layer_h = surface_get_height_safe(_surf);															\
																												\
			_pbox.mask = surface_create(_pbox.w, _pbox.h);														\
			surface_set_shader(_pbox.mask, sh_pb_to_mask);														\
				draw_surface_safe(_surf, 0, 0);																		\
			surface_reset_shader();																				\
																												\
			return _pbox;																						\
		}