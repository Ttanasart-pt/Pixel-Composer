/// @description init
event_inherited();

#region data
	dialog_w = ui(640);
	dialog_h = ui(140);
	
	node = noone;
	prog = "";
	cmd  = "";
	
	ctxt = [];
	
	function setData(_node, _prog, _cmd) {
		node = _node;
		prog = _prog;
		cmd  = _cmd;
		
		ctxt[0] = $"Do you want the [{node.name}] node to run";
		ctxt[1] = $"{prog} {cmd}";
		ctxt[2] = $"Running unknown shell script can cause damage to your computer. Make sure you trust the author of the node before running it.";
		
		draw_set_font(f_p0);
		var _hh  = string_height_ext(ctxt[0], -1, dialog_w - ui(48)) + ui(16);
		
		draw_set_font(f_code);
			_hh += string_height_ext(ctxt[1], -1, dialog_w - ui(64)) + ui(16);
			
		draw_set_font(f_p0);
			_hh += string_height_ext(ctxt[2], -1, dialog_w - ui(48));
		
		dialog_h = _hh + ui(124);
		dialog_y = WIN_H / 2 - dialog_h / 2;
	}
#endregion