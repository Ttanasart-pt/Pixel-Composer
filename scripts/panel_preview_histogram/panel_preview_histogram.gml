function Panel_Preview_Histogram() : PanelContent() constructor {
	title   = __txt("Histogram");
	padding = 8;
	
	w = ui(320);
	h = ui(240);
	
	bg_surf = surface_create(32, 32);
	ch_surf = [ noone, noone, noone, noone, ];
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		draw_sprite_stretched(THEME.ui_panel_bg, 1, 0, 0, w, h);
		
		var _s = PANEL_PREVIEW.getNodePreviewSurface();
		if(!surface_exists(_s)) return;
		
		bg_surf = surface_verify(bg_surf, 32, 32);
		for (var i = 0, n = array_length(ch_surf); i < n; i++)
			ch_surf[i] = surface_verify(ch_surf[i], w, h);
		
		gpu_set_texfilter(true);
		surface_set_target(bg_surf);
			DRAW_CLEAR
			draw_surface_stretched(_s, 0, 0, 32, 32);
		surface_reset_target();
		gpu_set_texfilter(false);
		
		for(var i = 0; i < 4; i++)
			surface_set_target_ext(i, ch_surf[i]);
			
		shader_set(sh_preview_histogram);
			DRAW_CLEAR	
			
			shader_set_surface("surface", bg_surf);
			shader_set_color("color", CDEF.main_grey);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, w, h);
		shader_reset();
		surface_reset_target();
		
		draw_surface_ext(ch_surf[0], 0, 0, 1, 1, 0, CDEF.main_grey, 1);
		
		shader_set(sh_preview_histogram_outline);
			shader_set_f("dimension", w, h);
			
			draw_surface_ext(ch_surf[1], 0, 0, 1, 1, 0, c_red,  1);	
			draw_surface_ext(ch_surf[2], 0, 0, 1, 1, 0, c_lime, 1);	
			draw_surface_ext(ch_surf[3], 0, 0, 1, 1, 0, c_blue, 1);	
		shader_reset();
	}
}