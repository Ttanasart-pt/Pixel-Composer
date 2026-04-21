/// @description init
event_inherited();

#region data
	dialog_w = ui(440);
	dialog_h = ui(128);
	padding  = ui(16);
	
    title   = "New title";
    content = "";

	buttonIndex = 0;
	buttons     = [];
	
	backdrop = true;
	
	function resetPosition() {
		if(!active) return;
		dialog_x = xstart - dialog_w / 2;
		dialog_y = ystart - dialog_h / 2;
		
		dialog_x = round(clamp(dialog_x, 2, WIN_SW - dialog_w - 2));
		dialog_y = round(clamp(dialog_y, 2, WIN_SH - dialog_h - 2));
	}
	
	function setButtons(_b)               { buttons = _b;               return self; }
	function setDim(_d)                   { dim_bg  = _d;               return self; }
	function setContent(_t = "", _c = "") { title   = _t; content = _c; return self; }
#endregion