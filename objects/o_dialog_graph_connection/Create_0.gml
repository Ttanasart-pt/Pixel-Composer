/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	dialog_h = ui(180);
	
	destroy_on_click_out = true;
#endregion

#region data
	bs_type = buttonGroup([ THEME.icon_curve_connection, THEME.icon_curve_connection, THEME.icon_curve_connection, THEME.icon_curve_connection ], 
		function(val) {
			PREF_MAP[? "curve_connection_line"] = val;
		}
	);
	
	tb_width = new textBox(TEXTBOX_INPUT.number, function(str) {
		PREF_MAP[? "connection_line_width"] = max(0.5, real(str));
	})
	
	tb_corner = new textBox(TEXTBOX_INPUT.number, function(str) {
		PREF_MAP[? "connection_line_corner"] = max(0, real(str));
	})
	tb_corner.slidable = true;
#endregion