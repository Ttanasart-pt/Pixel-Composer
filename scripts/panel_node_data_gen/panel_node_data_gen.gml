var _filter = ["x", "y", "updated", "rendered", "show_output_name", "insp2UpdateIcon", "preview_trans", "value_validation", "group", "draw_padding", "draw_droppable",
	"preview_drop_y", "badgeInspect", "preview_mx", "temp_surface", "load_scale", "node_id", "show_input_name", "graph_h", "display_data", "drawLineIndex", "draw_line_shift_x", 
	"draw_line_shift_y", "cache_array", "drag_mx", "drag_my", "expTree", "value_to", "draw_line_thick", "expUse", "expression", "drag_sx", "drag_sy", "drag_type", "con_node",
	"cache_value", "show_graph", "preview_x", "preview_y", "badgePreview", "data_list", "open_rx", "open_ry", "parent", "active", "cached_output", "current_data", "cache_result",
	"draw_graph_culled", "dopesheet_y", "render_time", "renderActive", "preview_speed", "preview_drop_x", "preview_drop_y", "inspecting", "value_to_arr", "draw_name", "anim_priority",
	"draw_line_vb", "error_notification", "animators", "junction_drawing", "draw_line_shift_hover", "value_from", "is_anim", "popup_dialog", "draw_line_blend", "is_changed", 
	"on_end", "editWidget", "key_inter", "dyna_depo", "def_length", "con_index", "bg_sel_spr", "load_map", "preview_alpha", "icon", "junction_draw_pad_y", "previewable", "active_range", 
	"inputMap", "tools", "preview_amount", "anim_show", "active_draw_index", "onSetDisplayName", "previewing", "on_drop_file", "autoUpdatedTrigger", "attributeEditors", "error_noti_update",
	"bg_spr", "insp1UpdateIcon", "outputMap", "preview_surface", "manual_updated", "preview_my", "tool_settings", "isTool" ];
global.node_data_filter = ds_map_create();
for( var i = 0, n = array_length(_filter); i < n; i++ ) 
	global.node_data_filter[? _filter[i]] = 1;

function __node_data_clone(struct) {
	var _var = variable_struct_get_names(struct);
	var _str = {};
	
	for( var i = 0, n = array_length(_var); i < n; i++ ) {
		if(ds_map_exists(global.node_data_filter, _var[i])) continue;
		
		var val = struct[$ _var[i]];
		if(is_struct(val)) continue;
		if(is_array(val)) {
			for( var j = 0; j < array_length(val); j++ ) {
				if(is_struct(val[j]))
					val[j] = __node_data_clone(val[j]);
			}
		}
		
		_str[$ _var[i]] = val;
	}
	
	return _str;
}

function Panel_Node_Data_Gen() : PanelContent() constructor {
	w = ui(640);
	h = ui(64);
	
	title = "Dump node data";
	amo = ds_map_size(ALL_NODES);
	cur = 0;
	key = ds_map_find_first(ALL_NODES);
	
	LOADING = true;
	NODE_EXTRACT = true;
	
	dir  = DIRECTORY + "Nodes/";
	if(!directory_exists(dir)) directory_create(dir);
	data   = {};
	junc   = {};
	locale = {};
	
	game_set_speed(99999, gamespeed_fps);
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		draw_set_text(f_p0, fa_center, fa_top, COLORS._main_text);
		draw_text(w / 2, ui(8), cur + 2 < amo? "Dumping node data... (Program terminate on complete)" : "Writing JSON");
		
		var bx0 = ui(8);
		var by0 = ui(40);
		var bx1 = w - ui(8);
		var by1 = h - ui(8);
		
		var bw = bx1 - bx0;
		var bh = by1 - by0;
		
		draw_sprite_stretched(THEME.progress_bar, 0, bx0, by0, bw, bh);
		draw_sprite_stretched(THEME.progress_bar, 1, bx0, by0, bw * cur / amo, bh);
		
		var _n = ALL_NODES[? key];
		var _b = _n.build(0, 0);
		key = ds_map_find_next(ALL_NODES, key);
		
		if(_b.name == "") return;
		
		var _data = __node_data_clone(_b);
		
		var _junc = {};
		_junc.node	   = _n.node;
		
		var _loca = {};
		_loca.name	   = _n.name;
		_loca.tooltip  = _n.tooltip;
		
		var _jin = [], _jot = [];
		var _lin = [], _lot = [];
		var _din = [], _dot = [];
		
		for( var i = 0; i < ds_list_size(_b.inputs); i++ ) {
			_din[i] = __node_data_clone(_b.inputs[| i]);
			var _in = _b.inputs[| i];
			
			_jin[i] = {
				type:	 _in.type,
				visible: _in.visible? 1 : 0,
			};
			
			_lin[i] = {
				name:	 _in._initName,
				tooltip: _in.tooltip,
			};
			
			switch(_in.display_type) {
				case VALUE_DISPLAY.enum_button :
				case VALUE_DISPLAY.enum_scroll :
					_lin[i].display_data = _in.display_data;
					break;
			}
		}
		
		for( var i = 0; i < ds_list_size(_b.outputs); i++ ) {
			_dot[i] = __node_data_clone(_b.outputs[| i]);
			
			_jot[i] = {
				type:	 _b.outputs[| i].type,
				visible: _b.outputs[| i].visible? 1 : 0,
			};
			
			_lot[i] = {
				name:	 _b.outputs[| i]._initName,
				tooltip: _b.outputs[| i].tooltip,
			};
		}
		
		nodeDelete(_b);
		
		_junc.inputs  = _jin;
		_junc.outputs = _jot;
		junc[$ _n.name] = _junc;
			
		_loca.inputs  = _lin;
		_loca.outputs = _lot;
		locale[$ _n.node] = _loca;
		
		_data.inputs  = _din;
		_data.outputs = _dot;
		data[$ _n.name] = _data;
		
		cur++;
		if(cur < amo) return;
		
		json_save_struct(dir + "node_data.json", data, false);
		json_save_struct(dir + "node_junctions.json", junc, false);
		json_save_struct(dir + "node_locale.json", locale, true);
		shellOpenExplorer(dir);
		
		game_end();
	}
}