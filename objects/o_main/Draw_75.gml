/// @description tooltip filedrop
if(winMan_isMinimized()) exit;

#region tooltip
	
	if(!_MOUSE_BLOCK) {
		if(is_struct(TOOLTIP)) {
			if(struct_has(TOOLTIP, "drawTooltip"))
				TOOLTIP.drawTooltip();
				
		} else if(is_array(TOOLTIP)) {
			var raw  = TOOLTIP[0];
			var type = TOOLTIP[1];
			var content = raw;
			
			if(is(raw, valueKey)) {
				content = raw.value;
				
			} else if(is_method(raw)) content = raw();
			
			switch(type) {
				
				case VALUE_TYPE.float    :
				case VALUE_TYPE.integer  : 
				case VALUE_TYPE.text     :
				case VALUE_TYPE.struct   :
				case VALUE_TYPE.path     : draw_tooltip_text(content);            break;
				
				case VALUE_TYPE.boolean  : draw_tooltip_text(printBool(content)); break;
				case VALUE_TYPE.curve    : draw_tooltip_curve(content);           break;
				case VALUE_TYPE.color    : draw_tooltip_color(content);           break;
				case VALUE_TYPE.gradient : draw_tooltip_gradient(content);        break;
				case VALUE_TYPE.atlas    : 
				case VALUE_TYPE.surface  : draw_tooltip_surface(content);         break;
				case VALUE_TYPE.buffer   : draw_tooltip_buffer(content);          break;
				case VALUE_TYPE.pathnode : draw_tooltip_path(content);            break;
				
				case VALUE_TYPE.d3object : draw_tooltip_text($"[{__txt("3D Object")}]");                                        break;
				case VALUE_TYPE.object   : draw_tooltip_text($"[{__txt("Object")}]");                                           break;
				case VALUE_TYPE.rigid    : draw_tooltip_text($"[{__txt("Rigidbody Object")} (id: {content})]");                 break;
				case VALUE_TYPE.particle : draw_tooltip_text($"[{__txt("Particle Object")} (size: {array_length(content)}) ]"); break;
				case VALUE_TYPE.sdomain  : draw_tooltip_text($"[{__txt("Domain")} (id: {content})]");                           break;
				case VALUE_TYPE.d3vertex : draw_tooltip_text($"[{__txt("3D Vertex")} (groups: {array_length(content)})]");      break;
				
				case VALUE_TYPE.strands :
					var txt = __txt("Strands Object");
					if(is_struct(content))
						txt += $" (strands: {array_length(content.hairs)})";
					draw_tooltip_text($"[{txt}]");
					break;
				
				case VALUE_TYPE.mesh :
					var txt = __txt("Mesh Object");
					if(is(content, MeshedSurface)) txt += $" (triangles: {array_length(content.tris)})";
					draw_tooltip_text($"[{txt}]");
					break;
				
				case "sprite" : draw_tooltip_sprite(content); break;
				
				default :
					var tt = "";
					if(is_struct(content)) tt = $"[{instanceof(content)}] {content}";
					else                   tt = string(content);
					
					draw_tooltip_text(tt);
			} 
			
		} else if(TOOLTIP != "")
			draw_tooltip_text(TOOLTIP);
	}
	TOOLTIP = "";
#endregion

#region dragging
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
		
		if(mouse_release(mb_left)) 
			DRAGGING = noone;
	}
#endregion

#region safe mode
	if(PROJECT.safeMode) {
		draw_sprite_stretched_ext(THEME.ui_panel, 1, 0, 0, WIN_W, WIN_H, COLORS._main_value_negative, 1);
		draw_set_text(f_h1, fa_right, fa_bottom, COLORS._main_value_negative);
		draw_set_alpha(0.25);
		draw_text(WIN_W - ui(16), WIN_H - ui(8), __txtx("safe_mode", "SAFE MODE"));
		draw_set_alpha(1);
	}
#endregion

#region draw gui top
	PANEL_MAIN.drawGUI();
	
	if(NODE_DROPPER_TARGET != noone) {
		draw_sprite_ui(THEME.node_dropper, 0, mouse_x + ui(20), mouse_y + ui(20));
		if(mouse_press(mb_left, NODE_DROPPER_TARGET_CAN))
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