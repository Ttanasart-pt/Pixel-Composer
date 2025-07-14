/// @description init
event_inherited();

#region data
	dialog_w = ui(240);
	dialog_h = ui(48);
	anchor   = ANCHOR.left | ANCHOR.top;
	
	destroy_on_click_out = true;
	font     = f_p2;
	text     = "";
	
	refocus  = true;
	onModify = -1;
	tb_name  = textBox_Text(function(txt) /*=>*/ { onModify(txt); instance_destroy(); });
	
	function activate(_initText = "") {
		text = _initText;
		tb_name.activate(text);
	}
#endregion