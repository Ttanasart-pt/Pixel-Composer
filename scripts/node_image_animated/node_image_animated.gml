function Node_create_Image_Animated(_x, _y, _group = noone) {
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_open_filenames(".png", "");
		key_release();
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

function Node_Image_Animated(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Animation";
	spr   = [];
	color = COLORS.node_blend_input;
	
	update_on_frame = true;
	always_output   = true;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, [])
		.setDisplay(VALUE_DISPLAY.path_array, ["*.png", ""]);
	
	inputs[| 1]  = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding)
		.rejectArray();
		
	inputs[| 2] = nodeValue("Stretch frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.rejectArray();
	
	inputs[| 3] = nodeValue("Frame duration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.rejectArray();
		
	inputs[| 4] = nodeValue("Animation end", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Loop", "Ping pong", "Hold last frame", "Hide"])
		.rejectArray();
		
	inputs[| 5] = nodeValue("Set animation length to match", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
				if(array_length(spr) == 0) return;
				ANIMATOR.frames_total = array_length(spr);
			}, "Match length"] );
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Image", false],		0, 1,
		["Animation", false],	5, 2, 3, 4,
	];
	
	attribute_surface_depth();
	
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
			display_name  = string_replace(filename_name(path), filename_ext(path), "");
			
			var ext = string_lower(filename_ext(path));
			
			switch(ext) {
				case ".png"	 :
				case ".jpg"	 :
				case ".jpeg" :
					array_push(spr, sprite_add(path, 1, false, false, 0, 0));
					break;
			}
		}
		
		return true;
	}
	
	static onInspectorUpdate = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		update();
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
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
		surfs = surface_verify(surfs, ww, hh, attrDepth());
		outputs[| 0].setValue(surfs);
		
		var _frame = floor(ANIMATOR.current_frame / spd);
		
		switch(_end) {
			case ANIMATION_END.loop : 
				_frame = safe_mod(_frame, array_length(spr));
				break;
			case ANIMATION_END.ping :
				_frame = safe_mod(_frame, array_length(spr) * 2 - 2);
				if(_frame >= array_length(spr))
					_frame = array_length(spr) * 2 - 2 - _frame;
				break;
			case ANIMATION_END.hold :
				_frame = min(_frame, array_length(spr) - 1);
				break;
		}
		
		var curr_w = sprite_get_width(spr[_frame]);
		var curr_h = sprite_get_height(spr[_frame]);
		var curr_x = pad[2] + (ww - curr_w) / 2;
		var curr_y = pad[1] + (hh - curr_h) / 2;
		
		surface_set_target(surfs);
			DRAW_CLEAR
			BLEND_OVERRIDE;
			if(_end == ANIMATION_END.hide) {
				if(_frame < array_length(spr))
					draw_sprite(spr[_frame], 0, curr_x, curr_y);
			} else
				draw_sprite(spr[_frame], 0, curr_x, curr_y);
			BLEND_NORMAL;
		surface_reset_target();
	}
}