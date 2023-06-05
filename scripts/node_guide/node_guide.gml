globalvar NODE_EXTRACT;
NODE_EXTRACT = false;

function __generate_node_data() { 
	var amo = ds_map_size(ALL_NODES);
	var k = ds_map_find_first(ALL_NODES);
	
	CLONING = true;
	NODE_EXTRACT = true;
	
	var dir  = DIRECTORY + "Nodes/";
	if(!directory_exists(dir)) directory_create(dir);
	var data   = {};
	var locale = {};
	
	repeat(amo) {
		var _n = ALL_NODES[? k];
		var _b = _n.build(0, 0);
		k = ds_map_find_next(ALL_NODES, k);
		
		if(_b.name == "") continue;
		
		var _data = {};
		_data.node	   = _n.node;
		
		var _loca = {};
		_loca.name	   = _n.name;
		_loca.tooltip  = _n.tooltip;
		
		var _din = [], _dot = [];
		var _lin = [], _lot = [];
		
		for( var i = 0; i < ds_list_size(_b.inputs); i++ ) {
			_din[i] = {
				type:	 _b.inputs[| i].type,
				visible: _b.inputs[| i].visible? 1 : 0,
			};
			
			_lin[i] = {
				name:	 _b.inputs[| i].name,
				tooltip: _b.inputs[| i].tooltip,
			};
		}
		
		for( var i = 0; i < ds_list_size(_b.outputs); i++ ) {
			_dot[i] = {
				type:	 _b.outputs[| i].type,
				visible: _b.outputs[| i].visible? 1 : 0,
			};
			
			_lot[i] = {
				name:	 _b.outputs[| i].name,
				tooltip: _b.outputs[| i].tooltip,
			};
		}
			
		_data.inputs  = _din;
		_data.outputs = _dot;
		data[$ _n.name] = _data;
			
		_loca.inputs  = _lin;
		_loca.outputs = _lot;
		locale[$ _n.node] = _loca;
	}
	
	json_save_struct(dir + "nodes.json", data, false);
	json_save_struct(dir + "lnodes.json", locale, true);
	
	CLONING = false;
	game_end();
}

function __initNodeData() {
	global.NODE_GUIDE = {};
	
	var nodeDir = DIRECTORY + "Nodes/";
	var _l = nodeDir + "/version";
	
	//if(file_exists(_l)) {
	//	var res = json_load_struct(_l);
	//	if(res.version == BUILD_NUMBER) return;
	//}
	//json_save_struct(_l, { version: BUILD_NUMBER });
	
	if(file_exists("data/tooltip.zip"))
		zip_unzip("data/tooltip.zip", nodeDir);
	else
		noti_status("Tooltip image file not found.")
	
	if(file_exists("data/nodes.json")) {
		file_delete(nodeDir + "nodes.json");
		file_copy("data/nodes.json", nodeDir + "nodes.json");
	}
}