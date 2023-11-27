/// @description init
event_inherited();

#region data
	dialog_w = ui(360);
	dialog_h = ui(64);
	
	dialog_w_expand = ui(480);
	dialog_h_expand = ui(570);
			
	draggable = false;
	
	destroy_on_click_out = false;
	
	meta		= PROJECT.meta.clone();
	meta_expand = false;
	updating	= noone;
	update_note = "Updated";
	onModify    = -1;
	
	node      = noone;
	data_path = "";
	
	ugc  = 0;
	ugc_loading = false;
	
	tb_name  = new textBox(TEXTBOX_INPUT.text, function(str) { meta.name = str; });
	KEYBOARD_STRING = "";
	
	t_desc  = new textArea(TEXTBOX_INPUT.text, function(str) { meta.description = str; });
	t_auth  = new textArea(TEXTBOX_INPUT.text, function(str) { meta.author	    = str; });
	t_cont  = new textArea(TEXTBOX_INPUT.text, function(str) { meta.contact	    = str; });
	t_alias = new textArea(TEXTBOX_INPUT.text, function(str) { meta.alias	    = str; });
	t_tags  = new textArrayBox(function() { return meta.tags; }, META_TAGS);
	
	t_update = new textArea(TEXTBOX_INPUT.text, function(str) { update_note	    = str; });
	
	t_desc.auto_update   = true;
	t_auth.auto_update   = true;
	t_cont.auto_update   = true;
	t_alias.auto_update  = true;
	t_update.auto_update = true;
	
	function doExpand() {
		meta_expand = true;
		
		dialog_w = dialog_w_expand;
		dialog_h = dialog_h_expand;
	}
#endregion