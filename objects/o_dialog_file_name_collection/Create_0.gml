/// @description init
event_inherited();

#region data
	dialog_w = ui(360);
	dialog_h = ui(48);
	padding  = ui(12);
	
	dialog_w_expand = ui(480);
	dialog_h_expand = ui(570);
			
	draggable = true;
	
	destroy_on_click_out = false;
	
	meta		= PROJECT.meta.clone();
	meta_expand = false;
	updating	= noone;
	update_note = "Updated";
	onModify    = -1;
	
	node      = noone;
	data_path = "";
	
	font = f_p2;
	ugc  = 0;
	ugc_loading = false;
	
	KEYBOARD_RESET
	tb_name  = textBox_Text(  function(str) /*=>*/ { meta.name        = filename_name_validate(str); });
	
	t_update = textArea_Text( function(str) /*=>*/ { update_note      = str; }).setAutoUpdate();
	t_desc   = textArea_Text( function(str) /*=>*/ { meta.description = str; }).setAutoUpdate();
	t_auth   = textBox_Text(  function(str) /*=>*/ { meta.author      = str; }).setAutoUpdate();
	t_cont   = textBox_Text(  function(str) /*=>*/ { meta.contact     = str; }).setAutoUpdate();
	t_alias  = textBox_Text(  function(str) /*=>*/ { meta.alias       = str; }).setAutoUpdate();
	t_tags   = new textArrayBox(function() /*=>*/ {return meta.tags}, META_TAGS).setAddable(true);
	
	function doExpand() {
		meta_expand = true;
		
		dialog_w = dialog_w_expand;
		dialog_h = dialog_h_expand;
	}
#endregion