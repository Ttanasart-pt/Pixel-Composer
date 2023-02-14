function __generate_node_guide() { 
	var amo = ds_map_size(ALL_NODES);
	var k = ds_map_find_first(ALL_NODES);
	var node_struct = {};
	
	CLONING = true;
	
	repeat(amo) {
		var _n = ALL_NODES[? k];
		var _b = _n.build(0, 0);
		
		var _in = [];
		var _ot = [];
		
		for( var i = 0; i < ds_list_size(_b.inputs); i++ )
			_in[i] = _b.inputs[| i].type;
		for( var i = 0; i < ds_list_size(_b.outputs); i++ )
			_ot[i] = _b.outputs[| i].type;
			
		node_struct[$ k] = {
			inputs: _in,
			outputs: _ot
		}
		
		k = ds_map_find_next(ALL_NODES, k);
	}
	
	CLONING = false;
	
	var path = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\Pixels Composer\\datafiles\\data\\nodes\\node_guides.json"
	json_save_struct(path, node_struct);
	ds_map_destroy(node_struct);
	game_end();
}

function __init_node_guide() {
	global.NODE_GUIDE = {};
	var path = "data\\nodes\\node_guides.json";
	if(!file_exists(path)) return;
	
	global.NODE_GUIDE = json_load_struct(path);
}