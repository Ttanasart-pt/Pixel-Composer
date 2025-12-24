function Node_PB_Draw_Surface(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "PB Draw Surface";
	color = COLORS.node_blend_feedback;
	
	////- =Layout
	newInput(0, nodeValue_Pbbox("Base PBBOX" )).setWidget(noone);
	newInput(1, nodeValue_Pbbox("PBBOX"      ));
	
	////- =Override
	newInput(2, nodeValue_Float("PBBOX Left",   0 ));
	newInput(3, nodeValue_Float("PBBOX Top",    0 ));
	newInput(4, nodeValue_Float("PBBOX Right",  0 ));
	newInput(5, nodeValue_Float("PBBOX Bottom", 0 ));
	newInput(6, nodeValue_Float("PBBOX Width",  0 ));
	newInput(7, nodeValue_Float("PBBOX Height", 0 ));
	
	////- =Surface
	newInput(8, nodeValue_Surface( "Surface" ));
	newInput(9, nodeValue_Bool(    "Crop"    ));
	// 10
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Layout",         false], 0, 1, 
		["Layout Override", true], 2, 3, 4, 5, 
		["Surface",        false], 8, 9, 
	]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pbbox = getInputSingle(1);
		if(is(_pbbox, __pbBox)) _pbbox.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
	    var _dim   = group.dimension;
		var _pbase = _data[0];
		var _pbbox = _data[1];
		var _surf  = _data[8];
		var _crop  = _data[9];
		
		var _sdim = surface_get_dimension(_surf);
		
		if(inputs[0].value_from == noone) _pbase.base_bbox = [ 0, 0, _dim[0], _dim[1] ];
		if(inputs[2].value_from != noone || inputs[2].is_anim) _pbbox.anchor_l = _data[2];
		if(inputs[3].value_from != noone || inputs[3].is_anim) _pbbox.anchor_t = _data[3];
		if(inputs[4].value_from != noone || inputs[4].is_anim) _pbbox.anchor_r = _data[4];
		if(inputs[5].value_from != noone || inputs[5].is_anim) _pbbox.anchor_b = _data[5];
		
		_pbbox.base_bbox = is(_pbase, __pbBox)? _pbase.getBBOX() : [ 0, 0, _dim[0], _dim[1] ];
		_pbbox.anchor_w_fract = false;
        _pbbox.anchor_h_fract = false;
		_pbbox.anchor_w = _sdim[0];
		_pbbox.anchor_h = _sdim[1];
		
		var _bbox = _pbbox.getBBOX();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		surface_set_shader(_outSurf);
			var _scis = gpu_get_scissor();
			if(_crop) gpu_set_scissor(_bbox[0], _bbox[1], _bbox[2], _bbox[3]);
			
		    draw_surface_safe(_surf, _bbox[0], _bbox[1])
			gpu_set_scissor(_scis);
		surface_reset_target();
		
		return _outSurf;
	}
}