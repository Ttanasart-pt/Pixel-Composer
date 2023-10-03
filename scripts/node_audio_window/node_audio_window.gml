function Node_Audio_Window(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Audio Window";
	previewable = false;
	
	w = 128;
	h = 128;
	min_h = h;
	
	inputs[| 0] = nodeValue("Audio data", self, JUNCTION_CONNECT.input, VALUE_TYPE.audioBit, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 64, "Amount of bits to extract.");
	
	inputs[| 2] = nodeValue("Location", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY._default, { unit: 0, side_button: button(function() { 
					inputs[| 2].display_data.unit = (inputs[| 2].display_data.unit + 1) % 3; 
					inputs[| 2].display_data.side_button.tooltip.index = inputs[| 2].display_data.unit; 
					update();
				}).setTooltip( new tooltipSelector("Unit", [ "Bit", "Second", "Progress" ]) ) 
				  .setIcon( THEME.unit_audio, function() { return inputs[| 2].display_data.unit; }, COLORS._main_icon )
			}
		);
		
	inputs[| 3] = nodeValue("Cursor location", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Start", "Middle", "End" ]);
	
	inputs[| 4] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[| 5] = nodeValue("Match animation", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Set window cursor to match animation timeline.");
	
	outputs[| 0] = nodeValue("Bit Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setArrayDepth(1);
		
	input_display_list = [ 0, 
		["Window",	false], 1, 5, 2, 3, 4, 
	];
	
	preview_cr = 0;
	preview_st = 0;
	preview_ed = 0;
	
	static step = function() {
		var _anim = getInputData(5);
		
		inputs[| 2].setVisible(!_anim);
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _aud = getInputData(0);
		if(!is_instanceof(_aud, audioObject)) return;
		
		var _wid  = getInputData(1);
		var _loc  = getInputData(2);
		var _cloc = getInputData(3);
		var _stp  = getInputData(4);	_stp = max(1, _stp);
		var _anim = getInputData(5);
		
		var _unit = inputs[| 2].display_data.unit;
		var off = 0, st = 0, ed = 1, len = 1;
		var _ch = _aud.getChannel();
		
		if(_anim) off = frame / PROJECT.animator.framerate * _aud.sample;
		else {
			switch(_unit) {
				case 0 : off = _loc;								break;
				case 1 : off = _loc * _aud.sample;					break;
				case 2 : off = _loc * _aud.duration * _aud.sample;	break;
			}
		}
		
		switch(_cloc) {
			case 0 : st = off;					 break;
			case 1 : st = off - round(_wid / 2); break;
			case 2 : st = off - _wid;			 break;
		}
		
		ed = st + _wid;
		st = clamp(st, 0, _aud.packet - 1);
		ed = clamp(ed, 0, _aud.packet - 1);
		len = (ed - st) / _stp;
		
		preview_cr = off / _aud.packet;
		preview_st = st / _aud.packet;
		preview_ed = ed / _aud.packet;
		
		var res = array_create(_ch);
		var dat = _aud.getData();
		
		for( var i = 0; i < _ch; i++ ) {
			var _dat = dat[i];
			var _ind = 0;
			
			res[i] = array_create(len);
			
			for(var j = st; j < ed; j += _stp)
				res[i][_ind++] = _dat[j];
		}
		
		outputs[| 0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var _aud = getInputData(0);
		if(!is_instanceof(_aud, audioObject)) return;
		
		var bbox = drawGetBbox(xx, yy, _s);
		var surf = _aud.checkPreview(320, 128);
		
		if(!is_surface(surf)) return;
		
		var sw = surface_get_width_safe(surf);
		var sh = surface_get_height_safe(surf);
		var ss = min(bbox.w / sw, bbox.h / sh);
		
		var dx = bbox.xc - sw * ss / 2;
		var dy = bbox.yc - sh * ss / 2;
		draw_surface_ext_safe(surf, dx, dy, ss, ss,,, 0.50);
				
		var st = preview_st * sw;
		var ed = preview_ed * sw;
		var cr = preview_cr * sw;
		
		draw_surface_part_ext_safe(surf, st, 0, ed - st, sh, dx + st * ss, dy, ss, ss,, COLORS._main_accent);
		
		draw_set_color(COLORS._main_accent);
		draw_line(dx + cr * ss, bbox.yc - 16 * _s, dx + cr * ss, bbox.yc + 16 * _s);
	} #endregion
	
}