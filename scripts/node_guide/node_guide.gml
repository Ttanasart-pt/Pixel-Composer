function __generate_node_data() { #region
	CLONING = true;
	
	var key = struct_get_names(ALL_NODES);
	var dir = DIRECTORY + "Nodes/";
	directory_verify(dir);
	
	var data   = {};
	var junc   = {};
	var locale = {};
	
	for( var i = 0, n = array_length(key); i < n; i++ ) {
		var  k = key[i];
		var _n = ALL_NODES[$ k];
		var _b = _n.build(0, 0);
		
		if(_b.name == "") continue;
		
		var _data = variable_clone(_n, 1);
		
		var _junc = {};
		_junc.node	   = _n.node;
		
		var _loca = {};
		_loca.name	   = _n.name;
		_loca.tooltip  = _n.tooltip;
		
		var _jin = [], _jot = [];
		var _lin = [], _lot = [];
		var _din = [], _dot = [];
		
		for( var j = 0; j < array_length(_b.inputs); j++ ) {
			_din[j] = variable_clone(_b.inputs[j], 1);
			
			_jin[j] = {
				type:	 _b.inputs[j].type,
				visible: _b.inputs[j].visible? 1 : 0,
			};
			
			_lin[j] = {
				name:	 _b.inputs[j]._initName,
				tooltip: _b.inputs[j].tooltip,
			};
		}
		
		for( var j = 0; j < array_length(_b.outputs); j++ ) {
			_dot[j] = variable_clone(_b.outputs[j], 1);
			
			_jot[j] = {
				type:	 _b.outputs[j].type,
				visible: _b.outputs[j].visible? 1 : 0,
			};
			
			_lot[j] = {
				name:	 _b.outputs[j]._initName,
				tooltip: _b.outputs[j].tooltip,
			};
		}
			
		_junc.inputs  = _jin;
		_junc.outputs = _jot;
		junc[$ _n.name] = _junc;
			
		_loca.inputs  = _lin;
		_loca.outputs = _lot;
		locale[$ _n.node] = _loca;
		
		_data.inputs  = _din;
		_data.outputs = _dot;
		data[$ _n.name] = _data;
	}
	
	json_save_struct(dir + "node_data.json", data, true);
	json_save_struct(dir + "node_junctions.json", junc, false);
	json_save_struct(dir + "node_locale.json", locale, true);
	shellOpenExplorer(dir);
	
	CLONING = false;
	game_end();
} #endregion

#region node suggestion
	function __loadNodeReleated(path) {
		var _json = json_load_struct(path);
		var _keys = variable_struct_get_names(_json);
		var _rel  = global.NODE_RELATION;
		
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var _group = _json[$ _keys[i]];
			
			if(!struct_has(_rel, _keys[i]))
				_rel[$ _keys[i]] = { relations : {} };
			var _Vgroup = _rel[$ _keys[i]].relations;
			
			switch(_group.key) {
				case "connectionType" :
					var _types = variable_struct_get_names(_group.relations);
					for( var j = 0, m = array_length(_types); j < m; j++ ) {
						var _k = value_type_from_string(_types[j]);
						if(!struct_has(_Vgroup, _k)) _Vgroup[$ _k] = [];
						array_append(_Vgroup[$ _k], _group.relations[$ _types[j]]);
					}
					break;
				case "contextNode" :
					var _nodes = variable_struct_get_names(_group.relations);
					for( var j = 0, m = array_length(_nodes); j < m; j++ ) {
						if(!struct_has(_Vgroup, _nodes[j])) _Vgroup[$ _nodes[j]] = [];
						array_append(_Vgroup[$ _nodes[j]], _group.relations[$ _nodes[j]]);
					}
					break;
			}
		}
	}
		
		
	function __initNodeReleated() {
		global.NODE_RELATION = {};
		
		var _dir = DIRECTORY + "Nodes/Related";
		directory_verify(_dir);
		
		var f = file_find_first(_dir + "/*.json", fa_none);
		
		while (f != "") {
		    __loadNodeReleated(_dir + "/" + f);
		    f = file_find_next();
		}
		
		file_find_close();
	}
	
	function nodeReleatedQuery(type, key) {
		if(!struct_has(global.NODE_RELATION, type)) return [];
		var _sugs = global.NODE_RELATION[$ type];
		
		if(!struct_has(_sugs.relations, key)) return [];
		return _sugs.relations[$ key];
	}
#endregion

function __initNodeData() {
	var nodeDir = DIRECTORY + "Nodes/";
	directory_verify(nodeDir);
	
	var dir = $"{nodeDir}Related/";
	directory_verify(dir);
	
	if(check_version($"{dir}version")) {
		var _relFrom = $"{working_directory}data/nodes/related_node.json";
		var _relTo   = $"{dir}default.json";
		
		file_copy_override(_relFrom, _relTo);
	}
	
	__initNodeReleated();
}