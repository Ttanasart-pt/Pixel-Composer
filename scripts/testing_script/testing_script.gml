function __test_update_current_collections() { #region
	var st = ds_stack_create();
	ds_stack_push(st, PANEL_COLLECTION.context);
	
	print("---------- COLLECTION UPDATING STARTED ----------");
	
	var sel = PANEL_GRAPH.getFocusingNode(), outj = noone;
	if(sel != noone) outj = sel.outputs[0];
	
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < ds_list_size(_st.content); i++ ) {
			var _node = _st.content[| i];
			
			print("  > Updating " + _node.meta_path);
			var _map = json_load_struct(_node.meta_path);
			_map.version = SAVE_VERSION;
			json_save_struct(_node.meta_path, _map);
			
			var _map = json_load_struct(_node.path);
			_map.version = SAVE_VERSION;
			json_save_struct(_node.path, _map);
		}
		
		for( var i = 0; i < ds_list_size(_st.subDir); i++ )
			ds_stack_push(st, _st.subDir[| i]);
	}
	
	ds_stack_destroy(st);
	
	print("---------- COLLECTION UPDATING ENDED ----------");
} #endregion

function __test_update_sample_projects() { #region
	print("---------- PROJECT UPDATING STARTED ----------");
	
	for( var i = 0; i < ds_list_size(SAMPLE_PROJECTS); i++ ) {
		var _proj = SAMPLE_PROJECTS[| i];
			
		print("  > Updating " + _proj.meta_path);
		var _map = json_load_struct(_proj.meta_path);
		_map.version = SAVE_VERSION;
		json_save_struct(_proj.meta_path, _map);
		
		var _map = json_load_struct(_proj.path);
		_map.version = SAVE_VERSION;
		json_save_struct(_proj.path, _map);
	}
	
	print("---------- PROJECT UPDATING ENDED ----------");
} #endregion

function __test_load_current_collections() { #region
	var st = ds_stack_create();
	ds_stack_push(st, PANEL_COLLECTION.context);
	
	var xx = 0;
	var yy = 0;
	var col = 6;
	var ind = 0;
	
	print("---------- COLLECTION TESTING STARTED ----------");
	
	var sel = PANEL_GRAPH.getFocusingNode();
	var outj = sel == noone? noone : sel.outputs[0];
			
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < ds_list_size(_st.content); i++ ) {
			var _node = _st.content[| i];
			
			print("  > Building " + _node.path);
			var coll = APPEND(_node.path);
			if(coll == noone) continue;
			
			if(is_struct(coll)) {
				coll.x = xx;
				coll.y = yy;
				
				if(outj) 
				for( var k = 0; k < array_length(coll.inputs); k++ ) {
					if(coll.inputs[k].type != VALUE_TYPE.surface) continue;
					coll.inputs[k].setFrom(outj);
					break;
				}
			} else {
				for( var j = 0; j < array_length(coll); j++ ) {
					coll[j].x = xx;
					coll[j].y = yy;
					
					if(outj) 
					for( var k = 0; k < array_length(coll[j].inputs); k++ ) {
						if(coll[j].inputs[k].type != VALUE_TYPE.surface) continue;
						coll[j].inputs[k].setFrom(outj);
						break;
					}
				}
			}
			
			if(++ind > col) {
				ind = 0;
				xx = 0;
				yy += 160;
			} else 
				xx += 160;
		}
			
		for( var i = 0; i < ds_list_size(_st.subDir); i++ )
			ds_stack_push(st, _st.subDir[| i]);
	}
	
	ds_stack_destroy(st);
	
	print("---------- COLLECTION TESTING ENDED ----------");
} #endregion

function __test_load_all_nodes() { #region
	var amo = ds_map_size(ALL_NODES);
	var k = ds_map_find_first(ALL_NODES);
	var xx = 0;
	var yy = 0;
	var col = 10;
	var ind = 0;
	var sel = PANEL_GRAPH.getFocusingNode();
	var outj = sel == noone? noone : sel.outputs[0];
	
	var index = 0;
	var indst = 0; // 150 -- 175 -- 200
	var inded = 1000;
	
	LOADING = true;
	repeat(amo) {
		if(index > inded) break;
		if(index > indst) {
			var node = ALL_NODES[? k];
			print($"==== Building {node.node} ====");
			var b = node.build(xx, yy);
			
			if(++ind > col) {
				ind = 0;
				xx = 0;
				yy += 160;
			} else 
				xx += 160;
			if(b) {
				if(outj) 
				for( var i = 0; i < array_length(b.inputs); i++ ) {
					if(b.inputs[i].type != VALUE_TYPE.surface) continue;
					b.inputs[i].setFrom(outj);	
					break;
				}
			}
		}
		
		index++;
		k = ds_map_find_next(ALL_NODES, k);
	}
	LOADING = false;
} #endregion

function __test_metadata_current_collections() { #region
	var st = ds_stack_create();
	ds_stack_push(st, PANEL_COLLECTION.context);
	
	print("---------- COLLECTION UPDATING STARTED ----------");
	
	var sel   = PANEL_GRAPH.getFocusingNode(), outj = noone;
	var _meta = PROJECT.meta.serialize();
	if(sel != noone) outj = sel.outputs[0];
	
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < ds_list_size(_st.content); i++ ) {
			var _node = _st.content[| i];
			
			print("  > Updating " + _node.path);
			json_save_struct(_node.meta_path, _meta, true);
		}
		
		for( var i = 0; i < ds_list_size(_st.subDir); i++ )
			ds_stack_push(st, _st.subDir[| i]);
	}
	
	ds_stack_destroy(st);
	
	print("---------- COLLECTION UPDATING ENDED ----------");
} #endregion
	
function __test_generate_theme() { #region
	var _txt = "function Theme() constructor {\n";
	var _spr = struct_get_names(THEME);
	
	for( var i = 0, n = array_length(_spr); i < n; i++ )
		_txt += $"\t{_spr[i]} = noone;\n";
	_txt += "}";
	
	clipboard_set_text(_txt);
} #endregion