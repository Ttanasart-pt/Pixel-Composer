function Node_RGB_Channel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RGBA Extract";
	batch_output = false;
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Enum_Scroll("Output Type", self,  0, [ "Channel value", "Greyscale" ]));
		
	newInput(2, nodeValue_Bool("Keep Alpha", self, false));
	
	newInput(3, nodeValue_Bool("Output Array", self, false));
	
	outputs[0] = nodeValue_Output("Red",   self, VALUE_TYPE.surface, noone);
	outputs[1] = nodeValue_Output("Green", self, VALUE_TYPE.surface, noone);
	outputs[2] = nodeValue_Output("Blue",  self, VALUE_TYPE.surface, noone);
	outputs[3] = nodeValue_Output("Alpha", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { #region
		var _arr = getInputData(3);
		
		outputs[0].name = _arr? "RGBA" : "Red";
		outputs[0].setArrayDepth(_arr);
		
		outputs[1].setVisible(!_arr, !_arr);
		outputs[2].setVisible(!_arr, !_arr);
		outputs[3].setVisible(!_arr, !_arr);
	} #endregion
	
	static setShader = function(index, grey, _alp) {
		DRAW_CLEAR
		BLEND_OVERRIDE
				
		switch(index) {
			case 0 : shader_set(grey? sh_channel_R_grey : sh_channel_R); break;
			case 1 : shader_set(grey? sh_channel_G_grey : sh_channel_G); break;
			case 2 : shader_set(grey? sh_channel_B_grey : sh_channel_B); break;
			case 3 : shader_set(grey? sh_channel_A_grey : sh_channel_A); break;
		}
		
		shader_set_i("keepAlpha", _alp);
	}
	
	static resetShader = function() {
		shader_reset();
		BLEND_NORMAL
	}
	
	static processData = function(_outSurf, _data, output_index) { #region
		var _out = _data[1];
		var _alp = _data[2];
		var _arr = _data[3];
		
		if(_arr && output_index) return _outSurf;
		
		var _ww = surface_get_width_safe(_data[0]);
		var _hh = surface_get_height_safe(_data[0]);
		
		if(_arr) {
			for( var i = 0; i < 4; i++ ) {
				var _surf = array_safe_get_fast(_outSurf, i);
				    _surf = surface_verify(_surf, _ww, _hh);
				_outSurf[i] = _surf;
				
				surface_set_target(_surf);
					setShader(i, _out, _alp);
					draw_surface_safe(_data[0]);
					resetShader();
				surface_reset_target();
			}
			
		} else {
			surface_set_target(_outSurf);
				setShader(output_index, _out, _alp);
				draw_surface_safe(_data[0]);
				resetShader();
			surface_reset_target();
		}
		
		return _outSurf;
	} #endregion
}