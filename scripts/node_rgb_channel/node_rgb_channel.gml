function Node_RGB_Channel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RGBA Extract";
	
	newInput(0, nodeValue_Surface(     "Surface In",   self));
	newInput(1, nodeValue_Enum_Scroll( "Output Type",  self, 0, [ "Channel value", "Greyscale" ]));
	newInput(2, nodeValue_Bool(        "Keep Alpha",   self, false));
	newInput(3, nodeValue_Bool(        "Output Array", self, false));
	
	newOutput(0, nodeValue_Output("Red",   self, VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Green", self, VALUE_TYPE.surface, noone));
	newOutput(2, nodeValue_Output("Blue",  self, VALUE_TYPE.surface, noone));
	newOutput(3, nodeValue_Output("Alpha", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static getShader = function(index, grey) {
		switch(index) {
			case 0 : return grey? sh_channel_R_grey : sh_channel_R;
			case 1 : return grey? sh_channel_G_grey : sh_channel_G;
			case 2 : return grey? sh_channel_B_grey : sh_channel_B;
			case 3 : return grey? sh_channel_A_grey : sh_channel_A;
		}
		
		return noone;
	}
	
	static processData = function(_outData, _data, output_index) {
		var _surf = _data[0];
		var _grey = _data[1];
		var _alp  = _data[2];
		var _arr  = _data[3];
		
		outputs[0].name = _arr? "RGBA" : "Red";
		outputs[0].setArrayDepth(_arr);
		
		outputs[1].setVisible(!_arr, !_arr);
		outputs[2].setVisible(!_arr, !_arr);
		outputs[3].setVisible(!_arr, !_arr);
		
		var _ww = surface_get_width_safe(_surf);
		var _hh = surface_get_height_safe(_surf);
		var _odata = _arr? _outData[0] : _outData;
		
		for( var i = 0; i < 4; i++ ) {
			var _osurf = array_safe_get_fast(_odata, i);
			    _osurf = surface_verify(_osurf, _ww, _hh);
			_odata[i] = _osurf;
			
			surface_set_shader(_osurf, getShader(i, _grey));
				shader_set_i("keepAlpha", _alp);
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