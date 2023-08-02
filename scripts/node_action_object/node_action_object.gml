#region node action
	function NodeAction() constructor {
		name = "";
		spr  = noone;
		node = noone;
		tags = [];
		
		tooltip	    = "";
		tooltip_spr = noone;
		new_node    = false;
	
		nodes		= [];
		connections = [];
		
		inputNode   = noone;
		outputNode  = noone;
	
		static getName    = function() { return name;		/*__txt_node_name(node, name);		 */ }
		static getTooltip = function() { return tooltip;	/*__txt_node_tooltip(node, tooltip); */ }
		
		static build = function(_x, _y, _group = PANEL_GRAPH.getCurrentContext(), _param = "") {
			var _n = [];
			for( var i = 0, n = array_length(nodes); i < n; i++ ) {
				var __n = nodes[i];
				var _nx = struct_has(__n, "x")? _x + __n.x : _x + 160 * i;
				var _ny = struct_has(__n, "y")? _y + __n.y : _y;
				
				_n[i] = nodeBuild(__n.node, _nx, _ny, _group);
				
				if(struct_has(__n, "setValues")) {
					var _setVals = __n.setValues;
					for(var j = 0, m = array_length(_setVals); j < m; j++ ) {
						var _setVal = _setVals[j];
						var _index  = _n[i].inputs[| _setVal.index];
						
						if(struct_has(_setVal, "value"))
							_index.setValue(_setVal.value);
						if(struct_has(_setVal, "unit"))
							_index.unit.setMode(_setVal.unit);
					}
				}
			}
		
			for( var i = 0, n = array_length(connections); i < n; i++ ) {
				var _c = connections[i];
			
				_n[_c.to].inputs[| _c.toIndex].setFrom(_n[_c.from].outputs[| _c.fromIndex]);
			}
		
			return _n;
		}
	
		static serialize = function() {
			var map = { name, tooltip, nodes, connections, tags };
			return map;
		}
		
		static deserialize = function(path) {
			var map = json_load_struct(path);
			
			name		= struct_try_get(map, "name", "");
			tags		= struct_try_get(map, "tags", []);
			tooltip		= struct_try_get(map, "tooltip", "");
			nodes		= struct_try_get(map, "nodes", []);
			connections	= struct_try_get(map, "connections", []);
			
			inputNode	= struct_try_get(map, "inputNode", noone);
			outputNode	= struct_try_get(map, "outputNode", noone);
			
			if(struct_has(map, "sprPath")) {
				var _path = string_replace(map.sprPath, "./", filename_dir(path) + "/");
				
				if(file_exists(_path)) {
					spr = sprite_add(_path, 1, false, false, 0, 0);
					sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
				}
			}
		
			return self;
		}
	}

	function __initNodeActions(list) {
		var root = DIRECTORY + "Actions";
		if(!directory_exists(root)) directory_create(root);
		
		root += "/Nodes";
		if(!directory_exists(root)) directory_create(root);
		
		var f = file_find_first(root + "/*", 0);
		
		while (f != "") {
			if(filename_ext(f) == ".json") {
				var _c   = new NodeAction().deserialize($"{root}/{f}");
				ds_list_add(list, _c);
			}
			
			f = file_find_next();
		}
		file_find_close();
	}
#endregion