/// @description init
event_inherited();

#region data
	dialog_w = min(ui(800), WIN_W);
	dialog_h = ui(140);
	
	node = noone;
	lib  = "";
	link = "";
	file = "";
	
	ctxt = [];
	
	function setData(_node, _lib, _link, _file, _ext, _tfile) {
		node = _node;
		lib  = _lib;
		link = _link;
		file = _file;
		
		var fdir = filename_dir(file);
		
		if(OS == os_macosx) {
			ctxt[0] = $"Missing library required to build the {_ext} file. Runs homebrew command.";
			ctxt[1] = $"{link}";
			ctxt[2] = $"and try again.";
			
		} else {
			ctxt[0] = $"Missing library required to build the {_ext} file. Download the library from:";
			ctxt[1] = $"{link}";
			ctxt[2] = $"Extract the file and copy the {_tfile} to {fdir} and try again.";
			
		}
		
		draw_set_font(f_p0);
		var _hh  = string_height_ext(ctxt[0], -1, dialog_w - ui(48)) + ui(16);
		
		draw_set_font(f_code);
			_hh += string_height_ext_override(ctxt[1], -1, dialog_w - ui(64), true) + ui(16);
			
		draw_set_font(f_p0);
			_hh += string_height_ext(ctxt[2], -1, dialog_w - ui(48));
		
		dialog_h = _hh + ui(124);
		dialog_y = WIN_H / 2 - dialog_h / 2;
	}
#endregion