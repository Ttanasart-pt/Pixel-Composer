function gamemakerPathBox(project) : widget() constructor {
    self.project = project;
    
    static trigger = function() { }
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _gmPath, _m) {	
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		if(project.bind_gamemaker == noone) {
    		if(buttonInstant(THEME.button_def, _x, _y, _w, _h, _m, active, hover) == 2) {
    		    var path = get_open_filename("GameMaker project|*.yyp", ""); key_release();
				if(path == "") return noone;
				
				project.attributes.bind_gamemaker_path = path;
				project.bind_gamemaker = Binder_Gamemaker(project.attributes.bind_gamemaker_path);
    		}
    		    
    		draw_sprite_uniform(s_gamemaker, 0, _x + ui(16), _y + _h / 2, 1, COLORS._main_icon, 1);
    		
    		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
    		draw_text_add(_x + _w / 2, _y + _h / 2, "Link .yyp");
    		
		} else {
		    var _gm = project.bind_gamemaker;
		    
		    draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
		    
		    if(buttonInstant(THEME.button_def, _x, _y, ui(32), _h, _m, active, hover, "Explore project", s_gamemaker, 0, COLORS._main_icon) == 2) 
				dialogPanelCall(new Panel_GM_Explore(_gm));
    		
    		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
    		draw_text_add(_x + _w / 2, _y + _h / 2, _gm.projectName);
    		
    		if(buttonInstant(THEME.button_def, _x + _w - ui(32), _y, ui(32), _h, _m, active, hover, "Disconnect", THEME.cross_12, 0, [ COLORS._main_icon, COLORS._main_value_negative ]) == 2) {
				project.attributes.bind_gamemaker_path = "";
				project.bind_gamemaker = noone;
    		}
		}
		
		return h;
	}
}