function Panel_Canvas_Brush_Pressure(_brush) : PanelContent() constructor {
	title = __txt("pen_pressure_settings", "Pen Pressure Settings");
	brush = _brush;
	w = ui(400);
	h = ui(320);
	
	editActive = new checkBox(function(   ) /*=>*/ { brush.pressureUse = !brush.pressureUse; });
	editSize   = new rangeBox(function(v,i) /*=>*/ { brush.pressureRange[i] = v; });
	editCurve  = new curveBox(function(v  ) /*=>*/ { brush.pressureCurve    = v; });
	
	function drawContent(panel) {
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		var wdw = pw / 2;
		var wdh = TEXTBOX_HEIGHT;
		
		var wdx = w - padding - wdw;
		var wdy = py;
		
		draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
		draw_text_add(px + ui(8), wdy + TEXTBOX_HEIGHT / 2, __txt("Active"));
		
		var param = new widgetParam(wdx, wdy, wdw, wdh, brush.pressureUse, undefined, [mx,my], x, y).setFont(f_p3);
		editActive.setFocusHover(pFOCUS, pHOVER);
		editActive.drawParam(param);
		wdy += wdh + ui(8);
		
		draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
		draw_text_add(px + ui(8), wdy + TEXTBOX_HEIGHT / 2, __txt("Range"));
		
		var param = new widgetParam(wdx, wdy, wdw, wdh, brush.pressureRange, undefined, [mx,my], x, y).setFont(f_p3);
		editSize.setFocusHover(pFOCUS, pHOVER);
		editSize.drawParam(param);
		wdy += wdh + ui(8);
		
		wdh = max(ui(32), h - padding - wdy);
		var param = new widgetParam(px, wdy, pw, wdh, brush.pressureCurve, undefined, [mx,my], x, y).setFont(f_p3);
		editCurve.h = wdh;
		editCurve.setFocusHover(pFOCUS, pHOVER);
		editCurve.drawParam(param);
		wdy += wdh + ui(8);
		
	}	
}