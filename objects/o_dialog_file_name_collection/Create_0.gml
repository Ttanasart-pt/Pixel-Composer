/// @description init
event_inherited();

#region data
	dialog_w = ui(400);
	dialog_h = ui(40);
	padding  = ui(8);
	
	dialog_w_expand = ui(480);
	dialog_h_expand = ui(570);
			
	draggable = true;
	
	destroy_on_click_out = false;
	
	meta		= PROJECT.meta.clone();
	meta_expand = false;
	updating	= noone;
	update_note = "Updated";
	onModify    = -1;
	
	node        = noone; function setNode(n) { node = n; meta.name = n.display_name; return self; }
	data_path   = "";    function setPath(s) { data_path = s; return self; }
	
	font = f_p2;
	ugc  = 0;
	move = true;
	ugc_loading = false;
	
	KEYBOARD_RESET
	tb_name  = textBox_Text(  function(str) /*=>*/ { meta.name        = filename_name_validate(str); });
	
	t_update = textArea_Text( function(str) /*=>*/ { update_note      = str; }).setAutoUpdate();
	t_desc   = textArea_Text( function(str) /*=>*/ { meta.description = str; }).setAutoUpdate();
	t_auth   = textBox_Text(  function(str) /*=>*/ { meta.author      = str; }).setAutoUpdate();
	t_cont   = textBox_Text(  function(str) /*=>*/ { meta.contact     = str; }).setAutoUpdate();
	t_alias  = textBox_Text(  function(str) /*=>*/ { meta.alias       = str; }).setAutoUpdate();
	t_tags   = new textArrayBox(function() /*=>*/ {return meta.tags}, META_TAGS).setAddable(true);
	c_dep    = new checkBox(  function() /*=>*/ { meta.deprecated  = !meta.deprecated; });
	
	if(STEAM_ENABLED)
		t_auth.setSideButton(button(function() /*=>*/ {return meta.author = STEAM_USERNAME}).setIcon(THEME.steam, 0, COLORS._main_icon).iconPad(ui(8)));
	
	widgets = [
		[ __txt("Author"),       t_auth,  function() /*=>*/ {return meta.author}     ],
		[ __txt("Contact info"), t_cont,  function() /*=>*/ {return meta.contact}    ],
		[ __txt("Alias"),        t_alias, function() /*=>*/ {return meta.alias}      ],
		[ __txt("Tags"),         t_tags,  function() /*=>*/ {return meta.tags}       ],
		[ __txt("Deprecated"),   c_dep,   function() /*=>*/ {return meta.deprecated} ],
	];
#endregion
	
function setPrefix( _l ) { tb_name.setPrefix(_l); return self; }
	
function doExpand() {
	meta_expand = true;
	padding     = ui(12)
	
	dialog_w = dialog_w_expand;
		dialog_h = dialog_h_expand;
}