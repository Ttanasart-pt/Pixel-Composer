function Panel_Animation_Scaler() : Panel_Linear_Setting() constructor {
	title = __txtx("anim_scale_title", "Animation Scaler");
	w     = ui(380);
	
	scale_to = TOTAL_FRAMES;
	quantize = false;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txtx("anim_scale_target_frame_length", "Target frame length"),
			new textBox(TEXTBOX_INPUT.number, function(to) /*=>*/ { scale_to = toNumber(to); }), 
			function() /*=>*/ {return scale_to},
		),
		new __Panel_Linear_Setting_Item(
			__txtx("anim_scale_quantize", "Quantize Keyframes"),
			new checkBox(function() /*=>*/ { quantize = !quantize; }), 
			function() /*=>*/ {return quantize},
		),
	];
	
	hpad = ui(36);
	setHeight();
	
	b_apply = button(function() /*=>*/ {return scale()}).setIcon(THEME.accept_16, 0, COLORS._main_icon_dark);
	
	static scale = function() {
		var fac = scale_to / TOTAL_FRAMES;
		
		for (var i = 0, n = array_length(PROJECT.allNodes); i < n; i++) {
			var _node = PROJECT.allNodes[i];
			if(!_node || !_node.active) continue;
			
			for(var j = 0, m = array_length(_node.inputs); j < m; j++) {
				var in = _node.inputs[j];
				if(!in.is_anim) continue;
				
				for(var k = 0, p = array_length(in.animator.values); k < p; k++) {
					var t = in.animator.values[k];
					t.time = t.ratio * scale_to;
					if(quantize) t.time = round(t.time);
				}
			}
		}
		
		TOTAL_FRAMES = scale_to;
		close();
	}
	
	function drawContent(panel) { 
		drawSettings(panel); 
		
		var bs = ui(28);
		var bx = w - ui(8) - bs;
		var by = h - ui(8) - bs;
		
		b_apply.setFocusHover(pFOCUS, pHOVER);
		b_apply.register();
		b_apply.draw(bx, by, bs, bs, [ mx, my ], THEME.button_lime);
	}
}