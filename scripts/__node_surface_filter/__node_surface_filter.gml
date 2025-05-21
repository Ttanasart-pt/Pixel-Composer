/* Surface filter template
function Node_(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Bool("Active", true));
	active_index = 1;
	
	newInput(2, nodeValue_Surface("Mask"));
	
	newInput(3, nodeValue_Float("Mix", 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(2); // inputs 5, 6, 
	
	input_display_list = [ 1, 4, 
		["Surfaces",  true], 0, 2, 3, 5, 6, 
		["Effect",   false], 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	
	static processData = function(_outSurf, _data, _array_index) {
		
		var _rad = _data[7];
		var _int = _data[8];
		var _dim = surface_get_dimension(_data[0]);
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_shader(_outSurf, SHADER, true, BLEND.over);
			shader_set_i("sampleMode", getAttribute("oversample"));
			shader_set_2("dimension",  _dim);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}