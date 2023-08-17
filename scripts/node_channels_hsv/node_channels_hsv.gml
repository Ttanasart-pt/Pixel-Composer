function Node_HSV_Channel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "HSV Extract";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue("Hue", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Saturation", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 2] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 3] = nodeValue("Alpha", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, output_index) {
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
			switch(output_index) {
				case 0 : shader_set(sh_channel_H); break;
				case 1 : shader_set(sh_channel_S); break;
				case 2 : shader_set(sh_channel_V); break;
				case 3 : shader_set(sh_channel_A); break;
			}
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}