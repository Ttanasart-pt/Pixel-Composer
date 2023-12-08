globalvar NODE_EXTRACT;
NODE_EXTRACT = false;

function __generate_node_data() { #region
	var amo = ds_map_size(ALL_NODES);
	var k = ds_map_find_first(ALL_NODES);
	
	CLONING = true;
	NODE_EXTRACT = true;
	
	var dir  = DIRECTORY + "Nodes/";
	directory_verify(dir);
	
	var data   = {};
	var junc   = {};
	var locale = {};
	
	repeat(amo) {
		var _n = ALL_NODES[? k];
		var _b = _n.build(0, 0);
		k = ds_map_find_next(ALL_NODES, k);
		
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
		
		for( var i = 0; i < ds_list_size(_b.inputs); i++ ) {
			_din[i] = variable_clone(_b.inputs[| i], 1);
			
			_jin[i] = {
				type:	 _b.inputs[| i].type,
				visible: _b.inputs[| i].visible? 1 : 0,
			};
			
			_lin[i] = {
				name:	 _b.inputs[| i]._initName,
				tooltip: _b.inputs[| i].tooltip,
			};
		}
		
		for( var i = 0; i < ds_list_size(_b.outputs); i++ ) {
			_dot[i] = variable_clone(_b.outputs[| i], 1);
			
			_jot[i] = {
				type:	 _b.outputs[| i].type,
				visible: _b.outputs[| i].visible? 1 : 0,
			};
			
			_lot[i] = {
				name:	 _b.outputs[| i]._initName,
				tooltip: _b.outputs[| i].tooltip,
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
	global.NODE_GUIDE = {};
	
	var nodeDir = DIRECTORY + "Nodes/";
	
	if(file_exists_empty("data/tooltip.zip")) 
		zip_unzip("data/tooltip.zip", nodeDir);
	
	if(file_exists_empty("data/nodes.json")) {
		file_delete(nodeDir + "nodes.json");
		file_copy_override("data/nodes.json", nodeDir + "nodes.json");
	}
	
	var _relFrom = $"data/related_node.json";
	var _relTo   = nodeDir + "Related/default.json";
	
	directory_verify(nodeDir + "Related");
	file_copy_override(_relFrom, _relTo);
	//print($"Copying related nodes from {_relFrom} to {_relTo}\n\t{file_exists_empty(_relFrom)}, {file_exists_empty(_relTo)}");
	
	__initNodeReleated();
}