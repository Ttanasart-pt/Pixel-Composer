function Panel_Collection_Manager() : PanelContent() constructor {
	w = ui(540);
	h = ui(480);
	
	title       = "Collection Manager";
	auto_pin    = true;
	padding     = ui(4);
	content_w   = w - ui(200);
	
	stack = ds_stack_create();
	
	sc_content = new scrollPane(content_w, h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _h = 0;
		var hg = ui(20);
		var yy = _y;
		
		ds_stack_clear(stack);
		ds_stack_push(stack, COLLECTIONS);
		
		while(!ds_stack_empty(stack)) {
		    var st = ds_stack_pop(stack);
		    
		    var _list = st.subDir;
		    for( var i = 0, n = ds_list_size(_list); i < n; i++ ) 
		        ds_stack_push(stack, _list[| i]);
		        
		    draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
    		draw_text_add(ui(16), yy + hg / 2, st.name);
		        
	        _h += hg;
		    yy += hg;
		    
		    var _list = st.content;
    		for( var i = 0, n = ds_list_size(_list); i < n; i++ ) {
    		    var _con = _list[| i];
    		    
    		    draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
    		    draw_text_add(ui(8), yy + hg / 2, _con.name);
    		    
    		    _h += hg;
    		    yy += hg;
    		}
		}
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		content_w = w - ui(200);
		
		// Lists
		
		var _pd = padding;
		var ndx = _pd;
		var ndy = _pd;
		var ndw = content_w + ui(16);
		var ndh = h - _pd * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		sc_content.verify(content_w, ndh - ui(16));
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.drawOffset(ndx + ui(8), ndy + ui(8), mx, my);
		
		// Button
		
		var lx = ndx + ndw + ui(8);
		
		var bw = w - _pd - lx;
		var bh = TEXTBOX_HEIGHT;
		var bx = lx;
		var by = _pd;
		
		if(buttonInstant(THEME.button_def, bx, by, bw, bh, [ mx, my ], pHOVER, pFOCUS) == 2)
			__test_load_current_collections(COLLECTIONS);
			
		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
		draw_text_add(bx + bw / 2, by + bh / 2, "Load All");
		
		by += bh + ui(4);
		if(buttonInstant(THEME.button_def, bx, by, bw, bh, [ mx, my ], pHOVER, pFOCUS) == 2)
			__test_update_current_collections(COLLECTIONS);
			
		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
		draw_text_add(bx + bw / 2, by + bh / 2, "Update All");
		
		by += bh + ui(4);
		if(buttonInstant(THEME.button_def, bx, by, bw, bh, [ mx, my ], pHOVER, pFOCUS) == 2)
			__test_metadata_current_collections(COLLECTIONS);
			
		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
		draw_text_add(bx + bw / 2, by + bh / 2, "Update Metadata");
		
	}
	
}