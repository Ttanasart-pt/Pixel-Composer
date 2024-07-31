function Node_create_Display_Image(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_pxc("image|*.png;*.jpg", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Display_Image(_x, _y, _group).skipDefault();
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	return node;
}

function Node_create_Display_Image_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_Display_Image(_x, _y, PANEL_GRAPH.getCurrentContext()).skipDefault();
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;	
}

function Node_Display_Image(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Display Image";
	auto_height	= false;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setVisible(false)
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "image|*.png;*.jpg" })
		.rejectArray();
	
	inputs[| 1]  = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ x, y ])
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	inputs[| 2]  = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	inputs[| 3]  = nodeValue("Smooth transform", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.rejectArray();
	
	input_display_list = [ 0,
		["Display", false], 1, 2, 3, 
	]
	
	spr = noone;
	path_current = "";
	
	first_update = false;
	
	smooth = true;
	pos_x  = x;
	pos_y  = y;
	sca_x  = 1;
	sca_y  = 1;
	sca_dx = 1;
	sca_dy = 1;
	
	static move = function(_x, _y, _s) { #region
		if(x == _x && y == _y) return;
		if(!LOADING) PROJECT.modified = true;
		
		x = _x;
		y = _y;
		
		if(inputs[| 1].setValue([ _x, _y ]))
			UNDO_HOLDING = true;
	} #endregion
	
	static onInspector1Update = function() { #region
		var path = getInputData(0);
		if(path == "") return;
		updatePaths(path);
		update(); 
	} #endregion
	
	function updatePaths(path) { #region
		path = path_get(path);
		if(path == -1) return false;
		
		var ext = string_lower(filename_ext(path));
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
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var path = getInputData(0);
		var posi = getInputData(1);
		var scal = getInputData(2);
		smooth   = getInputData(3);
		
		if(path == "") return;
		if(path_current != path) updatePaths(path);
		
		if(!spr || !sprite_exists(spr)) return;
		
		pos_x = posi[0];
		pos_y = posi[1];
		sca_x = scal[0];
		sca_y = scal[1];
	} #endregion
	
	static drawNodeBase = function(xx, yy, _s) { #region
		if(!spr || !sprite_exists(spr)) return;
		
		draw_sprite_uniform(spr, 0, xx, yy, _s);
	} #endregion
	
	static drawNode = function(_x, _y, _mx, _my, _s) { #region
		if(spr == noone) return noone;
		
		x = smooth? lerp_float(x, pos_x, 4) : pos_x;
		y = smooth? lerp_float(y, pos_y, 4) : pos_y;
		
		sca_dx = smooth? lerp_float(sca_dx, sca_x, 4) : sca_x;
		sca_dy = smooth? lerp_float(sca_dy, sca_y, 4) : sca_y;
		
		w = sprite_get_width(spr)  * sca_dx;
		h = sprite_get_height(spr) * sca_dy;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		draw_sprite_stretched_ext(spr, 0, xx, yy, w * _s, h * _s, c_white, 1);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_sel_spr, 0, xx, yy, w * _s, h * _s, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		return noone;
	} #endregion
}