/// @description init
event_inherited();

#region data
	dialog_w = 240;
	dialog_h = 48;
	
	destroy_on_click_out = true;
	
	path = "";
#endregion

#region text
	onModify = -1;
	tb_name = new textBox(TEXTBOX_INPUT.text, function(txt) {
		while(string_char_at(txt, 1) == " ") {
			txt = string_copy(txt, 2, string_length(txt) - 1);
		}
		
		onModify(path + txt);
		instance_destroy();
	});
	
	TEXTBOX_ACTIVE  = tb_name;
	keyboard_string = "";
#endregion