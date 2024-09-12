/// @description init
event_inherited();

#region data
	dialog_w = ui(240);
	dialog_h = ui(48);
	
	destroy_on_click_out = true;
	
	path = "";
	name = "New file";
#endregion

#region text
	onModify = -1;
	tb_name = new textBox(TEXTBOX_INPUT.text, function(txt) {
		txt = filename_name_validate(txt);
		onModify(path + txt);
		instance_destroy();
	});
	
	function setName(_name) {
		self.name = _name;
		return self;
	}
	
	WIDGET_CURRENT  = tb_name;
	KEYBOARD_STRING = "";
#endregion