/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	
	font     = f_p2;
	dialog_w = ui(240);
	dialog_h = line_get_height(font, 8+8);
	anchor   = ANCHOR.left | ANCHOR.top;
	
	text  = "";
	label = "";
	
	refocus  = true;
	onModify = -1;
	params   = undefined;
	tb_name  = textBox_Text(function(txt) /*=>*/ { onModify(txt, params); instance_destroy(); }).setEmpty();
	
	function setLabel(l)  { label    = l; return self; }
	function setParam(p)  { params   = p; return self; }
	function setModify(m) { onModify = m; return self; }
	
	function activate(_initText = "") {
		text = _initText;
		tb_name.activate(text);
		tb_name.mouse_lhold = true;
		
		return self;
	}
#endregion