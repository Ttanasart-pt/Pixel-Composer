#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur", "Size > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blur";
	
	newActiveInput(7);
	newInput(8, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(14, nodeValue_Surface( "UV Map"     ));
	newInput(15, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 5, nodeValue_Surface( "Mask"       ));
	newInput( 6, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(5, 9); // inputs 9, 10
	
	////- =Blur
	newInput( 1, nodeValue_Float(   "Size",       8 )).setHotkey("S").setMappable(16).setUnitSimple(false).setValidator(VV_min(0))
	newInput( 2, nodeValue_EScroll( "Intensity",  0, [ "Gaussian", "Custom" ] ));
	newInput(17, nodeValue_Curve(   "Intensity Modulation", CURVE_DEF_11 ));
	newInput( 3, nodeValue_Bool(    "Override color",       false        )).setTooltip("Replace all color while keeping the alpha. Used to\nfix grey outline when bluring transparent pixel.");
	newInput( 4, nodeValue_Color(   "Color",                ca_black     ));
	newInput(11, nodeValue_Bool(    "Gamma Correction",     false        ));
	
	////- =Directional
	newInput(12, nodeValue_Slider(   "Aspect Ratio", 1));
	newInput(13, nodeValue_Rotation( "Direction",    0));
	// inputs 18
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  7,  8, 
		[ "Surfaces",     true ],  0, 14, 15,  5,  6,  9, 10, 
		[ "Blur",        false ],  1, 16,  2, 17,  3,  4, 11, 
		[ "Directional",  true ], 12, 13, 
	];
	
	////- Node
	
	temp_surface = [ noone, noone ];
	
	attribute_surface_depth();
	attribute_oversample();
	surface_blur_init();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {	
		#region data
			var _surf  = _data[ 0];
			var _uvm   = _data[14];
			var _uvmx  = _data[15];
			var _mask  = _data[ 5];
			var _mix   = _data[ 6];
			
			var _size  = _data[ 1];
			var _ints  = _data[ 2];
			var _intc  = _data[17];
			var _isovr = _data[ 3];
			
			var _overc = _isovr? _data[4] : noone;
			var _gam   = _data[11];
			var _aspc  = _data[12];
			var _dirr  = _data[13];
			
			var _clamp = getAttribute("oversample");
			
			inputs[17].setVisible(_ints == 1);
		#endregion
		
		inputs[4].setVisible(_isovr);
		
		if(!is_surface(_surf)) return _outSurf;
		var format = surface_get_format(_surf);
		var _sw    = surface_get_width_safe(_surf);
		var _sh    = surface_get_height_safe(_surf);
		var _msize = is_array(_size)? max(_size[0], _size[1]) : _size;
		
		temp_surface[0] = surface_verify(temp_surface[0], _sw, _sh, format);	
		temp_surface[1] = surface_verify(temp_surface[1], _sw, _sh, format);	
		
		BLEND_OVERRIDE
		gpu_set_tex_filter(true);
		
		var _k    = __gaussian_get_kernel(_msize);
		var _kern = _k;
		
		if(_ints == 1) {
			var _klen = array_length(_k);
			    _kern = array_create(_klen);
			var _ktot = 0;
			
			for( var i = 0; i < _klen; i++ ) {
				_kern[i] = eval_curve_x(_intc, i / (_klen - 1));
				_ktot += _kern[i];
			}
			
			if(_ktot != 0)
			for( var i = 0; i < _klen; i++ )
				_kern[i] /= _ktot;
		}
		
		surface_set_target(temp_surface[0]);
			draw_clear_alpha(c_white, false);
			
			shader_set(sh_blur_gaussian);
			shader_set_uv(_uvm, _uvmx);
			shader_set_f("dimension",  [_sw,_sh] );
			shader_set_f("weight",     _kern     );
			
			shader_set_i("sampleMode", _clamp    );
			shader_set_f_map("size",   _size, _data[16], inputs[1] );
			shader_set_i("horizontal", 1         );
			shader_set_i("gamma",      _gam      );
			
			shader_set_i("overrideColor", _overc != noone );
			shader_set_c("overColor",     _overc          );
			shader_set_f("angle",         degtorad(_dirr) );
			
			shader_set_f("sizeModulate",  1      );
			
			draw_surface_safe(_surf);
			shader_reset();
		surface_reset_target();
		
		surface_set_target(temp_surface[1]);
			draw_clear_alpha(c_white, false);
			
			shader_set(sh_blur_gaussian);
			shader_set_f("weight",    _kern);
			shader_set_f_map("size",   _size, _data[16], inputs[1]);
			shader_set_i("horizontal", 0);
			
			shader_set_f("sizeModulate",  _aspc);
			
			draw_surface_safe(temp_surface[0]);
			shader_reset();
		surface_reset_target();
		
		gpu_set_tex_filter(false);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(_isovr? _overc : 0, 0);
			draw_surface_safe(temp_surface[1]);
		surface_reset_target();
		BLEND_NORMAL
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	}
}