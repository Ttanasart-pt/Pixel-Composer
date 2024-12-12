function Node_Dither_Diffuse(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
    name = "Error Diffuse Dither";
    
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Surface("Mask", self));
	
	newInput(2, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
	
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(1); // inputs 5, 6, 
	
	newInput(7, nodeValue_Enum_Scroll("Type", self, 0, [ "Floyd-Steinberg" ]));
	
	newInput(8, nodeValueSeed(self));
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 4, 8, 
		["Surfaces", true], 0, 1, 2, 5, 6, 
		["Dither",  false], 7, 
	];
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
	    var _surf = _data[0];
	    var _type = _data[7];
	    var _seed = _data[8];
	    
	    if(!is_surface(_surf)) return _outSurf;
	    
	    var _sw = surface_get_width(_surf);
	    var _sh = surface_get_height(_surf);
	    var _a  = _sw * _sh;
	    _outSurf = surface_verify(_outSurf, _sw, _sh);
	    
	    var _b  = buffer_from_surface(_surf, false);      buffer_to_start(_b);
	    var _bi = buffer_create(_a * 8, buffer_fixed, 1); buffer_to_start(_bi);
	    var _bo = buffer_create(_a * 4, buffer_fixed, 1); buffer_to_start(_bo);
	    
	    repeat(_a) {
	    	buffer_write(_bi, buffer_s16, buffer_read(_b, buffer_u8));
	    	buffer_write(_bi, buffer_s16, buffer_read(_b, buffer_u8));
	    	buffer_write(_bi, buffer_s16, buffer_read(_b, buffer_u8));
	    	buffer_write(_bi, buffer_s16, buffer_read(_b, buffer_u8));
	    }
	    
	    buffer_to_start(_b);
		buffer_to_start(_bi);
		buffer_to_start(_bo);

	    var _i  = 0;
	    var _p  = 0;
	    var _x  = 0;
	    var _y  = 0;
	    
	    var _k1 = 7 / 16;
	    var _k2 = 3 / 16;
	    var _k3 = 5 / 16;
	    var _k4 = 1 / 16;
    	
	    repeat(_a) {
	    	var _prop_l = _x > 0;
	    	var _prop_r = _x < _sw - 1;
	    	var _prop_d = _y < _sh - 1;
	    	
	    	buffer_seek(_bi, buffer_seek_start, _p * 2);
	    	var _o0 = buffer_read(_bi, buffer_s16);
	    	var _o1 = buffer_read(_bi, buffer_s16);
	    	var _o2 = buffer_read(_bi, buffer_s16);
	    	var _o3 = buffer_read(_bi, buffer_s16);
	    	
	    	var _d0 = _o0 > 128? 255 : 0;
	    	var _d1 = _o1 > 128? 255 : 0;
	    	var _d2 = _o2 > 128? 255 : 0;
	    	var _d3 = _o3 > 128? 255 : 0;
	    	
	    	var _e0 = _o0 - _d0;
	    	var _e1 = _o1 - _d1;
	    	var _e2 = _o2 - _d2;
	    	var _e3 = _o3 - _d3;
	    	
	    	buffer_write(_bo, buffer_u8, _d0);
	    	buffer_write(_bo, buffer_u8, _d1);
	    	buffer_write(_bo, buffer_u8, _d2);
	    	buffer_write(_bo, buffer_u8, _d3);
	    	
	    	if(_prop_r) {
	    		var _pl = _p * 2 + 8;
	    		
	    		buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e0 * _k1); _pl += 2;
	    		buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e1 * _k1); _pl += 2;
	    		buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e2 * _k1); _pl += 2;
	    		buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e3 * _k1); _pl += 2;
	    	}
	    	
	    	if(_prop_d) {
	    		var _pl = _p * 2 + _sw * 8;
	            
	    		if(_prop_l) {
	    			_pl -= 8;
	    			
	    			buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e0 * _k2); _pl += 2;
	    			buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e1 * _k2); _pl += 2;
	    			buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e2 * _k2); _pl += 2;
	    			buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e3 * _k2); _pl += 2;
	    		}
	            
	            buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e0 * _k3); _pl += 2;
	            buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e1 * _k3); _pl += 2;
	            buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e2 * _k3); _pl += 2;
	            buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e3 * _k3); _pl += 2;
	            
	    		if(_prop_r) {
	    			buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e0 * _k4); _pl += 2;
		            buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e1 * _k4); _pl += 2;
		            buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e2 * _k4); _pl += 2;
		            buffer_poke(_bi, _pl, buffer_s16, buffer_peek(_bi, _pl, buffer_s16) + _e3 * _k4); _pl += 2;
	    		}
	    	}
	    	
	    	_p += 4;
	    	
	    	_x++;
	    	if(_x >= _sw) {
	    		_x = 0;
	    		_y++;
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