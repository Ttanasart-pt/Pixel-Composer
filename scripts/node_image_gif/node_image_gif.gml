function Node_create_Image_gif(_x, _y, _group = noone) {
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_open_filename(".gif", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Image_gif(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_create_Image_gif_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_Image_gif(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Image_gif(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name			= "Image GIF";
	color			= COLORS.node_blend_input;
	update_on_frame = true;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.gif", ""]);
		
	inputs[| 1] = nodeValue("Set animation length to gif", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
				if(!spr) return;
				if(!sprite_exists(spr)) return;
				PROJECT.animator.frames_total = sprite_get_number(spr);
				PROJECT.animator.framerate = 12;
			}, "Match length"] );
	
	inputs[| 2]  = nodeValue("Output as array", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	outputs[| 1] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	attribute_surface_depth();
	
	spr = noone;
	path_current = "";
	loading = 0;
	spr_builder = noone; 
	
	surfaces = [];
	
	on_dragdrop_file = function(path) {
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		update();
	}
	
	function updatePaths(path) {
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext   = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".gif")
			return false;
			
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
	
	static step = function() {
		if(loading == 2 && spr_builder != noone && spr_builder.building()) {
			surfaces = [];
			spr = spr_builder._spr;
			triggerRender();
			loading = 0;
			delete spr_builder;
			
			gc_collect();
		}
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		if(path_current != path) updatePaths(path);
		if(!spr || !sprite_exists(spr)) return;
		
		var ww = sprite_get_width(spr);
		var hh = sprite_get_height(spr);
		
		var _outsurf = outputs[| 0].getValue();
		var array = inputs[| 2].getValue();
		
		if(array) {
			var amo = sprite_get_number(spr);
			if(array_length(surfaces) == amo && is_surface(surfaces[0])) {
				outputs[| 0].setValue(surfaces);
				return;
			}
			
			surface_array_free(_outsurf);
			surfaces = array_create(amo);
			
			for( var i = 0; i < amo; i++ ) {
				surfaces[i] = surface_create_valid(ww, hh, attrDepth());
				
				surface_set_shader(surfaces[i]);
					draw_sprite(spr, i, 0, 0);
				surface_reset_shader();
			}
			
			outputs[| 0].setValue(surfaces);
			return;
		}
		
		_outsurf = surface_verify(_outsurf, ww, hh, attrDepth());
		outputs[| 0].setValue(_outsurf);
		
		surface_set_shader(_outsurf);
			draw_sprite(spr, PROJECT.animator.current_frame, 0, 0);
		surface_reset_shader();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(loading) draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	}
	
	static onDestroy = function() {
		if(sprite_exists(spr))
			sprite_flush(spr);
	}
}