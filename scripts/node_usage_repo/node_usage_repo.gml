function Node_Usage_Repo_Create(_project = PROJECT, pname = "", purl = "") {
	var _dirpath = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/docsdata/examples";
	if(!directory_exists(_dirpath)) return;

	if(pname == "") {
		pname = filename_name_only(_project.path);
		if(string_pos("_", pname)) pname = string_split(pname, "_")[0];
		pname = string_replace_all(pname, "-", " ");
	
		var _oName = string_replace_all(pname, " ", "%20");
		purl = $"https://pixel-composer.com/projects/{_oName}";
	}
	
	var nodes = _project.allNodes;
	
	for( var i = 0, n = array_length(nodes); i < n; i++ ) {
		var _node = nodes[i];
		var _type = instanceof(_node);
		
		if(_node.active_index != -1 && !_node.active_value) continue;
		if(!_node.attributes.show_preview) continue;
		
		var _dirr = filename_combine(_dirpath, _type);
		directory_verify(_dirr);
		
		var _dirr = filename_combine(_dirr, $"{pname}-{_node.node_id}");
		directory_verify(_dirr);
		
		var _imgp   = filename_combine(_dirr, $"preview.png");
		var surface = graph_export_image([_node], [_node], new graph_export_settings());
		surface_save_safe(surface, _imgp);
		surface_free(surface);
		
		var inputs = [];
		
		for( var j = 0, m = array_length(_node.inputs); j < m; j++ ) {
			var _inp = _node.inputs[j];
			
			var _nam = _inp.getName();
			var _val = _inp.getValue();
			
			if(_inp.type == VALUE_TYPE.surface) {
				if(!is_surface(_val)) continue;
				
				var _imgp = filename_combine(_dirr, _nam + ".png");
				surface_save_safe(_val, _imgp);
				array_push(inputs, _nam);
				continue;
			}
			
			if(!_inp.is_modified) continue;
			
			if(_inp.display_type == VALUE_DISPLAY.enum_button || _inp.display_type == VALUE_DISPLAY.enum_scroll) {
				var _edit = _inp.getEditWidget();
				
				if(is(_edit, widget)) {
					var _edat = _edit[$ "data"];
					if(is_array(_edat)) {
						var _vval = array_safe_get(_edat, _val);
						
						     if(is_string(_vval))      _val = _vval;
						else if(is(_vval, scrollItem)) _val = _vval.name;
					}
					
				}
			}
			
			array_push(inputs, { name : _nam, value : _val });
		}
		
		var _data = {
			project : pname,
			url     : purl,
			inputs  : inputs,
		}
		
		json_save_struct(filename_combine(_dirr, $"data.json"), _data);
		
		
	}
}