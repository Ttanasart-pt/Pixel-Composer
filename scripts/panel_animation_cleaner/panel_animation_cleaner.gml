function Panel_Animation_Cleaner() : Panel_Linear_Setting() constructor {
	title = __txtx("anim_clean_title", "Animation Cleaner");
	w     = ui(380);
	
	quantize        = false;
	delete_overflow = false;
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txtx("anim_clean_quantize", "Quantize Time"),
			new checkBox(function() /*=>*/ { quantize = !quantize; }), function() /*=>*/ {return quantize},
		),
		new __Panel_Linear_Setting_Item(
			__txtx("anim_clean_overflow", "Delete Overflow Keyframes"),
			new checkBox(function() /*=>*/ { delete_overflow = !delete_overflow; }), function() /*=>*/ {return delete_overflow},
		),
	];
	
	hpad = ui(36);
	setHeight();
	
	b_apply = button(function() /*=>*/ {return scale()}).setIcon(THEME.accept_16, 0, COLORS._main_icon_dark);
	
	static scale = function() {
		
		for (var i = 0, n = array_length(PROJECT.allNodes); i < n; i++) {
			var _node = PROJECT.allNodes[i];
			if(!_node || !_node.active) continue;
			
			for(var j = 0, m = array_length(_node.inputs); j < m; j++) {
				var in = _node.inputs[j];
				if(!in.is_anim) continue;
				
				for(var k = array_length(in.animator.values) - 1; k >= 0; k--) {
					var t = in.animator.values[k];
					
					if(quantize) t.time = round(t.time);
					
					if(delete_overflow && (t.time < 0 || t.time > GLOBAL_TOTAL_FRAMES))
					    in.animator.removeKey(t, false);
				}
				
				in.animator.updateKeyMap();
			}
		}
		
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