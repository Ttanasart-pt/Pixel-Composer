function Node_Assert(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Assert";
	setDimension(96, 32 + 24 * 1); 
	
	draw_padding = 8;
	
	newInput(0, nodeValue_Text("Name", self, ""));
	
	newInput(1, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(2, nodeValue("Target", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
		
	function checkSurface(s1, s2) {
		if(!is_surface(s1)) return false;
		if(!is_surface(s2)) return false;
		
		if(surface_get_width(s1)  != surface_get_width(s2))  return false;
		if(surface_get_height(s1) != surface_get_height(s2)) return false;
		if(surface_get_format(s1) != surface_get_format(s2)) return false;
		
		var b1 = buffer_from_surface(s1, false); buffer_to_start(b1);
		var b2 = buffer_from_surface(s2, false); buffer_to_start(b2);
		
		var ss = buffer_get_size(b1);
		var ii = 0;
		var eq = true;
		
		repeat(ss) {
			var r1 = buffer_read(b1, buffer_u8);
			var r2 = buffer_read(b2, buffer_u8);
			
			if(r1 != r2) {
				eq = false;
				break;
			}
		}
		
		buffer_delete(b1);
		buffer_delete(b2);
		
		return eq;
	}
	
	static update = function() { 
		var name = getInputData(0);
		var val  = getInputData(1);
		var tar  = getInputData(2);
		
		var _typ  = inputs[2].value_from != noone? inputs[2].value_from.type : VALUE_TYPE.any;
		inputs[1].setType(_typ);
		inputs[2].setType(_typ);
		
		if(!ASSERTING) return;
		ASSERT_AMOUNT++;
		
		var _pass = false;
		var _ast  = {
			type : -1,
			text : $"Assertion {name} failed: get {val} instead of target {tar}.",
			tooltip : -1,
		}
		
		switch(_typ) {
			case VALUE_TYPE.surface :
				if(is_array(tar)) {
					for( var i = 0, n = array_length(tar); i < n; i++ ) {
						if(checkSurface(array_safe_get(val, i), tar[i])) continue;
						_pass = false;
						break;
					}
					
				} else 
					_pass = checkSurface(val, tar);
					
				_ast.text    = $"Assertion {name} failed: surface not match the target.";
				_ast.tooltip = new tooltipSurfaceAssetion(surface_array_clone(tar), surface_array_clone(val));
				break;
				
			default : _pass = isEqual(val, tar);
		}
		
		if(_pass) ASSERT_PASSED++;
		else      array_append(ASSERT_LOG, _ast);
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var name = getInputData(0);
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, name);
	}
}

function tooltipSurfaceAssetion(expect, got) constructor {
	self.expect = is_array(expect)? expect : [ expect ];
	self.got    = is_array(got)?    got    : [ got    ];
	
	static drawTooltip = function() {
		var ss = ui(100);
		var tw =  ss * 2 + ui(8);
		var th = (ss + ui(4)) * array_length(expect) + ui(20) - ui(4);
		
		var mx = min(__mouse_tx + ui(16), __win_tw - (tw + ui(16)));
		var my = min(__mouse_ty + ui(16), __win_th - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		
		var xe = mx + ui(8);
		var xg = mx + ui(8) + ss + ui(8);
		
		draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
		draw_text(xe + ss / 2, my + ui(4), "Expected");
		draw_text(xg + ss / 2, my + ui(4), "Got");
		
		for( var i = 0, n = array_length(expect); i < n; i++ ) {
			var _e = array_safe_get(expect, i);
			var _g = array_safe_get(got, i);
			
			var _ew = surface_get_width_safe(_e);
			var _eh = surface_get_height_safe(_e);
			
			var _gw = surface_get_width_safe(_g);
			var _gh = surface_get_height_safe(_g);
			
			var yy = my + ui(8 + 20) + i * (ss + ui(4));
			
			var sc  = min(ss / _ew, ss / _eh);
			draw_surface_ext_safe(_e, xe + ss / 2 - _ew * sc / 2, yy + ss / 2 - _eh * sc / 2, sc, sc);
			draw_sprite_stretched_add(THEME.s_box_r2, 1, xe, yy, ss, ss, c_white, .15);
			
			var sc  = min(ss / _gw, ss / _gh);
			draw_surface_ext_safe(_g, xg + ss / 2 - _gw * sc / 2, yy + ss / 2 - _gh * sc / 2, sc, sc);
			draw_sprite_stretched_add(THEME.s_box_r2, 1, xg, yy, ss, ss, c_white, .15);
		}
	}
}