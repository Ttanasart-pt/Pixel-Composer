/// @description tooltip filedrop
if(OS == os_windows && gameframe_is_minimized()) exit;

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
				case VALUE_TYPE.struct :
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
					draw_tooltip_text("[" + get_text("tooltip_rigid_object", "Rigidbody Object") + " (id: " + string(content[$ "object"]) + ")]");
					break;
				case VALUE_TYPE.particle :
					var txt = "[" + 
						get_text("tooltip_particle_object", "Particle Object") + 
						" (size: " + string(array_length(content)) + ") " + 
						"]";
					draw_tooltip_text(txt);
					break;
				case VALUE_TYPE.pathnode :
					draw_tooltip_text("[" + get_text("tooltip_path_object", "Path Object") + "]");
					break;
				case VALUE_TYPE.fdomain :
					draw_tooltip_text("[" + get_text("tooltip_fluid_object", "Fluid Domain Object") + " (id: " + string(content) + ")]");
					break;
				case VALUE_TYPE.strands :
					var txt = get_text("tooltip_strand_object", "Strands Object");
					if(is_struct(content))
						txt += " (strands: " + string(array_length(content.hairs)) + ")";
					draw_tooltip_text("[" + txt + "]");
					break;
				case VALUE_TYPE.mesh :
					var txt = get_text("tooltip_mesh_object", "Mesh Object");
					if(is_struct(content))
						txt += " (triangles: " + string(array_length(content.triangles)) + ")";
					draw_tooltip_text("[" + txt + "]");
					break;
				case VALUE_TYPE.d3vertex :
					var txt = get_text("tooltip_mesh_vertex", "3D Vertex");
					txt += " (groups: " + string(array_length(content)) + ")";
					draw_tooltip_text("[" + txt + "]");
					break;
			}
		} else 
			draw_tooltip_text(TOOLTIP);
	}
	TOOLTIP = "";
#endregion

#region dragging
	if(DRAGGING != noone) {
		switch(DRAGGING.type) {
			case "Color" :
				draw_sprite_stretched_ext(THEME.color_picker_box, 1, mouse_mx + ui(-16), mouse_my + ui(-16), ui(32), ui(32), DRAGGING.data, 0.5);
				break;
			case "Palette" :
				drawPalette(DRAGGING.data, mouse_mx - ui(64), mouse_my - ui(12), ui(128), ui(24), 0.5);
				break;
			case "Gradient" :
				DRAGGING.data.draw(mouse_mx - ui(64), mouse_my - ui(12), ui(128), ui(24), 0.5);
				break;
			case "Asset" :
				if(DRAGGING.data.spr) {
					var ss = 32 / max(sprite_get_width(DRAGGING.data.spr), sprite_get_height(DRAGGING.data.spr))
					draw_sprite_ext(DRAGGING.data.spr, 0, mouse_mx, mouse_my, ss, ss, 0, c_white, 0.5);
				}
				break;
			case "Collection" :
				if(DRAGGING.data.spr) {
					var ss = 32 / max(sprite_get_width(DRAGGING.data.spr), sprite_get_height(DRAGGING.data.spr))
					draw_sprite_ext(DRAGGING.data.spr, 0, mouse_mx, mouse_my, ss, ss, 0, c_white, 0.5);
				}
				break;
			case "Bool" :
				draw_set_alpha(0.5);
				draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
				draw_text_bbox({ xc: mouse_mx, yc: mouse_my, w: ui(128), h: ui(24) }, DRAGGING.data? "True" : "False");
				draw_set_alpha(1);
				break;
			default:
				draw_set_alpha(0.5);
				draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
				draw_text_bbox({ xc: mouse_mx, yc: mouse_my, w: ui(128), h: ui(24) }, DRAGGING.data);
				draw_set_alpha(1);
		}
		
		if(mouse_release(mb_left)) 
			DRAGGING = noone;
	}
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

#region draw gui top
	PANEL_MAIN.drawGUI();
#endregion

#region frame
	draw_set_color(merge_color(COLORS._main_icon, COLORS._main_icon_dark, 0.95));
	draw_rectangle(1, 1, WIN_W - 2, WIN_H - 2, true);
#endregion