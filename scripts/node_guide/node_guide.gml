function __generate_node_data() { 
	var amo = ds_map_size(ALL_NODES);
	var k = ds_map_find_first(ALL_NODES);
	
	CLONING = true;
	
	var dir  = DIRECTORY + "Nodes//";
	if(!directory_exists(dir)) directory_create(dir);
	
	repeat(amo) {
		var _n = ALL_NODES[? k];
		var _b = _n.build(0, 0);
		k = ds_map_find_next(ALL_NODES, k);
		
		if(_b.name == "") continue;
		
		var data = {};
		data.name	      = _n.name;
		data.node	      = _n.node;
		data.tooltip      = _b.tooltip;
		
		var _in = [];
		var _ot = [];
		
		for( var i = 0; i < ds_list_size(_b.inputs); i++ ) {
			_in[i] = {
				name:	 _b.inputs[| i].name,
				tooltip: _b.inputs[| i].tooltip,
				type:	 _b.inputs[| i].type,
			};
		}
		
		for( var i = 0; i < ds_list_size(_b.outputs); i++ ) {
			_ot[i] = {
				name:	 _b.outputs[| i].name,
				tooltip: _b.outputs[| i].tooltip,
				type:	 _b.outputs[| i].type,
			};
		}
			
		data.inputs  = _in;
		data.outputs = _ot;
		
		var path = dir + data.name + ".json";
		json_save_struct(path, data, true);
	}
	
	CLONING = false;
	game_end();
}

function __initNodeData() {
	global.NODE_GUIDE = {};
	
	var dir  = DIRECTORY + "Nodes/Guides";
	if(!directory_exists(dir))
		directory_create(dir);
			
	var f = file_find_first(dir + "*", 0);
	while(f != "") {
		var path  = dir + f;
		
		if(file_exists(path)) {
			var _node = json_load_struct(path);
			global.NODE_GUIDE[$ _node.node] = _node;
		}
		
		f = file_find_next();
	}
	
	//var _l = dir + "/version";
	//if(file_exists(_l)) {
	//	var res = json_load_struct(_l);
	//	if(res.version >= VERSION) return;
	//}
	//json_save_struct(_l, { version: VERSION });
	
	var tooltipDir = DIRECTORY + "Nodes/";
	if(file_exists("data/tooltip.zip"))
		zip_unzip("data/tooltip.zip", tooltipDir);
	else
		noti_status("Tooltip image file not found.")
}