function Node_create_Image_Sequence(_x, _y) {
	var path = "";
	if(!LOADING && !APPENDING) {
		path = get_open_filenames(".png", "");
		if(path == "") return noone;
	}
	
	var node = new Node_Image_Sequence(_x, _y);
	var paths = paths_to_array(path);
	node.inputs[| 0].setValue(paths);
	node.update();
	
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_create_Image_Sequence_path(_x, _y, _path) {
	var node = new Node_Image_Sequence(_x, _y);
	node.inputs[| 0].setValue(_path);
	node.update();
	
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

enum CANVAS_SIZE {
	individual,
	minimum,
	maximum
}

enum CANVAS_SIZING {
	padding,
	scale
}

function Node_Image_Sequence(_x, _y) : Node(_x, _y) constructor {
	name  = "";
	spr   = [];
	color = c_ui_lime_light;
	always_output   = true;
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_array, ["*.png", ""]);
	
	inputs[| 1]  = nodeValue(1, "Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
	
	inputs[| 2] = nodeValue(2, "Canvas size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Individual", "Minimum", "Maximum" ])
		.setVisible(false);
	
	inputs[| 3] = nodeValue(3, "Sizing method", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Padding / Crop", "Scale" ])
		.setVisible(false);
	
	inputs[| 4] = nodeValue(4, "Edit", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() {
			with(dialogCall(o_dialog_image_array_edit, WIN_W / 2, WIN_H / 2)) {
				target = other;	
			}
		}, "Edit array" ]);
	
	input_display_list = [
		["Sequence settings",	false], 4, 0, 1, 2, 3
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, [ surface_create(1, 1) ]);
	outputs[| 1] = nodeValue(1, "Paths", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, [] ).
		setVisible(true, true);
	
	path_loaded = [];
	
	on_dragdrop_file = function(path) {
		if(directory_exists(path)) {
			with(dialogCall(o_dialog_drag_folder, WIN_W / 2, WIN_H / 2)) {
				dir_paths = path;
				target    = other;
			}
			return true;
		}
		
		var paths = paths_to_array(path);
		if(updatePaths(paths)) {
			update();
			return true;
		}
		
		return false;
	}
	
	function updatePaths(paths) {
		for(var i = 0; i < array_length(spr); i++) {
			if(spr[i] && sprite_exists(spr[i]))
				sprite_delete(spr[i]);
		}
		spr = [];
		
		path_loaded = array_create(array_length(paths));
		inputs[| 0].setValue(paths);
		
		for( var i = 0; i < array_length(paths); i++ )  {
			path_loaded[i] = paths[i];
			var path = try_get_path(paths[i]);
			if(path == -1) continue;
			
			name  = string_replace(filename_name(path), filename_ext(path), "");
			array_push(spr, sprite_add(path, 1, false, false, 0, 0));
		}
		
		outputs[| 1].setValue(paths);
		
		return true;
	}
	
	function update() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		if(!array_equals(path, path_loaded)) 
			updatePaths(path);
		
		var pad = inputs[| 1].getValue();
		var can = inputs[| 2].getValue();
		inputs[| 3].show_in_inspector = can != CANVAS_SIZE.individual;
		
		var siz = inputs[| 3].getValue();
		
		var ww = -1, hh = -1;
		var _ww = -1, _hh = -1;
		
		var surfs = outputs[| 0].getValue();
		
		for(var i = 0; i < array_length(surfs); i++) {
			if(is_surface(surfs[i]))
				surface_free(surfs[i]);
		}
		
		for(var i = 0; i < array_length(spr); i++) {
			var _spr = spr[i];
			var _w = sprite_get_width(_spr);
			var _h = sprite_get_height(_spr);
			
			switch(can) {
				case CANVAS_SIZE.minimum :
					if(ww == -1)	ww = _w;
					else			ww = min(ww, _w);
					if(hh == -1)	hh = _h;
					else			hh = min(hh, _h);
					break;
				case CANVAS_SIZE.maximum :
					if(ww == -1)	ww = _w;
					else			ww = max(ww, _w);
					if(hh == -1)	hh = _h;
					else			hh = max(hh, _h);
					break;
			}
		}
		_ww = ww;
		_hh = hh;
		ww += pad[0] + pad[2];
		hh += pad[1] + pad[3];
		
		for(var i = 0; i < array_length(spr); i++) {
			var _spr = spr[i];
			switch(can) {
				case CANVAS_SIZE.individual :
					ww = sprite_get_width(_spr) + pad[0] + pad[2];
					hh = sprite_get_height(_spr) + pad[1] + pad[3];
					
					surfs[i] = surface_create(ww, hh);
					surface_set_target(surfs[i]);
						draw_clear_alpha(0, 0);
						BLEND_ADD
						draw_sprite(_spr, 0, pad[2], pad[1]);
						BLEND_NORMAL
					surface_reset_target();
					break;
				case CANVAS_SIZE.maximum :
				case CANVAS_SIZE.minimum :
					surfs[i] = surface_create(ww, hh);
					var _w = sprite_get_width(_spr);
					var _h = sprite_get_height(_spr);
						
					if(siz == CANVAS_SIZING.scale) {
						var ss = min(_ww / _w, _hh / _h);
						var sw = (ww - _w * ss) / 2;
						var sh = (hh - _h * ss) / 2;
						
						surface_set_target(surfs[i]);
							draw_clear_alpha(0, 0);
							BLEND_ADD
							draw_sprite_ext(_spr, 0, sw, sh, ss, ss, 0, c_white, 1);
							BLEND_NORMAL
						surface_reset_target();
					} else {
						var xx = (ww - _w) / 2;
						var yy = (hh - _h) / 2;
						
						surface_set_target(surfs[i]);
							draw_clear_alpha(0, 0);
							BLEND_ADD
							draw_sprite(_spr, 0, xx, yy);
							BLEND_NORMAL
						surface_reset_target();
					}
					break;
			}
			
		}
		
		outputs[| 0].setValue(surfs);
	}
	doUpdate();
}