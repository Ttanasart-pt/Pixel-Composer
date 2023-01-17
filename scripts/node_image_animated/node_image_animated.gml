function Node_create_Image_Animated(_x, _y, _group = -1) {
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_open_filenames(".png", "");
		if(path == "") return noone;
	}
	
	var node = new Node_Image_Animated(_x, _y, _group);
	var paths = paths_to_array(path);
	node.inputs[| 0].setValue(paths);
	node.doUpdate();
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_create_Image_Animated_path(_x, _y, _path) {
	var node = new Node_Image_Animated(_x, _y, PANEL_GRAPH.getCurrentContext());
	
	node.inputs[| 0].setValue(_path);
	node.doUpdate();
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

enum ANIMATION_END {
	loop,
	ping,
	hold,
	hide
}

function Node_Image_Animated(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name  = "";
	spr   = [];
	color = COLORS.node_blend_input;
	
	update_on_frame = true;
	always_output   = true;
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, [])
		.setDisplay(VALUE_DISPLAY.path_array, ["*.png", ""]);
	
	inputs[| 1]  = nodeValue(1, "Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
		
	inputs[| 2] = nodeValue(2, "Stretch frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 3] = nodeValue(3, "Frame duration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	inputs[| 4] = nodeValue(4, "Animation end", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Loop", "Ping pong", "Hold last frame", "Hide"]);
		
	inputs[| 5] = nodeValue(5, "Set animation length to match", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
				if(array_length(spr) == 0) return;
				ANIMATOR.frames_total = array_length(spr);
			}, "Match length"] );
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Image", false],		0, 1,
		["Animation", false],	5, 2, 3, 4,
	];
	
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
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	function updatePaths(paths) {
		if(!is_array(paths) && ds_exists(paths, ds_type_list))
			paths = ds_list_to_array(paths);
			
		for(var i = 0; i < array_length(spr); i++) {
			if(spr[i] && sprite_exists(spr[i]))
				sprite_delete(spr[i]);
		}
		spr = [];
		
		path_loaded = array_create(array_length(paths));
		
		for( var i = 0; i < array_length(paths); i++ )  {
			path_loaded[i] = paths[i];
			var path = try_get_path(paths[i]);
			if(path == -1) continue;
			
			name  = string_replace(filename_name(path), filename_ext(path), "");
			array_push(spr, sprite_add(path, 1, false, false, 0, 0));
		}
		
		return true;
	}
	
	static inspectorUpdate = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		update();
	}
	
	static update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		if(is_array(path) && !array_equals(path, path_loaded)) 
			updatePaths(path);
		if(array_length(spr) == 0) return;
		
		var pad  = inputs[| 1].getValue();
		var str  = inputs[| 2].getValue();
		inputs[| 3].setVisible(!str);
		inputs[| 4].setVisible(!str);
		
		var spd  = str? (ANIMATOR.frames_total + 1) / array_length(spr) : inputs[| 3].getValue();
		var _end = inputs[| 4].getValue();
		if(spd == 0) spd = 1;
		
		var ww = sprite_get_width(spr[0]); 
		var hh = sprite_get_height(spr[0]);
		ww += pad[0] + pad[2];
		hh += pad[1] + pad[3];
		
		var surfs = outputs[| 0].getValue();
		surfs = surface_verify(surfs, ww, hh);
		outputs[| 0].setValue(surfs);
		
		var frame = floor(ANIMATOR.current_frame / spd);
		
		switch(_end) {
			case ANIMATION_END.loop : 
				frame = safe_mod(frame, array_length(spr));
				break;
			case ANIMATION_END.ping :
				frame = safe_mod(frame, array_length(spr) * 2 - 2);
				if(frame >= array_length(spr))
					frame = array_length(spr) * 2 - 2 - frame;
				break;
			case ANIMATION_END.hold :
				frame = min(frame, array_length(spr) - 1);
				break;
		}
		
		var curr_w = sprite_get_width(spr[frame]);
		var curr_h = sprite_get_height(spr[frame]);
		var curr_x = pad[2] + (ww - curr_w) / 2;
		var curr_y = pad[1] + (hh - curr_h) / 2;
		
		surface_set_target(surfs);
			draw_clear_alpha(0, 0);
			BLEND_OVER
			if(_end == ANIMATION_END.hide) {
				if(frame < array_length(spr))
					draw_sprite(spr[frame], 0, curr_x, curr_y);
			} else
				draw_sprite(spr[frame], 0, curr_x, curr_y);
			BLEND_NORMAL
		surface_reset_target();
	}
}