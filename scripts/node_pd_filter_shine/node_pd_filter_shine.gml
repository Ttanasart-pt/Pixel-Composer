function Node_PB_FX_Shine(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shine";
	
	newInput( 0, nodeValue_Surface( "Surface" ));
	newInput( 1, nodeValue_Surface( "Mask"    ));
	
	////- =Shine
	newInput( 8, nodeValue_EButton( "Axis",      0, [ "X", "Y" ]  ));
	newInput( 5, nodeValue_Slider(  "Progress", .5      ));
	newInput( 4, nodeValue_Float(   "Shines",   [2,1,1] )).setDisplay(VALUE_DISPLAY.number_array);
	newInput( 9, nodeValue_Float(   "Scale",     1      ));
	newInput( 6, nodeValue_Float(   "Slope",     1      ));
	newInput( 3, nodeValue_Bool(    "Flip",      false  ));
	
	////- =Render
	newInput( 2, nodeValue_Palette( "Colors",     [ca_white] ));
	newInput(10, nodeValue_EScroll( "Blend Mode", 0, [ "Normal", "Additive", "Multiply" ] ));
	newInput( 7, nodeValue_Slider(  "Intensity",  1          ));
	// input 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surface", false ],  0,  1, 
	    [ "Shine",   false ],  8,  5,  4,  9,  6,  3, 
	    [ "Render",  false ],  2, 10,  7, 
    ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
		    var _surf  = _data[ 0];
		    var _mask  = _data[ 1];
		    
		    var _invx  = _data[ 8];
		    var _progr = _data[ 5];
		    var _shine = _data[ 4];
		    var _scale = _data[ 9];
		    var _slope = _data[ 6];
		    var _inver = _data[ 3];
		    
		    var _color = _data[ 2];
		    var _blend = _data[10];
		    var _ints  = _data[ 7];
	    #endregion
	    
	    var _useSurf = is_surface(_surf);
	    var _dim     = _useSurf? surface_get_dimension(_surf) : getDimension();
	    
	    surface_set_shader(_outSurf, sh_pb_fx_shine);
	        shader_set_2("dimension",   _dim);
	        shader_set_i("useSurf",     _useSurf);
	        
	        shader_set_i("useMask",     is_surface(_mask));
	        shader_set_s("mask",        _mask );
	        
            shader_set_i("invAxis",     _invx  );
            shader_set_f("progress",    _progr );
            shader_set_i("side",        _inver );
            
            shader_set_f("shines",      _shine );
            shader_set_i("shineAmount", array_length(_shine) );
            shader_set_f("shinesWidth", array_sum(_shine)    );
            
            shader_set_f("scale",       _scale);
            shader_set_f("slope",       _slope);
            shader_set_i("straight",    _slope == 0);
            
            shader_set_palette( _color, "shineColor", "shineColorAmo" );
            shader_set_i("blendMode",   _blend );
            shader_set_f("intensity",   _ints  );
			
			if(_useSurf) draw_surface_safe(_surf);
			else draw_empty();
	    surface_reset_shader();
	    
	    return _outSurf; 
	}
}