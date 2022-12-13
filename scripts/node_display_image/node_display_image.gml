function Node_create_Display_Image(_x, _y, _group = -1) {
	var path = "";
	if(!LOADING && !APPENDING) {
		path = get_open_filename(".png", "");
		if(path == "") return noone;
	}
	
	var node = new Node_Display_Image(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_create_Display_Image_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_Display_Image(_x, _y);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;	
}

function Node_Display_Image(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name			= "";
	always_output   = true;
	auto_height		= false;
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.png", ""]);
	
	spr = noone;
	path_current = "";
	
	first_update = false;
	
	function updatePaths(path) {
		if(path_current == path) return false;
		
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext = filename_ext(path);
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		switch(ext) {
			case ".png":
			case ".jpg":
			case ".jpeg":
			case ".gif":
				name = _name;
				
				if(spr) sprite_delete(spr);
				spr = sprite_add(path, 1, false, false, 0, 0);
				
				if(path_current == "") 
					first_update = true;
				path_current = path;
				
				return true;
		}
		return false;
	}
	
	static update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		
		if(!spr || !sprite_exists(spr)) return;
		
		w = sprite_get_width(spr);
		h = sprite_get_height(spr);
	}
	doUpdate();
	
	static drawNodeBase = function(xx, yy, _s) {
		if(!spr || !sprite_exists(spr)) return;
		
		draw_sprite_uniform(spr, 0, xx, yy, _s);
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		drawNodeBase(xx, yy, _s);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_sel_spr, 0, xx, yy, w * _s, h * _s, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		return noone;
	}
}