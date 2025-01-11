/// @description init
event_inherited();

#region data
	anchor = ANCHOR.left | ANCHOR.top;
	
	padding = ui(8);
	destroy_on_click_out = true;
	warning_text = "";
	life = 300;
	
	function setText(txt) { warning_text = txt; return self; }
#endregion