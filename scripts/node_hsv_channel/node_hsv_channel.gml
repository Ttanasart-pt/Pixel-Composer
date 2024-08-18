function Node_HSV_Channel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "HSV Extract";
	batch_output = false;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Output Array", self, false));
	
	outputs[0] = nodeValue_Output("Hue",        self, VALUE_TYPE.surface, noone);
	outputs[1] = nodeValue_Output("Saturation", self, VALUE_TYPE.surface, noone);
	outputs[2] = nodeValue_Output("Value",      self, VALUE_TYPE.surface, noone);
	outputs[3] = nodeValue_Output("Alpha",      self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { #region
		var _arr = getInputData(1);
		
		outputs[0].name = _arr? "HSV" : "Hue";
		outputs[0].setArrayDepth(_arr);
		
		outputs[1].setVisible(!_arr, !_arr);
		outputs[2].setVisible(!_arr, !_arr);
		outputs[3].setVisible(!_arr, !_arr);
	} #endregion
	
	static setShader = function(index) {
		DRAW_CLEAR
		BLEND_OVERRIDE
				
		switch(index) {
			case 0 : shader_set(sh_channel_H); break;
			case 1 : shader_set(sh_channel_S); break;
			case 2 : shader_set(sh_channel_V); break;
			case 3 : shader_set(sh_channel_A); break;
		}
	}
	
	static resetShader = function() {
		shader_reset();
		BLEND_NORMAL
	}
	
	static processData = function(_outSurf, _data, output_index) { #region
		var _arr = _data[1];
		if(_arr && output_index) return _outSurf;
		
		if(_arr) {
			for( var i = 0; i < 4; i++ ) {
				var _surf = array_safe_get_fast(_outSurf, i);
				    _surf = surface_verify(_surf, _ww, _hh);
				_outSurf[i] = _surf;
				
				surface_set_target(_surf);
					setShader(i);
					draw_surface_safe(_data[0]);
					resetShader();
				surface_reset_target();
			}
			
		} else {
			surface_set_target(_outSurf);
				setShader(output_index);
				draw_surface_safe(_data[0]);
				resetShader();
			surface_reset_target();
		}
		
		return _outSurf;
	} #endregion
}