function Node_PB_Box_Split(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "PBBox Split";
	color = COLORS.node_blend_feedback;
	setDimension(96, 48);
	
	////- Layout
	newInput(0, nodeValue_Pbbox());
	
	////- Split
	newInput(1, nodeValue_EButton( "Axis",    0, [ "X", "Y" ]         ));
	newInput(2, nodeValue_EButton( "Anchor",  0, [ "Start", "End" ]   ));
	newInput(3, nodeValue_EButton( "Unit",    0, [ "Ratio", "Pixel" ] ));
	newInput(4, nodeValue_Slider(  "Ratio",  .5 ));
	newInput(5, nodeValue_Int(     "Size",    4 ));
	// 6
	
	newOutput(0, nodeValue_Output("PBBOX", VALUE_TYPE.pbBox, noone));
	newOutput(1, nodeValue_Output("PBBOX", VALUE_TYPE.pbBox, noone));
	
	input_display_list = [
		["Layout", false], 0, 
		["Split",  false], 1, 2, 3, 4, 5, 
	]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pbase = getSingleValue(0);
		
		if(is(_pbase, __pbBox)) {
			draw_set_color(COLORS._main_icon_light);
			_pbase.drawOverlayBBOX(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
		}
		
		var _pbres = getSingleValue(0,, true);
		if(is(_pbres, __pbBox)) _pbres.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
		
		var _pbres = getSingleValue(1,, true);
		if(is(_pbres, __pbBox)) _pbres.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim   = group.dimension;
		var _pbbox = _data[0];
		var _axis  = _data[1];
		var _anch  = _data[2];
		var _unit  = _data[3];
		var _rato  = _data[4];
		var _pixl  = _data[5];
		
		inputs[4].setVisible(_unit == 0);
		inputs[5].setVisible(_unit == 1);
		
		if(inputs[0].value_from == noone) _pbbox.base_bbox = [ 0, 0, _dim[0], _dim[1] ];
		var _bbox = _pbbox.getBBOX();
		var _box0, _box1;
		
		var _ww = _bbox[2] - _bbox[0];
	    var _hh = _bbox[3] - _bbox[1];
		    
		if(_axis == 0) {
		    var _bw = _unit? _pixl : floor(_ww * _rato);
		    if(_anch) _bw = _ww - _bw;
		    
			_box0 = [ _bbox[0],       _bbox[1], 
			          _bbox[0] + _bw, _bbox[3] ];
			
			_box1 = [ _bbox[0] + _bw, _bbox[1], 
			          _bbox[2],       _bbox[3] ];
			
		} else {
			var _bh = _unit? _pixl : floor(_hh * _rato);
		    if(_anch) _bh = _hh - _bh;
		    
			_box0 = [ _bbox[0], _bbox[1], 
			          _bbox[2], _bbox[1] + _bh ];
			
			_box1 = [ _bbox[0], _bbox[1] + _bh, 
			          _bbox[2], _bbox[3] ];
			
		}
		
		var _pbox0 = _pbbox.clone().setBBOX(_box0);
		var _pbox1 = _pbbox.clone().setBBOX(_box1);
		
		return [ _pbox0, _pbox1 ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_fit(s_node_pb_box_split, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
}