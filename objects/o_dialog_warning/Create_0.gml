/// @description init
event_inherited();

#region data
	anchor  = ANCHOR.left | ANCHOR.top;
	padding = ui(8);
	destroy_on_click_out = true;
	
	text  = "";
	icon  = noone;
	color = COLORS._main_accent;
	anim  = -1;
	life  = 15;
	y    += life * UI_SCALE;
	
	function setText(txt) { text  = txt; return self; }
	function setColor(_c) { color = _c;  return self; }
	function setIcon(_i)  { icon  = _i;  return self; }
#endregion