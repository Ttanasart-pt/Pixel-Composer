function Node_Scale(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scale";
	dimension_index = -1;
	
	manage_atlas = false;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY._default, { slide_speed: 0.01 });
	
	inputs[| 2] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Upscale", "Scale to fit" ]);
	
	inputs[| 3] = nodeValue("Target dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 4;
		
	inputs[| 5] = nodeValue("Scale atlas position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 4, 
		["Surfaces", true], 0,
		["Scale",	false], 2, 1, 3, 5, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static step = function() { #region
		var _surf = getSingleValue(0);
		
		var _atlas = is_instanceof(_surf, SurfaceAtlas);
		inputs[| 5].setVisible(_atlas);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var scale = _data[1];
		var mode  = _data[2];
		var targ  = _data[3];
		var _atlS = _data[5];
		var cDep  = attrDepth();
		
		inputs[| 1].setVisible(mode == 0);
		inputs[| 3].setVisible(mode == 1);
		
		var isAtlas = is_instanceof(_data[0], SurfaceAtlas);
		if(isAtlas && !is_instanceof(_outSurf, SurfaceAtlas))
			_outSurf = _data[0].clone(true);
		var _surf = isAtlas? _outSurf.getSurface() : _outSurf;
		
		var ww, hh, scx = 1, scy = 1;
		switch(mode) {
			case 0 :
				scx = scale;
				scy = scale;
				ww	= scale * surface_get_width_safe(_data[0]);
				hh	= scale * surface_get_height_safe(_data[0]);
				break;
			case 1 : 
				scx = targ[0] / surface_get_width_safe(_data[0]);
				scy = targ[1] / surface_get_height_safe(_data[0]);
				ww	= targ[0];
				hh	= targ[1];
				break;
		}
		
		_surf = surface_verify(_surf, ww, hh, cDep);
		
		surface_set_shader(_surf);
		shader_set_interpolation(_data[0]);
		draw_surface_stretched_safe(_data[0], 0, 0, ww, hh);
		surface_reset_shader();
		
		if(isAtlas) {
			if(_atlS) {
				_outSurf.x = _data[0].x * scx;
				_outSurf.y = _data[0].y * scy;
			} else {
				_outSurf.x = _data[0].x;
				_outSurf.y = _data[0].y;
			}
			
			_outSurf.setSurface(_surf);
		} else 
			_outSurf = _surf;
		
		return _outSurf;
	}
}