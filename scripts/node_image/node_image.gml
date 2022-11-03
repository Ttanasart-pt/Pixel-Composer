function Node_create_Image(_x, _y) {
	var path = "";
	if(!LOADING && !APPENDING) {
		path = get_open_filename(".png", "");
		if(path == "") return noone;
	}
	
	var node = new Node_Image(_x, _y);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_create_Image_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_Image(_x, _y);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;	
}

function Node_Image(_x, _y) : Node(_x, _y) constructor {
	name			= "";
	color			= c_ui_lime_light;
	always_output   = true;
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.png", ""]);
		
	inputs[| 1]  = nodeValue(1, "Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
		
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 1] = nodeValue(1, "Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	spr = noone;
	path_current = "";
	
	first_update = false;
	
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
			case ".png":
			case ".jpg":
			case ".jpeg":
			case ".gif":
				name = _name;
				outputs[| 1].setValue(path);
				
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
		var pad  = inputs[| 1].getValue();
		if(path == "") return;
		updatePaths(path);
		
		if(!spr || !sprite_exists(spr)) return;
		
		var ww = sprite_get_width(spr) + pad[0] + pad[2];
		var hh = sprite_get_height(spr) + pad[1] + pad[3];
		
		var _outsurf  = outputs[| 0].getValue();
		if(is_surface(_outsurf)) 
			surface_size_to(_outsurf, ww, hh);
		else {
			_outsurf = surface_create_valid(ww, hh);
			outputs[| 0].setValue(_outsurf);
		}
		
		surface_set_target(_outsurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD 
		draw_sprite(spr, 0, pad[2], pad[1]);
		BLEND_NORMAL
		surface_reset_target();
		
		if(first_update) {
			if(string_pos("strip", name) > 0) {
				var sep_pos = string_pos("strip", name) + 5;
				var sep     = string_copy(name, sep_pos, string_length(name) - sep_pos + 1);
				var amo		= toNumber(sep);
			
				if(amo) {
					var ww = sprite_get_width(spr) / amo;
					var hh = sprite_get_height(spr);
					
					var _splice = nodeBuild("Splice spritesheet", x + w + 64, y);
					_splice.inputs[| 0].setFrom(outputs[| 0], false);
					_splice.inputs[| 1].setValue([ww, hh]);
					_splice.inputs[| 2].setValue(amo);
					_splice.inputs[| 3].setValue(amo);
					
					ds_list_add(PANEL_GRAPH.nodes_select_list, self);
					ds_list_add(PANEL_GRAPH.nodes_select_list, _splice);
				}
			}	
			first_update = false;
		}
	}
	doUpdate();
}