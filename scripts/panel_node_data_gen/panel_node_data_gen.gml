var _filter = [ "name", "tooltip", "type", "input_display_list", "output_display_list", "inspector_display_list", ];

global.node_data_filter = ds_map_create();
for( var i = 0, n = array_length(_filter); i < n; i++ ) 
	global.node_data_filter[? _filter[i]] = 1;

function __node_data_clone(struct) {
	var _var = variable_struct_get_names(struct);
	var _str = {};
	
	for( var i = 0, n = array_length(_var); i < n; i++ ) {
		if(!ds_map_exists(global.node_data_filter, _var[i])) continue;
		
		var val = struct[$ _var[i]];
		if(is_struct(val)) continue;
		if(is_array(val)) {
			for( var j = 0; j < array_length(val); j++ ) {
				if(is_struct(val[j])) val[j] = __node_data_clone(val[j]);
			}
		}
		
		_str[$ _var[i]] = val;
	}
	
	return _str;
}

function Panel_Node_Data_Gen() : PanelContent() constructor {
	w = ui(640);
	h = ui(64);
	
	title    = "Dump node data";
	auto_pin = true;
	
	key = struct_get_names(ALL_NODES);
	array_sort(key, function(k1, k2) /*=>*/ {return string_compare(ALL_NODES[$ k1].nodeName, ALL_NODES[$ k2].nodeName)});
	
	amo = array_length(key);
	cur = 0;
	
	LOADING = true;
	
	dir  = DIRECTORY + "Nodes/gen/";
	directory_verify(dir);
	
	locText = "";
	
	game_set_speed(99999, gamespeed_fps);
	
	function drawContent(panel) {
		var _n = ALL_NODES[$ key[cur]];
		if(_n.nodeName == "Node_Custom") { if(++cur < amo) return; }
		
		var _b = _n.build(0, 0);
		
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		draw_set_text(f_p0, fa_center, fa_top, COLORS._main_text);
		draw_text_add(w / 2, ui(8), cur + 2 < amo? $"Dumping node data [{key[cur]}]" : "Writing JSON");
		
		var bx0 = ui(8);
		var by0 = ui(40);
		var bx1 = w - ui(8);
		var by1 = h - ui(8);
		
		var bw = bx1 - bx0;
		var bh = by1 - by0;
		
		draw_sprite_stretched(THEME.progress_bar, 0, bx0, by0, bw, bh);
		draw_sprite_stretched(THEME.progress_bar, 1, bx0, by0, bw * cur / amo, bh);
		
		if(_b.name == "") return;
		
		var _lCon  = $"\t\t\"name\":\"{_n.name}\",\n";
		    _lCon += $"\t\t\"tooltip\":\"{_n.tooltip}\",\n";
		
		var _tIn = "";
		var _tOt = "";
		
		for( var i = 0; i < array_length(_b.inputs); i++ ) {
			var _in = _b.inputs[i];
			if(!is(_in, NodeValue)) continue;
			
			var _ti  = $"\t\t\t\t\"name\":\"{_in._initName}\",\n";
		    if(_in.tooltip != "") _ti += $"\t\t\t\t\"tooltip\":\"{_in.tooltip}\",\n";
			
			switch(_in.display_type) {
				case VALUE_DISPLAY.enum_button :
				case VALUE_DISPLAY.enum_scroll :
					var _eData = _in.display_data.data;
					var _sData = "";
					
					for( var j = 0, m = array_length(_eData); j < m; j++ ) {
						var _s = _eData[j];
						if(struct_has(_s, "name")) _s = _s.name;
						_sData += $"\t\t\t\t\t\"{_s}\",\n";
					}
					
					_ti += $"\t\t\t\t\"display_data\":[\n{_sData}\t\t\t\t],\n";
					break;
			}
			
			_tIn += $"\t\t\t\{\n{_ti}\t\t\t\},\n";
		}
		
		for( var i = 0; i < array_length(_b.outputs); i++ ) {
			var _ot = _b.outputs[i];
			if(!is(_ot, NodeValue)) continue;
			
			var _to  = $"\t\t\t\t\"name\":\"{_ot._initName}\",\n";
			if(_ot.tooltip != "") _to += $"\t\t\t\t\"tooltip\":\"{_ot.tooltip}\",\n";
			
			_tOt += $"\t\t\t\{\n{_to}\t\t\t\},\n";
		}
		
		try { _b.destroy(); } catch(e) {}
			
		_lCon += _tIn == ""? $"\t\t\"inputs\":[],\n"  : $"\t\t\"inputs\":[\n{_tIn}\t\t],\n";
		_lCon += _tOt == ""? $"\t\t\"outputs\":[],\n" : $"\t\t\"outputs\":[\n{_tOt}\t\t],\n";
		
		var _lTxt = $"\t\"{_n.nodeName}\":\{\n{_lCon}\t\},\n";
		locText += _lTxt;
		
		if(++cur < amo) return;
		
		locText = string_replace_all(locText, "\t", "  ");
		file_text_write_all($"{dir}node.json", $"\{\n{locText}\}");
		shellOpenExplorer(dir);
		
		game_end();
	}
}