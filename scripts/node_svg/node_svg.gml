function Node_create_SVG_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_SVG(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	return node;	
}

function Node_SVG(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "SVG";
	color = COLORS.node_blend_input;
	
	newInput(0, nodeValue_Path(    "Path")).setDisplay(VALUE_DISPLAY.path_load, { filter: "Scalable Vector Graphics|*.svg" });
	newInput(2, nodeValue_EButton( "Type",      0, [ "Scale", "Constant" ] ));
	newInput(1, nodeValue_Float(   "Scale",     1        ));
	newInput(3, nodeValue_Dimension());
		
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface,  noone ));
	newOutput(1, nodeValue_Output( "SVG Object",  VALUE_TYPE.dynaSurface, {} ));
	newOutput(2, nodeValue_Output( "Dimension",   VALUE_TYPE.integer, [1,1] )).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0, 
		[ "Dimension", false ], 2, 1, 3, 
	];
	
	attribute_surface_depth();
	
	////- Nodes
	
	rawContent = noone;
	content    = {};
	edit_time  = 0;
	curr_path  = "";
	
	attributes.file_checker = true;
	array_push(attributeEditors, Node_Attribute( "File Watcher", function() /*=>*/ {return attributes.file_checker}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")})}));
	
	on_drop_file = function(path) {
		inputs[0].setValue(path);
		if(readFile(path)) { doUpdate(); return true; }
		return false;
	}
	
	insp1button = button(function() /*=>*/ { readFile(path_get(getInputData(0))); triggerRender(); }).setTooltip(__txt("Refresh"))
		.setIcon(THEME.refresh_icon, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(!is(content, SVG)) return;
		
		var _stype = getInputData(2);
		if(_stype == 0) {
			var _scale = getInputData(1);
			content.drawOverlay(hover, active, _x, _y, _s * _scale, _mx, _my, _snx, _sny);
		}
	}
	
	function readFile(path) {
		curr_path = path;
		if(!file_exists_empty(path)) 
			return noone;
		
		edit_time = file_get_modify_s(path);
		var ext   = string_lower(filename_ext(path));
		var _name = filename_name_only(path);
		
		if(ext != ".svg") return;
		
		var _rawContent = file_read_all(path);
		var _st         = string_pos("<svg", _rawContent);
		var _end        = string_length(_rawContent);
		_rawContent     = string_copy(_rawContent, _st, _end - _st + 1);
		
		rawContent = SnapFromXML(_rawContent);
		if(is_array(rawContent) && array_length(rawContent)) 
			rawContent = rawContent[0];
		content    = svg_parse(rawContent);
		
		logNode($"Loaded file: {path}", false);
		return;
	}
	
	static step = function() {
		if(!attributes.file_checker)      return;
		if(!file_exists_empty(curr_path)) return;
		
		if(file_get_modify_s(curr_path) > edit_time) {
			run_in_s(PREFERENCES.file_watcher_delay, function() /*=>*/ { readFile(curr_path); triggerRender(); });
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var path = path_get(getInputData(0));
		if(path != curr_path) readFile(path);
		
		if(!is(content, SVG)) return;
		outputs[1].setValue(path);
		
		var _outsurf = outputs[0].getValue();
		
		var _stype = getInputData(2);
		var _sx = 1, _sy = 1;
		
		switch(_stype) {
			case 0 : 
				inputs[1].setVisible(true);
				inputs[3].setVisible(false);
				
				var _scale = getInputData(1);
				_sx = _scale;
				_sy = _scale;
				break;
			
			case 1 : 
				inputs[1].setVisible(false);
				inputs[3].setVisible(true);
				
				var _tdim = getInputData(3);
				_sx = _tdim[0] / content.width;
				_sy = _tdim[1] / content.height;
				break;
		}
		
		var ww = content.width  * _sx;
		var hh = content.height * _sy;
	    _outsurf = surface_verify(_outsurf, ww, hh, attrDepth());
		
		surface_set_shader(_outsurf, noone);
			content.draw(0, 0, _sx, _sy);
		surface_reset_shader();
		
		outputs[0].setValue(_outsurf);
		outputs[1].setValue(content);
		outputs[2].setValue([ww,hh]);
	}
	
	static dropPath = function(path) {
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return;
		
		inputs[0].setValue(path);
	}
}