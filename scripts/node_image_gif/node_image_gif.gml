function Node_create_Image_gif(_x, _y) {
	var path = "";
	if(!LOADING && !APPENDING) {
		path = get_open_filename(".gif", "");
		if(path == "") return noone;
	}
	
	var node = new Node_Image_gif(_x, _y);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_create_Image_gif_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_Image_gif(_x, _y);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;	
}

function Node_Image_gif(_x, _y) : Node(_x, _y) constructor {
	name			= "";
	color			= c_ui_lime_light;
	update_on_frame = true;
	always_output   = true;
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.gif", ""]);
		
	inputs[| 1] = nodeValue(1, "Set animation length to gif", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
				if(!spr) return;
				if(!sprite_exists(spr)) return;
				ANIMATOR.frames_total = sprite_get_number(spr);
				ANIMATOR.framerate = 12;
			}, "Match length"] );
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	outputs[| 1] = nodeValue(1, "Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true);
	
	spr = noone;
	path_current = "";
	loading = 0;
	spr_builder = noone; 
	
	on_dragdrop_file = function(path) {
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	function updatePaths(path) {
		if(path_current == path) return false;
		
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext = filename_ext(path);
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		switch(ext) {
			case ".gif":
				name			= _name;
				inputs[| 0].setValue(path);
				outputs[| 1].setValue(path);
				
				if(spr) sprite_delete(spr);
				sprite_add_gif(path, function(_spr) { 
						spr_builder = _spr; 
						loading = 2;
					});
				loading = 1;
				
				if(path_current == "") 
					first_update = true;
				path_current	= path;
				
				return true;
		}
		return false;
	}
	
	static step = function() {
		if(loading == 2 && spr_builder != noone) {
			if(spr_builder.building()) {
				spr = spr_builder._spr;
				doUpdate();
				loading = 0;
				delete spr_builder;
				
				gc_collect();
			}
		}
	}
	
	static update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		
		if(!spr || !sprite_exists(spr)) return;
		
		var ww = sprite_get_width(spr);
		var hh = sprite_get_height(spr);
		
		var _outsurf  = outputs[| 0].getValue();
		if(is_surface(_outsurf)) 
			surface_size_to(_outsurf, ww, hh);
		else {
			_outsurf = surface_create(ww, hh);
			outputs[| 0].setValue(_outsurf);
		}
		
		surface_set_target(_outsurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		draw_sprite(spr, ANIMATOR.current_frame, 0, 0);
		BLEND_NORMAL
		surface_reset_target();
	}
	doUpdate();
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		if(loading) {
			draw_sprite_ext(s_loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, c_ui_blue_grey, 1);
		}
	}
	
	static onDestroy = function() {
		if(sprite_exists(spr))
			sprite_flush(spr);
	}
}