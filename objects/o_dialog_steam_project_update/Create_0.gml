/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	
	font     = f_p2;
	tbh      = line_get_height(font, 8);
	dialog_w = ui(240);
	dialog_h = ui(4) + tbh + ui(4);
	anchor   = ANCHOR.left | ANCHOR.top;
	
	text    = "";
	label   = "";
	refocus = true;
	update_thumbnail = false;
	
	tb_name  = textBox_Text(function(txt) /*=>*/ { text = txt; }).setEmpty();
	
	function setLabel(l)  { label    = l; return self; }
	function setParam(p)  { params   = p; return self; }
	
	function activate(_initText = "") {
		text = _initText;
		tb_name.activate(text);
		tb_name.mouse_lhold = true;
		return self;
	}
	
	function update() {
    	steam_ugc_update_project(update_thumbnail, text);
    	PANEL_INSPECTOR.workshop_uploading = 2;
    	
    	instance_destroy();
	}
#endregion