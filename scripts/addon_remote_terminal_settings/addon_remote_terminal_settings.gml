function Remote_Terminal_Settings(_addon) : PanelContent() constructor {
	title = __txt("Remote Terminal");
	addonInst = _addon;
	auto_pin  = true;
	
	w = ui(320);
	h = ui(400);
	
	settings = [
		new __Panel_Linear_Setting_Item(
			__txt("Active"),
			new checkBox(function() /*=>*/ { if(addonInst.active) addonInst.deactivate(); else addonInst.activate(); }),
			function()    /*=>*/   {return addonInst.active},
			function(val) /*=>*/ { addonInst.active = val; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Port"),
			textBox_Number(function(_p) /*=>*/ { addonInst.setPort(_p); }),
			function()    /*=>*/   {return addonInst.port},
			function(val) /*=>*/ { addonInst.port = val; },
			22400,
		),
		
	];
	
	sc_terminal_output = new scrollPane(0, 0, function(_y, _m) /*=>*/ {
		draw_clear_alpha(CDEF.main_dkblack, 1);
		
		var _w = sc_terminal_output.surface_w;
		var _h = sc_terminal_output.surface_h;
		
		var _rx = x + sc_terminal_output.x;
		var _ry = y + sc_terminal_output.y;
		
		var _hover = sc_terminal_output.hover;
		var _focus = sc_terminal_output.active;
		
		var hh = 0;
		
		draw_set_text(f_code, fa_left, fa_bottom, COLORS._main_text);
		
		var _text = addonInst.outputLog;
		var _tamo = array_length(_text);
		
		var tx = ui(8);
		var ty = _h - ui(4);
		
		BLEND_ADD
		for(var i = _tamo - 1; i >= 0; i--) {
			var outp = _text[i];
			
			draw_text(tx, ty, outp);
			var th = string_height(outp);
			
			ty -= th;
			hh += th;
		}
		BLEND_NORMAL
		
		return hh;
	});
	
	function drawContent() { 
		if(!instance_exists(addonInst)) {
			close();
			return;
		}
		
		var pd = padding;
		var px = pd;
		var py = pd;
		var pw = w - pd * 2;
		var ph = h - pd * 2;
		
		for( var i = 0, n = array_length(settings); i < n; i++ ) {
			var sett = settings[i];
			
			var name = sett.name;
			var wdgt = sett.editWidget;
			var vall = sett.data();
			
			var wx = px;
			var wy = py;
			var ww = pw / 2;
			var wh = ui(24);
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
			draw_text_add(wx, wy + wh / 2, name);
			
			var wgx = w - pd - ww;
			wdgt.setFocusHover(pFOCUS, pHOVER);
			wdgt.drawParam(new widgetParam(wgx, wy, ww, wh, vall, undefined, [mx,my], x, y).setFont(f_p3));
			
			py += wh + ui(2);
			ph -= wh + ui(2);
		}
		
		py += ui(4);
		ph -= ui(4);
		
		sc_terminal_output.setFocusHover(pFOCUS, pHOVER);
		sc_terminal_output.verify(pw + ui(8), ph + ui(4));
		sc_terminal_output.drawOffset(px - ui(4), py, mx, my);
		
		draw_sprite_stretched_ext(THEME.ui_panel, 1, px - ui(4), py, pw + ui(8), ph + ui(4), COLORS._main_icon, .5);
		
	}
}