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
	
	new_node     = false;
	tooltip_spr  = noone;
	deprecated   = false;
	
	show_in_recent = true;
	show_in_global = true;
	
	is_patreon_extra = false;
	testable = true;
	
	_fn = registerFunctionLite("New node", _name, function(n) /*=>*/ { PANEL_GRAPH.createNodeHotkey(n); }, [ node ]);
	_fn.spr = _spr;
	
	if(!IS_CMD) {
		var pth = DIRECTORY + $"Nodes/Tooltip/{node}.png";
		if(file_exists_empty(pth)) tooltip_spr = sprite_add(pth, 0, false, false, 0, 0);
		
		if(struct_has(global.NODE_GUIDE, node)) {
			var _n = global.NODE_GUIDEarn[$ node];
			name   = _n.name;
			if(_n.tooltip != "")
				tooltip = _n.tooltip;
		}
	}
	
	static setTags    = function(_tags) { tags    = _tags;     return self; }
	static setSpr     = function(_spr)  { spr     = _spr;      return self; }
	static setTooltip = function(_tool) { tooltip = _tool;     return self; }
	static setBuild   = function(_fn)   { createFn = _fn;      return self; }
	static setParam   = function(_par)  { createParam = _par;  return self; }
	
	static setVersion = function(version) {
		INLINE 
		if(IS_CMD) return self;
		
		new_node = version >= LATEST_VERSION;
		
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
	
	static patreonExtra = function() {
		INLINE 
		if(IS_CMD) return self;
		
		is_patreon_extra = true;
		
		ds_list_add(SUPPORTER_NODES, self);
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
		
		var fav = struct_exists(global.FAV_NODES, node);
		if(fav) {
			gpu_set_tex_filter(true);
			draw_sprite_ui_uniform(THEME.star, 0, _x + grid_size - ui(10), _y + grid_size - ui(10), .8, COLORS._main_accent, 1.);
			gpu_set_tex_filter(false);
		}
		
		var spr_x = _x + grid_size - 4;
		var spr_y = _y + 4;
				
		if(IS_PATREON && is_patreon_extra) {
			BLEND_SUBTRACT
			gpu_set_colorwriteenable(0, 0, 0, 1);
			draw_sprite_ext(s_patreon_supporter, 0, spr_x, spr_y, 1, 1, 0, c_white, 1);
			gpu_set_colorwriteenable(1, 1, 1, 1);
			BLEND_NORMAL
			
			draw_sprite_ext(s_patreon_supporter, 1, spr_x, spr_y, 1, 1, 0, COLORS._main_accent, 1);
			
			if(point_in_circle(_mx, _my, spr_x, spr_y, 10)) TOOLTIP = __txt("Supporter exclusive");
		}
		
		if(icon) draw_sprite_ext(icon, 0, spr_x, spr_y, 1, 1, 0, c_white, 1);
	}
	
	static drawList = function(_x, _y, _mx, _my, _h, _w, _param = {}) {
		var fav = struct_exists(global.FAV_NODES, node);
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
		
		if(IS_PATREON && is_patreon_extra) {
			var spr_x = tx + ui(4);
			var spr_y = _y + _h / 2 - ui(6);
						
			gpu_set_colorwriteenable(0, 0, 0, 1); BLEND_SUBTRACT
			draw_sprite_ext(s_patreon_supporter, 0, spr_x, spr_y, 1, 1, 0, c_white, 1);
			gpu_set_colorwriteenable(1, 1, 1, 1); BLEND_NORMAL
			
			draw_sprite_ext(s_patreon_supporter, 1, spr_x, spr_y, 1, 1, 0, COLORS._main_accent, 1);
			
			if(point_in_circle(_mx, _my, spr_x, spr_y, ui(10))) TOOLTIP = __txt("Supporter exclusive");
			
			tx += ui(12);
		}
		
		return tx;
	}
}

#region globalvar
	globalvar ALL_NODES, NODE_CATEGORY, NODE_PB_CATEGORY, NODE_PCX_CATEGORY;
	globalvar SUPPORTER_NODES, NEW_NODES;
	
	globalvar NODE_PAGE_DEFAULT;
	
	ALL_NODES		  = ds_map_create();
	NODE_CATEGORY	  = ds_list_create();
	NODE_PB_CATEGORY  = ds_list_create();
	NODE_PCX_CATEGORY = ds_list_create();
	SUPPORTER_NODES   = ds_list_create();
	NEW_NODES		  = ds_list_create();
	
	global.__currPage    = "";
	global.__currNewPage = "";
	
	#macro NODE_ADD_CAT if(!IS_CMD) addNodeCatagory
#endregion

function nodeBuild(_name, _x, _y, _group = PANEL_GRAPH.getCurrentContext()) {
	INLINE
	
	if(!ds_map_exists(ALL_NODES, _name)) {
		log_warning("LOAD", $"Node type {_name} not found");
		return noone;
	}
	
	var _node  = ALL_NODES[? _name];
	var _bnode = _node.build(_x, _y, _group);
	
	return _bnode;
}
	
function addNodeObject(_list, _name = "", _node = noone, tooltip = "") {
	var _nodeName = script_get_name(_node);
	
	if(ds_map_exists(ALL_NODES, _nodeName)) {
		var _n = ALL_NODES[? _nodeName];
		if(tooltip != "") _n.setTooltip(tooltip);
		
		ds_list_add(_list, _n);
		return _n;
	}
	
	var _spr  = asset_get_index($"s_{string_lower(_nodeName)}"); 
	if(_spr == -1) _spr = s_node_icon;
	
	var _n = new NodeObject(_name, _spr, _node, tooltip);
	if(tooltip != "") _n.setTooltip(tooltip);
	
	ALL_NODES[? _nodeName] = _n;
	
	ds_list_add(_list, _n);
	return _n;
}
	
function addNodeCatagory(    name, list, filter = [], color = noone) { ds_list_add(NODE_CATEGORY,     { name, list, filter, color }); global.__currPage = name; }
function addNodePBCatagory(  name, list, filter = [])                { ds_list_add(NODE_PB_CATEGORY,  { name, list, filter        }); }
function addNodePCXCatagory( name, list, filter = [])                { ds_list_add(NODE_PCX_CATEGORY, { name, list, filter        }); }

	////- Nodes
	
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
	
	// NODE LIST
	
	var fav = ds_list_create();
	NODE_ADD_CAT("Home", fav);
	
	#region group
	var group = ds_list_create(); 
	NODE_ADD_CAT("Group", group, ["Node_Group"], COLORS.node_blend_collection); 
		ds_list_add(group, "Groups");
		addNodeObject(group, "Input",      Node_Group_Input).hideRecent();
		addNodeObject(group, "Output",     Node_Group_Output).hideRecent();
		addNodeObject(group, "Thumbnail",  Node_Group_Thumbnail).hideRecent();
	#endregion
	
	#region for
	var iter = ds_list_create(); 
	NODE_ADD_CAT("Loop", iter, ["Node_Iterate"], COLORS.node_blend_loop); //#For
		ds_list_add(iter, "Groups");
		addNodeObject(iter, "Loop Input",  Node_Iterator_Input).setSpr(s_node_loop_input).hideRecent();
		addNodeObject(iter, "Loop Output", Node_Iterator_Output).setSpr(s_node_loop_output).hideRecent();
		addNodeObject(iter, "Input",       Node_Group_Input).hideRecent();
		addNodeObject(iter, "Output",      Node_Group_Output).hideRecent();
		addNodeObject(iter, "Thumbnail",   Node_Group_Thumbnail).hideRecent();
			
		ds_list_add(iter, "Loops");
		addNodeObject(iter, "Index",       Node_Iterator_Index).hideRecent();
		addNodeObject(iter, "Loop amount", Node_Iterator_Length).setSpr(s_node_iterator_amount).hideRecent();
	#endregion 
	
	#region for inline
	var iter_il = ds_list_create(); 
	NODE_ADD_CAT("Loop", iter_il, ["Node_Iterate_Inline"], COLORS.node_blend_loop); //#For inline
		ds_list_add(iter_il, "Loops");
		addNodeObject(iter_il, "Index",       Node_Iterator_Index).hideRecent();
		addNodeObject(iter_il, "Loop amount", Node_Iterator_Length).setSpr(s_node_iterator_amount).hideRecent();
	#endregion
	
	#region for each
	var itere = ds_list_create(); 
	NODE_ADD_CAT("Loop", itere, ["Node_Iterate_Each"], COLORS.node_blend_loop); //#Foreach
		ds_list_add(itere, "Groups");
		addNodeObject(itere, "Input",        Node_Group_Input).hideRecent();
		addNodeObject(itere, "Output",       Node_Group_Output).hideRecent();
		addNodeObject(itere, "Thumbnail",    Node_Group_Thumbnail).hideRecent();
			
		ds_list_add(itere, "Loops");
		addNodeObject(itere, "Index",        Node_Iterator_Index).hideRecent();
		addNodeObject(itere, "Array Length", Node_Iterator_Each_Length).setSpr(s_node_iterator_length).hideRecent();
	#endregion
	
	#region for each inline
	var itere_il = ds_list_create(); 
	NODE_ADD_CAT("Loop", itere_il, ["Node_Iterate_Each_Inline"], COLORS.node_blend_loop); //#Foreach inline
		ds_list_add(itere_il, "Loops");
		addNodeObject(itere_il, "Index",        Node_Iterator_Index).hideRecent();
		addNodeObject(itere_il, "Array Length", Node_Iterator_Length).hideRecent();
	#endregion
	
	#region iterate filter
	var filter = ds_list_create(); 
	NODE_ADD_CAT("Filter", filter, ["Node_Iterate_Filter"], COLORS.node_blend_loop); //#Loop filter
		ds_list_add(filter, "Groups");
		addNodeObject(filter, "Input",        Node_Group_Input).hideRecent();
		addNodeObject(filter, "Output",       Node_Group_Output).hideRecent();
		addNodeObject(filter, "Thumbnail",    Node_Group_Thumbnail).hideRecent();
			
		ds_list_add(filter, "Loops");
		addNodeObject(filter, "Index",        Node_Iterator_Index).hideRecent();
		addNodeObject(filter, "Array Length", Node_Iterator_Each_Length).setSpr(s_node_iterator_length).hideRecent();
	#endregion
	
	#region iterate filter inline
	var filter_il = ds_list_create(); 
	NODE_ADD_CAT("Filter", filter_il, ["Node_Iterate_Filter_Inline"], COLORS.node_blend_loop); //#Loop filter inline
		ds_list_add(filter_il, "Loops");
		addNodeObject(filter_il, "Index",        Node_Iterator_Index).hideRecent();
		addNodeObject(filter_il, "Array Length", Node_Iterator_Length).hideRecent();
	#endregion
	
	#region iterate feedback
	var feed = ds_list_create(); 
	NODE_ADD_CAT("Feedback", feed, ["Node_Feedback"], COLORS.node_blend_feedback); //#Feedback
		ds_list_add(feed, "Groups");
		addNodeObject(feed, "Input",     Node_Feedback_Input).hideRecent();
		addNodeObject(feed, "Output",    Node_Feedback_Output).hideRecent();
		addNodeObject(feed, "Thumbnail", Node_Group_Thumbnail).hideRecent();
	#endregion
	
	#region vfx
	var vfx = ds_list_create(); 
	NODE_ADD_CAT("VFX", vfx, ["Node_VFX_Group", "Node_VFX_Group_Inline"], COLORS.node_blend_vfx);
		ds_list_add(vfx, "Groups");
		addNodeObject(vfx, "Input",           Node_Group_Input).hideRecent().hideGlobal();
		addNodeObject(vfx, "Output",          Node_Group_Output).hideRecent().hideGlobal();
		addNodeObject(vfx, "Renderer",        Node_VFX_Renderer_Output).setSpr(s_node_vfx_render_output).hideRecent().hideGlobal();
			
		ds_list_add(vfx, "Main");
		addNodeObject(vfx, "Spawner",         Node_VFX_Spawner,    "Spawn new particles.").setSpr(s_node_vfx_spawn).hideRecent();
		addNodeObject(vfx, "Renderer",        Node_VFX_Renderer,   "Render particle objects to surface.").setSpr(s_node_vfx_render).hideRecent();
			
		ds_list_add(vfx, "Affectors");
		addNodeObject(vfx, "Accelerate",      Node_VFX_Accelerate, "Change the speed of particle in range.").hideRecent();
		addNodeObject(vfx, "Destroy",         Node_VFX_Destroy,    "Destroy particle in range.").hideRecent();
		addNodeObject(vfx, "Attract",         Node_VFX_Attract,    "Attract particle in range to one point.").hideRecent();
		addNodeObject(vfx, "Wind",            Node_VFX_Wind,       "Move particle in range.").hideRecent();
		addNodeObject(vfx, "Vortex",          Node_VFX_Vortex,     "Rotate particle around a point.").hideRecent();
		addNodeObject(vfx, "Turbulence",      Node_VFX_Turbulence, "Move particle in range randomly.").hideRecent();
		addNodeObject(vfx, "Repel",           Node_VFX_Repel,      "Move particle away from point.").hideRecent();
		addNodeObject(vfx, "Oscillate",       Node_VFX_Oscillate,  "Swing particle around its original trajectory.").hideRecent().setVersion(11560);
		addNodeObject(vfx, "Boids",           Node_VFX_Boids,      "Apply boids algorithm to create a flock behaviour.").hideRecent().setVersion(1_18_01_0);
			
		ds_list_add(vfx, "Generates");
		addNodeObject(vfx, "VFX Trail",       Node_VFX_Trail,       "Generate path from particle movement.").hideRecent().setVersion(11560);
		addNodeObject(vfx, "VFX Triangulate", Node_VFX_Triangulate, "Render line between particles.").hideRecent().setVersion(11670);
		
		ds_list_add(vfx, "Variables");
		addNodeObject(vfx, "VFX Variable",	  Node_VFX_Variable, "Extract variable from particle objects.").hideRecent().setVersion(1120);
		addNodeObject(vfx, "VFX Override",	  Node_VFX_Override, "Replace particle variable with a new one.").hideRecent().setVersion(1120);
	#endregion
	
	#region rigidSim
	var rigidSim = ds_list_create(); 
	NODE_ADD_CAT("RigidSim", rigidSim, ["Node_Rigid_Group", "Node_Rigid_Group_Inline"], COLORS.node_blend_simulation);
		ds_list_add(rigidSim, "Group");
		addNodeObject(rigidSim, "Input",              Node_Group_Input).hideRecent().hideGlobal();
		addNodeObject(rigidSim, "Output",             Node_Group_Output).hideRecent().hideGlobal();
		addNodeObject(rigidSim, "Render",             Node_Rigid_Render_Output).hideRecent().hideGlobal();
		addNodeObject(rigidSim, "RigidSim Global",    Node_Rigid_Global).setVersion(1110).hideRecent();
		
		ds_list_add(rigidSim, "RigidSim");
		addNodeObject(rigidSim, "Object",             Node_Rigid_Object,         "Spawn a rigidbody object.").hideRecent().setVersion(1110);
		addNodeObject(rigidSim, "Object Spawner",     Node_Rigid_Object_Spawner, "Spawn multiple rigidbody objects.").hideRecent().setVersion(1110);
		addNodeObject(rigidSim, "Wall",               Node_Rigid_Wall).hideRecent().setVersion(11680);
		addNodeObject(rigidSim, "Render",             Node_Rigid_Render,         "Render rigidbody object to surface.").hideRecent().setVersion(1110);
		addNodeObject(rigidSim, "Apply Force",        Node_Rigid_Force_Apply,    "Apply force to objects.").hideRecent().setVersion(1110);
		addNodeObject(rigidSim, "Activate Physics",   Node_Rigid_Activate,       "Enable or disable rigidbody object.").hideRecent().setVersion(1110);
			
		ds_list_add(rigidSim, "Variables");
		addNodeObject(rigidSim, "Rigidbody Variable", Node_Rigid_Variable, "Extract veriable from rigidbody object.").hideRecent().setVersion(1120);
		addNodeObject(rigidSim, "Rigidbody Override", Node_Rigid_Override, "Replace rigidbody object variable with a new one.").hideRecent().setVersion(1120);
	#endregion
	
	#region smokeSim
	var smokeSim = ds_list_create(); 
	NODE_ADD_CAT("SmokeSim", smokeSim, ["Node_Smoke_Group", "Node_Smoke_Group_Inline"], COLORS.node_blend_smoke);
		ds_list_add(smokeSim, "Group");
		addNodeObject(smokeSim, "Input",          Node_Group_Input).hideRecent().hideGlobal();
		addNodeObject(smokeSim, "Output",         Node_Group_Output).hideRecent().hideGlobal();
		addNodeObject(smokeSim, "Render Domain",  Node_Smoke_Render_Output).hideRecent().setVersion(11540).hideGlobal();
		
		ds_list_add(smokeSim, "Domain");
		addNodeObject(smokeSim, "Domain",         Node_Smoke_Domain).hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Update Domain",  Node_Smoke_Update,         "Run smoke by one step.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Render Domain",  Node_Smoke_Render,         "Render smoke to surface. This node also have update function build in.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Queue Domain",   Node_Smoke_Domain_Queue,   "Sync multiple domains to be render at the same time.").hideRecent().setVersion(1120);
			
		ds_list_add(smokeSim, "Smoke");
		addNodeObject(smokeSim, "Add Emitter",    Node_Smoke_Add,            "Add smoke emitter.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Apply Velocity", Node_Smoke_Apply_Velocity, "Apply velocity to smoke.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Add Collider",   Node_Smoke_Add_Collider,   "Add solid object that smoke can collides to.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Vortex",         Node_Smoke_Vortex,         "Apply rotational force around a point.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Repulse",        Node_Smoke_Repulse,        "Spread smoke away from a point.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Turbulence",     Node_Smoke_Turbulence,     "Apply random velocity map to the smoke.").hideRecent().setVersion(1120);
	#endregion
	
	#region flipSim
	var flipSim = ds_list_create(); 
	NODE_ADD_CAT("FLIP Fluid", flipSim, ["Node_FLIP_Group_Inline"], COLORS.node_blend_fluid);
		ds_list_add(flipSim, "Domain");
		addNodeObject(flipSim, "Domain",          Node_FLIP_Domain).hideRecent().setVersion(11620);
		addNodeObject(flipSim, "Render",          Node_FLIP_Render).hideRecent().setVersion(11620);
		addNodeObject(flipSim, "Update",          Node_FLIP_Update).hideRecent().setVersion(11620);
		
		ds_list_add(flipSim, "Fluid");
		addNodeObject(flipSim, "Spawner",         Node_FLIP_Spawner).hideRecent().setVersion(11620);
		addNodeObject(flipSim, "Destroy",         Node_FLIP_Destroy).hideRecent().setVersion(11680);
		
		ds_list_add(flipSim, "Affectors");
		addNodeObject(flipSim, "Apply Velocity",  Node_FLIP_Apply_Velocity).hideRecent().setVersion(11620);
		addNodeObject(flipSim, "Add Collider",    Node_FLIP_Apply_Force).hideRecent().setVersion(11620);
		//addNodeObject(flipSim, "Add Rigidbody", Node_FLIP_Add_Rigidbody).hideRecent().setVersion(11680);
		addNodeObject(flipSim, "Repel",           Node_FLIP_Repel).hideRecent().setVersion(11680);
		addNodeObject(flipSim, "Vortex",          Node_FLIP_Vortex).hideRecent().setVersion(11680);
		
		ds_list_add(flipSim, "Misc");
		addNodeObject(flipSim, "FLIP to VFX",     Node_FLIP_to_VFX).hideRecent().setVersion(11680);
	#endregion
	
	#region strandSim
	var strandSim = ds_list_create(); 
	NODE_ADD_CAT("StrandSim", strandSim, ["Node_Strand_Group", "Node_Strand_Group_Inline"], COLORS.node_blend_strand);
		ds_list_add(strandSim, "Group");
		addNodeObject(strandSim, "Input",  Node_Group_Input).hideRecent().hideGlobal();
		addNodeObject(strandSim, "Output", Node_Group_Output).hideRecent().hideGlobal();
			
		ds_list_add(strandSim, "System");
		addNodeObject(strandSim, "Strand Create",         Node_Strand_Create, "Create strands from point, path, or mesh.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Update",         Node_Strand_Update, "Update strands by one step.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Render",         Node_Strand_Render, "Render strands to surface as a single path.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Render Texture", Node_Strand_Render_Texture, "Render strands to surface as a textured path.").hideRecent().setVersion(1140);
			
		ds_list_add(strandSim, "Affectors");
		addNodeObject(strandSim, "Strand Gravity",        Node_Strand_Gravity,       "Apply downward acceleration to strands.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Force Apply",    Node_Strand_Force_Apply,   "Apply general force to strands.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Break",          Node_Strand_Break,         "Detach strands from its origin.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Length Adjust",  Node_Strand_Length_Adjust, "Adjust length of strands in area.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Collision",      Node_Strand_Collision,     "Create solid object for strands to collides to.").hideRecent().setVersion(1140);
	#endregion
	
	//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\//\
	
	global.__startPage = ds_list_size(NODE_CATEGORY); 
	
	#region io
	var input = ds_list_create(); 
	addNodeCatagory("IO", input);
		ds_list_add(input, "Images");
			ds_list_add(input, "/Importers");
		addNodeObject(input, "Image",              Node_Image,          "Load a single image from your computer.").setBuild(Node_create_Image);
		addNodeObject(input, "Image GIF",          Node_Image_gif,      "Load animated .gif from your computer.").setBuild(Node_create_Image_gif);
		addNodeObject(input, "Image Array",        Node_Image_Sequence, "Load multiple images from your computer as array.").setBuild(Node_create_Image_Sequence);
		addNodeObject(input, "Animation",          Node_Image_Animated, "Load multiple images from your computer as animation.").setBuild(Node_create_Image_Animated);
		addNodeObject(input, "SVG",                Node_SVG,            "Load a SVG file.");
			ds_list_add(input, "/Converters");
		addNodeObject(input, "Splice Spritesheet", Node_Image_Sheet,   "Cut up spritesheet into animation or image array.");
		addNodeObject(input, "Array to Anim",      Node_Sequence_Anim, "Convert array of images into animation.");
		if(!DEMO) {
			ds_list_add(input, "/Exporters");
			addNodeObject(input, "Export",         Node_Export, "Export image, image array to file, image sequence, animation.").setBuild(Node_create_Export);
		}
		
		ds_list_add(input, "Canvas");
		addNodeObject(input, "Canvas",             Node_Canvas,        "Draw on surface using brush, eraser, etc.").setTags(["draw"]);
		addNodeObject(input, "Canvas Group",       Node_Canvas_Group,  "Create a group that combines multiple canvas nodes a layers.").setTags(["draw"]).setVersion(11740);
		addNodeObject(input, "Active Canvas",      Node_Active_Canvas, "Draw using parameterized brush.").setTags(["draw"]).setVersion(11570);
		
		ds_list_add(input, "Tileset");
			ds_list_add(input, "/Creators");
		addNodeObject(input, "Tileset",            Node_Tile_Tileset, "Create tileset object.").setVersion(1_18_03_0);
		addNodeObject(input, "Tile Drawer",        Node_Tile_Drawer,  "Draw using tileset.").setVersion(1_18_03_0);
		addNodeObject(input, "Tile Rule",          Node_Tile_Rule,    "Apply tileset rules.").setVersion(1_18_03_0);
		addNodeObject(input, "Convert to Tilemap", Node_Tile_Convert, "Convert color image to tile data.").setVersion(1_18_03_0);
			ds_list_add(input, "/Exporters");
		addNodeObject(input, "Render Tilemap",     Node_Tile_Render,         "Render tilemap to image.").setVersion(1_18_03_0);
		addNodeObject(input, "Export Tilemap",     Node_Tile_Tilemap_Export, "Export tilemap to file.").setVersion(1_18_03_0);
		
		ds_list_add(input, "Files");
		addNodeObject(input, "Text File In",       Node_Text_File_Read,       "Load .txt in as text.").setTags(["txt"]).setVersion(1080);
		addNodeObject(input, "Text File Out",      Node_Text_File_Write,      "Save text as a .txt file.").setTags(["txt"]).setVersion(1090);
		addNodeObject(input, "CSV File In",        Node_CSV_File_Read,        "Load .csv as text, number array.").setTags(["comma separated value"]).setVersion(1090);
		addNodeObject(input, "CSV File Out",       Node_CSV_File_Write,       "Save array as .csv file.").setTags(["comma separated value"]).setVersion(1090);
		addNodeObject(input, "JSON File In",       Node_Json_File_Read,       "Load .json file using keys.").setVersion(1090);
		addNodeObject(input, "JSON File Out",      Node_Json_File_Write,      "Save data to .json file.").setVersion(1090);
		addNodeObject(input, "WAV File In",        Node_WAV_File_Read,        "Load wav audio file.").setBuild(Node_create_WAV_File_Read).setVersion(1144);
		addNodeObject(input, "WAV File Out",       Node_WAV_File_Write,       "Save wav audio file.").setVersion(1145);
		addNodeObject(input, "XML File In",        Node_XML_File_Read,        "Load xml file.").setBuild(Node_create_XML_File_Read).setVersion(11720);
		addNodeObject(input, "XML File Out",       Node_XML_File_Write,       "Write struct to xml file.").setVersion(11720);
		addNodeObject(input, "Byte File In",       Node_Byte_File_Read,       "Load any file to buffer.").setVersion(11670);
		addNodeObject(input, "Byte File Out",      Node_Byte_File_Write,      "Save buffer content to a file.").setVersion(11670);
		addNodeObject(input, "Directory Search",   Node_Directory_Search,     "Search for files in directory.").setBuild(Node_create_Directory_Search).setVersion(11710);
		
		ds_list_add(input, "Aseprite");
		addNodeObject(input, "ASE File In",        Node_ASE_File_Read,        "Load Aseprite file with support for layers, tags.").setBuild(Node_create_ASE_File_Read).setVersion(1100);
		addNodeObject(input, "ASE Layer",          Node_ASE_layer,            "Load Aseprite project file").setVersion(1100);
		addNodeObject(input, "ASE Tag",            Node_ASE_Tag,              "Read tag from ASE file.").setSpr(s_node_ase_layer).setVersion(1_18_03_0);
			
		ds_list_add(input, "External");
		addNodeObject(input, "Websocket Receiver", Node_Websocket_Receiver, "Create websocket server to receive data from the network.").setVersion(1145);
		addNodeObject(input, "Websocket Sender",   Node_Websocket_Sender,   "Create websocket server to send data to the network.").setVersion(1145);
		addNodeObject(input, "Spout Sender",       Node_Spout_Send,         "Send surface through Spout.").setVersion(11600);
		addNodeObject(input, "MIDI In",            Node_MIDI_In,            "Receive MIDI message.").setVersion(11630).notTest();
		addNodeObject(input, "HTTP",               Node_HTTP_request,       "Request data from the internet.").setVersion(11780);
		
		ds_list_add(input, "Gamemaker");
		addNodeObject(input, "GMRoom", Node_GMRoom).setSpr(s_gmroom).setVersion(1_18_04_1);
	#endregion
	
	#region transform
	var transform = ds_list_create(); 
	addNodeCatagory("Transform", transform);
		ds_list_add(transform, "Transforms");
		addNodeObject(transform, "Transform",       Node_Transform,         "Move, rotate, and scale image.").setTags(["move", "rotate", "scale"]);
		addNodeObject(transform, "Scale",           Node_Scale,             "Simple node for scaling image.").setTags(["resize"]);
		addNodeObject(transform, "Scale Algorithm", Node_Scale_Algo,        "Scale image using pixel-art based scaling algorithms.").setBuild(Node_create_Scale_Algo).setTags(["scale2x", "scale3x", "cleanedge"]);
		addNodeObject(transform, "Flip",            Node_Flip,              "Flip image horizontally or vertically.").setTags(["mirror"]);
		addNodeObject(transform, "Offset",          Node_Offset,            "Shift image with tiling.").setTags(["shift"]);
		addNodeObject(transform, "Mirror",          Node_Mirror,            "Reflect the image along a reflection line.").setVersion(1070);
		addNodeObject(transform, "Polar Mirror",    Node_Mirror_Polar,      "Reflect the image along multiple reflection lines.").setTags(["kaleidoscope"]).setVersion(1_18_06_2);
		
		ds_list_add(transform, "Crops");
		addNodeObject(transform, "Crop",            Node_Crop,         "Crop out image to create smaller ones.");
		addNodeObject(transform, "Crop Content",    Node_Crop_Content, "Crop out empty pixel from the image.");
		
		ds_list_add(transform, "Warps");
		addNodeObject(transform, "Warp",            Node_Warp,        "Warp image by freely moving the corners.").setTags(["warp corner"]);
	 // addNodeObject(transform, "Perspective Warp",Node_Warp_Perspective, "Warp image by modifying perspective.").setTags(["warp perspective"]);
		addNodeObject(transform, "Skew",            Node_Skew,        "Skew image horizontally, or vertically.").setTags(["shear"]);
	 // addNodeObject(transform, "Grid Warp",       Node_Grid_Warp,   "Wrap image by modifying mesh lacttice.");
		addNodeObject(transform, "Bend",            Node_Bend,        "Warp an image into a predefined shape.").setVersion(11650);
		addNodeObject(transform, "Mesh Warp",       Node_Mesh_Warp,   "Wrap image by converting it to mesh, and using control points.");
		addNodeObject(transform, "Polar",           Node_Polar,       "Convert image to polar coordinate.");
		addNodeObject(transform, "Area Warp",       Node_Wrap_Area,   "Wrap image to fit an area value.");
		
		ds_list_add(transform, "Others");
		addNodeObject(transform, "Composite",       Node_Composite,   "Combine multiple images with controllable position, rotation, scale.").setTags(["merge"]);
		addNodeObject(transform, "Nine Slice",      Node_9Slice,      "Cut image into 3x3 parts, and scale/repeat only the middle part.").setTags(["9 slice", "splice", "nine patch"]);
		addNodeObject(transform, "Padding",         Node_Padding,     "Make image bigger by adding space in 4 directions.");
		addNodeObject(transform, "Tile Random",     Node_Tile_Random, "Repeat images on a larger surface randomly.").setVersion(11780);
	#endregion
	
	#region filter
	var filter = ds_list_create(); 
	addNodeCatagory("Filter", filter);
		
		ds_list_add(filter, "Combines");
		addNodeObject(filter, "Blend",            Node_Blend,            "Blend 2 images using different blend modes.").setBuild(Node_create_Blend).setTags(global.node_blend_keys);
		addNodeObject(filter, "RGBA Combine",     Node_Combine_RGB,      "Combine 4 image in to one. Each image use to control RGBA channel.").setVersion(1070);
		addNodeObject(filter, "HSV Combine",      Node_Combine_HSV,      "Combine 4 image in to one. Each image use to control HSVA channel.").setVersion(1070);
		addNodeObject(filter, "Override Channel", Node_Override_Channel, "Replace RGBA value of one surface with another.").setVersion(11640);
		
		ds_list_add(filter, "Blurs");
			ds_list_add(filter, "/Kernel-based");
		addNodeObject(filter, "Blur",             Node_Blur,             "Blur image smoothly.").setTags(["gaussian blur"]);
		addNodeObject(filter, "Non-Uniform Blur", Node_Blur_Simple,      "Blur image using simpler algorithm. Allowing for variable blur strength.").setVersion(1070);
		addNodeObject(filter, "Contrast Blur",    Node_Blur_Contrast,    "Blur only pixel of a similiar color.");
		addNodeObject(filter, "Box Blur",         Node_Blur_Box,         "Blur pixel in square area uniformly.").setVersion(1_18_06_2);
		addNodeObject(filter, "Shape Blur",       Node_Blur_Shape,       "Blur image using another image as blur map.").setVersion(11650);
		addNodeObject(filter, "High Pass",        Node_High_Pass,        "Apply high pass filter").setTags(["sharpen"]).setVersion(1_18_01_0);
			ds_list_add(filter, "/Linear");
		addNodeObject(filter, "Directional Blur", Node_Blur_Directional, "Blur image given a direction.").setTags(["motion blur"]);
		addNodeObject(filter, "Slope Blur",       Node_Blur_Slope,       "Blur along a gradient of a slope map.").setTags(["motion blur"]).setVersion(11640);
		addNodeObject(filter, "Zoom Blur",        Node_Blur_Zoom,        "Blur image by zooming in/out from a mid point.");
		addNodeObject(filter, "Radial Blur",      Node_Blur_Radial,      "Blur image by rotating around a mid point.").setVersion(1110);
		addNodeObject(filter, "Path Blur",        Node_Blur_Path,        "Blur pixel along path.").setVersion(11750);
		addNodeObject(filter, "Smear",            Node_Smear,            "Stretch out brighter pixel in one direction.").setVersion(11670);
			ds_list_add(filter, "/Non-Linear");
		addNodeObject(filter, "Lens Blur",        Node_Blur_Bokeh,       "Create bokeh effect. Blur lighter color in a lens-like manner.").setTags(["bokeh"]).setVersion(1110);
		addNodeObject(filter, "Average",          Node_Average,          "Average color of every pixels in the image.").setVersion(1110);
		addNodeObject(filter, "Kuwahara",         Node_Kuwahara,         "Apply Kuwahara filter. Creating a watercolor-like effect.").setVersion(11660);
		addNodeObject(filter, "Brush",            Node_Brush_Linear,     "Apply brush effect.").patreonExtra();
		
		ds_list_add(filter, "Warps");
			ds_list_add(filter, "/Effects");
		addNodeObject(filter, "Mirror",           Node_Mirror,           "Reflect the image along a reflection line.");
		addNodeObject(filter, "Polar Mirror",     Node_Mirror_Polar,     "Reflect the image around multiple radial reflection lines.");
		addNodeObject(filter, "Twirl",            Node_Twirl,            "Twist the image around a mid point.").setTags(["twist"]);
		addNodeObject(filter, "Dilate",           Node_Dilate,           "Expand the image around a mid point.").setTags(["inflate"]);
		addNodeObject(filter, "Spherize",         Node_Spherize,         "Wrap a texture on to sphere.").setVersion(11630);
		addNodeObject(filter, "Displace",         Node_Displace,         "Distort image using another image as a map.").setTags(["distort"]);
		addNodeObject(filter, "Morph Surface",    Node_Morph_Surface,    "Morph pixel between two surfaces.").setVersion(1141);
		addNodeObject(filter, "Liquefy",          Node_Liquefy,          "Distort image using variety of tools.").setVersion(1_18_02_0);
			ds_list_add(filter, "/Mappers");
		addNodeObject(filter, "Texture Remap",    Node_Texture_Remap,    "Remap image using texture map. Where red channel control x position and green channel control y position.");
		addNodeObject(filter, "Time Remap",       Node_Time_Remap,       "Remap image using texture as time map. Where brighter pixel in time map means using pixel from an older frame.");
		addNodeObject(filter, "Shape Map",        Node_Shape_Map,        "Map image into shapes.").setVersion(11660);
		
		ds_list_add(filter, "Effects");
			ds_list_add(filter, "/Basics");
		addNodeObject(filter, "Outline",              Node_Outline,         "Add border to the image.").setTags(["border"]);
		addNodeObject(filter, "Glow",                 Node_Glow,            "Apply glow to the border of the image.");
		addNodeObject(filter, "Shadow",               Node_Shadow,          "Apply shadow behind the image.");
		addNodeObject(filter, "Blobify",              Node_Blobify,         "Round off sharp corner in BW image by bluring and thresholding.").setVersion(11650);
		addNodeObject(filter, "SDF",                  Node_SDF,             "Create signed distance field using jump flooding algorithm.").setVersion(1130);
		addNodeObject(filter, "Replace Image",        Node_Surface_Replace, "Replace instances of an image with a new one.").setTags(["image replace"]).setVersion(1140);
			ds_list_add(filter, "/Post Processing");
		addNodeObject(filter, "Bloom",                Node_Bloom,           "Apply bloom effect, blurring and brighten the bright part of the image.");
		addNodeObject(filter, "Blend Edge",           Node_Blend_Edge,      "Blend the edges of an image to create tilable patterns.").setVersion(11740);
		addNodeObject(filter, "Chromatic Aberration", Node_Chromatic_Aberration, "Apply chromatic aberration effect to the image.");
		addNodeObject(filter, "FXAA",                 Node_FXAA,            "Apply fast approximate anti-aliasing to te image.").setTags(["anti aliasing"]);
		addNodeObject(filter, "Vignette",             Node_Vignette,        "Apply vignette effect to the border.").setVersion(11630);
		addNodeObject(filter, "JPEG",                 Node_JPEG,            "Apply JPEG compression to the image.").setVersion(11730);
		addNodeObject(filter, "Grain",                Node_Grain,           "Add noise pattern to the image.").setVersion(11770);
			ds_list_add(filter, "/Convolutions");
		addNodeObject(filter, "Convolution",          Node_Convolution,     "Apply convolution operation on each pixel using a custom 3x3 kernel.").setTags(["kernel"]).setVersion(1090);
		addNodeObject(filter, "Edge Detect",          Node_Edge_Detect,     "Edge detect by applying Sobel, Prewitt, or Laplacian kernel.");
		addNodeObject(filter, "Local Analyze",        Node_Local_Analyze,   "Apply non-linear operation (minimum, maximum) on each pixel locally.").setVersion(1110);
		addNodeObject(filter, "Erode",                Node_Erode,           "Remove pixel that are close to the border of the image.");
		addNodeObject(filter, "Round Corner",         Node_Corner,          "Round out sharp corner of the image.").setVersion(1110);
			ds_list_add(filter, "/Pixel Operations");
		addNodeObject(filter, "Pixel Math",           Node_Pixel_Math, "Apply mathematical operation directly on RGBA value.").setBuild(Node_create_Pixel_Math).setTags(global.node_math_keys).setVersion(1_18_02_0);
		addNodeObject(filter, "Pixel Expand",         Node_Atlas,           "Replace transparent pixel with the closest non-transparent pixel.").setTags(["atlas"]);
		addNodeObject(filter, "Pixel Cloud",          Node_Pixel_Cloud,     "Displace each pixel of the image randomly.");
		addNodeObject(filter, "Pixel Sort",           Node_Pixel_Sort,      "Sort pixel by brightness in horizontal, or vertial axis.");
		addNodeObject(filter, "Shuffle",              Node_Shuffle,         "Shuffle image while keeping pixel colors.").setVersion(1_18_05_6);
			ds_list_add(filter, "/Lights");
		addNodeObject(filter, "2D Light",             Node_2D_light,        "Apply different shaped light on the image.");
		addNodeObject(filter, "Cast Shadow",          Node_Shadow_Cast,     "Apply light that casts shadow.").setTags(["raycast"]).setVersion(1100);
			ds_list_add(filter, "/Animations");
		addNodeObject(filter, "Interlace",            Node_Interlaced,      "Apply interlace effect to an image.").setVersion(11760);
		addNodeObject(filter, "Trail",                Node_Trail,           "Blend animation by filling in the pixel 'in-between' two or more frames.").setVersion(1130);
		
		ds_list_add(filter, "Colors");
			ds_list_add(filter, "/Replacements");
		addNodeObject(filter, "Replace Palette",      Node_Color_replace,   "Match image to a palette then remap it to another palette.").setTags(["isolate colors", "select colors", "palette swap", "colors replace"]);
		addNodeObject(filter, "Replace Colors",       Node_Colors_Replace,  "Replace selected colors with a new one.").setTags(["isolate colors", "select color", "palette swap"]);
		addNodeObject(filter, "Remove Color",         Node_Color_Remove,    "Remove color that match a palette.").setTags(["delete color"]);
		addNodeObject(filter, "Separate Color",       Node_Color_Separate,  "Generate array of surfaces for each color.");
			ds_list_add(filter, "/Colorizers");
		addNodeObject(filter, "Colorize",             Node_Colorize,        "Map brightness of a pixel to a color from a gradient.").setTags(["recolor"]);
		addNodeObject(filter, "Posterize",            Node_Posterize,       "Reduce and remap color to match a palette.");
		addNodeObject(filter, "Dither",               Node_Dither,          "Reduce color and use dithering to preserve original color.");
		addNodeObject(filter, "Error Diffuse Dither", Node_Dither_Diffuse,  "Dither image using error diffusion algorithm.").setVersion(1_18_05_1);
		addNodeObject(filter, "Palette Shift",        Node_Palette_Shift,   "Shift the order of color in palette.").setVersion(1147);
			ds_list_add(filter, "/Conversions");
		addNodeObject(filter, "BW",                   Node_BW,              "Convert color image to black and white.").setTags(["black and white"]);
		addNodeObject(filter, "Greyscale",            Node_Greyscale,       "Convert color image to greyscale.").setTags(["grayscale"]);
		addNodeObject(filter, "RGBA Extract",         Node_RGB_Channel,     "Extract RGBA channel on an image, each channel becomes its own image.").setTags(["channel extract"]);
		addNodeObject(filter, "HSV Extract",          Node_HSV_Channel,     "Extract HSVA channel on an image, each channel becomes its own image.").setVersion(1070);
		addNodeObject(filter, "Alpha to Grey",        Node_Alpha_Grey,      "Convert alpha value into solid greyscale.").setTags(["alpha to gray"]);
		addNodeObject(filter, "Grey to Alpha",        Node_Grey_Alpha,      "Convert greyscale to alpha value.").setTags(["gray to alpha"]);
			ds_list_add(filter, "/Adjustments");
		addNodeObject(filter, "Color Adjust",         Node_Color_adjust,    "Adjust brightness, contrast, hue, saturation, value, alpha, and blend image with color.").setTags(["brightness", "contrast", "hue", "saturation", "value", "color blend", "alpha"]);
		addNodeObject(filter, "Level",                Node_Level,           "Adjust brightness of an image by changing its brightness range.");
		addNodeObject(filter, "Level Selector",       Node_Level_Selector,  "Isolate part of the image that falls in the selected brightness range.");
		addNodeObject(filter, "Curve",                Node_Curve,           "Adjust brightness of an image using curves.").setVersion(1120);
		addNodeObject(filter, "HSV Curve",            Node_Curve_HSV,       "Adjust hsv values of an image using curves.").setVersion(11720);
		addNodeObject(filter, "Invert",               Node_Invert,          "Invert color.").setTags(["negate"]);
		addNodeObject(filter, "Threshold",            Node_Threshold,       "Set a threshold where pixel darker will becomes black, and brighter to white. Also works with alpha.").setVersion(1080);
		addNodeObject(filter, "Alpha Cutoff",         Node_Alpha_Cutoff,    "Remove pixel with low alpha value.").setTags(["remove alpha"]);
		addNodeObject(filter, "Normalize",            Node_Normalize,       "Normalize image ranges (brightness, RGB channels) in to [0, 1] range.").setVersion(11710);
		addNodeObject(filter, "Gamma Map",            Node_Gamma_Map,       "Apply gamma approximation (pow(2.2)) to an image.").setTags(["srgb"]).setVersion(11660);
		addNodeObject(filter, "ACE",                  Node_Tonemap_ACE,     "Apply ACE tonemapping.").setVersion(11710);
		
		ds_list_add(filter, "Fixes");
		addNodeObject(filter, "De-Corner",            Node_De_Corner,       "Attempt to remove single pixel corner from the image.").setTags(["decorner"]);
		addNodeObject(filter, "De-Stray",             Node_De_Stray,        "Attempt to remove orphan pixel.").setTags(["destray"]);
	#endregion
	
	#region d3d
	var d3d = ds_list_create(); 
	addNodeCatagory("3D", d3d);
		ds_list_add(d3d, "2D Operations");
		addNodeObject(d3d, "Transform 3D",            Node_3D_Transform_Image, "Transform image in 3D space").setTags(["3d transform"]).setVersion(11600);
		addNodeObject(d3d, "Normal",                  Node_Normal,             "Create normal map using greyscale value as height.");
		addNodeObject(d3d, "Normal Light",            Node_Normal_Light,       "Light up the image using normal mapping.");
		addNodeObject(d3d, "Bevel",                   Node_Bevel,              "Apply 2D bevel on the image.");
		addNodeObject(d3d, "Sprite Stack",            Node_Sprite_Stack,       "Create sprite stack either from repeating a single image or stacking different images using array.");
		addNodeObject(d3d, "Ambient Occlusion",       Node_Ambient_Occlusion,  "Apply simple 2D AO effect using height map.").setTags(["ao"]).patreonExtra();
		
		ds_list_add(d3d, "Scenes");
		addNodeObject(d3d, "3D Camera",               Node_3D_Camera,     "Create 3D camera that render scene to surface.").setVersion(11510);
		addNodeObject(d3d, "3D Camera Set",           Node_3D_Camera_Set, "3D camera with built-in key and fill directional lights.").setVersion(11571);
		addNodeObject(d3d, "3D Scene",                Node_3D_Scene,      "Combine multiple 3D objects into a single junction.").setVersion(11510);
		
		ds_list_add(d3d, "Materials");
		addNodeObject(d3d, "3D Material",             Node_3D_Material,   "Create 3D material with adjustable parameters.").setVersion(11510);
		
		ds_list_add(d3d, "Meshes");
			ds_list_add(d3d, "/Creators");
		addNodeObject(d3d, "3D Object",               Node_3D_Mesh_Obj, "Load .obj file from your computer as a 3D object.").setBuild(Node_create_3D_Obj).setVersion(11510);
		addNodeObject(d3d, "3D Plane",                Node_3D_Mesh_Plane, "Put 2D image on a plane in 3D space.").setVersion(11510);
		addNodeObject(d3d, "3D Cube",                 Node_3D_Mesh_Cube).setVersion(11510);
		addNodeObject(d3d, "3D Cylinder",             Node_3D_Mesh_Cylinder).setVersion(11510);
		addNodeObject(d3d, "3D UV Sphere",            Node_3D_Mesh_Sphere_UV).setVersion(11510);
		addNodeObject(d3d, "3D Icosphere",            Node_3D_Mesh_Sphere_Ico).setVersion(11510);
		addNodeObject(d3d, "3D Cone",                 Node_3D_Mesh_Cone).setVersion(11510);
		addNodeObject(d3d, "3D Torus",                Node_3D_Mesh_Torus).setVersion(1_18_01_0);
		addNodeObject(d3d, "3D Terrain",              Node_3D_Mesh_Terrain,      "Create 3D terrain from height map.").setVersion(11560);
		addNodeObject(d3d, "3D Wall Builder",         Node_3D_Mesh_Wall_Builder).setVersion(1_18_01_0);
		addNodeObject(d3d, "Surface Extrude",         Node_3D_Mesh_Extrude,      "Extrude 2D image into 3D object.").setVersion(11510);
		addNodeObject(d3d, "Path Extrude",            Node_3D_Mesh_Path_Extrude, "Extrude path into 3D object.").setVersion(11750);
			ds_list_add(d3d, "/Exporters");
		addNodeObject(d3d, "Mesh Export",             Node_3D_Mesh_Export, "Export 3D mesh as .obj file").setVersion(11740);
		addNodeObject(d3d, "Slice Stack",             Node_3D_Mesh_Stack_Slice).setVersion(11750);
		
		ds_list_add(d3d, "Light");
		addNodeObject(d3d, "Directional Light",       Node_3D_Light_Directional, "Create directional light directed at the origin point.").setVersion(11510);
		addNodeObject(d3d, "Point Light",             Node_3D_Light_Point,       "Create point light to illuminate surrounding area.").setVersion(11510);
			
		ds_list_add(d3d, "Modify");
			ds_list_add(d3d, "/Meshes");
		addNodeObject(d3d, "Transform",               Node_3D_Transform,       "Transform 3D object.").setVersion(11570);
		addNodeObject(d3d, "Transform Scene",         Node_3D_Transform_Scene, "Transform 3D scene, accepts array of transformations for each objects.").setVersion(11570);
		addNodeObject(d3d, "Discretize vertex",       Node_3D_Round_Vertex,    "Round out vertex position to a specified step.").setVersion(11560);
		addNodeObject(d3d, "3D Displace",             Node_3D_Displace).setVersion(1_18_01_0);
		addNodeObject(d3d, "3D Subdivide",            Node_3D_Subdivide).setVersion(1_18_03_0);
			ds_list_add(d3d, "/Instances");
		addNodeObject(d3d, "3D Repeat",               Node_3D_Repeat, "Repeat the same 3D mesh multiple times.").setVersion(11510);
	 // addNodeObject(d3d, "3D Instancer",            Node_3D_Instancer).setVersion(11560);
	 // addNodeObject(d3d, "3D Particle",             Node_3D_Particle).setVersion(11560);
			ds_list_add(d3d, "/Materials");
		addNodeObject(d3d, "Set Material",            Node_3D_Set_Material, "Replace mesh material with a new one.").setVersion(11560);
		addNodeObject(d3d, "UV Remap",                Node_3D_UV_Remap,     "Remap UV map using plane.").setVersion(11570);
		
		ds_list_add(d3d, "Points");
		addNodeObject(d3d, "Point Affector",          Node_3D_Point_Affector, "Generate array of 3D points interpolating between two values based on the distance.").setVersion(11570);
		
		ds_list_add(d3d, "Ray Marching");
		addNodeObject(d3d, "RM Primitive",            Node_RM_Primitive).setBuild(Node_create_RM_Primitive).setTags(global.node_rm_primitive_keys).setVersion(11720);
		addNodeObject(d3d, "RM Terrain",              Node_RM_Terrain).setTags(["ray marching"]).setVersion(11720);
		addNodeObject(d3d, "RM Combine",              Node_RM_Combine).setTags(["ray marching", "rm boolean"]).setVersion(11740);
		addNodeObject(d3d, "RM Render",               Node_RM_Render).setTags(["ray marching"]).setVersion(11740);
		addNodeObject(d3d, "RM Cloud",                Node_RM_Cloud, "Generate distance field cloud.").patreonExtra();
	#endregion
	
	#region generator
	var generator = ds_list_create(); 
	addNodeCatagory("Generate", generator);
		ds_list_add(generator, "Colors");
		addNodeObject(generator, "Solid",                  Node_Solid,           "Create image of a single color.");
		addNodeObject(generator, "Draw Gradient",          Node_Gradient,        "Create image from gradient.");
		addNodeObject(generator, "Draw 4 Points Gradient", Node_Gradient_Points, "Create image from 4 color points.");
		addNodeObject(generator, "Sky",                    Node_Sky,             "Generate sky texture using different model.");
		
		ds_list_add(generator, "Drawer");
		addNodeObject(generator, "Draw Line",              Node_Line,               "Draw line on an image. Connect path data to it to draw line from path.");
		addNodeObject(generator, "Draw Text",              Node_Text,               "Draw text on an image.");
		addNodeObject(generator, "Draw Shape",             Node_Shape,              "Draw simple shapes using signed distance field.").setBuild(Node_create_Shape).setTags(global.node_shape_keys);
		addNodeObject(generator, "Draw Shape Polygon",     Node_Shape_Polygon,      "Draw polygonal shapes.").setVersion(1130);
		addNodeObject(generator, "Draw Random Shape",      Node_Random_Shape,       "Generate random shape, use for testing purposes.").setVersion(1147);
		addNodeObject(generator, "Draw Bar / Graph",       Node_Plot_Linear,        "Plot graph or bar chart from array of number.").setBuild(Node_create_Plot_Linear).setTags(global.node_plot_linear_keys).setVersion(1144);
		addNodeObject(generator, "Draw Path Profile",      Node_Path_Profile,       "Fill-in an area on one side of a path.").setVersion(11660);
		addNodeObject(generator, "Draw Cross Section",     Node_Cross_Section,      "Map the brightness of pixels on a linear axis into a surface.").setVersion(11710);
		addNodeObject(generator, "Interpret Number",       Node_Interpret_Number,   "Convert array of number into surface.").setVersion(11530);
		addNodeObject(generator, "Pixel Builder",          Node_Pixel_Builder,      "Will break, do not create. please. Why is it here??").setVersion(11540);
		addNodeObject(generator, "Tile Drawer",            Node_Tile_Drawer).setVersion(1_18_03_0);
		
		ds_list_add(generator, "Noises");
			ds_list_add(generator, "/Basics");
		addNodeObject(generator, "Noise",                  Node_Noise,           "Generate white noise.");
		addNodeObject(generator, "Perlin Noise",           Node_Perlin,          "Generate perlin noise.");
		addNodeObject(generator, "Simplex Noise",          Node_Noise_Simplex,   "Generate simplex noise, similiar to perlin noise with better fidelity but non-tilable.").setTags(["perlin"]).setVersion(1080);
		addNodeObject(generator, "Cellular Noise",         Node_Cellular,        "Generate voronoi pattern.").setTags(["voronoi", "worley"]);
		addNodeObject(generator, "Anisotropic Noise",      Node_Noise_Aniso,     "Generate anisotropic noise.");
	 // addNodeObject(generator, "Blue Noise",             Node_Noise_Blue,      "Generate blue noise texture").setVersion(1_18_06_2);
		addNodeObject(generator, "Extra Perlins",          Node_Perlin_Extra,    "Random perlin noise made with different algorithms.").setTags(["noise"]).patreonExtra();
		addNodeObject(generator, "Extra Voronoi",          Node_Voronoi_Extra,   "Random voronoi noise made with different algorithms.").setTags(["noise"]).patreonExtra();
			ds_list_add(generator, "/Artistics");
		addNodeObject(generator, "Fold Noise",             Node_Fold_Noise,      "Generate cloth fold noise").setVersion(11650);
		addNodeObject(generator, "Strand Noise",           Node_Noise_Strand,    "Generate random srtands noise.").setVersion(11650);
		addNodeObject(generator, "Gabor Noise",            Node_Gabor_Noise,     "Generate Gabor noise").patreonExtra();
		addNodeObject(generator, "Shard Noise",            Node_Shard_Noise,     "Generate glass shard-looking noise").patreonExtra();
		addNodeObject(generator, "Wavelet Noise",          Node_Wavelet_Noise,   "Generate wavelet noise").patreonExtra();
		addNodeObject(generator, "Caustic",                Node_Caustic,         "Generate caustic noise").patreonExtra();
		addNodeObject(generator, "Bubble Noise",           Node_Noise_Bubble,    "Generate bubble noise").patreonExtra();
		addNodeObject(generator, "Flow Noise",             Node_Flow_Noise,      "Generate fluid flow noise").patreonExtra();
		addNodeObject(generator, "Cristal Noise",          Node_Noise_Cristal,   "Generate Cristal noise").patreonExtra();
		addNodeObject(generator, "Honeycomb Noise",        Node_Honeycomb_Noise, "Generate honeycomb noise").patreonExtra();
		
		ds_list_add(generator, "Patterns");
			ds_list_add(generator, "/Basics");
		addNodeObject(generator, "Stripe",                 Node_Stripe,          "Generate stripe pattern.");
		addNodeObject(generator, "Zigzag",                 Node_Zigzag,          "Generate zigzag pattern.");
		addNodeObject(generator, "Checker",                Node_Checker,         "Generate checkerboard pattern.");
			ds_list_add(generator, "/Grids");
		addNodeObject(generator, "Grid",                   Node_Grid,            "Generate grid pattern.").setTags(["tile", "mosaic"]);
		addNodeObject(generator, "Triangular Grid",        Node_Grid_Tri,        "Generate triangular grid pattern.");
		addNodeObject(generator, "Hexagonal Grid",         Node_Grid_Hex,        "Generate hexagonal grid pattern.");
		addNodeObject(generator, "Pentagonal Grid",        Node_Grid_Pentagonal, "Generate Pentagonal grid pattern.").patreonExtra();
			ds_list_add(generator, "/Tiles");
		addNodeObject(generator, "Pytagorean Tile",        Node_Pytagorean_Tile, "Generate Pytagorean tile pattern.").patreonExtra();
		addNodeObject(generator, "Herringbone Tile",       Node_Herringbone_Tile, "Generate Herringbone tile pattern.").patreonExtra();
		addNodeObject(generator, "Random Tile",            Node_Random_Tile,     "Generate Random tile pattern.").patreonExtra();
			ds_list_add(generator, "/Others");
		addNodeObject(generator, "Box Pattern",            Node_Box_Pattern,     "Generate square-based patterns..").setVersion(11750);
		addNodeObject(generator, "Quasicrystal",           Node_Quasicrystal,    "Generate Quasicrystal pattern.").setVersion(11660);
		addNodeObject(generator, "Pixel Sampler",          Node_Pixel_Sampler,   "Map image on to each individual pixels of another image.").setVersion(11730);
		addNodeObject(generator, "Julia",                  Node_Julia_Set,       "Generate Julia fractal.").setVersion(1_18_05_6);
		
		ds_list_add(generator, "Populate");
		addNodeObject(generator, "Repeat",                 Node_Repeat,          "Repeat image multiple times linearly, or in grid pattern.").setBuild(Node_create_Repeat).setTags(global.node_repeat_keys).setVersion(1100);
		addNodeObject(generator, "Scatter",                Node_Scatter,         "Scatter image randomly multiple times.");
		addNodeObject(generator, "Repeat Texture",         Node_Repeat_Texture,  "Repeat texture over larger surface without repeating patterns.");
		
		ds_list_add(generator, "Simulation");
		addNodeObject(generator, "Particle",               Node_Particle,            "Generate particle effect.");
		addNodeObject(generator, "VFX",                    Node_VFX_Group_Inline,    "Create VFX group, which generate particles that can be manipulated using different force nodes.").setSpr(s_node_vfx);
		addNodeObject(generator, "RigidSim",               Node_Rigid_Group_Inline,  "Create group for rigidbody simulation.").setSpr(s_node_rigid).setVersion(1110);
		addNodeObject(generator, "FLIP Fluid",             Node_FLIP_Group_Inline,   "Create group for fluid simulation.").setSpr(s_node_flip_group).setVersion(11620);
		addNodeObject(generator, "SmokeSim",               Node_Smoke_Group_Inline,  "Create group for smoke simulation.").setSpr(s_node_smoke_group).setVersion(1120);
		addNodeObject(generator, "StrandSim",              Node_Strand_Group_Inline, "Create group for hair simulation.").setSpr(s_node_strand).setTags(["hair"]).setVersion(1140);
		addNodeObject(generator, "Diffuse",                Node_Diffuse,             "Simulate diffusion like simulation.").setVersion(11640);
		addNodeObject(generator, "Reaction Diffusion",     Node_RD,                  "Simulate reaction diffusion effect.").setSpr(s_node_reaction_diffusion).setVersion(11630);
		
		ds_list_add(generator, "Region");
		addNodeObject(generator, "Separate Shape",   Node_Seperate_Shape, "Separate disconnected pixel each into an image in an image array.");
		addNodeObject(generator, "Region Fill",      Node_Region_Fill,    "Fill connected pixel with colors.").setVersion(1147);		
		addNodeObject(generator, "Flood Fill",       Node_Flood_Fill,     "Filled connected pixel given position and color.").setVersion(1133);
		
		ds_list_add(generator, "MK Effects");
		addNodeObject(generator, "MK Rain",          Node_MK_Rain,      "Generate deterministic rain.").setVersion(11600);
		addNodeObject(generator, "MK GridBalls",     Node_MK_GridBalls, "Generate controllable grid of spheres.").setVersion(11600);
		addNodeObject(generator, "MK GridFlip",      Node_MK_GridFlip,  "Generate controllable grid of planes.").setVersion(11600);
		addNodeObject(generator, "MK Saber",         Node_MK_Saber,     "Generate glowing saber from 2 points.").setVersion(11600);
		addNodeObject(generator, "MK Tile",          Node_MK_Tile,      "Generate game engines-ready tileset.").setVersion(11600);
		addNodeObject(generator, "MK Flag",          Node_MK_Flag,      "Generate waving flag.").setVersion(11600);
		addNodeObject(generator, "MK Brownian",      Node_MK_Brownian,  "Generate random particle.").setVersion(11630);
		addNodeObject(generator, "MK Fall",          Node_MK_Fall,      "Generate leaves falling effects.").setTags(["Leaf", "Leaves"]).setVersion(11630);
		addNodeObject(generator, "MK Blinker",       Node_MK_Blinker,   "Flicker regions of the selected colors randomly.").setVersion(11630);
		addNodeObject(generator, "MK Lens Flare",    Node_MK_Flare,     "Generate lens flare.").setVersion(11630);
		addNodeObject(generator, "MK Delay Machine", Node_MK_Delay_Machine,"Combines multiple frames of animation into one.").setVersion(11680);
		addNodeObject(generator, "MK Fracture",      Node_MK_Fracture,  "Deterministically fracture and image and apply basic physics.").patreonExtra();
		addNodeObject(generator, "MK Sparkle",       Node_MK_Sparkle,   "Generate random star animation.").patreonExtra();
		addNodeObject(generator, "MK Subpixel",      Node_MK_Subpixel,  "Apply subpixel filter on top of a surface.").setVersion(1_17_11_0);
	#endregion
	
	#region compose
	var compose = ds_list_create(); 
	addNodeCatagory("Compose", compose);
		ds_list_add(compose, "Composes");
		addNodeObject(compose, "Blend",              Node_Blend,				"Combine 2 images using different blend modes.");
		addNodeObject(compose, "Composite",          Node_Composite,			"Combine multiple images with custom transformation.");
		addNodeObject(compose, "Stack",              Node_Stack,				"Place image next to each other linearly, or on top of each other.").setVersion(1070);
		addNodeObject(compose, "Image Grid",         Node_Image_Grid,			"Place image next to each other in grid pattern.").setVersion(11640);
		addNodeObject(compose, "Camera",             Node_Camera,              "Create camera that crop image to fix dimension with control of position, zoom. Also can be use to create parallax effect.");
		addNodeObject(compose, "Render Spritesheet", Node_Render_Sprite_Sheet, "Create spritesheet from image array or animation.");
		addNodeObject(compose, "Pack Sprites",       Node_Pack_Sprites,		"Combine array of images with different dimension using different algorithms.").setVersion(1140);
			
		ds_list_add(compose, "Armature");
			ds_list_add(compose, "/Basics");
		addNodeObject(compose, "Armature Create",    Node_Armature,          "Create new armature system."                  ).setTags(["rigging", "bone"]).setVersion(1146);
		addNodeObject(compose, "Armature Pose",      Node_Armature_Pose,     "Pose armature system."                        ).setTags(["rigging", "bone"]).setVersion(1146);
		addNodeObject(compose, "Armature Bind",      Node_Armature_Bind,     "Bind and render image to an armature system." ).setTags(["rigging", "bone"]).setVersion(1146);
		addNodeObject(compose, "Armature Mesh Rig",  Node_Armature_Mesh_Rig, "Rig mesh to armature system."                 ).setTags(["rigging", "bone"]).setVersion(1_18_04_0);
			ds_list_add(compose, "/Convertors");
		addNodeObject(compose, "Armature Path",      Node_Armature_Path,     "Generate path from armature system."          ).setTags(["rigging", "bone"]).setVersion(1146);
		addNodeObject(compose, "Armature Sample",    Node_Armature_Sample,   "Sample point from armature system."           ).setTags(["rigging", "bone"]).setVersion(1147);
		
		if(!DEMO) {
			ds_list_add(compose, "Export");
			addNodeObject(compose, "Export", Node_Export, "Export image/animation to file(s).").setBuild(Node_create_Export);
		}
	#endregion
	
	#region values
	var values = ds_list_create(); 
	addNodeCatagory("Values", values);
		ds_list_add(values, "Raw data");
		addNodeObject(values, "Number",  Node_Number,  "Generate number data.");
		addNodeObject(values, "Boolean", Node_Boolean, "Generate boolean (true, false) data.").setVersion(1090);
		addNodeObject(values, "Text",    Node_String,  "Generate text/string data.");
		addNodeObject(values, "Path",    Node_Path,    "Generate path.");
		addNodeObject(values, "Area",    Node_Area,    "Generate area data.");
		
		ds_list_add(values, "Numbers");
			ds_list_add(values, "/Creators");
		addNodeObject(values, "Number",          Node_Number,           "Generate number data.");
		addNodeObject(values, "To Number",       Node_To_Number,        "Convert string to number, supports scientific format (e.g. 1e-2 = 0.02).").setVersion(1145);
		addNodeObject(values, "Random",          Node_Random,           "Generate pseudorandom value based on seed.");
		addNodeObject(values, "Scatter Points",  Node_Scatter_Points,   "Generate array of vector 2 points.").setVersion(1120);
		addNodeObject(values, "Transform Array", Node_Transform_Array,  "Generate transfomation array.").setVersion(1146);
			ds_list_add(values, "/Operators");
		addNodeObject(values, "Math",            Node_Math,             "Apply mathematical function to number(s).").setBuild(Node_create_Math).setTags(global.node_math_keys);
		addNodeObject(values, "Equation",        Node_Equation,         "Evaluate string of equation. With an option for setting variables.").setBuild(Node_create_Equation);
		addNodeObject(values, "Statistic",       Node_Statistic,        "Apply statistical operation (sum, average, median, etc.) to array of numbers.").setBuild(Node_create_Statistic).setTags(global.node_statistic_keys);
		addNodeObject(values, "Convert Base",    Node_Base_Convert,     "Convert number from one base to another.").setTags(["binary", "hexadecimal"]).setVersion(1140);
		addNodeObject(values, "FFT",             Node_FFT,              "Perform fourier transform on number array.").setTags(["frequency analysis"]).setVersion(1144);
		
		ds_list_add(values, "Vector");
			ds_list_add(values, "/Creators");
		addNodeObject(values, "Vector2",          Node_Vector2,          "Genearte vector composite of 2 members.");
		addNodeObject(values, "Vector3",          Node_Vector3,          "Genearte vector composite of 3 members.");
		addNodeObject(values, "Vector4",          Node_Vector4,          "Genearte vector composite of 4 members.");
			ds_list_add(values, "/Components");
		addNodeObject(values, "Vector Split",     Node_Vector_Split,     "Split vector (up to 4) into individual components.");
		addNodeObject(values, "Swizzle",          Node_Vector_Swizzle,   "Rearrange vector using string containing axis indicies (x, y, z, w).").setTags(["swap axis"]).setVersion(1_17_10_0);
			ds_list_add(values, "/Operators");
		addNodeObject(values, "Magnitude",        Node_Vector_Magnitude, "Calculate magnitude (length) of a vector.").setTags(["vector length", "vector magnitude"]).setVersion(1_17_10_0);
		addNodeObject(values, "Dot product",      Node_Vector_Dot,       "Calculate dot product between vectors.").setVersion(1141);
		addNodeObject(values, "Cross product 2D", Node_Vector_Cross_2D,  "Calculate cross product of 2 vec2s.").setVersion(1141);
		addNodeObject(values, "Cross product 3D", Node_Vector_Cross_3D,  "Calculate cross product of 2 vec3s.").setVersion(1141);
			ds_list_add(values, "/Points");
		addNodeObject(values, "Translate Point",  Node_Move_Point,       "Translate array of points.").setVersion(1141);
		addNodeObject(values, "Point in Area",    Node_Point_In_Area,    "Check whether a point lies in an area.").setVersion(1_17_10_0);
		
		ds_list_add(values, "Texts");
			ds_list_add(values, "/Creators");
		addNodeObject(values, "Text",               Node_String,    "Generate text/string data.");
		addNodeObject(values, "To Text",            Node_To_Text,   "Convert string to number.").setVersion(1145);
		addNodeObject(values, "Unicode",            Node_Unicode,   "Convert unicode id into string.");
			ds_list_add(values, "/Info");
		addNodeObject(values, "Text Length",        Node_String_Length,   "Return number of character in a string.").setVersion(1138);
		addNodeObject(values, "Get Character",      Node_String_Get_Char, "Get a nth character in a string.").setVersion(1100);
			ds_list_add(values, "/Operators");
		addNodeObject(values, "Combine Texts",      Node_String_Merge,    "Combine multiple strings into one long string.").setTags(["join text", "concatenate text"]);
		addNodeObject(values, "Join Text Array",    Node_String_Join,     "Combine string array with an option to add extra string in-between.").setVersion(1120);
		addNodeObject(values, "Split Text",         Node_String_Split,    "Split string into arrays of substring based on delimiter.");
		addNodeObject(values, "Trim Text",          Node_String_Trim,     "Remove first and last n character(s) from a string.").setVersion(1080);
			ds_list_add(values, "/RegEx");
		addNodeObject(values, "RegEx Match",        Node_String_Regex_Match,   "Check whether regular expression pattern exist in a string.").setVersion(1140);
		addNodeObject(values, "RegEx Search",       Node_String_Regex_Search,  "Search for instances in a string using regular expression.").setVersion(1140);
		addNodeObject(values, "RegEx Replace",      Node_String_Regex_Replace, "Replace instances of a string with another using regular expression.").setVersion(1140);
			ds_list_add(values, "/Filename");
		addNodeObject(values, "Separate File Path", Node_Path_Separate_Folder, "Separate path string into a pair of directory and filename.").setVersion(1145);
		
		ds_list_add(values, "Arrays");
			ds_list_add(values, "/Creators");
		addNodeObject(values, "Array",             Node_Array,           "Create an array.");
		addNodeObject(values, "Array Range",       Node_Array_Range,     "Create array of numbers by setting start, end and step length.");
		addNodeObject(values, "Parse CSV",         Node_Array_CSV_Parse, "Parse CSV string into array.").setVersion(1145);
			ds_list_add(values, "/Info");
		addNodeObject(values, "Array Length",      Node_Array_Length,    "Returns number of members in an array.");
		addNodeObject(values, "Array Get",         Node_Array_Get,       "Returns nth member in an array.");
		addNodeObject(values, "Array Sample",      Node_Array_Sample,    "Sample member from an array to create smaller one.").setVersion(11540);
		addNodeObject(values, "Array Find",        Node_Array_Find,      "Returns index of an array member that match a condition.").setVersion(1120);
			ds_list_add(values, "/Operators");
		addNodeObject(values, "Array Set",         Node_Array_Set,       "Set array member based on index.").setVersion(1120);
		addNodeObject(values, "Array Add",         Node_Array_Add,       "Add elements into an array.");
		addNodeObject(values, "Array Split",       Node_Array_Split,     "Split array members into individual outputs.");
		addNodeObject(values, "Array Insert",      Node_Array_Insert,    "Insert member into an array at any position.").setVersion(1120);
		addNodeObject(values, "Array Remove",      Node_Array_Remove,    "Remove member in an array.").setTags(["delete array"]).setVersion(1120);
		addNodeObject(values, "Array Reverse",     Node_Array_Reverse,   "Reverse array order").setVersion(1120);
		addNodeObject(values, "Array Shift",       Node_Array_Shift,     "Shift all member in an array.").setVersion(1137);
		addNodeObject(values, "Array Rearrange",   Node_Array_Rearrange, "Rearrange array member manually.").setVersion(11640);
		addNodeObject(values, "Array Zip",         Node_Array_Zip,       "Combine multiple arrays into higher dimension array by grouping member of the same indicies.").setVersion(1138);
		addNodeObject(values, "Array Copy",        Node_Array_Copy,      "Copy array or subarray.").setVersion(1144);
		addNodeObject(values, "Array Convolute",   Node_Array_Convolute, "Apply convolution between 2 number arrays.").setVersion(11540);
		addNodeObject(values, "Array Composite",   Node_Array_Composite, "Create 2D array by multiplying each member in the first 1D array with the second 1D array.").setVersion(11540);
		addNodeObject(values, "Shuffle Array",     Node_Array_Shuffle,   "Randomly rearrange the array members.").setVersion(1120);
			ds_list_add(values, "/Group Operators");
		addNodeObject(values, "Sort Array",        Node_Array_Sort,            "Sort array using default comparison.").setVersion(1120);
		addNodeObject(values, "Loop Array",        Node_Iterate_Each_Inline,   "Create group that iterate to each member in an array.").setSpr(s_node_loop_array).setTags(["iterate each", "for each"]);
		addNodeObject(values, "Filter Array",	   Node_Iterate_Filter_Inline, "Filter array using condition.").setSpr(s_node_filter_array).setVersion(1140);
		addNodeObject(values, "Sort Array Inline", Node_Iterate_Sort_Inline,   "Sort array using node graph.").setSpr(s_node_sort_array).setVersion(1143);
		
		ds_list_add(values, "Paths");
			ds_list_add(values, "/Creators");
		addNodeObject(values, "Path",            Node_Path,           "Create path using bezier curve.");
		addNodeObject(values, "Smooth Path",     Node_Path_Smooth,    "Create path with automatic smoothness.").setVersion(11640);
		addNodeObject(values, "Shape Path",      Node_Path_Shape,     "Create path with predefined shape.").setVersion(1_18_05_6);
		addNodeObject(values, "Path Builder",    Node_Path_Builder,   "Create path from array of vec2 points.").setVersion(1137);
		addNodeObject(values, "L system",        Node_Path_L_System,  "Generate path using Lindenmayer system.").setVersion(1137);
		addNodeObject(values, "Path from Mask",  Node_Path_From_Mask, "Create path that wrap around a mask.").setVersion(11640);
		addNodeObject(values, "Plot Path",       Node_Path_Plot,      "Create path from parametric equations.").setVersion(1138);
		addNodeObject(values, "3D Path",         Node_Path_3D,        "Create path in 3D space.").setVersion(11750);
		addNodeObject(values, "Path Anchor",     Node_Path_Anchor,    "Create path anchor data.").setVersion(1140);
			ds_list_add(values, "/Modifiers");
		addNodeObject(values, "Transform Path",  Node_Path_Transform, "Move rotate and scale a path.").setVersion(1130);
		addNodeObject(values, "Remap Path",      Node_Path_Map_Area,  "Scale path to fit a given area.").setVersion(1130);
		addNodeObject(values, "Shift Path",      Node_Path_Shift,     "Move path along its normal.").setVersion(1130);
		addNodeObject(values, "Trim Path",       Node_Path_Trim,      "Trim path.").setVersion(1130);
		addNodeObject(values, "Wave Path",       Node_Path_Wave,      "Apply wave effect along the path.").setTags(["zigzag path"]).setVersion(1130);
		addNodeObject(values, "Path Combine",    Node_Path_Array,     "Combine multiple path into one.").setTags(["array path"]).setVersion(1137);
		addNodeObject(values, "Reverse Path",    Node_Path_Reverse,   "Reverse path direction.").setVersion(1130);
			ds_list_add(values, "/Combine");
		addNodeObject(values, "Repeat Path",     Node_Path_Repeat,    "Repeat paths.").setVersion(1_18_05_6);
		addNodeObject(values, "Scatter Path",    Node_Path_Scatter,   "Scatter paths along another path.").setVersion(11740);
		addNodeObject(values, "Bridge Path",     Node_Path_Bridge,    "Create new paths that connect multiple paths at the same sample positions.").setVersion(11640);
		addNodeObject(values, "Blend Path",      Node_Path_Blend,     "Blend between 2 paths.");
			ds_list_add(values, "/To Number");
		addNodeObject(values, "Sample Path",     Node_Path_Sample,    "Sample a 2D position from a path");
		addNodeObject(values, "Bake Path",       Node_Path_Bake,      "Bake path data into array of vec2 points.").setVersion(11640);
			ds_list_add(values, "/To Surface");
		addNodeObject(values, "Fill Path",       Node_Path_Fill,      "Fill area inside path.").setVersion(1_18_06_2);
		addNodeObject(values, "Map Path",        Node_Path_Map,       "Map a texture between multiple paths.").setVersion(11640);
		addNodeObject(values, "Morph Path",      Node_Path_Morph).setVersion(1_18_06_2);
			ds_list_add(values, "/Segments");
		addNodeObject(values, "Filter Segments", Node_Segment_Filter, "Filter segment (vec2 array) based on a conditions.").setVersion(11780);
		
		ds_list_add(values, "Boolean");
		addNodeObject(values, "Boolean",         Node_Boolean);
		addNodeObject(values, "Compare",         Node_Compare,        "Compare 2 numbers.").setBuild(Node_create_Compare).setTags(global.node_compare_keys);
		addNodeObject(values, "Logic Opr",       Node_Logic,          "Apply logic operation (and, or, not, etc.) to boolean(s).").setBuild(Node_create_Logic).setTags(global.node_logic_keys);
			
		ds_list_add(values, "Trigger");
		addNodeObject(values, "Trigger",         Node_Trigger,        "Create trigger value.").setVersion(1140);
		addNodeObject(values, "Boolean Trigger", Node_Trigger_Bool,   "Create trigger based on boolean condition.").setVersion(1140);
			
		ds_list_add(values, "Struct");
		addNodeObject(values, "Struct",          Node_Struct,            "Create key-value pair struct.");
		addNodeObject(values, "Struct Get",      Node_Struct_Get,        "Get value from struct and key.");
		addNodeObject(values, "Struct Set",      Node_Struct_Set,        "Modify struct");
		addNodeObject(values, "Parse JSON",      Node_Struct_JSON_Parse, "Parse json string into struct/array.").setVersion(1145);
			
		ds_list_add(values, "Mesh");
		addNodeObject(values, "Path to Mesh",    Node_Mesh_Create_Path,  "Create mesh from path.").setVersion(1140);
		addNodeObject(values, "Mesh Transform",  Node_Mesh_Transform,    "Transform (move, rotate, scale) mesh.").setVersion(1140);
			
		ds_list_add(values, "Atlas");
		addNodeObject(values, "Draw Atlas",      Node_Atlas_Draw,        "Render image atlas to a surface.").setVersion(1141);
		addNodeObject(values, "Atlas Get",       Node_Atlas_Get,         "Extract atlas data.").setVersion(1141);
		addNodeObject(values, "Atlas Set",       Node_Atlas_Set,         "Modify atlas data.").setVersion(1141);
		addNodeObject(values, "Atlas to Struct", Node_Atlas_Struct,      "Convert atlas into generic struct.").setVersion(11710);
			
		ds_list_add(values, "Surface");
		//addNodeObject(values, "Dynamic Surface",   Node_dynaSurf).setVersion(11520);
		addNodeObject(values, "IsoSurf",             Node_IsoSurf,             "Create a dynamic surface that changes its texture based on rotation.").setVersion(11520);
		addNodeObject(values, "Surface from Buffer", Node_Surface_From_Buffer, "Create surface from a valid buffer.").setTags(["buffer to surface"]).setVersion(1146);
			
		ds_list_add(values, "Buffer");
		addNodeObject(values, "Buffer from Surface", Node_Surface_To_Buffer, "Create buffer from a surface.").setTags(["surface to buffer"]).setVersion(1146);
	#endregion
	
	#region color
	var color = ds_list_create(); 
	addNodeCatagory("Color", color);
		ds_list_add(color, "Colors");
			ds_list_add(color, "/Creators");
		addNodeObject(color, "Color",           Node_Color,        "Create color value.").setSpr(s_node_color_out);
		addNodeObject(color, "RGB Color",       Node_Color_RGB,    "Create (rgb) color from value in RGB color space.").setSpr(s_node_color_from_rgb);
		addNodeObject(color, "HSV Color",       Node_Color_HSV,    "Create (rgb) color from value in HSV color space.").setSpr(s_node_color_from_hsv);
		addNodeObject(color, "OKLCH Color",     Node_Color_OKLCH,  "Create (rgb) color from value in OKLCH color space.").setSpr(s_node_color_from_oklch).setTags(["oklab"]);
			ds_list_add(color, "/Data");
		addNodeObject(color, "Color Data",      Node_Color_Data,  "Get data (rgb, hsv, brightness) from color.").setTags(["red", "green", "blue", "alpha", "brightness", "luminance"]);
			ds_list_add(color, "/Operators");
		addNodeObject(color, "Mix Color",       Node_Color_Mix,   "Combine two colors.").setVersion(1140);
			ds_list_add(color, "/Surfaces");
		addNodeObject(color, "Sampler",         Node_Sampler,     "Sample color from an image.");
		addNodeObject(color, "Find pixel",      Node_Find_Pixel,  "Get the position of the first pixel with a given color.").setVersion(1130);
			
		ds_list_add(color, "Palettes");
		addNodeObject(color, "Palette",         Node_Palette,         "Create palette value. Note that palette is simple an array of colors.");
		addNodeObject(color, "Sort Palette",    Node_Palette_Sort,    "Sort palette with specified order.").setVersion(1130);
		addNodeObject(color, "Shrink Palette",  Node_Palette_Shrink,  "Reduce palette size by collapsing similiar colors.").setVersion(1_18_03_0);
		addNodeObject(color, "Palette Extract", Node_Palette_Extract, "Extract palette from an image.").setVersion(1100);
		addNodeObject(color, "Palette Replace", Node_Palette_Replace, "Replace colors in a palette with new one.").setVersion(1120);
			
		ds_list_add(color, "Gradient");
		addNodeObject(color, "Gradient",            Node_Gradient_Out,           "Create gradient object");
		addNodeObject(color, "Palette to Gradient", Node_Gradient_Palette,       "Create gradient from palette.").setVersion(1135);
		addNodeObject(color, "Gradient Shift",      Node_Gradient_Shift,         "Move gradients keys.");
		addNodeObject(color, "Gradient Replace",    Node_Gradient_Replace_Color, "Replace color inside a gradient.").setVersion(1135);
		addNodeObject(color, "Gradient Data",       Node_Gradient_Extract,       "Get palatte and array of key positions from gradient.").setVersion(1135);
		addNodeObject(color, "Sample Gradient",     Node_Gradient_Sample,        "Sample gradient into palette.").setVersion(1_18_04_1);
	#endregion
	
	#region animation
	var animation = ds_list_create(); 
	addNodeCatagory("Animation", animation);
		ds_list_add(animation, "Animations");
		addNodeObject(animation, "Frame Index",     Node_Counter,    "Output current frame as frame index, or animation progress (0 - 1).").setTags(["current frame", "counter"]);
		addNodeObject(animation, "Rate Remap",      Node_Rate_Remap, "Remap animation to a new framerate.").setVersion(1147);
		addNodeObject(animation, "Delay",           Node_Delay,      "Delay the animation by fix amount of frames.").setVersion(11640);
		addNodeObject(animation, "Stagger",         Node_Stagger,    "Delay the animation based on array index.").setVersion(11640);
		addNodeObject(animation, "Reverse",         Node_Revert,     "Cache the entire animation and replay backward.").setVersion(1_17_11_0);
		
		ds_list_add(animation, "Value");	
		addNodeObject(animation, "Evaluate Curve", Node_Anim_Curve,    "Evaluate value from an animation curve.");
		addNodeObject(animation, "WaveTable",      Node_Fn_WaveTable,  "Create value changing overtime in wave pattern.").setVersion(11720);
		addNodeObject(animation, "Wiggler",        Node_Wiggler,       "Create random value smoothly changing over time.");
		addNodeObject(animation, "Ease",           Node_Fn_Ease,       "Create easing function.").setVersion(11720);
		addNodeObject(animation, "Math",           Node_Fn_Math,       "Apply mathematic operation of wave value.").setVersion(11720);
		addNodeObject(animation, "SmoothStep",     Node_Fn_SmoothStep, "Apply smoothstop function to a value.").setVersion(11720);
		
		ds_list_add(animation, "Audio");
			ds_list_add(animation, "/Files");
		addNodeObject(animation, "WAV File In",    Node_WAV_File_Read,  "Load wav audio file.").setBuild(Node_create_WAV_File_Read).setVersion(1144);
		addNodeObject(animation, "WAV File Out",   Node_WAV_File_Write, "Save wav audio file.").setVersion(1145);
			ds_list_add(animation, "/Analyzers");
		addNodeObject(animation, "Audio Window",   Node_Audio_Window,   "Take a slice of an audio array based on the current frame.").setVersion(1144);
		addNodeObject(animation, "Audio Volume",   Node_Audio_Loudness, "Calculate volume of an audio bit array.").setVersion(11540);
		addNodeObject(animation, "FFT",            Node_FFT,            "Perform fourier transform on number array.").setTags(["frequency analysis"]).setVersion(1144);
			ds_list_add(animation, "/Renders");
		addNodeObject(animation, "Bar / Graph",    Node_Plot_Linear,    "Plot graph or bar chart from array of number.").setBuild(Node_create_Plot_Linear).setTags(global.node_plot_linear_keys).setVersion(1144);
	#endregion
	
	#region misc
	var node = ds_list_create(); 
	addNodeCatagory("Misc", node);
		ds_list_add(node, "Control");
		addNodeObject(node, "Condition",         Node_Condition,         "Output value based on conditions.");
		addNodeObject(node, "Switch",            Node_Switch,            "Output value based on index.").setVersion(1090);
		addNodeObject(node, "Animation Control", Node_Animation_Control, "Control animation state with triggers.").setVersion(1145);
		
		ds_list_add(node, "Groups");
		addNodeObject(node, "Group",       Node_Group);
		addNodeObject(node, "Feedback",    Node_Feedback, "Create a group that reuse output from last frame to the current one.").isDeprecated();
		addNodeObject(node, "Loop",        Node_Iterate,  "Create group that reuse output as input repeatedly in one frame.").isDeprecated();
		addNodeObject(node, "Loop Array",  Node_Iterate_Each_Inline,   "Create group that iterate to each member in an array.").setSpr(s_node_loop_array).setTags(["iterate each", "for each", "array loop"]);
		addNodeObject(node, "Filter Array",Node_Iterate_Filter_Inline, "Filter array using condition.").setSpr(s_node_filter_array).setVersion(1140);
		
		if(OS == os_windows) {
			ds_list_add(node, "Lua");
			addNodeObject(node, "Lua Global",  Node_Lua_Global,  "Execute lua script in global scope without returning any data.").setVersion(1090);
			addNodeObject(node, "Lua Surface", Node_Lua_Surface, "Execute lua script on a surface.").setVersion(1090);
			addNodeObject(node, "Lua Compute", Node_Lua_Compute, "Execute lua function and returns a data.").setVersion(1090);
		
			ds_list_add(node, "Shader");
			addNodeObject(node, "HLSL",        Node_HLSL, "Execute HLSL shader on a surface.").setVersion(11520);
		}
		
		ds_list_add(node, "Organize");
		addNodeObject(node, "Pin",             Node_Pin,           "Create a pin to organize your connection. Can be create by double clicking on a connection line.");
		addNodeObject(node, "Array Pin",       Node_Array_Pin,     "Create a pin that can receive multiple values and return an array.").setVersion(11770);
		addNodeObject(node, "Frame",           Node_Frame,         "Create frame surrounding nodes.");
		addNodeObject(node, "Tunnel In",       Node_Tunnel_In,     "Create tunnel for sending value based on key matching.");
		addNodeObject(node, "Tunnel Out",      Node_Tunnel_Out,    "Receive value from tunnel in of the same key.");
		addNodeObject(node, "Display Text",    Node_Display_Text,  "Display text on the graph.");
		addNodeObject(node, "Display Image",   Node_Display_Image, "Display image on the graph.").setBuild(Node_create_Display_Image).setSpr(s_node_image);
			
		ds_list_add(node, "Cache");
		addNodeObject(node, "Cache",           Node_Cache,       "Store current animation. Cache persisted between save.").setVersion(1134);
		addNodeObject(node, "Cache Array",     Node_Cache_Array, "Store current animation as array.  Cache persisted between save.").setVersion(1130);
		
		ds_list_add(node, "Debug");
		addNodeObject(node, "Print",           Node_Print, "Display text to notification.").setTags(["debug log"]).setVersion(1145);
		addNodeObject(node, "Widget Test",     Node_Widget_Test).setSpr(s_node_print);
		addNodeObject(node, "Graph Preview",   Node_Graph_Preview).setSpr(s_node_image);
		addNodeObject(node, "Slideshow",       Node_Slideshow).setSpr(s_node_image);
		//addNodeObject(node, "Module Test",	s_node_print,		Node_Module_Test);
		
		ds_list_add(node, "Project");
		addNodeObject(node, "Project Data",    Node_Project_Data).setVersion(11650);
		
		ds_list_add(node, "System");
		addNodeObject(node, "Argument",         Node_Argument).setVersion(11660);
		addNodeObject(node, "Terminal trigger", Node_Terminal_Trigger).setVersion(11660);
		addNodeObject(node, "Execute Shell",    Node_Shell, "Execute shell script.").setTags(["terminal", "execute", "run", "console"]).setVersion(11530);
		addNodeObject(node, "Monitor Capture",  Node_Monitor_Capture).notTest();
		addNodeObject(node, "GUI In",           Node_Application_In).setSpr(s_node_gui_in).notTest();
		addNodeObject(node, "GUI Out",          Node_Application_Out).setSpr(s_node_gui_out).notTest();
		addNodeObject(node, "Assert",           Node_Assert).setSpr(s_node_shell);
		// addNodeObject(node, "DLL",				s_node_gui_out,				Node_DLL).setVersion(11750);
	#endregion
	
	globalvar NODE_ACTION_LIST;
	NODE_ACTION_LIST = ds_list_create();
	addNodeCatagory("Action", NODE_ACTION_LIST);
		__initNodeActions();
	
	var customs = ds_list_create();
	addNodeCatagory("Custom", customs);
		__initNodeCustom(customs);
	
	if(IS_PATREON) addNodeCatagory("Extra", SUPPORTER_NODES);
	
	//var vct = ds_list_create();
	//addNodeCatagory("VCT", vct);
	//	addNodeObject(vct, "Biterator",		s_node_print,		Node_Biterator);
	
	//////////////////////////////////////////////////////////// PIXEL  BUILDER ////////////////////////////////////////////////////////////
	
	#region pb_group
	var pb_group = ds_list_create(); 
	addNodePBCatagory("Group", pb_group); //#PB Group
		ds_list_add(pb_group, "Groups");
		addNodeObject(pb_group, "Input",  Node_Group_Input).hideRecent();
		addNodeObject(pb_group, "Output", Node_Group_Output).hideRecent();
	#endregion
	
	#region pb_draw
	var pb_draw = ds_list_create(); 
	addNodePBCatagory("Draw", pb_draw); //#PB Draw
		ds_list_add(pb_draw, "Fill");
		addNodeObject(pb_draw, "Fill", Node_PB_Draw_Fill).hideRecent();
			
		ds_list_add(pb_draw, "Shape");
		addNodeObject(pb_draw, "Rectangle",       Node_PB_Draw_Rectangle).hideRecent();
		addNodeObject(pb_draw, "Round Rectangle", Node_PB_Draw_Round_Rectangle).hideRecent();
		addNodeObject(pb_draw, "Trapezoid",       Node_PB_Draw_Trapezoid).hideRecent();
		addNodeObject(pb_draw, "Diamond",         Node_PB_Draw_Diamond).hideRecent();
		addNodeObject(pb_draw, "Ellipse",         Node_PB_Draw_Ellipse).hideRecent();
		addNodeObject(pb_draw, "Semi-Ellipse",    Node_PB_Draw_Semi_Ellipse).hideRecent();
		addNodeObject(pb_draw, "Line",            Node_PB_Draw_Line).hideRecent();
		addNodeObject(pb_draw, "Angle",           Node_PB_Draw_Angle).hideRecent();
		addNodeObject(pb_draw, "Blob",            Node_PB_Draw_Blob).hideRecent();
	#endregion
	
	#region pb_box
	var pb_box = ds_list_create(); 
	addNodePBCatagory("Box", pb_box); //#PB Box
		ds_list_add(pb_box, "Layer");
		addNodeObject(pb_box, "Layer", Node_PB_Layer).hideRecent();
			
		ds_list_add(pb_box, "Box");
		addNodeObject(pb_box, "Transform",    Node_PB_Box_Transform).hideRecent();
		addNodeObject(pb_box, "Mirror",       Node_PB_Box_Mirror).hideRecent();
		addNodeObject(pb_box, "Inset",        Node_PB_Box_Inset).hideRecent();
		addNodeObject(pb_box, "Split",        Node_PB_Box_Split).hideRecent();
		addNodeObject(pb_box, "Divide",       Node_PB_Box_Divide).hideRecent();
		addNodeObject(pb_box, "Divide Grid",  Node_PB_Box_Divide_Grid).hideRecent();
		addNodeObject(pb_box, "Contract",     Node_PB_Box_Contract).hideRecent();
	#endregion
	
	#region pb_fx
	var pb_fx = ds_list_create(); 
	addNodePBCatagory("Effects", pb_fx); //#PB Effects
		ds_list_add(pb_fx, "Effect");
		addNodeObject(pb_fx, "Outline",       Node_PB_Fx_Outline).hideRecent();
		addNodeObject(pb_fx, "Stack",         Node_PB_Fx_Stack).hideRecent();
		addNodeObject(pb_fx, "Radial",        Node_PB_Fx_Radial).hideRecent();
			
		ds_list_add(pb_fx, "Lighting");
		addNodeObject(pb_fx, "Highlight",     Node_PB_Fx_Highlight).hideRecent();
		addNodeObject(pb_fx, "Shading",       Node_PB_Fx_Shading).hideRecent();
			
		ds_list_add(pb_fx, "Texture");
		addNodeObject(pb_fx, "Hashing",       Node_PB_Fx_Hash).hideRecent();
		addNodeObject(pb_fx, "Strip",         Node_PB_Fx_Strip).hideRecent();
		addNodeObject(pb_fx, "Brick",         Node_PB_Fx_Brick).hideRecent();
			
		ds_list_add(pb_fx, "Blend");
		addNodeObject(pb_fx, "Add",           Node_PB_Fx_Add).hideRecent();
		addNodeObject(pb_fx, "Subtract",      Node_PB_Fx_Subtract).hideRecent();
		addNodeObject(pb_fx, "Intersect",     Node_PB_Fx_Intersect).hideRecent();
	#endregion
	
	#region pb_arr
	var pb_arr = ds_list_create(); 
	addNodePBCatagory("Array", pb_arr); //#PB Array 
		addNodeObject(pb_arr, "Array",        Node_Array).hideRecent();
		addNodeObject(pb_arr, "Array Get",    Node_Array_Get).setTags(["get array"]).hideRecent();
		addNodeObject(pb_arr, "Array Set",    Node_Array_Set).setTags(["set array"]).hideRecent().setVersion(1120);
		addNodeObject(pb_arr, "Array Insert", Node_Array_Insert).setTags(["insert array"]).hideRecent().setVersion(1120);
		addNodeObject(pb_arr, "Array Remove", Node_Array_Remove).setTags(["remove array", "delete array", "array delete"]).hideRecent().setVersion(1120);
	#endregion
	
	/////////////////////////////////////////////////////////////// PCX NODE ///////////////////////////////////////////////////////////////
	
	#region pcx_var
	var pcx_var = ds_list_create(); 
	addNodePCXCatagory("Variable", pcx_var);
		addNodeObject(pcx_var, "Variable",      Node_PCX_var).setSpr(s_node_array).hideRecent();
		addNodeObject(pcx_var, "Fn Variable",   Node_PCX_fn_var).setSpr(s_node_array).hideRecent();
	#endregion
	
	#region pcx_fn
	var pcx_fn = ds_list_create(); 
	addNodePCXCatagory("Functions", pcx_fn);
		addNodeObject(pcx_fn, "Equation",       Node_PCX_Equation).setSpr(s_node_array).hideRecent();
			
		ds_list_add(pcx_fn, "Numbers");
		addNodeObject(pcx_fn, "Math",           Node_PCX_fn_Math).setSpr(s_node_array).hideRecent();
		addNodeObject(pcx_fn, "Random",         Node_PCX_fn_Random).setSpr(s_node_array).hideRecent();
			
		ds_list_add(pcx_fn, "Surface");
		addNodeObject(pcx_fn, "Surface Width",  Node_PCX_fn_Surface_Width).setSpr(s_node_array).hideRecent();
		addNodeObject(pcx_fn, "Surface Height", Node_PCX_fn_Surface_Height).setSpr(s_node_array).hideRecent();
			
		ds_list_add(pcx_fn, "Array");
		addNodeObject(pcx_fn, "Array Get",      Node_PCX_Array_Get).setSpr(s_node_array).hideRecent();
		addNodeObject(pcx_fn, "Array Set",      Node_PCX_Array_Set).setSpr(s_node_array).hideRecent();
	#endregion
	
	#region pcx_flow
	var pcx_flow = ds_list_create(); 
	addNodePCXCatagory("Flow Control", pcx_flow);
		addNodeObject(pcx_flow, "Condition",    Node_PCX_Condition).setSpr(s_node_array).hideRecent();
	#endregion
	
	//////////////////////////////////////////////////////////////// HIDDEN ////////////////////////////////////////////////////////////////
	
	#region hid
	var hid = ds_list_create(); 
	addNodeCatagory("Hidden", hid, ["Hidden"]);
		addNodeObject(hid, "Input",            Node_Iterator_Each_Input).setSpr(s_node_loop_input).hideRecent();
		addNodeObject(hid, "Output",           Node_Iterator_Each_Output).setSpr(s_node_loop_output).hideRecent();
		addNodeObject(hid, "Input",            Node_Iterator_Filter_Input).setSpr(s_node_loop_input).hideRecent();
		addNodeObject(hid, "Output",           Node_Iterator_Filter_Output).setSpr(s_node_loop_output).hideRecent();
		addNodeObject(hid, "Grid Noise",       Node_Grid_Noise).hideRecent();
		addNodeObject(hid, "Triangular Noise", Node_Noise_Tri).setSpr(s_node_grid_tri_noise).hideRecent().setVersion(1090);
		addNodeObject(hid, "Hexagonal Noise",  Node_Noise_Hex).setSpr(s_node_grid_hex_noise).hideRecent().setVersion(1090);
		addNodeObject(hid, "Sort Input",       Node_Iterator_Sort_Input).setSpr(s_node_grid_hex_noise).hideRecent();
		addNodeObject(hid, "Sort Output",      Node_Iterator_Sort_Output).setSpr(s_node_grid_hex_noise).hideRecent();
		addNodeObject(hid, "Onion Skin",       Node_Onion_Skin).setSpr(s_node_cache).setVersion(1147).hideRecent();
		addNodeObject(hid, "RigidSim",         Node_Rigid_Group,  "Create group for rigidbody simulation.").setSpr(s_node_rigid).setVersion(1110).hideRecent();
		addNodeObject(hid, "SmokeSim",         Node_Smoke_Group,  "Create group for fluid simulation.").setSpr(s_node_smoke_group).setVersion(1120).hideRecent();
		addNodeObject(hid, "StrandSim",        Node_Strand_Group, "Create group for hair simulation.").setSpr(s_node_strand).setVersion(1140).hideRecent();
		addNodeObject(hid, "Feedback",         Node_Feedback_Inline).setSpr(s_node_feedback).hideRecent();
		addNodeObject(hid, "Loop",             Node_Iterate_Inline).setSpr(s_node_iterate).hideRecent();
		addNodeObject(hid, "VFX",              Node_VFX_Group).setSpr(s_node_vfx).hideRecent();
		
		addNodeObject(hid, "Loop Array",       Node_Iterate_Each).setSpr(s_node_loop_array).hideRecent();
		addNodeObject(hid, "Loop Input",       Node_Iterator_Each_Inline_Input).setSpr(s_node_loop_array).hideRecent();
		addNodeObject(hid, "Loop Output",      Node_Iterator_Each_Inline_Output).setSpr(s_node_loop_array).hideRecent();
		addNodeObject(hid, "Filter Array",     Node_Iterate_Filter, "Filter array using condition.").setSpr(s_node_filter_array).hideRecent();
		addNodeObject(hid, "Filter Input",     Node_Iterator_Filter_Inline_Input).setSpr(s_node_filter_array).hideRecent();
		addNodeObject(hid, "Filter Output",    Node_Iterator_Filter_Inline_Output).setSpr(s_node_filter_array).hideRecent();
		addNodeObject(hid, "Sort Array",       Node_Iterate_Sort, "Sort array using node graph.").setSpr(s_node_sort_array).hideRecent();
		addNodeObject(hid, "Sort Input",       Node_Iterator_Sort_Inline_Input).setSpr(s_node_sort_array).hideRecent();
		addNodeObject(hid, "Sort Output",      Node_Iterator_Sort_Inline_Output).setSpr(s_node_sort_array).hideRecent();
		
		ds_list_add(hid, "DynaSurf");
		addNodeObject(hid, "Input",            Node_DynaSurf_In).setSpr(s_node_pixel_builder).hideRecent();
		addNodeObject(hid, "Output",           Node_DynaSurf_Out).setSpr(s_node_pixel_builder).hideRecent();
		addNodeObject(hid, "getWidth",         Node_DynaSurf_Out_Width).setSpr(s_node_pixel_builder).hideRecent();
		addNodeObject(hid, "getHeight",        Node_DynaSurf_Out_Height).setSpr(s_node_pixel_builder).hideRecent();
	#endregion
	
}
