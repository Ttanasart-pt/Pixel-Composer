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

function __initNodeData() {
	__initAction();
	
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

function nodeReleatedQuery(type, key) {
	if(!struct_has(global.NODE_RELATION, type)) return [];
	var _sugs = global.NODE_RELATION[$ type];
	
	if(!struct_has(_sugs.relations, key)) return [];
	return _sugs.relations[$ key];
}
