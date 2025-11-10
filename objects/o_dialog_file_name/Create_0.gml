/// @description init
event_inherited();

#region data
	draggable = false;
	dialog_w  = ui(240);
	dialog_h  = ui(40);
	padding   = ui(8);
	
	destroy_on_click_out = true;
	
	label = __txt("Name");
	path  = "";
	name  = "New file";
#endregion

#region text
	onModify = -1;
	tb_width = ui(200);
	tb_name  = textBox_Text(function(t) /*=>*/ { onModify(path + filename_name_validate(t)); instance_destroy(); });
	
	function setLabel(  _l ) { label    = _l; return self; }
	function setName(   _n ) { name     = _n; return self; }
	function setPath(   _p ) { path     = _p; return self; }
	function setModify( _m ) { onModify = _m; return self; }
	function setWidth(  _w ) { tb_width = _w; return self; }
	
	function setPrefix( _l ) { tb_name.setPrefix(_l); return self; }
	
	WIDGET_CURRENT  = tb_name;
	KEYBOARD_RESET
#endregion