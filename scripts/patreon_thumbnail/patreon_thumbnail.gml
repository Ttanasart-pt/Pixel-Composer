function generate_patreon_thumbnail() {
    var proj = PROJECT.path;
    var prev = PANEL_PREVIEW.getNodePreviewSurface();
    if(!is_just_surface(prev)) return;
    
    var dest = filename_combine(filename_dir(proj), filename_name_only(proj) + ".png");
    steam_ugc_generate_thumbnail(prev, UGC_TYPE.patreon, dest);
    
    /////////////////////////////////////////////////
    
    var dest = filename_combine(filename_dir(proj), filename_name_only(proj) + "_cover.png");
    var sw   = 1920;
    var sh   = 1080;
    
    var surf = surface_create(sw, sh);
    var surp = surface_create(sw, sh);
    
    var sett = new graph_export_settings();
        sett.bgEnable   = true;
        sett.gridEnable = true;
        
    var grph = graph_export_image(PANEL_GRAPH.nodes_list, PANEL_GRAPH.nodes_list, sett);
    
    surface_set_target(surp);
    	DRAW_CLEAR
    	
	    var pw = surface_get_width(prev);
	    var ph = surface_get_height(prev);
    	var ss = sh / ph * .8;
    	
    	var sx = sw / 2 - ss * pw / 2;
    	var sy = sh / 2 - ss * ph / 2;
    	
		draw_surface_ext(prev, sx, sy, ss, ss, 0, c_white, 1);
    surface_reset_target();
    
    surface_set_target(surf);
    	draw_clear_alpha(CDEF.main_bg, 1);
    	
	    var pw = surface_get_width(grph);
	    var ph = surface_get_height(grph);
    	var ss = max(sw / pw, sh / ph);
    	
    	var sx = sw / 2 - ss * pw / 2;
    	var sy = sh / 2 - ss * ph / 2;
    	
    	gpu_set_colorwriteenable(1,1,1,0);
    	draw_surface_ext(grph, sx, sy, ss, ss, 0, c_white, .75);
    	gpu_set_colorwriteenable(1,1,1,1);
    	
    	shader_set(sh_process_maker_shadow);
		shader_set_2("dimension",  [pw,ph]  );
		shader_set_f("shadow",      64      );
		shader_set_f("intensity",  .75      );
		shader_set_c("color",      c_black  );
    	draw_surface(surp, 0, 0);
		shader_reset();
		
		draw_set_text(f_pixel, fa_right, fa_top, COLORS._main_icon, .6);
		draw_text_transformed(sw - 16, 16, VERSION_STRING_BETA, 8, 8, 0);
		draw_set_alpha(1);
    surface_reset_target();
    
    surface_save(surf, dest);
    
    surface_free(grph);
    surface_free(surf);
    surface_free(surp);
}
