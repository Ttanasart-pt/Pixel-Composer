function __EXPORT_HTML(project = PROJECT, _path = "", _fName = "", _pName = "", _tPath = "", _fSize) {
	var _project_temp_path = "D:/Project/MakhamDev/LTS-PixelComposer/PROMOTIONAL MATERIALS/site/__projectview_template.html";
	if(!file_exists_empty(_project_temp_path)) return undefined;
	
	var _project_template = file_read_all(_project_temp_path);
	var _project_html = "";
	
	var _pdir = filename_dir(_path);
	var _sdir = filename_combine(_pdir, "src");
	directory_verify(_sdir);
	
	var minx =  infinity;
	var miny =  infinity;
	var maxx = -infinity;
	var maxy = -infinity;
	
	for( var i = 0, n = array_length(project.nodes); i < n; i++ ) {
		var _node = project.nodes[i];
		
		if(is(_node, Node_Collection_Inline)) {
			for( var j = 0, m = array_length(_node.group_vertex); j < m; j++ ) {
				var a = _node.group_vertex[j];
				minx = min(minx, a[0]);
				miny = min(miny, a[1]);
				maxx = max(maxx, a[0]);
				maxy = max(maxy, a[1]);
			}
			
			continue;
		}
		
		var _nx    = _node.x;
		var _ny    = _node.y;
		var _nw    = _node.w;
		var _nh    = _node.h;
		
		minx = min(minx, _nx);
		miny = min(miny, _ny);
		maxx = max(maxx, _nx + _nw);
		maxy = max(maxy, _ny + _nh);
	}
	
	minx -= 32;
	miny -= 32;
	maxx += 32;
	maxy += 32;
	
	var sw = maxx - minx;
	var sh = maxy - miny;
	var __temp_surf = surface_create(64,64);
	
	for( var i = 0, n = array_length(project.nodes); i < n; i++ ) {
		var _node = project.nodes[i];
		if(!is(_node, Node_Frame)) continue;
		
		var _iname = _node.node_id;
		var _nname = _node.getDisplayName();
		var _color = _node.getColor();
		var _colhx = "#" + colorToHex(_color, false);
		
		var _nx    = _node.x - minx;
		var _ny    = _node.y - miny;
		var _nw    = _node.w;
		var _nh    = _node.h;
		
		_project_html += $"drawFrame(\"{_nname}\", {_nx}, {_ny}, {_nw}, {_nh}, \"{_colhx}\");\n";
	}
	
	for( var i = 0, n = array_length(project.nodes); i < n; i++ ) {
		var _node = project.nodes[i];
		
		var _iname = _node.node_id;
		var _nname = _node.getDisplayName();
		var _color = _node.getColor();
		var _colhx = "#" + colorToHex(_color);
		
		if(is(_node, Node_Frame)) continue;
		
		if(is(_node, Node_Collection_Inline)) {
			var _poly = "[";
			for( var j = 0, m = array_length(_node.group_vertex); j < m; j++ ) {
				var a = _node.group_vertex[j];
				if(j) _poly += ",";
				_poly += $"[{a[0] - minx},{a[1] - miny}]";
			}
			
			_poly += "]";
			_project_html += $"drawPolygon({_poly}, \"{_colhx}\");\n";
			continue;
		}
		
		var _nx = _node.x - minx;
		var _ny = _node.y - miny;
		var _nw = _node.w;
		var _nh = _node.h;
		
		var _type = string_lower(instanceof(_node));
    	var _url  = $"\"https://docs.pixel-composer.com/nodes/_index/{_type}.html\"";
		
		var _draw = true;
		     if(is(_node, Node_Pin))             _draw = false;
		else if(is(_node, Node_Tunnel_In))     { _draw = false; _ny += 8; }
		else if(is(_node, Node_Tunnel_Out))    { _draw = false; _ny += 8; }
		else if(is(_node, Node_Feedback_Inline)) _draw = false;
		
		if(_draw) {
			var _prev  = undefined;
			
			if(_node.attributes.show_preview) {
				var _prev  = _node.getGraphPreviewSurface();
				if(is_array(_prev)) _prev = array_safe_get_fast(_prev, _node.preview_index, noone);
				
				if(!is_just_surface(_prev)) {
					surface_set_target(__temp_surf);
						DRAW_CLEAR
						var _bbox = _node.draw_bbox;
						var temp_bbox = new BBOX().fromPoints(8,8,64-8,64-8);
						var ss = min(48 / _node.w, 48 / _node.h);
						_node.draw_bbox = temp_bbox;
						
						if(_node.node_draw_icon != undefined) {
							if(_node.node_draw_icon == -1)
								draw_sprite_bbox_uniform(_node.getMetaSpr(), 0, _node.draw_bbox);
							if(_node.node_draw_icon != -1)
								draw_sprite_bbox_uniform(_node.node_draw_icon, _node.node_draw_icon_index, _node.draw_bbox);
							
						} else if(is_callable(_node.onDrawNode))
							_node.onDrawNode(0, 0, 0, 0, ss, false, false);
					surface_reset_target();
					
					_node.draw_bbox = _bbox;
					_prev = __temp_surf;
				} 
				
			}
			
			if(is_just_surface(_prev)) {
				var _spath = filename_combine(_sdir, $"{_iname}.png");
				var _rpath = $"./src/{_iname}.png";
				
				surface_save_safe(_prev, _spath);
				_project_html += $"drawNode(\"{_nname}\", {_url}, {_nx}, {_ny}, {_nw}, {_nh}, \"{_rpath}\");\n";
				
			} else _project_html += $"drawNode(\"{_nname}\", {_url}, {_nx}, {_ny}, {_nw}, {_nh});\n";
		}
		
		for( var j = 0, m = array_length(_node.inputs); j < m; j++ ) {
			var _inp = _node.inputs[j];
			var _val = _inp.value_from;
			if(_val == noone) continue;
			
			var fx = _val.rx - minx; 
			var fy = _val.ry - miny;
			var tx = _inp.rx - minx;
			var ty = _inp.ry - miny;
			
			     if(is(_val.node, Node_Tunnel_In))  fx += 8;
			else if(is(_val.node, Node_Tunnel_Out)) fy += 8;
			
			     if(is(_node, Node_Tunnel_In))  ty += 8;
			else if(is(_node, Node_Tunnel_Out)) ty += 8;
		
			_project_html += $"connect({fx}, {fy}, {tx}, {ty});\n";
		}
		
		if(is(_node, Node_Tunnel_In)) {
			var _tunFrom = _node.getTunnelOut_context();
			if(_tunFrom) {
				var fx = _tunFrom.x - minx; 
				var fy = _tunFrom.y - miny + 8;
				
				_project_html += $"connectDash({fx}, {fy}, {_nx}, {_ny});\n";
			}
		}
	}
	
	surface_free(__temp_surf);
	
	var _badges = "";
	
	var _aut  = project.meta.author == ""? "MakhamDev" : project.meta.author;
	var _desc = project.meta.description;
	var _date = $"{current_day}/{current_month}/{current_year}";
	
	var _v    = string_split(VERSION_STRING, ".", true, 2);
	var _vstr = $"<span class='version-major'>v{_v[0]}.{_v[1]}</span>";
	
	if(array_length(_v) > 2)
		_vstr += "." + _v[2];
	
	_project_template = string_replace_all( _project_template, "{{thumbnail_path}}", _tPath  );
	
	_project_template = string_replace_all( _project_template, "{{project_title}}",  _fName  );
	_project_template = string_replace_all( _project_template, "{{project_author}}", _aut    );
	_project_template = string_replace_all( _project_template, "{{project_desc}}",   _desc   );
	_project_template = string_replace_all( _project_template, "{{download_link}}",  _pName  );
	_project_template = string_replace_all( _project_template, "{{file_size}}",      _fSize  );
	
	_project_template = string_replace_all( _project_template, "{{project_badges}}", _badges );
	_project_template = string_replace_all( _project_template, "{{upload_date}}",    _date   );
	_project_template = string_replace_all( _project_template, "{{version}}",        _vstr   );
	
	_project_template = string_replace_all( _project_template, "{{width}}",   string(sw  )   );
	_project_template = string_replace_all( _project_template, "{{width2}}",  string(sw*2)   );
	_project_template = string_replace_all( _project_template, "{{height}}",  string(sh  )   );
	_project_template = string_replace_all( _project_template, "{{height2}}", string(sh*2)   );
	
	_project_template = string_replace(     _project_template, "/*CONTENT*/", _project_html  );
	
	file_text_write_all(_path, _project_template);
}

function __EXPORT_SHOWCASE(project = PROJECT) {
	if(DEMO) return false;
	
	////- =Path
	
	var _oname = filename_name_only(project.path); 
	if(string_pos("_", _oname)) _oname = string_split(_oname, "_")[0];
	_oname = string_replace_all(_oname, "-", " ");
	
	var path = get_save_filename_compat("Directory", _oname); 
	key_release();
	if(path == "") return false;
	
	directory_verify(path);
	
	var _rName = filename_name_only(path);
	var _fName = string_replace_all(_rName, " ", "-");
	if(string_pos("_", _fName)) _fName = string_split(_fName, "_")[0];
	
	////- =Porject
	
	var _pName = $"{_fName}_{SAVE_VERSION}.pxc";
	var _path  = filename_combine(path, _pName);
	SAVE_AT(project, _path);
	
	////- =Thumbnail
	
	var _anim      = false;
	var _tPath     = "./thumbnail.png"
	var _thumbSurf = PANEL_PREVIEW.getNodePreviewSurface();
	if(is_surface(_thumbSurf)) surface_save_safe(_thumbSurf, filename_combine(path, "thumbnail.png"));
	
	var _outpNode  = project.outputNode;
	if(is(_outpNode, Node) && _outpNode.animated) {
		_outpNode.renderGif(filename_combine(path, "thumbnail.gif"));
		_tPath = "./thumbnail.gif"
		_anim  = true;
	}
	
	////- =Metadata
	
	var _mName = $"metadata.json";
	json_save_struct(filename_combine(path, _mName), project.meta, true);
	
	////- =Html
	
    var fsize   = file_size(_path);
    var unit    = "b"
    var divider = 1;
    
    if(fsize > 1024 * 1024) {
        unit    = "mb";
        divider = 1024 * 1024;
        
    } else if(fsize > 1024) {
        unit    = "kb";
        divider = 1024;
    }

    var fileSizeStr = $"{string_format(fsize / divider, 0, 2)} {unit}";
    
	var _projName = $"index.html";
	__EXPORT_HTML(project, filename_combine(path, _projName), _fName, $"./{_pName}", _tPath, fileSizeStr);
	
	if(!_anim) closeProject();
	print("Export folder complete.");
	print($"{_rName} #PixelComposer\n\nhttps://pixel-composer.com/projects/{_fName}");
	
	// ProcessExecuteAsync("python \"D:/Project/MakhamDev/LTS-PixelComposer/PROMOTIONAL MATERIALS/site/gen.py\"");
	// print("Push to Github complete");
	
	return true;
}