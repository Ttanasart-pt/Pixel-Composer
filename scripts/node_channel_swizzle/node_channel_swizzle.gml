function Node_Channel_Swizzle(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Channel Swizzle";
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In")).setRequired();
	
	////- =Output
	newInput( 1, nodeValue_Text( "Channel", "RGBA" )).setTooltip(@"Text controlling which input channel to place to output:
	- R: Red
	- G: Green
	- B: Blue
	- A: Alpha
	- 0/1: Fixed value");
	// 2
	
	newOutput( 0, nodeValue_Output( "Surface Out",   VALUE_TYPE.surface, noone ));
	
	input_display_list = [
		[ "Surface", false ], 0,
		[ "Output",  false ], 1, 
	]
	
	////- Node
	
	attribute_surface_depth();
	
	function getChannel(_chr) {
		switch(_chr) {
			case "r": case "R": return 0;
			case "g": case "G": return 1;
			case "b": case "B": return 2;
			case "a": case "A": return 3;
		}
		
		return 10 + toNumber(_chr);
	}
	
	static processData = function(_outSurf, _data, output_index) {
		#region data
			var _surf = _data[ 0];
			
			var _chan = _data[ 1];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _ww = surface_get_width_safe(_surf);
		var _hh = surface_get_height_safe(_surf);
		_outSurf = surface_verify(_outSurf, _ww, _hh);
		
		var _clen  = string_length(_chan);
		var _red   = _clen >= 1? getChannel(string_char_at(_chan, 1)) : 0;
		var _green = _clen >= 2? getChannel(string_char_at(_chan, 2)) : 1;
		var _blue  = _clen >= 3? getChannel(string_char_at(_chan, 3)) : 2;
		var _alpha = _clen >= 4? getChannel(string_char_at(_chan, 4)) : 3;
		
		surface_set_shader(_outSurf, sh_channel_swizzle);
			shader_set_i( "red",   _red   );
			shader_set_i( "green", _green );
			shader_set_i( "blue",  _blue  );
			shader_set_i( "alpha", _alpha );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	}
}