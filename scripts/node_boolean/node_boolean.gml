function Node_Boolean(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Boolean";
	color = COLORS.node_blend_number;
	setDimension(64, 64);
	
	hover_state    = 0;
	hover_state_to = 0;
	
	newInput(0, nodeValue_Bool( "Value", false )).setVisible(true, true);
		
	////- =Display
	newInput(1, nodeValue_Bool(    "Hide Background", false ));
	newInput(2, nodeValue_EButton( "Label Position",  0, [ "Top", "Bottom" ] ));
	
	newOutput(0, nodeValue_Output("Boolean", VALUE_TYPE.boolean, false));
	
	input_display_list = [ 0, 
		["Display",	false], 1, 2, 
	];
	
	////- Node
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		return _data[0]; 
	}
	
	////- Draw
	
	static pointIn = function(_x, _y, _mx, _my, _s, _panel) {
		var align = getInputData(2);
		var xx = x * _s + _x;
		var yy = (y - (!align * 20)) * _s + _y;
		
		var x1 = xx + w * _s;
		var y1 = yy + (h + 20) * _s;
		
		var _hov = point_in_rectangle(_mx, _my, xx, yy, x1, y1);
		if(key_mod_press(ALT) && !_hov && point_in_rectangle(_mx, _my, x1 - 24, y1 - 24, x1 + 24, y1 + 24)) { 
			_panel.node_hover_type = 1;
			_hov = true;
		}
		
		return _hov;
	}
	
	static onDrawHover = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) {
		hover_state_to = 1;
	}
	
	static drawNodeBase = function(xx, yy, _s) {
		if(!active) return;
		var hid = getInputData(1);
		
		if(hid) {
			hover_state    = lerp_float(hover_state, hover_state_to, 1);
			hover_state_to = 0;
			
		} else 
			hover_state = 1;
			
		var aa = (0.25 + 0.5 * renderActive) * hover_state;
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, colorMultiply(color, COLORS.node_base_bg), aa);
	}
	
	static drawNodeName = function(xx, yy, _s) {
		draw_name = false; 
		if(!active) return;
		if(_s < 0.75) return;
		
		var _name = renamed? display_name : name;
		if(_name == "") return;
		
		var hid   = getInputData(1);
		var align = getInputData(2);
		var ts = _s * .275 / UI_SCALE;
		var cx = xx + w * _s / 2;
		var oy = hid * ((1 - hover_state) * 8);
		
		draw_set_text(f_sdf, fa_center, align == 0? fa_bottom : fa_top, COLORS._main_text);
		
		     if(align == 0) draw_text_ext_add(cx, yy - 2 + oy,      _name, -1, 128 * _s, ts);
		else if(align == 1) draw_text_ext_add(cx, yy + h * _s - oy, _name, -1, 128 * _s, ts);
		
	}
	
	static drawDimension = undefined
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var val	 = getInputData(0);
		var bbox = draw_bbox;
		
		var x0 = bbox.x0;
		var y0 = bbox.y0;
		var x1 = bbox.x1;
		var y1 = bbox.y1;
		var ww = bbox.w;
		var hh = bbox.h;
		
		draw_sprite_stretched_ext(THEME.checkbox_def, 0, x0, y0, ww, hh, c_white, 1);
		
		if(_hover && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
			draw_sprite_stretched_ext(THEME.checkbox_def, 1, x0, y0, ww, hh, c_white, 1);	
			if(mouse_lpress(_focus))
				inputs[0].setValue(!val);
		}
		
		if(val) draw_sprite_stretched_ext(THEME.checkbox_def, 2, x0, y0, ww, hh, COLORS._main_accent, 1);
		
	}
}
