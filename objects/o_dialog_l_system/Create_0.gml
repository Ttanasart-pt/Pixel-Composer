/// @description init
event_inherited();

#region data
	dialog_resizable = true;
	dialog_w = ui(640);
	dialog_h = ui(480);
	destroy_on_click_out = true;
	
	onResize = function() {
		sp_note.resize(dialog_w - ui(padding + padding), dialog_h - ui(title_height + padding));
	}
	
	is_open = array_create(array_length(global.lua_functions), false);
	
	ref = [
		"Lindenmayer Systems is a system of drawing line using simple string. The line is draw from a pointer (sometime called turtle). The pointer is controlled by a rule containing letters or symbols.",
		[
			["F", "Move forward and draw a line"],
			["G", "Move forward without drawing a line"],
			["+", "Rotate to the left"],
			["-", "Rotate to the right"],
			["[", "Save current state in a stack."],
			["]", "Restore state from the top of the stack."],
		],
		"Move distance and turn angle is fixed.",
		"Rules is generate by repeatedly replace a letter with another letter/string. For example.",
		[
			["X", "Starting rule"],
			["X > FX", "Replace X by FX"],
			["F > X+F", "Replace F by X+F"],
		],
		"By applying this rule 1 time, we will get",
		[
			["X", "Starting rule"],
			["FX", "Apply the first rule, replacing X with FX"],
		],
		"The second iteration will be",
		[
			["F FX", "Applying the first rule, replacing X with FX"],
			["X+F FX", "Applying the second rule, replacing F with X+F"],
		],
		"Notice that both rules are being applied at the same time, thus the seconds rule won't replace the letter replaced by the first rule. By repeating this operation many times, we can construct more complex shape.",
		"You can also apply multiple rule to the same letter to randomize rule selection.",
		[
			["X > F+X", "Replace X by F+X"],
			["X > F-X", "Replace X by F-X"],
		],
		"This rules mean every X has 50% chance to become F+X and 50% chance to become F-X.",
	];
	
	sp_note = new scrollPane(dialog_w - ui(padding + padding), dialog_h - ui(title_height + padding), function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var pad = ui(8);
		var yy = _y + pad;
		var _h = 0;
		var ind = 0;
		
		for( var i = 0; i < array_length(ref); i++ ) {
			var _f = ref[i];
			if(is_string(_f)) {
				if(i) {
					yy += pad;
					_h += pad;
				}
				
				draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
				var hh = string_height_ext(_f, -1, sp_note.surface_w - ui(8 + 8));
				draw_text_ext(ui(8), yy, _f, -1, sp_note.surface_w - ui(8 + 8));
				
				ind = 0;
				yy += hh + pad * 2;
				_h += hh + pad * 2;
				continue;
			}
			
			if(is_array(_f)) {
				var hh = (line_get_height(f_p0b) + pad) * array_length(_f) + ui(16);
				BLEND_OVERRIDE
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(8), yy,
					sp_note.surface_w - ui(16), hh, COLORS.dialog_lua_ref_bg, 1);
				BLEND_NORMAL
				yy += ui(8);
				_h += hh + ui(8);
				
				for( var j = 0; j < array_length(_f); j++ ) {
					var _t = _f[j][0];
					var _c = _f[j][1];
					hh = line_get_height(f_p0b);
					
					draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_accent);
					draw_text(ui(32), yy, _t);
			
					draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
					draw_text(ui(32 + 64), yy, _c);
			
					yy += hh + pad;
				}
				
				yy += pad * 2;
				_h += pad * 2;
			}
		}
		
		return _h + pad;
	})
#endregion