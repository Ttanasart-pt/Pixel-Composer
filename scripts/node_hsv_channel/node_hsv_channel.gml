function Node_HSV_Channel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "HSV Extract";
	
	newInput(0, nodeValue_Surface( "Surface In",   self));
	newInput(1, nodeValue_Bool(    "Output Array", self, false));
	
	newOutput(0, nodeValue_Output("Hue",        self, VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Saturation", self, VALUE_TYPE.surface, noone));
	newOutput(2, nodeValue_Output("Value",      self, VALUE_TYPE.surface, noone));
	newOutput(3, nodeValue_Output("Alpha",      self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	shaders = [
		sh_channel_H,
		sh_channel_S,
		sh_channel_V,
		sh_channel_A
	]
	
	static processData = function(_outData, _data, output_index) {
		var _surf = _data[0];
		var _arr  = _data[1];
		
		outputs[0].name = _arr? "HSV" : "Hue";
		outputs[0].setArrayDepth(_arr);
		
		outputs[1].setVisible(!_arr, !_arr);
		outputs[2].setVisible(!_arr, !_arr);
		outputs[3].setVisible(!_arr, !_arr);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		var _odata = _arr? _outData[0] : _outData;
		
		for( var i = 0; i < 4; i++ ) {
			var _osurf = array_safe_get_fast(_odata, i);
			    _osurf = surface_verify(_osurf, _sw, _sh);
			_odata[i] = _osurf;
			
			surface_set_shader(_osurf, shaders[i]);
				draw_surface_safe(_surf);
			surface_reset_shader();
		}
		
		if(_arr) {
			_outData[0] = _odata;
			
		} else {
			_outData[0] = _odata[0];
			_outData[1] = _odata[1];
			_outData[2] = _odata[2];
			_outData[3] = _odata[3];
		}
		
		return _outData;
	}
}