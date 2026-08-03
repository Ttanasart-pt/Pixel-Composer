/// @description tooltip filedrop
if(IS_CMD) exit;
if(winMan_isMinimized()) exit;

if(USE_TEXTUREGROUP && texturegroup_get_status("UI") == texturegroup_status_loading) {
	DRAW_CLEAR;
	exit;
}

#region tooltip
	checkTOOLTIP();
#endregion

#region dragging
	panelDraw();
	
	if(DRAGGING != noone) {
		var mx = mouse_mx + ui(8);
		var my = mouse_my + ui(8);
		
		switch(DRAGGING.type) {
			case "Color" :
				draw_sprite_stretched_ext(THEME.box_r2, 0, mx, my, ui(32), ui(32), DRAGGING.data, 1);
				draw_sprite_stretched_add(THEME.box_r2, 1, mx, my, ui(32), ui(32), c_white, 0.3);
				break;
				
			case "Palette" :
				var _l = array_safe_length(DRAGGING.data);
				var _w = max(ui(128), _l * ui(10));
				drawPalette(DRAGGING.data, mx, my, _w, ui(24), 1);
				draw_sprite_stretched_add(THEME.box_r2, 1, mx, my, _w, ui(24), c_white, 0.3);
				break;
				
			case "Gradient" :
				DRAGGING.data.draw(mx, my, ui(128), ui(24), 1);
				draw_sprite_stretched_add(THEME.box_r2, 1, mx, my, ui(128), ui(24), c_white, 0.3);
				break;
				
			case "Bool" :
				draw_set_alpha(0.5);
				draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
				draw_text_bbox({ xc: mx, yc: my, w: ui(128), h: ui(24) }, __txt(DRAGGING.data? "True" : "False"));
				draw_set_alpha(1);
				break;
				
			case "Asset" :
			case "Project" :
			case "Collection" :
			case "Node" :
				if(DRAGGING.data.spr) {
					var ss = ui(48) / max(sprite_get_width(DRAGGING.data.spr), sprite_get_height(DRAGGING.data.spr))
					draw_sprite_ext(DRAGGING.data.spr, 0, mx, my, ss, ss, 0, c_white, 1);
				}
				break;
				
			case "GMSprite" :
				var _spr = DRAGGING.data.thumbnail;
				if(_spr) {
					var ss = ui(48) / max(sprite_get_width(_spr), sprite_get_height(_spr))
					draw_sprite_ext(_spr, 0, mx, my, ss, ss, 0, c_white, 1);
				}
				break;
				
			case "GMTileSet" :
				var _spm = struct_try_get(DRAGGING.data.gmBinder.resourcesMap, DRAGGING.data.sprite, noone);
                var _spr = _spm == noone? noone : _spm.thumbnail;
                    
				if(_spr) {
					var ss = ui(48) / max(sprite_get_width(_spr), sprite_get_height(_spr))
					draw_sprite_ext(_spr, 0, mx, my, ss, ss, 0, c_white, 1);
				}
				break;
				
			case "GMRoom" :
				draw_sprite_ext(s_gmroom, 0, mx + ui(32), my + ui(32), 1, 1, 0, c_white, 1);
				break;
				
			default:
				draw_set_alpha(0.5);
				draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
				draw_text_bbox({ xc: mx, yc: my, w: ui(128), h: ui(24) }, DRAGGING.data);
				draw_set_alpha(1);
		}
		
		if(mouse_lrelease()) 
			DRAGGING = noone;
	}
#endregion

#region draw gui top
	PANEL_MAIN.drawGUI();
	
	if(CURSOR_SPRITE != noone) {
		var ox = sprite_get_xoffset(CURSOR_SPRITE);
		var oy = sprite_get_yoffset(CURSOR_SPRITE);
		
		draw_sprite_ui(CURSOR_SPRITE, 0, mouse_x + ox + ui(4), mouse_y + oy + ui(4));
		CURSOR_SPRITE = noone;
	}
	
	if(NODE_DROPPER_TARGET != noone) {
		draw_sprite_ui(THEME.node_dropper, 0, mouse_x + ui(20), mouse_y + ui(20));
		if(mouse_lpress(NODE_DROPPER_TARGET_CAN))
			NODE_DROPPER_TARGET = noone;
		NODE_DROPPER_TARGET_CAN = true;
	} else	
		NODE_DROPPER_TARGET_CAN = false;
		
	panelDisplayDraw();
	dialogGUIDraw();
#endregion

#region debug
	if(global.FLAG[$ "hover_element"]) {
		draw_set_text(f_p0, fa_right, fa_bottom, COLORS._main_text);
		if(HOVERING_ELEMENT)
			draw_text(WIN_W, WIN_H, $"[{instanceof(HOVERING_ELEMENT)}]");
	}
#endregion

#region frame
	draw_set_color(merge_color(COLORS._main_icon, COLORS._main_icon_dark, 0.95));
	draw_rectangle(1, 1, WIN_W - 2, WIN_H - 2, true);
#endregion

#region zoom area
	if(PREFERENCES.video_mode) {
		zoom_area_draw();
		zoom_area_draw_gui();
	}
	
	if(PREFERENCES.annotation)
		video_pen_overlay();
#endregion

#region system debug
	// var tt = "";
	// tt += $"\nOperating system: {os_type_sting()} ({os_version})"
	// tt += $"\nCPU: {cpu_processor()} [{cpu_core_count()} cores]"
	// tt += $"\nGPU: {gpu_renderer()}"
	// tt += $"\nRAM: {memory_usedram(true)}/{memory_totalram(true)}"
	// tt += $"\nVRAM: {memory_totalvram(true)}"
	// print(tt);
	
	// var _dpi_x = display_get_dpi_x();
	// var _dpi_y = display_get_dpi_y();
	// print($"{_dpi_x}, {_dpi_y}");
#endregion