function Node_Recursive_Subdiv(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Recursive Subdivision";
	
	newInput(0, nodeValueSeed(self));
	
	////- Output
	
	newInput(1, nodeValue_Dimension(self));
	
	////- Pattern
	
	newInput( 2, nodeValue_Rotation(     "Phase",      self, 0));
	newInput( 3, nodeValue_Int(          "Iteration",  self, 2));
	newInput(13, nodeValue_Slider_Range( "SubD Range", self, [ .1, .9 ]));
	
	////- Render
	
	newInput(4, nodeValue_Enum_Button(  "Color Source", self, 0, [ "Palette", "Random HSV" ]));
	newInput(9, nodeValueSeed(self, VALUE_TYPE.integer, "Color Seed"));
	newInput(5, nodeValue_Palette(      "Palette",      self, array_clone(DEF_PALETTE)));
	newInput(6, nodeValue_Slider_Range( "H Range",      self, [0, 255], [ 0, 255, 1 ]));
	newInput(7, nodeValue_Slider_Range( "S Range",      self, [0, 255], [ 0, 255, 1 ]));
	newInput(8, nodeValue_Slider_Range( "V Range",      self, [0, 255], [ 0, 255, 1 ]));
	
	////- Gap
	
	newInput(10, nodeValue_Bool(  "Render Gap",    self, true));
	newInput(11, nodeValue_Color( "Gap Color",     self, ca_black));
	newInput(12, nodeValue_Int(   "Gap Thickness", self, 1));
	
	/// inputs 14
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Output",  false], 1, 
		["Pattern", false], 2, 3, 13, 
		["Render",  false], 4, 9, 5, 6, 7, 8, 
		["Gap",     false, 10], 11, 12, 
	];
	
	phase    = 0;
	subRange = [ 0, 1 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static subD = function(_box) {
		var _l0 = lerp(subRange[0], subRange[1], dsin(phase + random(360)) / 2 + .5);
		var _l1 = lerp(subRange[0], subRange[1], dsin(phase + random(360)) / 2 + .5);
		var _l2 = lerp(subRange[0], subRange[1], dsin(phase + random(360)) / 2 + .5);
		
		var xx = _box[0];
		var yy = _box[1];
		var ww = _box[2];
		var hh = _box[3];
		
		var _ax = choose(0, 1);
		
		if(_ax == 0) {
			var _w  = round(ww * _l0); var _iw  = ww * (1 - _l0);
			var _h0 = round(hh * _l1); var _ih0 = hh * (1 - _l1);
			var _h1 = round(hh * _l2); var _ih1 = hh * (1 - _l2);
			
			return [
				[
					[ xx,      yy,        _w, _h0  ], 
					[ xx,      yy + _h0,  _w, _ih0 ], 
					[ xx + _w, yy,       _iw, _h1  ], 
					[ xx + _w, yy + _h1, _iw, _ih1 ], 
				], 
				[
					[ xx + _w, yy - 1,   xx + _w, yy +  hh ],
					[ xx - 1,  yy + _h0, xx + _w, yy + _h0 ],
					[ xx + _w, yy + _h1, xx + ww, yy + _h1 ],
				]
			];
			
		} else {
			var _h  = round(hh * _l0); var _ih  = hh * (1 - _l0);
			var _w0 = round(ww * _l1); var _iw0 = ww * (1 - _l1);
			var _w1 = round(ww * _l2); var _iw1 = ww * (1 - _l2);
			
			return [
				[
					[ xx,       yy,      _w0,  _h  ], 
					[ xx + _w0, yy,      _iw0, _h  ], 
					[ xx,       yy + _h, _w1,  _ih ], 
					[ xx + _w1, yy + _h, _iw1, _ih ], 
				], 
				[
					[ xx - 1,   yy + _h, xx +  ww, yy + _h ],
					[ xx + _w0, yy - 1,  xx + _w0, yy + _h ],
					[ xx + _w1, yy + _h, xx + _w1, yy + hh ],
				]
			];
		} 
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { 
		var _sed = _data[0];
		
		var _dim = _data[1];
		
		phase    = _data[ 2];
		var _itr = _data[ 3]; _itr = clamp(_itr, 1, 5);
		subRange = _data[13];
		
		var _csrc = _data[4];
		var _csed = _data[9];
		var _palt = _data[5];
		var _rngH = _data[6];
		var _rngS = _data[7];
		var _rngV = _data[8];
		
		var _gapU = _data[10];
		var _gapC = _data[11];
		var _gapT = _data[12];
		
		inputs[5].setVisible(_csrc == 0);
		inputs[6].setVisible(_csrc == 1);
		inputs[7].setVisible(_csrc == 1);
		inputs[8].setVisible(_csrc == 1);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1])
		random_set_seed(_sed);
		
		var _boxes = [[ 0, 0, _dim[0], _dim[1]]];
		var _lines = [];
		
		repeat(_itr) {
			var _newBoxes = [];
			
			for( var i = 0, n = array_length(_boxes); i < n; i++ ) {
				var _subBoxes = subD(_boxes[i])
				array_append(_newBoxes, _subBoxes[0]);
				array_append(_lines,    _subBoxes[1]);
			}
			
			_boxes = _newBoxes;
		}
		
		surface_set_shader(_outSurf, noone);
			random_set_seed(_sed + _csed);
			
			for( var i = 0, n = array_length(_boxes); i < n; i++ ) {
				var _b = _boxes[i];
				
				switch(_csrc) {
					case 0 :
						draw_set_color(array_safe_get(_palt, irandom(array_length(_palt) - 1), ca_black));
						break;
						
					case 1 :
						draw_set_color(make_color_hsv(
							irandom_range(_rngH[0], _rngH[1]),
							irandom_range(_rngS[0], _rngS[1]),
							irandom_range(_rngV[0], _rngV[1]),
						));
						break;
				}
				
				draw_rectangle(_b[0], _b[1], _b[0] + _b[2], _b[1] + _b[3], false);
			}
			
			if(_gapU)
			for( var i = 0, n = array_length(_lines); i < n; i++ ) {
				var _l = _lines[i];
				
				draw_set_color(_gapC);
				draw_line_width(_l[0], _l[1], _l[2], _l[3], _gapT);
			}
		surface_reset_shader();
		
		return _outSurf; 
	}
}