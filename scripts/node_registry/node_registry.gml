#region globalvar
	globalvar ALL_NODES, NODE_CATEGORY, NODE_PB_CATEGORY, NODE_PCX_CATEGORY;
	globalvar SUPPORTER_NODES, NEW_NODES;
	
	globalvar NODE_PAGE_DEFAULT;
	globalvar NODE_ACTION_LIST;
	
	ALL_NODES		  = {};
	NODE_CATEGORY	  = ds_list_create();
	NODE_PB_CATEGORY  = ds_list_create();
	NODE_PCX_CATEGORY = ds_list_create();
	SUPPORTER_NODES   = ds_list_create();
	NEW_NODES		  = ds_list_create();
	
	global.__currPage    = "";
	global.__currNewPage = "";
	
	#macro NODE_ADD_CAT if(!IS_CMD) addNodeCatagory
	
	global.PATREON_NODES = [
		Node_Brush_Linear, 
		Node_Ambient_Occlusion, 
		Node_RM_Cloud, 
		Node_Perlin_Extra, 
		Node_Voronoi_Extra, 
		Node_Gabor_Noise, 
		Node_Shard_Noise, 
		Node_Wavelet_Noise, 
		Node_Caustic, 
		Node_Noise_Bubble, 
		Node_Flow_Noise, 
		Node_Noise_Cristal, 
		Node_Honeycomb_Noise, 
		Node_Grid_Pentagonal, 
		Node_Pytagorean_Tile, 
		Node_Herringbone_Tile, 
		Node_Random_Tile, 
		Node_MK_Fracture, 
		Node_MK_Sparkle, 
	];
#endregion

function NodeObject(_name, _spr, _node, _tooltip = "") constructor {
	name = _name;
	spr  = _spr;
	node = _node;
	icon = noone;
	
	nodeName     = script_get_name(node);
	createFn     = noone;
	createParam  = noone;
	
	tags         = [];
	tooltip      = _tooltip;
	
	pxc_version  = 0;
	new_node     = false;
	tooltip_spr  = noone;
	deprecated   = false;
	
	show_in_recent = true;
	show_in_global = true;
	
	patreon  = array_exists(global.PATREON_NODES, node);
	if(patreon) ds_list_add(SUPPORTER_NODES, self);
	
	testable = true;
	
	ioArray = [];
	input_type_mask  = 0b0;
	output_type_mask = 0b0;
	
	static init = function() {
		_fn = registerFunctionLite("New node", name, function(n) /*=>*/ { PANEL_GRAPH.createNodeHotkey(n); }, [ nodeName ]);
		_fn.spr = spr;
		
		if(!IS_CMD) {
			var pth = DIRECTORY + $"Nodes/Tooltip/{node}.png";
			if(file_exists_empty(pth)) tooltip_spr = sprite_add(pth, 0, false, false, 0, 0);
			
			if(struct_has(global.NODE_GUIDE, node)) {
				var _n = global.NODE_GUIDE[$ node];
				name   = _n.name;
				if(_n.tooltip != "")
					tooltip = _n.tooltip;
			}
		}
	} init();
		
	static setTags    = function(_tags) { tags    = _tags;     return self; }
	static setSpr     = function(_spr)  { spr     = _spr;      return self; }
	static setTooltip = function(_tool) { tooltip = _tool;     return self; }
	static setBuild   = function(_fn)   { createFn    = _fn;   return self; }
	static setParam   = function(_par)  { createParam = _par;  return self; }
	
	static setIO = function(t) { 
		for(var i = 0; i < argument_count; i++) { 
			input_type_mask  |= value_bit(argument[i]); 
			output_type_mask |= value_bit(argument[i]); 
			
			array_push(ioArray, value_type_to_string(argument[i]));
		} 
		return self; 
	}
	
	static setVersion = function(version) {
		INLINE 
		if(IS_CMD) return self;
		
		pxc_version = version;
		new_node    = version >= LATEST_VERSION;
		
		if(new_node) {
			if(global.__currPage != global.__currNewPage) {
				ds_list_add(NEW_NODES, global.__currPage);
				global.__currNewPage = global.__currPage;
			}
			
			ds_list_add(NEW_NODES, self);
		}
		return self;
	}
	
	static setIcon = function(_icon) {
		INLINE 
		if(IS_CMD) return self;
		
		icon = _icon;
		return self;
	}
	
	static isDeprecated = function() {
		INLINE 
		if(IS_CMD) return self;
		
		deprecated = true;
		return self;
	}
	
	static hideRecent = function() {
		INLINE 
		if(IS_CMD) return self;
		
		show_in_recent = false;
		testable       = false;
		variable_struct_remove(FUNCTIONS, _fn.fnName);
		return self;
	}
	
	static notTest = function() { testable = false; return self; }
	
	static hideGlobal = function() {
		INLINE 
		if(IS_CMD) return self;
		
		show_in_global = false;
		return self;
	}
	
	static getName    = function() { return __txt_node_name(node, name);	   }
	static getTooltip = function() { return __txt_node_tooltip(node, tooltip); }
	
	static build = function(_x = 0, _y = 0, _group = PANEL_GRAPH.getCurrentContext(), _param = {}) {
		INLINE 
		
		if(createParam != noone) struct_append(_param, createParam);
		var _node = createFn == noone? new node(_x, _y, _group, _param) : createFn(_x, _y, _group, _param);
		return _node;
	}
	
	static drawGrid = function(_x, _y, _mx, _my, grid_size, _param = {}) {
		var spr_x = _x + grid_size / 2;
		var spr_y = _y + grid_size / 2;
		
		var _spw = sprite_get_width(spr);
		var _sph = sprite_get_height(spr);
		var _ss  = grid_size / max(_spw, _sph) * 0.75;
		
		gpu_set_tex_filter(true);
		draw_sprite_uniform(spr, 0, spr_x, spr_y, _ss);
		gpu_set_tex_filter(false);
				
		if(new_node) {
			draw_sprite_ui_uniform(THEME.node_new_badge, 0, _x + grid_size - ui(12), _y + ui(6),, COLORS._main_accent);
			draw_sprite_ui_uniform(THEME.node_new_badge, 1, _x + grid_size - ui(12), _y + ui(6));
		}
				
		if(deprecated) {
			draw_sprite_ui_uniform(THEME.node_deprecated_badge, 0, _x + grid_size - ui(12), _y + ui(6),, COLORS._main_value_negative);
			draw_sprite_ui_uniform(THEME.node_deprecated_badge, 1, _x + grid_size - ui(12), _y + ui(6));
		}
		
		var fav = struct_exists(global.FAV_NODES, nodeName);
		if(fav) {
			gpu_set_tex_filter(true);
			draw_sprite_ui_uniform(THEME.star, 0, _x + grid_size - ui(10), _y + grid_size - ui(10), .8, COLORS._main_accent, 1.);
			gpu_set_tex_filter(false);
		}
		
		var spr_x = _x + grid_size - 4;
		var spr_y = _y + 4;
				
		if(IS_PATREON && patreon) {
			BLEND_SUBTRACT
			gpu_set_colorwriteenable(0, 0, 0, 1);
			draw_sprite_ext(THEME.patreon_supporter, 0, spr_x, spr_y, 1, 1, 0, c_white, 1);
			gpu_set_colorwriteenable(1, 1, 1, 1);
			BLEND_NORMAL
			
			draw_sprite_ext(THEME.patreon_supporter, 1, spr_x, spr_y, 1, 1, 0, COLORS._main_accent, 1);
			
			if(point_in_circle(_mx, _my, spr_x, spr_y, 10)) TOOLTIP = __txt("Supporter exclusive");
		}
		
		if(icon) draw_sprite_ext(icon, 0, spr_x, spr_y, 1, 1, 0, c_white, 1);
	}
	
	static drawList = function(_x, _y, _mx, _my, _h, _w, _param = {}) {
		var fav = struct_exists(global.FAV_NODES, nodeName);
		if(fav) {
			gpu_set_tex_filter(true);
			draw_sprite_ui_uniform(THEME.star, 0, _x + ui(16), _y + _h / 2, .8, COLORS._main_accent, 1.);
			gpu_set_tex_filter(false);
		}
				
		var spr_x = _x + ui(32) + _h / 2;
		var spr_y = _y + _h / 2;
				
		var ss = (_h - ui(8)) / max(sprite_get_width(spr), sprite_get_height(spr));
		gpu_set_tex_filter(true);
		draw_sprite_ext(spr, 0, spr_x, spr_y, ss, ss, 0, c_white, 1);
		gpu_set_tex_filter(false);
		
		var tx = spr_x + _h / 2 + ui(4);
		var ty =    _y + _h / 2;
				
		if(new_node) {
			var _nx = _w - ui(6 + 18);
			draw_sprite_ui_uniform(THEME.node_new_badge, 0, _nx, _y + _h / 2,, COLORS._main_accent);
			draw_sprite_ui_uniform(THEME.node_new_badge, 1, _nx, _y + _h / 2);
		}
				
		if(deprecated) {
			var _nx = _w - ui(6 + 18);
			draw_sprite_ui_uniform(THEME.node_deprecated_badge, 0, _nx, _y + _h / 2,, COLORS._main_value_negative);
			draw_sprite_ui_uniform(THEME.node_deprecated_badge, 1, _nx, _y + _h / 2);
		}	
		
		var _txt   = getName();
		var _query = struct_try_get(_param, "query", "");
		var _range = struct_try_get(_param, "range", 0);
		
		if(_query != "") {
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
			draw_text_add(tx, ty, _txt);
			tx += string_width(_txt);
			draw_sprite_ext(THEME.arrow, 0, tx + ui(12), ty, 1, 1, 0, COLORS._main_icon, 1);
			tx += ui(24);
			
			_query = string_title(_query);
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			if(_range == 0) draw_text_add(tx, ty, _query);
			else            draw_text_match_range(tx, ty, _query, _range);
			tx += string_width(_query);
			
		} else {
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			if(_range == 0) draw_text_add(tx, ty, _txt);
			else            draw_text_match_range(tx, ty, _txt, _range);
			tx += string_width(_txt);
		}
		
		if(IS_PATREON && patreon) {
			var spr_x = tx + ui(4);
			var spr_y = _y + _h / 2 - ui(6);
						
			gpu_set_colorwriteenable(0, 0, 0, 1); BLEND_SUBTRACT
			draw_sprite_ext(THEME.patreon_supporter, 0, spr_x, spr_y, 1, 1, 0, c_white, 1);
			gpu_set_colorwriteenable(1, 1, 1, 1); BLEND_NORMAL
			
			draw_sprite_ext(THEME.patreon_supporter, 1, spr_x, spr_y, 1, 1, 0, COLORS._main_accent, 1);
			
			if(point_in_circle(_mx, _my, spr_x, spr_y, ui(10))) TOOLTIP = __txt("Supporter exclusive");
			
			tx += ui(12);
		}
		
		return tx;
	}

	static serialize = function() {
		var _str = {
			name,
			
			spr: sprite_get_name(spr),
			baseNode: nodeName,
			io: ioArray,
		}
		
		if(tooltip != "")      _str.tooltip        = tooltip;
		if(createFn != noone)  _str.build          = script_get_name(createFn);
		if(deprecated)         _str.deprecated     = true;
		if(pxc_version)        _str.pxc_version    = pxc_version;
		if(!show_in_recent)    _str.show_in_recent = show_in_recent;
		if(!array_empty(tags)) _str.alias          = tags;
		
		return _str;
	}
	
	static deserialize = function(_data) {
		if(struct_has(_data, "tooltip")) setTooltip(_data.tooltip);
		
		if(struct_has(_data, "io")) {
			var _io = _data.io;
			for( var i = 0, n = array_length(_io); i < n; i++ ) 
				setIO(value_type_from_string(_io[i]));
		}
		
		if(struct_has(_data, "build")) {
			var _bfn = asset_get_index(_data.build);
			if(_bfn != -1) setBuild(_bfn);
		}
	
		if(struct_has(_data, "deprecated"))
			isDeprecated();
		
		if(struct_has(_data, "alias"))
			setTags(_data.alias);
			
		if(struct_has(_data, "show_in_recent"))
			show_in_recent = _data.show_in_recent;
			
		if(struct_has(_data, "pxc_version"))
			setVersion(_data.pxc_version);
		
		return self;
	}
}

function nodeBuild(_name, _x, _y, _group = PANEL_GRAPH.getCurrentContext()) {
	INLINE
	
	if(!struct_has(ALL_NODES, _name)) {
		log_warning("LOAD", $"Node type {_name} not found");
		return noone;
	}
	
	var _node  = ALL_NODES[$ _name];
	var _bnode = _node.build(_x, _y, _group);
	
	return _bnode;
}

function addNodeCatagory(    name, list, filter = [], color = noone) { ds_list_add(NODE_CATEGORY,     { name, list, filter, color }); global.__currPage = name; }
function addNodePBCatagory(  name, list, filter = [])                { ds_list_add(NODE_PB_CATEGORY,  { name, list, filter        }); }
function addNodePCXCatagory( name, list, filter = [])                { ds_list_add(NODE_PCX_CATEGORY, { name, list, filter        }); }

	////- Nodes

function __read_node_directory(dir) {
	if(!directory_exists(dir)) return;
	__read_node_folder(dir);
	
	var _dirs = [];
	var _f = file_find_first(dir + "/*", fa_directory);
	var f, p;
	
	while(_f != "") {
		 f = _f;
		 p = dir + "/" + f;
		_f = file_find_next();
		
		if(!directory_exists(p)) continue;
		array_push(_dirs, p);
	}
	file_find_close();
	
	array_foreach(_dirs, function(d) /*=>*/ {return __read_node_directory(d)});
}
	
function __read_node_folder(dir) {
	var _info = dir + "/info.json";
	if(!file_exists(_info)) return;
	
	var _data = json_load_struct(_info);
	var _name = _data[$ "name"];
	var _base = _data[$ "baseNode"];
	var _inme = _data[$ "iname"] ?? _base;
	var _spr  = _data[$ "spr"];
	
	if(is_undefined(_base)) {
		print($"NODE ERROR: baseNode not found in {_info}.");
		return;
	}
	
	if(struct_has(ALL_NODES, _inme))
		print($"NODE WARNING: Duplicate node iname {_inme}.");
	
	if(is_undefined(_spr))
		_spr = $"s_{string_lower(_inme)}"; 
	_spr = asset_get_index(_spr);
		
	if(!sprite_exists(_spr)) 
		_spr = s_node_icon;
		
	var _node = asset_get_index(_base);
	var _n = new NodeObject(_name, _spr, _node);
	
	_n.deserialize(_data);
	
	ALL_NODES[$ _inme] = _n;
	return _n;
}

function __read_node_display(_list, _addCat) {
	
	for( var i = 0, n = array_length(_list); i < n; i++ ) {
		var _dl     = _list[i];
		var _name   = _dl.name;
		var _filter = _dl[$ "context"] ?? [];
		var _color  = noone;
		
		if(struct_has(_dl, "color")) _color = COLORS[$ _dl.color];
		
		var _l  = ds_list_create();
		_addCat(_name, _l, _filter, _color);
		
		var _nodes = _dl.nodes;
		for( var j = 0, m = array_length(_nodes); j < m; j++ ) {
			var _n = _nodes[j];
			
			if(is_string(_n)) {
				if(struct_has(ALL_NODES, _n))
					ds_list_add(_l, ALL_NODES[$ _n]);
				continue;
			}
			
			if(is_struct(_n)) {
				if(struct_has(_n, "label"))
					ds_list_add(_l, _n.label);
			}
		}
	}
	
}

function __initNodes() { 
	global.__currPage  = "";
	global.__startPage =  0;
	global.FAV_NODES   = {};
	
	if(!IS_CMD) {
		var favPath = DIRECTORY + "Nodes/fav.json";
		if(file_exists_empty(favPath)) {
			var favs = json_load_struct(favPath);
			for (var i = 0, n = array_length(favs); i < n; i++)
				global.FAV_NODES[$ favs[i]] = 1;
		}
		
		var recPath = DIRECTORY + "Nodes/recent.json";
		global.RECENT_NODES = file_exists_empty(recPath)? json_load_struct(recPath) : [];
		if(!is_array(global.RECENT_NODES)) global.RECENT_NODES = [];
	}
	
	NODE_PAGE_DEFAULT = ds_list_size(NODE_CATEGORY);
	ADD_NODE_PAGE = NODE_PAGE_DEFAULT;
	
	////- DATA
	
	var dir = $"{DIRECTORY}Nodes/Data/";
	directory_verify(dir);
	if(check_version($"{dir}version")) 
		zip_unzip("data/Nodes/Internal.zip", $"{DIRECTORY}Nodes/Data/");
	
	var dir = $"{DIRECTORY}Nodes/Data/Internal";
	__read_node_directory(dir);
	
	////- DISPLAY
	
	var _relFrom = $"data/Nodes/display_data.json";
	var _relTo   = $"{DIRECTORY}Nodes/Data/display_data.json";
	print(file_exists(_relFrom))
	file_copy_override(_relFrom, _relTo);
	
	var _data = json_load_struct(_relTo);
	
	__read_node_display(_data.list, addNodeCatagory);
	
	NODE_ACTION_LIST = ds_list_create();
	addNodeCatagory("Action", NODE_ACTION_LIST);
	__initNodeActions();
	
	if(IS_PATREON) addNodeCatagory("Extra", SUPPORTER_NODES);
	
	__read_node_display(_data.pb,  addNodePBCatagory);
	__read_node_display(_data.pcx, addNodePCXCatagory);
}

function __generateNodeData() {
	var _dir = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/data/Nodes/Internal"
	
	for( var i = 0, n = ds_list_size(NODE_CATEGORY); i < n; i++ ) {
		var _cat = NODE_CATEGORY[| i];
		
		var _lnme = _cat.name;
		var _list = _cat.list;
		directory_verify($"{_dir}/{_lnme}");
		
		for( var j = 0, m = ds_list_size(_list); j < m; j++ ) {
			var _node = _list[| j];
			if(!is(_node, NodeObject)) continue;
			
			var _nme  = _node.nodeName;
			var _vnme = filename_name_validate(_nme);
			
			var _str  = _node.serialize();
			directory_verify($"{_dir}/{_lnme}/{_vnme}");
			json_save_struct($"{_dir}/{_lnme}/{_vnme}/info.json", _str, true);
		}
	}
	
	for( var i = 0, n = ds_list_size(NODE_PB_CATEGORY); i < n; i++ ) {
		var _cat = NODE_PB_CATEGORY[| i];
		
		var _lnme = _cat.name;
		var _list = _cat.list;
		directory_verify($"{_dir}/{_lnme}");
		
		for( var j = 0, m = ds_list_size(_list); j < m; j++ ) {
			var _node = _list[| j];
			if(!is(_node, NodeObject)) continue;
			
			var _nme  = _node.nodeName;
			var _vnme = filename_name_validate(_nme);
			
			var _str  = _node.serialize();
			directory_verify($"{_dir}/pb_{_lnme}/{_vnme}");
			json_save_struct($"{_dir}/pb_{_lnme}/{_vnme}/info.json", _str, true);
		}
	}
	
	for( var i = 0, n = ds_list_size(NODE_PCX_CATEGORY); i < n; i++ ) {
		var _cat = NODE_PCX_CATEGORY[| i];
		
		var _lnme = _cat.name;
		var _list = _cat.list;
		directory_verify($"{_dir}/{_lnme}");
		
		for( var j = 0, m = ds_list_size(_list); j < m; j++ ) {
			var _node = _list[| j];
			if(!is(_node, NodeObject)) continue;
			
			var _nme  = _node.nodeName;
			var _vnme = filename_name_validate(_nme);
			
			var _str  = _node.serialize();
			directory_verify($"{_dir}/pcx_{_lnme}/{_vnme}");
			json_save_struct($"{_dir}/pcx_{_lnme}/{_vnme}/info.json", _str, true);
		}
	}
}