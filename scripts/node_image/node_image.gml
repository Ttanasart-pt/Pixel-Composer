function Node_create_Image(_x, _y, _group = noone) { #region
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_open_filename("image|*.png;*.jpg", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Image(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	return node;
} #endregion

function Node_create_Image_path(_x, _y, path) { #region
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_Image(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	return node;	
} #endregion

function Node_Image(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Image";
	color = COLORS.node_blend_input;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "image|*.png;*.jpg" })
		.rejectArray();
		
	inputs[| 1]  = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	outputs[| 1] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	attribute_surface_depth();
	
	spr = noone;
	path_current = "";
	
	first_update = false;
	
	on_drop_file = function(path) { #region
		inputs[| 0].setValue(path);
		
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	} #endregion
	
	function updatePaths(path) { #region
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		switch(ext) {
			case ".png":
			case ".jpg":
			case ".jpeg":
			case ".gif":
				setDisplayName(_name);
				outputs[| 1].setValue(path);
				
				if(spr) sprite_delete(spr);
				spr = sprite_add(path, 1, false, false, 0, 0);
				
				if(path_current == "") 
					first_update = true;
				path_current = path;
				
				if(spr == -1) {
					noti_warning($"Image node: File not a valid image.");
					return false;
				}
				
				return true;
		}
		return false;
	} #endregion
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		var path = getInputData(0);
		if(path == "") return;
		updatePaths(path);
		update();
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var path = getInputData(0);
		var pad  = getInputData(1);
		if(path == "") return;
		if(path_current != path) updatePaths(path);
		
		if(!spr || !sprite_exists(spr)) return;
		
		var ww = sprite_get_width(spr)  + pad[0] + pad[2];
		var hh = sprite_get_height(spr) + pad[1] + pad[3];
		
		var _outsurf  = outputs[| 0].getValue();
		_outsurf = surface_verify(_outsurf, ww, hh, attrDepth());
		outputs[| 0].setValue(_outsurf);
		
		surface_set_shader(_outsurf, noone);
			draw_sprite(spr, 0, pad[2], pad[1]);
		surface_reset_shader();
		
		if(!first_update) return;
		first_update = false;
		
		if(LOADING || APPENDING) return;
		if(string_pos("strip", display_name) == 0) return;
		
		var sep_pos = string_pos("strip", display_name) + 5;
		var sep     = string_copy(display_name, sep_pos, string_length(display_name) - sep_pos + 1);
		var amo		= toNumber(string_digits(sep));
		
		if(amo) {
			var ww = sprite_get_width(spr) / amo;
			var hh = sprite_get_height(spr);
					
			var _splice = nodeBuild("Node_Image_Sheet", x + w + 64, y);
			_splice.inputs[| 0].setFrom(outputs[| 0], false);
			_splice.inputs[| 1].setValue([ww, hh]);
			_splice.inputs[| 2].setValue(amo);
			_splice.inputs[| 3].setValue([ amo, 1 ]);
			_splice.inspector1Update();
		}	
	} #endregion
}