/// @description tooltip filedrop
#region tooltip
	if(is_array(TOOLTIP) || TOOLTIP != "") {
		if(is_struct(TOOLTIP) && struct_has(TOOLTIP, "drawTooltip")) {
			TOOLTIP.drawTooltip();
		} else if(is_array(TOOLTIP)) {
			var content = TOOLTIP[0];
			var type    = TOOLTIP[1];
			
			if(is_method(content)) content = content();
			
			switch(type) {
				case VALUE_TYPE.float :
				case VALUE_TYPE.integer :
				case VALUE_TYPE.text :
				case VALUE_TYPE.path :
					draw_tooltip_text(string_real(content));
					break;
				case VALUE_TYPE.boolean :
					draw_tooltip_text(content? get_text("true", "True") : get_text("false", "False"));
					break;
				case VALUE_TYPE.curve :
					draw_tooltip_text("[" + get_text("tooltip_curve_object", "Curve Object") + "]");
					break;
				case VALUE_TYPE.color :
					draw_tooltip_color(content);
					break;
				case VALUE_TYPE.d3object :
					draw_tooltip_text("[" + get_text("tooltip_3d_object", "3D Object") + "]");
					break;
				case VALUE_TYPE.object :
					draw_tooltip_text("[" + get_text("tooltip_object", "Object") + "]");
					break;
				case VALUE_TYPE.surface :
					draw_tooltip_surface(content);
					break;
				case VALUE_TYPE.rigid :
					draw_tooltip_text("[" + get_text("tooltip_rigid_object", "Rigidbody Object") + "id: " + string(content[$ "object"]) + "]");
					break;
				case VALUE_TYPE.particle :
					draw_tooltip_text("[" + get_text("tooltip_particle_object", "Particle Object") + "]");
					break;
				case VALUE_TYPE.pathnode :
					draw_tooltip_text("[" + get_text("tooltip_path_object", "Path Object") + "]");
					break;
				case VALUE_TYPE.fdomain :
					draw_tooltip_text("[" + get_text("tooltip_fluid_object", "Fluid Domain Object") + "id: " + string(content) + "]");
					break;
			}
		} else 
			draw_tooltip_text(TOOLTIP);
	}
	TOOLTIP = "";
#endregion

#region safe mode
	if(SAFE_MODE) {
		draw_sprite_stretched_ext(THEME.ui_panel_active, 0, 0, 0, WIN_W, WIN_H, COLORS._main_value_negative, 1);
		draw_set_text(f_h1, fa_right, fa_bottom, COLORS._main_value_negative);
		draw_set_alpha(0.1);
		draw_text(WIN_W - ui(16), WIN_H - ui(8), get_text("safe_mode", "SAFE MODE"));
		draw_set_alpha(1);
	}
#endregion

#region frame
	draw_set_color(COLORS._main_icon_dark);
	draw_rectangle(1, 1, WIN_W - 2, WIN_H - 2, true);
#endregion