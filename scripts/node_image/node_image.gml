function Node_create_Image(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_compat("image|*.png;*.jpg", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Image(_x, _y, _group);
	node.skipDefault();
	node.inputs[0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
}

function Node_create_Image_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_Image(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	return node;	
}

function Node_Image(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Image";
	color = COLORS.node_blend_input;
	
	newInput(0, nodeValue_Path("Path"))
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "image|*.png;*.jpg" })
		.rejectArray();
		
	newInput(1, nodeValue_Padding("Padding", [0, 0, 0, 0]));
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Path", VALUE_TYPE.path, ""))
		.setVisible(true, true);
	
	attribute_surface_depth();
	
	spr       = noone;
	edit_time = 0;
	
	attributes.check_splice = true;
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() /*=>*/ {return attributes.file_checker}, new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")}) ]);
	
	static on_drop_file = function(path) {
		inputs[0].setValue(path);
		if(updatePaths(path)) { doUpdate(); return true; }
		return false;
	}
	
	static createSprite = function(path) {
		if(!file_exists(path)) 
			return noone;
		
		var ext   = string_lower(filename_ext(path));
		var _name = filename_name_only(path);
		
		switch(ext) {
			case ".png":
			case ".jpg":
			case ".jpeg":
			case ".gif":
				setDisplayName(_name, false);
				
				var _real_path = sprite_path_check_depth(path);
				var _spr = sprite_add(_real_path, 1, false, false, 0, 0);
				
				if(_spr == -1) {
					noti_warning($"Image node: File not a valid image.", noone, self);
					break;
				}
				
				edit_time = file_get_modify_s(path);
				logNode($"Loaded file: {path}", false);
				return _spr;
		}
		
		return noone;
	}
	
	static updatePaths = function(path) {
		if(sprite_exists(spr)) sprite_delete(spr);
		spr = createSprite(path);
	}
	
	setTrigger(1, __txt("Refresh"), [ THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ { updatePaths(path_get(getInputData(0))); triggerRender(); });
	
	static spliceImage = function() {
		if(!attributes.check_splice) return;
		attributes.check_splice = false;
		
		if(LOADING || APPENDING) return;
		if(string_pos("strip", display_name) == 0) return;
		
		var sep_pos = string_pos("strip", display_name) + 5;
		var sep     = string_copy(display_name, sep_pos, string_length(display_name) - sep_pos + 1);
		var amo		= toNumber(string_digits(sep));
		if(amo == 0) return;
		
		var ww = sprite_get_width(spr) / amo;
		var hh = sprite_get_height(spr);
				
		var _splice = nodeBuild("Node_Image_Sheet", x + w + 64, y);
		_splice.inputs[0].setFrom(outputs[0], false);
		_splice.inputs[1].setValue([ ww, hh ]);
		_splice.inputs[2].setValue(amo);
		_splice.inputs[3].setValue([ amo, 1 ]);
	}
	
	static step = function() {
		var path = path_get(getInputData(0));
		
		if(is_array(path)) return;
		if(!file_exists_empty(path)) return;
		
		if(attributes.file_checker && file_get_modify_s(path) > edit_time) {
			updatePaths(path);
			triggerRender();
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		insp2UpdateTooltip = attributes.cache_use? __txt("Remove Cache") : __txt("Cache");
		insp2UpdateIcon[0] = attributes.cache_use? THEME.cache : THEME.cache_group;
		insp2UpdateIcon[2] = attributes.cache_use? c_white : COLORS._main_icon;
		
		var path = path_get(getInputData(0));
		if(is_array(path)) return;
		
		var pad  = getInputData(1);
		outputs[1].setValue(path);
		updatePaths(path);
		
		var _spr = attributes.cache_use? cache_spr : spr;
		if(!sprite_exists(_spr)) return;
		
		var ww = sprite_get_width(_spr)  + pad[0] + pad[2];
		var hh = sprite_get_height(_spr) + pad[1] + pad[3];
		
		var _outsurf = outputs[0].getValue();
	    _outsurf = surface_verify(_outsurf, ww, hh, attrDepth());
		outputs[0].setValue(_outsurf);
		
		surface_set_shader(_outsurf, noone);
			draw_sprite(_spr, 0, pad[2], pad[1]);
		surface_reset_shader();
		
		spliceImage();
	}
	
	static dropPath = function(path) { 
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return;
		
		inputs[0].setValue(path); 
		check_directory_redirector(path);
	}
	
	////- Cache
	
	attributes.cache_use  = false;
	attributes.cache_data = "";
	cache_spr = noone;
	
	static cacheData = function() {
		attributes.cache_use  = true;
		cache_spr = spr;
		attributes.cache_data = sprite_array_serialize(spr);
		triggerRender();
	}
	
	static uncacheData = function() {
		attributes.cache_use  = false;
		triggerRender();
	}
	
	setTrigger(2, __txt("Cache"), [ THEME.cache_group, 0, COLORS._main_icon ], function() /*=>*/ { if(attributes.cache_use) uncacheData() else cacheData(); });
	
	////- Serialize

	static postDeserialize = function() {
		if(!attributes[$ "cache_use"] ?? 0) return;
		cache_spr = sprite_array_deserialize(attributes[$ "cache_data"] ?? "");
	}
}