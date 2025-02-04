// This code is bad.

//!#mfunc __error_diffuse {"args":["i"],"order":[0,0,0,0]}
#macro __error_diffuse_mf0  buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e0 * 
#macro __error_diffuse_mf1 ); _pl += 2; \
						  buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e1 * 
#macro __error_diffuse_mf2 ); _pl += 2; \
						  buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e2 * 
#macro __error_diffuse_mf3 ); _pl += 2; \
						  buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e3 * 
#macro __error_diffuse_mf4 ); _pl += 2; 

#macro __err_diffuse_write buffer_seek(_bi, buffer_seek_start, _p); 		\
		    	           var _o0 = buffer_read(_bi, buffer_s16);          \
		    	           var _o1 = buffer_read(_bi, buffer_s16);          \
		    	           var _o2 = buffer_read(_bi, buffer_s16);          \
		    	           var _o3 = buffer_read(_bi, buffer_s16);          \
		    	                                                            \
		    	           var _d0 = _o0 > 128? 255 : 0;                    \
		    	           var _d1 = _o1 > 128? 255 : 0;                    \
		    	           var _d2 = _o2 > 128? 255 : 0;                    \
		    	           var _d3 = _o3 > 128? 255 : 0;                    \
		    	                                                            \
		    	           var _e0 = _o0 - _d0;                             \
		    	           var _e1 = _o1 - _d1;                             \
		    	           var _e2 = _o2 - _d2;                             \
		    	           var _e3 = _o3 - _d3;                             \
		    	                                                            \
		    	           buffer_write(_bo, buffer_u8, _d0);               \
		    	           buffer_write(_bo, buffer_u8, _d1);               \
		    	           buffer_write(_bo, buffer_u8, _d2);               \
		    	           buffer_write(_bo, buffer_u8, _d3);

//!#mfunc __error_diffuse_grey {"args":["i"],"order":[0]}
#macro __error_diffuse_grey_mf0  buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e0 * 
#macro __error_diffuse_grey_mf1 ); _pl += 2; 

#macro __err_diffuse_write_grey buffer_seek(_bi, buffer_seek_start, _p); 	\
		    	           var _o0 = buffer_read(_bi, buffer_s16);          \
		    	                                                            \
		    	           var _d0 = _o0 > 128? 255 : 0;                    \
		    	           var _e0 = _o0 - _d0;                             \
		    	                                                            \
		    	           buffer_write(_bo, buffer_u8, _d0);               \
		    	           buffer_write(_bo, buffer_u8, _d0);               \
		    	           buffer_write(_bo, buffer_u8, _d0);               \
		    	           buffer_write(_bo, buffer_u8, 255);
		    	           
function Node_Dither_Diffuse(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
    name = "Error Diffuse Dither";
    
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Surface("Mask", self));
	
	newInput(2, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
	
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(1); // inputs 5, 6, 
	
	newInput(7, nodeValue_Enum_Scroll("Type", self, 0, { data: [ "Floyd-Steinberg", "Jarvis, Judice, and Ninke", "Atkinson", "Linear" ], update_hover: false }));
	
	newInput(8, nodeValueSeed(self));
	
	newInput(9, nodeValue_Bool("Greyscale", self, false));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 4, 8, 
		["Surfaces", true], 0, 1, 2, 5, 6, 
		["Dither",  false], 7, 9, 
	];
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
	    var _surf = _data[0];
	    var _type = _data[7];
	    var _seed = _data[8];
	    var _bw   = _data[9];
	    
	    if(!is_surface(_surf)) return _outSurf;
	    
	    #region buffer preparation
		    var _sw = surface_get_width(_surf);
		    var _sh = surface_get_height(_surf);
		    var _a  = _sw * _sh;
		    _outSurf = surface_verify(_outSurf, _sw, _sh);
		    
		    var _b  = buffer_from_surface(_surf, false);      buffer_to_start(_b);
		    var _bo = buffer_create(_a * 4, buffer_fixed, 1); buffer_to_start(_bo);
		    
		    if(_bw) {
		    	var _bi = buffer_create(_a * 2, buffer_fixed, 1); buffer_to_start(_bi);
			    
			    repeat(_a) {
			    	buffer_write(_bi, buffer_s16, buffer_read(_b, buffer_u8));
			    	buffer_seek(_b, buffer_seek_relative, 3);
			    }
			    
		    } else {
			    var _bi = buffer_create(_a * 8, buffer_fixed, 1); buffer_to_start(_bi);
			    
			    repeat(_a) {
			    	buffer_write(_bi, buffer_s16, buffer_read(_b, buffer_u8));
			    	buffer_write(_bi, buffer_s16, buffer_read(_b, buffer_u8));
			    	buffer_write(_bi, buffer_s16, buffer_read(_b, buffer_u8));
			    	buffer_write(_bi, buffer_s16, buffer_read(_b, buffer_u8));
			    }
		    }
		    
		    buffer_to_start(_b);
			buffer_to_start(_bi);
			buffer_to_start(_bo);
		#endregion
		
	    var _p = 0, _pl;
	    var _x = 0;
	    var _y = 0;
	    
	    if(_bw) {
	    	var _s = _sw * 2;
	    	
	    	if(_type == 0) { // Floyd-Steinberg
		    
			    var _k1 = 7 / 16, _k2 = 3 / 16, _k3 = 5 / 16, _k4 = 1 / 16;
		    	
			    repeat(_a) {
			    	__err_diffuse_write_grey
			    	
			    	if(_x < _sw - 1) { _pl = _p + 2; __error_diffuse_grey_mf0 _k1 __error_diffuse_grey_mf1 }
			    	
			    	if(_y < _sh - 1) {
			            if(_x > 0) {       _pl = _p + _s - 2; __error_diffuse_grey_mf0 _k2 __error_diffuse_grey_mf1 }
			                               _pl = _p + _s;     __error_diffuse_grey_mf0 _k3 __error_diffuse_grey_mf1
			    		if(_x < _sw - 1) { _pl = _p + _s + 2; __error_diffuse_grey_mf0 _k4 __error_diffuse_grey_mf1 }
			    	}
			    	
			    	_p += 2; _x++; if(_x >= _sw) { _x = 0; _y++; }
			    }
			    
		    } else if(_type == 1) { // Jarvis, Judice, and Ninke
		    
			    var _k1  = 7 / 48, _k2  = 5 / 48;
			    var _k3  = 3 / 48, _k4  = 1 / 48, _k5  = 7 / 48, _k6  = 5 / 48, _k7  = 3 / 48;
			    var _k8  = 1 / 48, _k9  = 3 / 48, _k10 = 5 / 48, _k11 = 3 / 48, _k12 = 1 / 48;
		    	
			    repeat(_a) {
			    	__err_diffuse_write_grey
			    	
			    	if(_x < _sw - 1) {
			    		                   _pl = _p + 2;  __error_diffuse_grey_mf0 _k1 __error_diffuse_grey_mf1
			    		if(_x < _sw - 2) { _pl = _p + 4;  __error_diffuse_grey_mf0 _k2 __error_diffuse_grey_mf1 }
			    	}
			    	
			    	if(_y < _sh - 1) {
			    		if(_x > 1) {       _pl = _p + _s - 4; __error_diffuse_grey_mf0 _k3 __error_diffuse_grey_mf1 }
			            if(_x > 0) {       _pl = _p + _s - 2; __error_diffuse_grey_mf0 _k4 __error_diffuse_grey_mf1 }
			    		                   _pl = _p + _s;     __error_diffuse_grey_mf0 _k5 __error_diffuse_grey_mf1
			    		if(_x < _sw - 1) { _pl = _p + _s + 2; __error_diffuse_grey_mf0 _k6 __error_diffuse_grey_mf1 }
			            if(_x < _sw - 2) { _pl = _p + _s + 4; __error_diffuse_grey_mf0 _k7 __error_diffuse_grey_mf1 }
			    	}
			    	
			    	if(_y < _sh - 2) {
			    		if(_x > 1) {       _pl = _p + _s * 2 - 4; __error_diffuse_grey_mf0 _k8 __error_diffuse_grey_mf1 }
			            if(_x > 0) {       _pl = _p + _s * 2 - 2; __error_diffuse_grey_mf0 _k9 __error_diffuse_grey_mf1 }
			    		                   _pl = _p + _s * 2;     __error_diffuse_grey_mf0 _k10 __error_diffuse_grey_mf1
			    		if(_x < _sw - 1) { _pl = _p + _s * 2 + 2; __error_diffuse_grey_mf0 _k11 __error_diffuse_grey_mf1 }
			            if(_x < _sw - 2) { _pl = _p + _s * 2 + 4; __error_diffuse_grey_mf0 _k12 __error_diffuse_grey_mf1 }
			    	}
			    	
			    	_p += 2; _x++; if(_x >= _sw) { _x = 0; _y++; }
			    }
			    
		    } else if(_type == 2) { // Atkinson
		    
			    var _k1  = 1 / 8;
			    
			    repeat(_a) {
			    	__err_diffuse_write_grey
			    	
			    	if(_x < _sw - 1) {
			    		                   _pl = _p + 2; __error_diffuse_grey_mf0 _k1 __error_diffuse_grey_mf1
			    		if(_x < _sw - 2) { _pl = _p + 4; __error_diffuse_grey_mf0 _k1 __error_diffuse_grey_mf1 }
			    	}
			    	
			    	if(_y < _sh - 1) {
			            if(_x > 0) {       _pl = _p + _s - 2; __error_diffuse_grey_mf0 _k1 __error_diffuse_grey_mf1 }
			    		                   _pl = _p + _s;     __error_diffuse_grey_mf0 _k1 __error_diffuse_grey_mf1
			    		if(_x < _sw - 1) { _pl = _p + _s + 2; __error_diffuse_grey_mf0 _k1 __error_diffuse_grey_mf1 }
			    	}
			    	
			    	if(_y < _sh - 2) {     _pl = _p + _s * 2; __error_diffuse_grey_mf0 _k1 __error_diffuse_grey_mf1 }
			    	
			    	_p += 2; _x++; if(_x >= _sw) { _x = 0; _y++; }
			    }
			    
		    } else if(_type == 3) { // Linear
		    	
			    repeat(_a) {
			    	__err_diffuse_write_grey
			    	
			    	if(_x < _sw - 1) { _pl = _p + 2; __error_diffuse_grey_mf0 1 __error_diffuse_grey_mf1 }
			    	
			    	_p += 2; _x++; if(_x >= _sw) { _x = 0; _y++; }
			    }
			    
		    } 
		    
	    } else {
	    	var _s = _sw * 8;
	    	
		    if(_type == 0) { // Floyd-Steinberg
		    
			    var _k1 = 7 / 16, _k2 = 3 / 16, _k3 = 5 / 16, _k4 = 1 / 16;
		    	
			    repeat(_a) {
			    	__err_diffuse_write
			    	
			    	if(_x < _sw - 1) { _pl = _p + 8; __error_diffuse_mf0 _k1 __error_diffuse_mf1 _k1 __error_diffuse_mf2 _k1 __error_diffuse_mf3 _k1 __error_diffuse_mf4 }
			    	
			    	if(_y < _sh - 1) {
			            if(_x > 0) {       _pl = _p + _s - 8; __error_diffuse_mf0 _k2 __error_diffuse_mf1 _k2 __error_diffuse_mf2 _k2 __error_diffuse_mf3 _k2 __error_diffuse_mf4 }
			                               _pl = _p + _s;     __error_diffuse_mf0 _k3 __error_diffuse_mf1 _k3 __error_diffuse_mf2 _k3 __error_diffuse_mf3 _k3 __error_diffuse_mf4
			    		if(_x < _sw - 1) { _pl = _p + _s + 8; __error_diffuse_mf0 _k4 __error_diffuse_mf1 _k4 __error_diffuse_mf2 _k4 __error_diffuse_mf3 _k4 __error_diffuse_mf4 }
			    	}
			    	
			    	_p += 8; _x++; if(_x >= _sw) { _x = 0; _y++; }
			    }
			    
		    } else if(_type == 1) { // Jarvis, Judice, and Ninke
		    
			    var _k1  = 7 / 48, _k2  = 5 / 48;
			    var _k3  = 3 / 48, _k4  = 1 / 48, _k5  = 7 / 48, _k6  = 5 / 48, _k7  = 3 / 48;
			    var _k8  = 1 / 48, _k9  = 3 / 48, _k10 = 5 / 48, _k11 = 3 / 48, _k12 = 1 / 48;
		    	
			    repeat(_a) {
			    	__err_diffuse_write
			    	
			    	if(_x < _sw - 1) {
			    		                   _pl = _p +  8;  __error_diffuse_mf0 _k1 __error_diffuse_mf1 _k1 __error_diffuse_mf2 _k1 __error_diffuse_mf3 _k1 __error_diffuse_mf4
			    		if(_x < _sw - 2) { _pl = _p + 16;  __error_diffuse_mf0 _k2 __error_diffuse_mf1 _k2 __error_diffuse_mf2 _k2 __error_diffuse_mf3 _k2 __error_diffuse_mf4 }
			    	}
			    	
			    	if(_y < _sh - 1) {
			    		if(_x > 1) {       _pl = _p + _s - 16; __error_diffuse_mf0 _k3 __error_diffuse_mf1 _k3 __error_diffuse_mf2 _k3 __error_diffuse_mf3 _k3 __error_diffuse_mf4 }
			            if(_x > 0) {       _pl = _p + _s -  8; __error_diffuse_mf0 _k4 __error_diffuse_mf1 _k4 __error_diffuse_mf2 _k4 __error_diffuse_mf3 _k4 __error_diffuse_mf4 }
			    		                   _pl = _p + _s;      __error_diffuse_mf0 _k5 __error_diffuse_mf1 _k5 __error_diffuse_mf2 _k5 __error_diffuse_mf3 _k5 __error_diffuse_mf4
			    		if(_x < _sw - 1) { _pl = _p + _s +  8; __error_diffuse_mf0 _k6 __error_diffuse_mf1 _k6 __error_diffuse_mf2 _k6 __error_diffuse_mf3 _k6 __error_diffuse_mf4 }
			            if(_x < _sw - 2) { _pl = _p + _s + 16; __error_diffuse_mf0 _k7 __error_diffuse_mf1 _k7 __error_diffuse_mf2 _k7 __error_diffuse_mf3 _k7 __error_diffuse_mf4 }
			    	}
			    	
			    	if(_y < _sh - 2) {
			    		if(_x > 1) {       _pl = _p + _s * 2 - 16; __error_diffuse_mf0 _k8 __error_diffuse_mf1 _k8 __error_diffuse_mf2 _k8 __error_diffuse_mf3 _k8 __error_diffuse_mf4 }
			            if(_x > 0) {       _pl = _p + _s * 2 -  8; __error_diffuse_mf0 _k9 __error_diffuse_mf1 _k9 __error_diffuse_mf2 _k9 __error_diffuse_mf3 _k9 __error_diffuse_mf4 }
			    		                   _pl = _p + _s * 2;      __error_diffuse_mf0 _k10 __error_diffuse_mf1 _k10 __error_diffuse_mf2 _k10 __error_diffuse_mf3 _k10 __error_diffuse_mf4
			    		if(_x < _sw - 1) { _pl = _p + _s * 2 +  8; __error_diffuse_mf0 _k11 __error_diffuse_mf1 _k11 __error_diffuse_mf2 _k11 __error_diffuse_mf3 _k11 __error_diffuse_mf4 }
			            if(_x < _sw - 2) { _pl = _p + _s * 2 + 16; __error_diffuse_mf0 _k12 __error_diffuse_mf1 _k12 __error_diffuse_mf2 _k12 __error_diffuse_mf3 _k12 __error_diffuse_mf4 }
			    	}
			    	
			    	_p += 8; _x++; if(_x >= _sw) { _x = 0; _y++; }
			    }
			    
		    } else if(_type == 2) { // Atkinson
		    
			    var _k1  = 1 / 8;
			    
			    repeat(_a) {
			    	__err_diffuse_write
			    	
			    	if(_x < _sw - 1) {
			    		                   _pl = _p +  8; __error_diffuse_mf0 _k1 __error_diffuse_mf1 _k1 __error_diffuse_mf2 _k1 __error_diffuse_mf3 _k1 __error_diffuse_mf4
			    		if(_x < _sw - 2) { _pl = _p + 16; __error_diffuse_mf0 _k1 __error_diffuse_mf1 _k1 __error_diffuse_mf2 _k1 __error_diffuse_mf3 _k1 __error_diffuse_mf4 }
			    	}
			    	
			    	if(_y < _sh - 1) {
			            if(_x > 0) {       _pl = _p + _s - 8; __error_diffuse_mf0 _k1 __error_diffuse_mf1 _k1 __error_diffuse_mf2 _k1 __error_diffuse_mf3 _k1 __error_diffuse_mf4 }
			    		                   _pl = _p + _s;     __error_diffuse_mf0 _k1 __error_diffuse_mf1 _k1 __error_diffuse_mf2 _k1 __error_diffuse_mf3 _k1 __error_diffuse_mf4
			    		if(_x < _sw - 1) { _pl = _p + _s + 8; __error_diffuse_mf0 _k1 __error_diffuse_mf1 _k1 __error_diffuse_mf2 _k1 __error_diffuse_mf3 _k1 __error_diffuse_mf4 }
			    	}
			    	
			    	if(_y < _sh - 2) {     _pl = _p + _s * 2; __error_diffuse_mf0 _k1 __error_diffuse_mf1 _k1 __error_diffuse_mf2 _k1 __error_diffuse_mf3 _k1 __error_diffuse_mf4 }
			    	
			    	_p += 8; _x++; if(_x >= _sw) { _x = 0; _y++; }
			    }
			    
		    } else if(_type == 3) { // Linear
		    	
			    repeat(_a) {
			    	__err_diffuse_write
			    	
			    	if(_x < _sw - 1) { _pl = _p + 8; __error_diffuse_mf0 1 __error_diffuse_mf1 1 __error_diffuse_mf2 1 __error_diffuse_mf3 1 __error_diffuse_mf4 }
			    	
			    	_p += 8; _x++; if(_x >= _sw) { _x = 0; _y++; }
			    }
			    
		    } 
	    }
	    
	    buffer_set_surface(_bo, _outSurf, 0);
	    buffer_delete(_b);
	    buffer_delete(_bi);
	    buffer_delete(_bo);
	    
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf; 
	}
}