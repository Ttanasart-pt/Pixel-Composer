function Node_Convolution(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Convolution";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(3, nodeValue_Surface( "Mask"       ));
	newInput(4, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(3, 7); // inputs 7, 8, 
	
	////- =Kernel
	newInput(10, nodeValue_Int(    "Size",      3             )).setValidator(VV_clamp(3, 16));
	newInput( 1, nodeValue_Matrix( "Kernel",    new Matrix(3) ));
	newInput( 9, nodeValue_Bool(   "Normalize", false         ));
	/* UNUSED */ newInput( 2, nodeValue_Enum_Scroll("Oversample mode", 0, [ "Empty", "Clamp", "Repeat" ]));
	// input 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 6, 
		["Surfaces", true],	0, 3, 4, 7, 8, 
		["Kernel",	false],	10, 1, 9, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _ker = _data[1];
		var _nrm = _data[9];
		var _siz = max(3, _data[10]);
		_ker.setSize(_siz);
		
		var _dat = _ker.raw;
		
		surface_set_shader(_outSurf, sh_convolution, true, BLEND.over);
			shader_set_i("sampleMode",  getAttribute("oversample"));
			shader_set_dim("dimension", _outSurf);
			shader_set_f("kernel",      _dat);
			shader_set_i("size",        _siz);
			shader_set_i("normalized",  _nrm);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}