function __addon_lua_setup_constants(lua, context) {
	lua_add_code(lua, $"ID = '{context.ID}'");
	
	lua_add_code(lua, $"c_aqua = {c_aqua}");
	lua_add_code(lua, $"c_black = {c_black}");
	lua_add_code(lua, $"c_blue = {c_blue}");
	lua_add_code(lua, $"c_dkgray = {c_dkgray}");
	lua_add_code(lua, $"c_fuchsia = {c_fuchsia}");
	lua_add_code(lua, $"c_gray = {c_gray}");
	lua_add_code(lua, $"c_green = {c_green}");
	lua_add_code(lua, $"c_lime = {c_lime}");
	lua_add_code(lua, $"c_ltgray = {c_ltgray}");
	lua_add_code(lua, $"c_maroon = {c_maroon}");
	lua_add_code(lua, $"c_navy = {c_navy}");
	lua_add_code(lua, $"c_olive = {c_olive}");
	lua_add_code(lua, $"c_orange = {c_orange}");
	lua_add_code(lua, $"c_purple = {c_purple}");
	lua_add_code(lua, $"c_red = {c_red}");
	lua_add_code(lua, $"c_silver = {c_silver}");
	lua_add_code(lua, $"c_teal = {c_teal}");
	lua_add_code(lua, $"c_white = {c_white}");
	lua_add_code(lua, $"c_yellow = {c_yellow}");
	
	lua_add_code(lua, $"color_accent = {COLORS._main_accent}");
	lua_add_code(lua, $"color_icon = {COLORS._main_icon}");
	lua_add_code(lua, $"color_icon_dark = {COLORS._main_icon_dark}");
	lua_add_code(lua, $"color_icon_light = {COLORS._main_icon_light}");
	lua_add_code(lua, $"color_text = {COLORS._main_text}");
	lua_add_code(lua, $"color_text_sub = {COLORS._main_text_sub}");
	lua_add_code(lua, $"color_positive = {COLORS._main_value_positive}");
	lua_add_code(lua, $"color_negative = {COLORS._main_value_negative}");
	
	lua_add_code(lua, $"color_dkblack = {CDEF.main_dkblack}");
	lua_add_code(lua, $"color_mdblack = {CDEF.main_mdblack}");
	lua_add_code(lua, $"color_black = {CDEF.main_black}");
	lua_add_code(lua, $"color_dkgrey = {CDEF.main_dkgrey}");
	lua_add_code(lua, $"color_dark = {CDEF.main_dark}");
	lua_add_code(lua, $"color_grey = {CDEF.main_grey}");
	lua_add_code(lua, $"color_ltgrey = {CDEF.main_ltgrey}");
	lua_add_code(lua, $"color_white = {CDEF.main_white}");

	lua_add_code(lua, $"fa_left = {fa_left}");
	lua_add_code(lua, $"fa_middle = {fa_middle}");
	lua_add_code(lua, $"fa_right = {fa_right}");
	//
	lua_add_code(lua, $"fa_top = {fa_top}");
	lua_add_code(lua, $"fa_center = {fa_center}");
	lua_add_code(lua, $"fa_bottom = {fa_bottom}");
	
	lua_add_code(lua, $"mb_left = {mb_left}");
	lua_add_code(lua, $"mb_middle = {mb_middle}");
	lua_add_code(lua, $"mb_right = {mb_right}");

	lua_add_code(lua, $"vk_nokey = {vk_nokey}");
	lua_add_code(lua, $"vk_anykey = {vk_anykey}");
	lua_add_code(lua, $"vk_left = {vk_left}");
	lua_add_code(lua, $"vk_right = {vk_right}");
	lua_add_code(lua, $"vk_up = {vk_up}");
	lua_add_code(lua, $"vk_down = {vk_down}");
	lua_add_code(lua, $"vk_enter = {vk_enter}");
	lua_add_code(lua, $"vk_escape = {vk_escape}");
	lua_add_code(lua, $"vk_space = {vk_space}");
	lua_add_code(lua, $"vk_shift = {vk_shift}");
	lua_add_code(lua, $"vk_control = {vk_control}");
	lua_add_code(lua, $"vk_alt = {vk_alt}");
	lua_add_code(lua, $"vk_backspace = {vk_backspace}");
	lua_add_code(lua, $"vk_tab = {vk_tab}");
	lua_add_code(lua, $"vk_home = {vk_home}");
	lua_add_code(lua, $"vk_end = {vk_end}");
	lua_add_code(lua, $"vk_delete = {vk_delete}");
	lua_add_code(lua, $"vk_insert = {vk_insert}");
	lua_add_code(lua, $"vk_pageup = {vk_pageup}");
	lua_add_code(lua, $"vk_pagedown = {vk_pagedown}");
	lua_add_code(lua, $"vk_pause = {vk_pause}");
	lua_add_code(lua, $"vk_printscreen = {vk_printscreen}");
	lua_add_code(lua, $"vk_f1 = {vk_f1}");
	lua_add_code(lua, $"vk_f2 = {vk_f2}");
	lua_add_code(lua, $"vk_f3 = {vk_f3}");
	lua_add_code(lua, $"vk_f4 = {vk_f4}");
	lua_add_code(lua, $"vk_f5 = {vk_f5}");
	lua_add_code(lua, $"vk_f6 = {vk_f6}");
	lua_add_code(lua, $"vk_f7 = {vk_f7}");
	lua_add_code(lua, $"vk_f8 = {vk_f8}");
	lua_add_code(lua, $"vk_f9 = {vk_f9}");
	lua_add_code(lua, $"vk_f10 = {vk_f10}");
	lua_add_code(lua, $"vk_f11 = {vk_f11}");
	lua_add_code(lua, $"vk_f12 = {vk_f12}");
	lua_add_code(lua, $"vk_numpad0 = {vk_numpad0}");
	lua_add_code(lua, $"vk_numpad1 = {vk_numpad1}");
	lua_add_code(lua, $"vk_numpad2 = {vk_numpad2}");
	lua_add_code(lua, $"vk_numpad3 = {vk_numpad3}");
	lua_add_code(lua, $"vk_numpad4 = {vk_numpad4}");
	lua_add_code(lua, $"vk_numpad5 = {vk_numpad5}");
	lua_add_code(lua, $"vk_numpad6 = {vk_numpad6}");
	lua_add_code(lua, $"vk_numpad7 = {vk_numpad7}");
	lua_add_code(lua, $"vk_numpad8 = {vk_numpad8}");
	lua_add_code(lua, $"vk_numpad9 = {vk_numpad9}");
	lua_add_code(lua, $"vk_multiply = {vk_multiply}");
	lua_add_code(lua, $"vk_divide = {vk_divide}");
	lua_add_code(lua, $"vk_add = {vk_add}");
	lua_add_code(lua, $"vk_subtract = {vk_subtract}");
	lua_add_code(lua, $"vk_decimal = {vk_decimal}");
		
	lua_add_code(lua, $"gp_face1 = {gp_face1}");
	lua_add_code(lua, $"gp_face2 = {gp_face2}");
	lua_add_code(lua, $"gp_face3 = {gp_face3}");
	lua_add_code(lua, $"gp_face4 = {gp_face4}");
	lua_add_code(lua, $"gp_shoulderl = {gp_shoulderl}");
	lua_add_code(lua, $"gp_shoulderlb = {gp_shoulderlb}");
	lua_add_code(lua, $"gp_shoulderr = {gp_shoulderr}");
	lua_add_code(lua, $"gp_shoulderrb = {gp_shoulderrb}");
	lua_add_code(lua, $"gp_select = {gp_select}");
	lua_add_code(lua, $"gp_start = {gp_start}");
	lua_add_code(lua, $"gp_stickl = {gp_stickl}");
	lua_add_code(lua, $"gp_stickr = {gp_stickr}");
	lua_add_code(lua, $"gp_padu = {gp_padu}");
	lua_add_code(lua, $"gp_padd = {gp_padd}");
	lua_add_code(lua, $"gp_padl = {gp_padl}");
	lua_add_code(lua, $"gp_padr = {gp_padr}");

	lua_add_code(lua, $"gp_axislh = {gp_axislh}");
	lua_add_code(lua, $"gp_axislv = {gp_axislv}");
	lua_add_code(lua, $"gp_axisrh = {gp_axisrh}");
	lua_add_code(lua, $"gp_axisrv = {gp_axisrv}");
	
	lua_add_code(lua, $"bm_normal = {bm_normal}");
	lua_add_code(lua, $"bm_add = {bm_add}");
	lua_add_code(lua, $"bm_subtract = {bm_subtract}");
	lua_add_code(lua, $"bm_max = {bm_max}");

	lua_add_code(lua, $"tb_text = {TEXTBOX_INPUT.text}");
	lua_add_code(lua, $"tb_number = {TEXTBOX_INPUT.number}");
	
	lua_add_code(lua, "Panel = {};");
	lua_add_code(lua, "Animator = {};");
	
	lua_add_code(lua, $"s_ui_panel_active = {THEME.ui_panel_active}");
	lua_add_code(lua, $"s_ui_panel_bg = {THEME.ui_panel_bg}");
	lua_add_code(lua, $"s_ui_scrollbar = {THEME.ui_scrollbar}");
	
}
	
function __addon_lua_panel_variable(lua, panel) {
	lua_add_code(lua, 
		"Panel.mouse = {" + string(panel.mx) + ", " + string(panel.my) + "}\n" + 
		"Panel.mouseUI = {" + string(mouse_mx) + ", " + string(mouse_my) + "}\n" + 
		"Panel.x  = " + string(panel.x ) + "\n" + 
		"Panel.y  = " + string(panel.y ) + "\n" + 
		"Panel.w  = " + string(panel.w ) + "\n" + 
		"Panel.h  = " + string(panel.h ) + "\n" +
		
		"Panel.hoverable = " + string(panel.pHOVER) + "\n" +
		"Panel.clickable = " + string(panel.pFOCUS) + "\n" 
	);
	
	lua_add_code(lua, 
		"Animator.frame_current = " + string(PROJECT.animator.current_frame) + "\n" + 
		"Animator.frame_total = " +   string(PROJECT.animator.frames_total) + "\n" + 
		"Animator.frame_rate  = " +   string(PROJECT.animator.framerate) + "\n"
	);
}
