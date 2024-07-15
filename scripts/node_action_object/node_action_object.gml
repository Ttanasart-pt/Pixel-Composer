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
		
		location = noone;
		
		static getName    = function() { return name;	 }
		static getTooltip = function() { return tooltip; }
		
		static build = function(_x = 0, _y = 0, _group = PANEL_GRAPH.getCurrentContext(), _param = {}) { #region
			var _n = {};
			
			for( var i = 0, n = array_length(nodes); i < n; i++ ) {
				var __n = nodes[i];
				var _nx = struct_has(__n, "x")? _x + __n.x : _x + 160 * i;
				var _ny = struct_has(__n, "y")? _y + __n.y : _y;
				
				var _id   = struct_try_get(__n, "id", i);
				var _node = nodeBuild(__n.node, _nx, _ny, _group);
				_n[$ _id] = _node;
				
				if(struct_has(__n, "setValues")) {
					var _setVals = __n.setValues;
					
					if(is_array(_setVals)) {
						for(var j = 0, m = array_length(_setVals); j < m; j++ ) {
							var _setVal = _setVals[j];
							var _input  = is_string(_setVal.index)? _node.inputMap[? _setVal.index] : _node.inputs[| _setVal.index];
							if(_input == undefined) continue;
							
							if(struct_has(_setVal, "value"))		_input.setValue(_setVal.value);
							if(struct_has(_setVal, "unit"))			_input.unit.setMode(_setVal.unit);
							if(struct_has(_setVal, "expression"))	_input.setExpression(_setVal.expression);
						}
					} else if(is_struct(_setVals)) {
						var _keys = struct_get_names(_setVals);
						for (var j = 0, m = array_length(_keys); j < m; j++) {
							var _key   = _keys[j];
							var _input = _node.inputs[| _key];
							if(_input == undefined) continue;
							
							var _setVal = _setVals[$ _key];
							
							if(struct_has(_setVal, "value"))		_input.setValue(_setVal.value);
							if(struct_has(_setVal, "unit"))			_input.unit.setMode(_setVal.unit);
							if(struct_has(_setVal, "expression"))	_input.setExpression(_setVal.expression);
						}
					}
				}
			}
		
			for( var i = 0, n = array_length(connections); i < n; i++ ) {
				var _c   = connections[i];
				var _frN = _n[$ _c.from];
				var _toN = _n[$ _c.to];
				if(_frN == undefined || _toN == undefined) continue;
				
				var _frO = is_string(_c.fromIndex)? _frN.outputMap[? _c.fromIndex] : _frN.outputs[| _c.fromIndex];
				var _toI = is_string(_c.toIndex)?   _toN.inputMap[? _c.toIndex]    : _toN.inputs[| _c.toIndex];
				if(_frO == undefined || _toI == undefined) continue;
				
				_toI.setFrom(_frO);
			}
		
			return _n;
		} #endregion
	
		static serialize = function() { #region
			var map = { name, tooltip, nodes, connections, tags };
			return map;
		} #endregion
		
		static deserialize = function(path) { #region
			var map = json_load_struct(path);
			
			name		= struct_try_get(map, "name", "");
			tags		= struct_try_get(map, "tags", []);
			tooltip		= struct_try_get(map, "tooltip", "");
			nodes		= struct_try_get(map, "nodes", []);
			connections	= struct_try_get(map, "connections", []);
			
			inputNode	= struct_try_get(map, "inputNode", noone);
			outputNode	= struct_try_get(map, "outputNode", noone);
			
			location	= struct_try_get(map, "location", noone);
			
			if(struct_has(map, "sprPath")) {
				var _path = string_replace(map.sprPath, "./", filename_dir(path) + "/");
				
				if(file_exists_empty(_path)) {
					spr = sprite_add(_path, 1, false, false, 0, 0);
					sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
				}
			}
		
			return self;
		} #endregion
	}
	
	function NodeAction_create() : NodeAction() constructor {
		name    = "Create Action...";
		spr     = s_action_add;
		hide_bg = true;
		
		static build = function() { PANEL_GRAPH.createAction(); }
	}

	function __initNodeActions(list) {
		var root = $"{DIRECTORY}Actions";
		directory_verify(root);
		
		root += "/Nodes";
		directory_verify(root);
		
		ds_list_add(list, new NodeAction_create());
		
		var f = file_find_first(root + "/*", 0);
		
		while (f != "") {
			if(filename_ext(f) == ".json") {
				var _c   = new NodeAction().deserialize($"{root}/{f}");
				ds_list_add(list, _c);
				
				if(_c.location != noone) {
					var _cat = array_safe_get(_c.location, 0, "");
					var _grp = array_safe_get(_c.location, 1, "");
					
					for( var i = 0, n = ds_list_size(NODE_CATEGORY); i < n; i++ ) {
						if(NODE_CATEGORY[| i].name != _cat) continue;
						var _list  = NODE_CATEGORY[| i].list;
						var j = 0;
						
						if(_grp != "")
						for( var m = ds_list_size(_list); j < m; j++ )
							if(_list[| j] == _grp) break;
						
						ds_list_insert(_list, j + 1, _c);
						break;
					}
				}
			}
			
			f = file_find_next();
		}
		file_find_close();
	}
#endregion