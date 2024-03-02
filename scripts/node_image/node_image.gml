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
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "image|*.png;*.jpg" });
		
	inputs[| 1]  = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	outputs[| 1] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	attribute_surface_depth();
	
	spr = [];
	path_current = [];
	
	first_update = false;
	edit_time    = [];
	
	on_drop_file = function(path) { #region
		inputs[| 0].setValue(path);
		
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	} #endregion
	
	function createSprite(path) { #region
		path = try_get_path(path);
		if(path == -1) return noone;
		
		var spr;
		var ext   = string_lower(filename_ext(path));
		var _name = filename_name_only(path);
		
		switch(ext) {
			case ".png":
			case ".jpg":
			case ".jpeg":
			case ".gif":
				setDisplayName(_name);
				spr = sprite_add(path, 1, false, false, 0, 0);
				
				if(spr == -1) {
					noti_warning($"Image node: File not a valid image.");
					break;
				}
				
				edit_time = file_get_modify_s(path);
				return spr;
		}
		
		return noone;
	} #endregion
	
	function updatePaths(path, index = 0) { #region
		if(array_empty(path_current)) first_update = true;
		path_current = path;
		
		for( var i = 0, n = array_length(spr); i < n; i++ )
			sprite_delete(spr[i]);
			
		if(!is_array(path)) path = [ path ];
		
		spr = [];
		for( var i = 0, n = array_length(path); i < n; i++ ) {
			var s = createSprite(path[i]);
			if(s) array_push(spr, s);
		}
	} #endregion
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		var path = getInputData(0);
		if(path == "") return;
		
		update();
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var path = getInputData(0);
		var pad  = getInputData(1);
		
		outputs[| 1].setValue(path);
		if(path_current != path)
			updatePaths(path);
		else {
			//if(!is_array(path)) path = [ path ];
			//var _upd = false;
			
			//for( var i = 0, n = array_length(path); i < n; i++ ) {
			//	var _et = array_safe_get(edit_time, i);
			//	var _ms = file_get_modify_s(path[i]);
				
			//	if(_ms > edit_time[i]) _upd = true;
			//	edit_time[i] = _ms;
			//}
			
			//if(_upd) updatePaths(path);
		}
		
		if(array_empty(spr)) return;
		
		var _arr     = is_array(spr) && array_length(spr) > 1;
		var _outsurf = outputs[| 0].getValue();
		
		if(!is_array(_outsurf)) _outsurf = [ _outsurf ];
		
		for( var i = 0, n = array_length(spr); i < n; i++ ) {
			var _spr = spr[i];
			
			if(!sprite_exists(_spr)) continue;
			
			var ww = sprite_get_width(_spr)  + pad[0] + pad[2];
			var hh = sprite_get_height(_spr) + pad[1] + pad[3];
			
			var _surf = array_safe_get(_outsurf, i);
			    _surf = surface_verify(_surf, ww, hh, attrDepth());
			
			surface_set_shader(_surf, noone);
				draw_sprite(_spr, 0, pad[2], pad[1]);
			surface_reset_shader();
			
			_outsurf[i] = _surf;
		}
		
		outputs[| 0].setValue(_arr? _outsurf : _outsurf[0]);
		
		#region splice
			if(!first_update) return;
			first_update = false;
		
			if(LOADING || APPENDING) return;
			if(string_pos("strip", display_name) == 0) return;
		
			var sep_pos = string_pos("strip", display_name) + 5;
			var sep     = string_copy(display_name, sep_pos, string_length(display_name) - sep_pos + 1);
			var amo		= toNumber(string_digits(sep));
		
			if(amo == 0) return;
			
			var ww = sprite_get_width(spr[0]) / amo;
			var hh = sprite_get_height(spr[0]);
					
			var _splice = nodeBuild("Node_Image_Sheet", x + w + 64, y);
			_splice.inputs[| 0].setFrom(outputs[| 0], false);
			_splice.inputs[| 1].setValue([ ww, hh ]);
			_splice.inputs[| 2].setValue(amo);
			_splice.inputs[| 3].setValue([ amo, 1 ]);
			_splice.inspector1Update();
			
		#endregion
	} #endregion
}