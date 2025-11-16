function Panel_Dev_Project_Manager() : PanelContent() constructor {
	w = ui(540);
	h = ui(480);
	
	title     = "Projects Manager";
	auto_pin  = true;
	content_w = w - ui(200);
	stack     = ds_stack_create();
	
	path  = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/data/Welcome files";
	files = new DirectoryObject(path).scan([".pxc"]);
	
	updating = false;
	update_projects = [];
	update_index    = 0;
	update_step     = 0;
	
	sc_content = new scrollPane(content_w, h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var ww = sc_content.surface_w;
		var _h = 0;
		var hg = ui(20);
		var bs = ui(16);
		var yy = _y;
		
		var _a = sc_content.active;
		
		ds_stack_clear(stack);
		ds_stack_push(stack, [files, 0]);
		
		while(!ds_stack_empty(stack)) {
		    var tp = ds_stack_pop(stack);
		    var st = tp[0];
		    var dp = tp[1];
		    
		    var _list = st.subDir;
		    for( var i = 0, n = array_length(_list); i < n; i++ ) 
		        ds_stack_push(stack, [_list[n - 1 - i], dp + 1]);
		        
		    draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
    		draw_text_add(ui(dp * 8 + 8), yy + hg / 2, st.name);
    		
		    //// content
	        _h += hg;
		    yy += hg;
		    
		    var _list = st.content;
    		for( var i = 0, n = array_length(_list); i < n; i++ ) {
    		    var _con = _list[i];
    		    
    		    draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
    		    draw_text_add(ui(dp * 8 + 16), yy + hg / 2, _con.name);
    		    
    		    _h += hg;
    		    yy += hg;
    		}
		}
		
		return _h;
	});
	
	function projectUpdateInit() {
		updating = true;
		update_projects = [];
		update_index    = 0;
		
		var st = ds_stack_create();
		ds_stack_push(st, files);
		
		while(!ds_stack_empty(st)) {
			var _st = ds_stack_pop(st);
			for( var i = 0; i < array_length(_st.content); i++ ) {
				var _node = _st.content[i];
				var _path = _node.path;
				if(file_exists_empty(_path)) 
					array_push(update_projects, _path);
				
			}
			
			for( var i = 0; i < array_length(_st.subDir); i++ )
				ds_stack_push(st, _st.subDir[i]);
		}
		
		ds_stack_destroy(st);
		
		if(array_empty(update_projects)) {
			updating = false;
			noti_warning("No project to update.");
		}
	}
	
	function projectUpdating() {
		var _total = array_length(update_projects);
		var _path  = update_projects[update_index];
		
		switch(update_step) {
			case 0 :
				print($"Updating {filename_name(_path)}")
				LOAD_AT(_path);
				update_step++;
				waiting = 0;
				break;
				
			case 1 : if(waiting++ > 5) update_step++; break;
			
			case 2 : 
				if(instance_exists(project_loader)) break;
				
				ASSERTING = true;
				RenderSync(PROJECT);
				ASSERTING = false;
				update_step++;
				break;
				
			case 3 : 
				if(RENDERING != undefined) break;
			
				SAVE_AT(PROJECT, PROJECT.path);
				closeProject(PROJECT);
				
				update_step = 0;
				
				if(++update_index >= _total - 1) {
					updating = false;
					noti_status("Update complete", noone, COLORS._main_value_positive);
				}
				break;
		}
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		// Lists
		
		var _pd = padding;
		var ndx = _pd;
		var ndy = _pd;
		
		content_w = w - ui(200);
		var ndw = content_w + ui(16) - _pd * 2;
		var ndh = h - _pd * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		sc_content.verify(content_w - ui(24), ndh - ui(16));
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.drawOffset(ndx + ui(8), ndy + ui(8), mx, my);
		
		// Button
		
		var lx = ndx + ndw + ui(8);
		
		var bs = THEME.button_def;
		var bw = w - _pd - lx;
		var bh = TEXTBOX_HEIGHT;
		var bx = lx;
		var by = _pd;
		
		var _m = [mx,my];
		var _h = pHOVER;
		var _f = pFOCUS;
		
		if(updating) { 
			projectUpdating(); 
			
			var _stp = update_index;
			var _tot = array_length(update_projects);
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw, bh, COLORS._main_value_positive, .3);
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw * _stp/_tot, bh, COLORS._main_value_positive, .5);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, COLORS._main_value_positive,  1);
			
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
			draw_text_add(bx + bw / 2, by + bh / 2, "Updating...");
			return;
		}
		
		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
		
		if(buttonInstant(bs, bx, by, bw, bh, _m, _h, _f) == 2) projectUpdateInit()
		draw_text_add(bx + bw / 2, by + bh / 2, "Update All");
		by += bh + ui(4);
		
		by += ui(4);
		if(buttonInstant(bs, bx, by, bw, bh, _m, _h, _f) == 2) __test_zip_project(files);
		draw_text_add(bx + bw / 2, by + bh / 2, "Zip Folder");
		by += bh + ui(4);
		
	}
	
}

function __test_zip_project(dir) {
	var _dirr = dir.path + "/";
	var _targ = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/data/Welcome files/Welcome files.zip"
	var _zip  = zip_create();
	
	print("---------- ZIP PROJECT STARTED ----------");
	
	var st = ds_stack_create();
	ds_stack_push(st, dir);
	
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < array_length(_st.content); i++ ) {
			var _cont = _st.content[i];
			var _path = _cont.path; 
			if(!file_exists(_path)) continue;
			
			var zpath = string_replace(_path, _dirr, "");
			zip_add_file(_zip, zpath, _path); print($" > Adding {zpath}")
		}
		
		for( var i = 0; i < array_length(_st.subDir); i++ )
			ds_stack_push(st, _st.subDir[i]);
	}
	
	ds_stack_destroy(st);
	zip_save(_zip, _targ);
	
	print("---------- ZIP PROJECT ENDED ----------");
	noti_status("ZIP project complete", noone, COLORS._main_value_positive);
}