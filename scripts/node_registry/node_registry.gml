function NodeObject(_name, _spr, _node, _create, tags = []) constructor { #region
	name = _name;
	spr  = _spr;
	node = _node;
	createNode = _create;
	self.tags  = tags;
	
	tooltip    	= "";
	tooltip_spr = noone;
	deprecated  = false;
	
	show_in_recent = true;
	show_in_global = true;
	
	is_patreon_extra = false;
	
	var pth = DIRECTORY + "Nodes/tooltip/" + node + ".png";
	if(file_exists_empty(pth))
		tooltip_spr = sprite_add(pth, 0, false, false, 0, 0);
	new_node = false;
	
	if(struct_has(global.NODE_GUIDE, node)) { #region
		var _n = global.NODE_GUIDEarn[$ node];
		name   = _n.name;
		if(_n.tooltip != "")
			tooltip = _n.tooltip;
	} #endregion
	
	static setVersion = function(version) { #region
		INLINE 
		new_node = version >= LATEST_VERSION;
		
		if(new_node) {
			if(global.__currPage != global.__currNewPage) {
				ds_list_add(NEW_NODES, global.__currPage);
				global.__currNewPage = global.__currPage;
			}
			
			ds_list_add(NEW_NODES, self);
		}
		return self;
	} #endregion
	
	static isDeprecated = function() { #region
		INLINE 
		deprecated = true;
		return self;
	} #endregion
	
	static hideRecent = function() { #region
		INLINE 
		show_in_recent = false;
		return self;
	} #endregion
	
	static hideGlobal = function() { #region
		INLINE 
		show_in_global = false;
		return self;
	} #endregion
	
	static patreonExtra = function() { #region
		INLINE 
		is_patreon_extra = true;
		
		ds_list_add(SUPPORTER_NODES, self);
		return self;
	} #endregion
	
	static getName    = function() { return __txt_node_name(node, name);	   }
	static getTooltip = function() { return __txt_node_tooltip(node, tooltip); }
	
	static build = function(_x = 0, _y = 0, _group = PANEL_GRAPH.getCurrentContext(), _param = {}) { #region
		var _node;
		var _buildCon = createNode[0];
		if(array_length(createNode) > 2)
			_param = struct_append(_param, createNode[2]);
		
		if(_buildCon)	_node = new createNode[1](_x, _y, _group, _param);
		else			_node = createNode[1](_x, _y, _group, _param);
			
		if(!_node) return noone;
		
		//if(!LOADING && !APPENDING) _node.doUpdate();
		return _node;
	} #endregion
	
	static drawGrid = function(_x, _y, _mx, _my, grid_size) { #region
		var spr_x = _x + grid_size / 2;
		var spr_y = _y + grid_size / 2;
		
		gpu_set_tex_filter(true);
		draw_sprite_ui_uniform(spr, 0, spr_x, spr_y, 0.5);
		gpu_set_tex_filter(false);
				
		if(new_node) {
			draw_sprite_ui_uniform(THEME.node_new_badge, 0, _x + grid_size - ui(12), _y + ui(6),, COLORS._main_accent);
			draw_sprite_ui_uniform(THEME.node_new_badge, 1, _x + grid_size - ui(12), _y + ui(6));
		}
				
		if(deprecated) {
			draw_sprite_ui_uniform(THEME.node_deprecated_badge, 0, _x + grid_size - ui(12), _y + ui(6),, COLORS._main_value_negative);
			draw_sprite_ui_uniform(THEME.node_deprecated_badge, 1, _x + grid_size - ui(12), _y + ui(6));
		}
		
		var fav = array_exists(global.FAV_NODES, node);
		if(fav) draw_sprite_ui_uniform(THEME.star, 0, _x + grid_size - ui(10), _y + grid_size - ui(10), 0.7, COLORS._main_accent, 1.);
					
		if(IS_PATREON && is_patreon_extra) {
			var spr_x = _x + grid_size - 4;
			var spr_y = _y + 4;
						
			BLEND_SUBTRACT
			gpu_set_colorwriteenable(0, 0, 0, 1);
			draw_sprite_ext(s_patreon_supporter, 0, spr_x, spr_y, 1, 1, 0, c_white, 1);
			gpu_set_colorwriteenable(1, 1, 1, 1);
			BLEND_NORMAL
			
			draw_sprite_ext(s_patreon_supporter, 1, spr_x, spr_y, 1, 1, 0, COLORS._main_accent, 1);
			
			if(point_in_circle(_mx, _my, spr_x, spr_y, 10)) TOOLTIP = __txt("Supporter exclusive");
		}
	} #endregion
	
	static drawList = function(_x, _y, _mx, _my, list_height) { #region
		var fav = array_exists(global.FAV_NODES, node);
		if(fav) draw_sprite_ui_uniform(THEME.star, 0, ui(32), yy + list_height / 2, 0.7, COLORS._main_accent, 1.);
				
		var spr_x = list_height / 2 + ui(44);
		var spr_y = _y + list_height / 2;
				
		var ss = (list_height - ui(8)) / max(sprite_get_width(spr), sprite_get_height(spr));
		gpu_set_tex_filter(true);
		draw_sprite_ext(spr, 0, spr_x, spr_y, ss, ss, 0, c_white, 1);
		gpu_set_tex_filter(false);
		
		var tx = list_height + ui(52);
				
		if(new_node) {
			draw_sprite_ui_uniform(THEME.node_new_badge, 0, tx + ui(16), _y + list_height / 2 + ui(1),, COLORS._main_accent);
			draw_sprite_ui_uniform(THEME.node_new_badge, 1, tx + ui(16), _y + list_height / 2 + ui(1));
			tx += ui(40);
		}
				
		if(deprecated) {
			draw_sprite_ui_uniform(THEME.node_deprecated_badge, 0, tx + ui(16), _y + list_height / 2 + ui(1),, COLORS._main_value_negative);
			draw_sprite_ui_uniform(THEME.node_deprecated_badge, 1, tx + ui(16), _y + list_height / 2 + ui(1));
			tx += ui(40);
		}	
		
		var _txt = getName();
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
		draw_text_add(tx, _y + list_height / 2, _txt);
		
		tx += string_width(_txt);
		
		if(IS_PATREON && is_patreon_extra) {
			var spr_x = tx + 8;
			var spr_y = _y + list_height / 2 - 4;
						
			BLEND_SUBTRACT
			gpu_set_colorwriteenable(0, 0, 0, 1);
			draw_sprite_ext(s_patreon_supporter, 0, spr_x, spr_y, 1, 1, 0, c_white, 1);
			gpu_set_colorwriteenable(1, 1, 1, 1);
			BLEND_NORMAL
			
			draw_sprite_ext(s_patreon_supporter, 1, spr_x, spr_y, 1, 1, 0, COLORS._main_accent, 1);
			
			if(point_in_circle(_mx, _my, spr_x, spr_y, 10)) TOOLTIP = __txt("Supporter exclusive");
		}
		
		return tx;
	} #endregion
} #endregion

#region globalvar
	globalvar ALL_NODES, ALL_NODE_LIST, NODE_CATEGORY, NODE_PB_CATEGORY, NODE_PCX_CATEGORY;
	globalvar SUPPORTER_NODES, NEW_NODES;
	
	globalvar NODE_PAGE_DEFAULT;
	
	ALL_NODES		  = ds_map_create();
	ALL_NODE_LIST	  = ds_list_create();
	NODE_CATEGORY	  = ds_list_create();
	NODE_PB_CATEGORY  = ds_list_create();
	NODE_PCX_CATEGORY = ds_list_create();
	SUPPORTER_NODES   = ds_list_create();
	NEW_NODES		  = ds_list_create();
	
	global.__currPage    = "";
	global.__currNewPage = "";
#endregion
	
function nodeBuild(_name, _x, _y, _group = PANEL_GRAPH.getCurrentContext()) { #region
	if(!ds_map_exists(ALL_NODES, _name)) {
		log_warning("LOAD", $"Node type {_name} not found");
		return noone;
	}
		
	var _node = ALL_NODES[? _name];
	return _node.build(_x, _y, _group);
} #endregion
	
function addNodeObject(_list, _name, _spr, _node, _fun, _tag = [], tooltip = "") { #region
	var _n;
		
	if(ds_map_exists(ALL_NODES, _node))
		_n = ALL_NODES[? _node];
	else { 
		_n = new NodeObject(_name, _spr, _node, _fun, _tag);
		if(!ds_map_exists(ALL_NODES, _node))
			ds_list_add(ALL_NODE_LIST, _n);
		ALL_NODES[? _node] = _n;
	}
		
	if(tooltip != "") _n.tooltip = tooltip;
	ds_list_add(_list, _n);
	return _n;
} #endregion
	
function addNodeCatagory(name, list, filter = []) { #region
	global.__currPage = name;
	ds_list_add(NODE_CATEGORY, { name: name, list: list, filter: filter });
} #endregion
	
function addNodePBCatagory(name, list, filter = []) { #region
	ds_list_add(NODE_PB_CATEGORY, { name: name, list: list, filter: filter });
} #endregion
	
function addNodePCXCatagory(name, list, filter = []) { #region
	ds_list_add(NODE_PCX_CATEGORY, { name: name, list: list, filter: filter });
} #endregion

function __initNodes() {
	global.__currPage = "";
	
	var favPath = DIRECTORY + "Nodes/fav.json";
	global.FAV_NODES = file_exists_empty(favPath)? json_load_struct(favPath) : [];
	if(!is_array(global.FAV_NODES)) global.FAV_NODES = [];
	
	var recPath = DIRECTORY + "Nodes/recent.json";
	global.RECENT_NODES = file_exists_empty(recPath)? json_load_struct(recPath) : [];
	if(!is_array(global.RECENT_NODES)) global.RECENT_NODES = [];
	
	NODE_PAGE_DEFAULT = ds_list_size(NODE_CATEGORY);
	ADD_NODE_PAGE = NODE_PAGE_DEFAULT;
	
	var fav = ds_list_create();
	addNodeCatagory("Favourites", fav);
	
	var group = ds_list_create(); #region
	addNodeCatagory("Group", group, ["Node_Group"]); 
		ds_list_add(group, "Groups");
		addNodeObject(group, "Input",		s_node_group_input,		"Node_Group_Input",		[1, Node_Group_Input]).hideRecent();
		addNodeObject(group, "Output",		s_node_group_output,	"Node_Group_Output",	[1, Node_Group_Output]).hideRecent();
		addNodeObject(group, "Thumbnail",	s_node_group_thumbnail,	"Node_Group_Thumbnail",	[1, Node_Group_Thumbnail]).hideRecent();
	#endregion
	
	var iter = ds_list_create(); #region
	addNodeCatagory("Loop", iter, ["Node_Iterate"]);
		ds_list_add(iter, "Groups");
		addNodeObject(iter, "Loop Input",	s_node_loop_input,		"Node_Iterator_Input",	[1, Node_Iterator_Input]).hideRecent();
		addNodeObject(iter, "Loop Output",	s_node_loop_output,		"Node_Iterator_Output",	[1, Node_Iterator_Output]).hideRecent();
		addNodeObject(iter, "Input",		s_node_group_input,		"Node_Group_Input",		[1, Node_Group_Input]).hideRecent();
		addNodeObject(iter, "Output",		s_node_group_output,	"Node_Group_Output",	[1, Node_Group_Output]).hideRecent();
		addNodeObject(iter, "Thumbnail",	s_node_group_thumbnail,	"Node_Group_Thumbnail",	[1, Node_Group_Thumbnail]).hideRecent();
			
		ds_list_add(iter, "Loops");
		addNodeObject(iter, "Index",		s_node_iterator_index,	"Node_Iterator_Index",	[1, Node_Iterator_Index]).hideRecent();
		addNodeObject(iter, "Loop amount",	s_node_iterator_amount,	"Node_Iterator_Length",	[1, Node_Iterator_Length]).hideRecent();
	#endregion
	
	var iter_il = ds_list_create(); #region
	addNodeCatagory("Loop", iter_il, ["Node_Iterate_Inline"]);
		ds_list_add(iter_il, "Loops");
		addNodeObject(iter_il, "Index",			s_node_iterator_index,	"Node_Iterator_Index",	[1, Node_Iterator_Index]).hideRecent();
		addNodeObject(iter_il, "Loop amount",	s_node_iterator_amount,	"Node_Iterator_Length",	[1, Node_Iterator_Length]).hideRecent();
	#endregion
	
	var itere = ds_list_create(); #region
	addNodeCatagory("Loop", itere, ["Node_Iterate_Each"]);
		ds_list_add(itere, "Groups");
		addNodeObject(itere, "Input",		s_node_group_input,		"Node_Group_Input",		[1, Node_Group_Input]).hideRecent();
		addNodeObject(itere, "Output",		s_node_group_output,	"Node_Group_Output",	[1, Node_Group_Output]).hideRecent();
		addNodeObject(itere, "Thumbnail",	s_node_group_thumbnail,	"Node_Group_Thumbnail",	[1, Node_Group_Thumbnail]).hideRecent();
			
		ds_list_add(itere, "Loops");
		addNodeObject(itere, "Index",			s_node_iterator_index,	"Node_Iterator_Index",	[1, Node_Iterator_Index]).hideRecent();
		addNodeObject(itere, "Array Length",	s_node_iterator_length,	"Node_Iterator_Each_Length",	[1, Node_Iterator_Each_Length]).hideRecent();
	#endregion
	
	var itere_il = ds_list_create(); #region
	addNodeCatagory("Loop", itere_il, ["Node_Iterate_Each_Inline"]);
		ds_list_add(itere_il, "Loops");
		addNodeObject(itere_il, "Index",		s_node_iterator_index,	"Node_Iterator_Index",	[1, Node_Iterator_Index]).hideRecent();
		addNodeObject(itere_il, "Array Length",	s_node_iterator_length,	"Node_Iterator_Length",	[1, Node_Iterator_Length]).hideRecent();
	#endregion
	
	var filter = ds_list_create(); #region
	addNodeCatagory("Filter", filter, ["Node_Iterate_Filter"]);
		ds_list_add(filter, "Groups");
		addNodeObject(filter, "Input",		s_node_group_input,		"Node_Group_Input",		[1, Node_Group_Input]).hideRecent();
		addNodeObject(filter, "Output",		s_node_group_output,	"Node_Group_Output",	[1, Node_Group_Output]).hideRecent();
		addNodeObject(filter, "Thumbnail",	s_node_group_thumbnail,	"Node_Group_Thumbnail",	[1, Node_Group_Thumbnail]).hideRecent();
			
		ds_list_add(filter, "Loops");
		addNodeObject(filter, "Index",			s_node_iterator_index,	"Node_Iterator_Index",			[1, Node_Iterator_Index]).hideRecent();
		addNodeObject(filter, "Array Length",	s_node_iterator_length,	"Node_Iterator_Each_Length",	[1, Node_Iterator_Each_Length]).hideRecent();
	#endregion
	
	var filter_il = ds_list_create(); #region
	addNodeCatagory("Filter", filter_il, ["Node_Iterate_Filter_Inline"]);
		ds_list_add(filter_il, "Loops");
		addNodeObject(filter_il, "Index",			s_node_iterator_index,	"Node_Iterator_Index",	[1, Node_Iterator_Index]).hideRecent();
		addNodeObject(filter_il, "Array Length",	s_node_iterator_length,	"Node_Iterator_Length",	[1, Node_Iterator_Length]).hideRecent();
	#endregion
	
	var feed = ds_list_create(); #region
	addNodeCatagory("Feedback", feed, ["Node_Feedback"]);
		ds_list_add(feed, "Groups");
		addNodeObject(feed, "Input",		s_node_feedback_input,	"Node_Feedback_Input",	[1, Node_Feedback_Input]).hideRecent();
		addNodeObject(feed, "Output",		s_node_feedback_output,	"Node_Feedback_Output",	[1, Node_Feedback_Output]).hideRecent();
		addNodeObject(feed, "Thumbnail",	s_node_group_thumbnail,	"Node_Group_Thumbnail",	[1, Node_Group_Thumbnail]).hideRecent();
	#endregion
	
	var vfx = ds_list_create(); #region
	addNodeCatagory("VFX", vfx, ["Node_VFX_Group", "Node_VFX_Group_Inline"]);
		ds_list_add(vfx, "Groups");
		addNodeObject(vfx, "Input",			s_node_vfx_input,			"Node_Group_Input",			[1, Node_Group_Input]).hideRecent().hideGlobal();
		addNodeObject(vfx, "Output",		s_node_vfx_output,			"Node_Group_Output",		[1, Node_Group_Output]).hideRecent().hideGlobal();
		addNodeObject(vfx, "Renderer",		s_node_vfx_render_output,	"Node_VFX_Renderer_Output",	[1, Node_VFX_Renderer_Output]).hideRecent().hideGlobal();
			
		ds_list_add(vfx, "VFXs");
		addNodeObject(vfx, "Spawner",		s_node_vfx_spawn,	"Node_VFX_Spawner",		[1, Node_VFX_Spawner],, "Spawn new particles.").hideRecent();
		addNodeObject(vfx, "Renderer",		s_node_vfx_render,	"Node_VFX_Renderer",	[1, Node_VFX_Renderer],, "Render particle objects to surface.").hideRecent();
			
		ds_list_add(vfx, "Affectors");
		addNodeObject(vfx, "Accelerate",	s_node_vfx_accel,	"Node_VFX_Accelerate",	[1, Node_VFX_Accelerate],, "Change the speed of particle in range.").hideRecent();
		addNodeObject(vfx, "Destroy",		s_node_vfx_destroy,	"Node_VFX_Destroy",		[1, Node_VFX_Destroy],, "Destroy particle in range.").hideRecent();
		addNodeObject(vfx, "Attract",		s_node_vfx_attract,	"Node_VFX_Attract",		[1, Node_VFX_Attract],, "Attract particle in range to one point.").hideRecent();
		addNodeObject(vfx, "Wind",			s_node_vfx_wind,	"Node_VFX_Wind",		[1, Node_VFX_Wind],, "Move particle in range.").hideRecent();
		addNodeObject(vfx, "Vortex",		s_node_vfx_vortex,	"Node_VFX_Vortex",		[1, Node_VFX_Vortex],, "Rotate particle around a point.").hideRecent();
		addNodeObject(vfx, "Turbulence",	s_node_vfx_turb,	"Node_VFX_Turbulence",	[1, Node_VFX_Turbulence],, "Move particle in range randomly.").hideRecent();
		addNodeObject(vfx, "Repel",			s_node_vfx_repel,	"Node_VFX_Repel",		[1, Node_VFX_Repel],, "Move particle away from point.").hideRecent();
		addNodeObject(vfx, "Oscillate",		s_node_vfx_osc,		"Node_VFX_Oscillate",	[1, Node_VFX_Oscillate],, "Swing particle around its original trajectory.").hideRecent().setVersion(11560);
			
		ds_list_add(vfx, "Effects");
		addNodeObject(vfx, "VFX Trail",		s_node_vfx_trail,	"Node_VFX_Trail",		[1, Node_VFX_Trail],, "Generate path from particle movement.").hideRecent().setVersion(11560);
			
		ds_list_add(vfx, "Instance control");
		addNodeObject(vfx, "VFX Variable",	s_node_vfx_variable,	"Node_VFX_Variable",	[1, Node_VFX_Variable],, "Extract variable from particle objects.").hideRecent().setVersion(1120);
		addNodeObject(vfx, "VFX Override",	s_node_vfx_override,	"Node_VFX_Override",	[1, Node_VFX_Override],, "Replace particle variable with a new one.").hideRecent().setVersion(1120);
	#endregion
	
	var rigidSim = ds_list_create(); #region
	addNodeCatagory("RigidSim", rigidSim, ["Node_Rigid_Group", "Node_Rigid_Group_Inline"]);
		ds_list_add(rigidSim, "Group");
		addNodeObject(rigidSim, "Input",	s_node_group_input,				"Node_Group_Input",			[1, Node_Group_Input]).hideRecent().hideGlobal();
		addNodeObject(rigidSim, "Output",	s_node_group_output,			"Node_Group_Output",		[1, Node_Group_Output]).hideRecent().hideGlobal();
		addNodeObject(rigidSim, "Render",	s_node_rigidSim_render_output,	"Node_Rigid_Render_Output",	[1, Node_Rigid_Render_Output]).hideRecent().hideGlobal();
			
		ds_list_add(rigidSim, "RigidSim");
		addNodeObject(rigidSim, "Object",			s_node_rigidSim_object,				"Node_Rigid_Object",			[1, Node_Rigid_Object],, "Spawn a rigidbody object.").hideRecent().setVersion(1110);
		addNodeObject(rigidSim, "Object Spawner",	s_node_rigidSim_object_spawner,		"Node_Rigid_Object_Spawner",	[1, Node_Rigid_Object_Spawner],, "Spawn multiple rigidbody objects.").hideRecent().setVersion(1110);
		addNodeObject(rigidSim, "Render",			s_node_rigidSim_renderer,			"Node_Rigid_Render",			[1, Node_Rigid_Render],, "Render rigidbody object to surface.").hideRecent().setVersion(1110);
		addNodeObject(rigidSim, "Apply Force",		s_node_rigidSim_force,				"Node_Rigid_Force_Apply",		[1, Node_Rigid_Force_Apply],, "Apply force to objects.").hideRecent().setVersion(1110);
			
		ds_list_add(rigidSim, "Instance control");
		addNodeObject(rigidSim, "Activate Physics",		s_node_rigidSim_activate,	"Node_Rigid_Activate",		[1, Node_Rigid_Activate],, "Enable or disable rigidbody object.").hideRecent().setVersion(1110);
		addNodeObject(rigidSim, "Rigidbody Variable",	s_node_rigid_variable,		"Node_Rigid_Variable",		[1, Node_Rigid_Variable],, "Extract veriable from rigidbody object.").hideRecent().setVersion(1120);
		addNodeObject(rigidSim, "Rigidbody Override",	s_node_rigid_override,		"Node_Rigid_Override",		[1, Node_Rigid_Override],, "Replace rigidbody object variable with a new one.").hideRecent().setVersion(1120);
	#endregion
	
	var smokeSim = ds_list_create(); #region
	addNodeCatagory("SmokeSim", smokeSim, ["Node_Fluid_Group", "Node_Fluid_Group_Inline"]);
		ds_list_add(smokeSim, "Group");
		addNodeObject(smokeSim, "Input",			s_node_group_input,				"Node_Group_Input",			[1, Node_Group_Input]).hideRecent().hideGlobal();
		addNodeObject(smokeSim, "Output",			s_node_group_output,			"Node_Group_Output",		[1, Node_Group_Output]).hideRecent().hideGlobal();
		addNodeObject(smokeSim, "Render Domain",	s_node_smokeSim_render_output,	"Node_Fluid_Render_Output",	[1, Node_Fluid_Render_Output]).hideRecent().setVersion(11540).hideGlobal();
		
		ds_list_add(smokeSim, "Domain");
		addNodeObject(smokeSim, "Domain",			s_node_smokeSim_domain,			"Node_Fluid_Domain",		[1, Node_Fluid_Domain]).hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Update Domain",	s_node_smokeSim_update,			"Node_Fluid_Update",		[1, Node_Fluid_Update],, "Run smoke by one step.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Render Domain",	s_node_smokeSim_render,			"Node_Fluid_Render",		[1, Node_Fluid_Render],, "Render smoke to surface. This node also have update function build in.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Queue Domain",		s_node_smokeSim_domain_queue,	"Node_Fluid_Domain_Queue",	[1, Node_Fluid_Domain_Queue],, "Sync multiple domains to be render at the same time.").hideRecent().setVersion(1120);
			
		ds_list_add(smokeSim, "Smoke");
		addNodeObject(smokeSim, "Add Emitter",		s_node_smokeSim_emitter,		"Node_Fluid_Add",				[1, Node_Fluid_Add],, "Add smoke emitter.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Apply Velocity",	s_node_smokeSim_apply_velocity,	"Node_Fluid_Apply_Velocity",	[1, Node_Fluid_Apply_Velocity],, "Apply velocity to smoke.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Add Collider",		s_node_smokeSim_add_collider,	"Node_Fluid_Add_Collider",		[1, Node_Fluid_Add_Collider],, "Add solid object that smoke can collides to.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Vortex",			s_node_smokeSim_vortex,			"Node_Fluid_Vortex",			[1, Node_Fluid_Vortex],, "Apply rotational force around a point.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Repulse",			s_node_smokeSim_repulse,		"Node_Fluid_Repulse",			[1, Node_Fluid_Repulse],, "Spread smoke away from a point.").hideRecent().setVersion(1120);
		addNodeObject(smokeSim, "Turbulence",		s_node_smokeSim_turbulence,		"Node_Fluid_Turbulence",		[1, Node_Fluid_Turbulence],, "Apply random velocity map to the smoke.").hideRecent().setVersion(1120);
	#endregion
	
	var flipSim = ds_list_create(); #region
	addNodeCatagory("FLIP Fluid", flipSim, ["Node_FLIP_Group_Inline"]);
		ds_list_add(flipSim, "Domain");
		addNodeObject(flipSim, "Domain",			s_node_fluidSim_domain,			"Node_FLIP_Domain",		[1, Node_FLIP_Domain]).hideRecent().setVersion(11620);
		addNodeObject(flipSim, "Render",			s_node_fluidSim_render,			"Node_FLIP_Render",		[1, Node_FLIP_Render]).hideRecent().setVersion(11620);
		addNodeObject(flipSim, "Update",			s_node_fluidSim_update,			"Node_FLIP_Update",		[1, Node_FLIP_Update]).hideRecent().setVersion(11620);
		
		ds_list_add(flipSim, "Fluid");
		addNodeObject(flipSim, "Spawner",			s_node_fluidSim_add_fluid,			"Node_FLIP_Spawner",		[1, Node_FLIP_Spawner]).hideRecent().setVersion(11620);
		addNodeObject(flipSim, "Apply Velocity",	s_node_fluidSim_apply_velocity,		"Node_FLIP_Apply_Velocity",	[1, Node_FLIP_Apply_Velocity]).hideRecent().setVersion(11620);
		addNodeObject(flipSim, "Apply Force",		s_node_fluidSim_force,				"Node_FLIP_Apply_Force",	[1, Node_FLIP_Apply_Force]).hideRecent().setVersion(11620);
	#endregion
	
	var strandSim = ds_list_create(); #region
	addNodeCatagory("StrandSim", strandSim, ["Node_Strand_Group", "Node_Strand_Group_Inline"]);
		ds_list_add(strandSim, "Group");
		addNodeObject(strandSim, "Input",	s_node_group_input,		"Node_Group_Input",		[1, Node_Group_Input]).hideRecent().hideGlobal();
		addNodeObject(strandSim, "Output",	s_node_group_output,	"Node_Group_Output",	[1, Node_Group_Output]).hideRecent().hideGlobal();
			
		ds_list_add(strandSim, "System");
		addNodeObject(strandSim, "Strand Create",	s_node_strandSim_create,	"Node_Strand_Create",	[1, Node_Strand_Create],, "Create strands from point, path, or mesh.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Update",	s_node_strandSim_update,	"Node_Strand_Update",	[1, Node_Strand_Update],, "Update strands by one step.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Render",	s_node_strandSim_render,	"Node_Strand_Render",	[1, Node_Strand_Render],, "Render strands to surface as a single path.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Render Texture",	s_node_strandSim_render_texture,	"Node_Strand_Render_Texture",	[1, Node_Strand_Render_Texture],, "Render strands to surface as a textured path.").hideRecent().setVersion(1140);
			
		ds_list_add(strandSim, "Affectors");
		addNodeObject(strandSim, "Strand Gravity",		 s_node_strandSim_gravity,	"Node_Strand_Gravity",		 [1, Node_Strand_Gravity],, "Apply downward acceleration to strands.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Force Apply",	 s_node_strandSim_force,	"Node_Strand_Force_Apply",	 [1, Node_Strand_Force_Apply],, "Apply general force to strands.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Break",		 s_node_strandSim_break,	"Node_Strand_Break",		 [1, Node_Strand_Break],, "Detach strands from its origin.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Length Adjust", s_node_strandSim_length,	"Node_Strand_Length_Adjust", [1, Node_Strand_Length_Adjust],, "Adjust length of strands in area.").hideRecent().setVersion(1140);
		addNodeObject(strandSim, "Strand Collision",	 s_node_strandSim_collide,	"Node_Strand_Collision",	 [1, Node_Strand_Collision],, "Create solid object for strands to collides to.").hideRecent().setVersion(1140);
	#endregion
	
	//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
	
	var input = ds_list_create(); #region
	addNodeCatagory("IO", input);
		ds_list_add(input, "Images");
		addNodeObject(input, "Canvas",				s_node_canvas,			"Node_Canvas",					[1, Node_Canvas], ["draw"], "Draw on surface using brush, eraser, etc.");
		addNodeObject(input, "Active Canvas",		s_node_active_canvas,	"Node_Active_Canvas",			[1, Node_Active_Canvas], ["draw"], "Draw using parameterized brush.").setVersion(11570);
		addNodeObject(input, "Image",				s_node_image,			"Node_Image",					[0, Node_create_Image],, "Load a single image from your computer.");
		addNodeObject(input, "Image GIF",			s_node_image_gif,		"Node_Image_gif",				[0, Node_create_Image_gif],, "Load animated .gif from your computer.");
		addNodeObject(input, "Splice Spritesheet",	s_node_image_sheet,		"Node_Image_Sheet",				[1, Node_Image_Sheet],, "Cut up spritesheet into animation or image array.");
		addNodeObject(input, "Image Array",			s_node_image_sequence,	"Node_Image_Sequence",			[0, Node_create_Image_Sequence],, "Load multiple images from your computer as array.");
		addNodeObject(input, "Animation",			s_node_image_animation, "Node_Image_Animated",			[0, Node_create_Image_Animated],, "Load multiple images from your computer as animation.");
		addNodeObject(input, "Array to Anim",		s_node_image_sequence_to_anim, "Node_Sequence_Anim",	[1, Node_Sequence_Anim],, "Convert array of images into animation.");
		if(!DEMO) addNodeObject(input, "Export",	s_node_export,			"Node_Export",					[0, Node_create_Export],, "Export image, image array to file, image sequence, animation.");
		
		ds_list_add(input, "Files");
		addNodeObject(input, "Text File In",		s_node_text_file_read,	"Node_Text_File_Read",		[1, Node_Text_File_Read],  ["txt"], "Load .txt in as text.").setVersion(1080);
		addNodeObject(input, "Text File Out",		s_node_text_file_write,	"Node_Text_File_Write",		[1, Node_Text_File_Write], ["txt"], "Save text as a .txt file.").setVersion(1090);
		addNodeObject(input, "CSV File In",			s_node_csv_file_read,	"Node_CSV_File_Read",		[1, Node_CSV_File_Read],  ["comma separated value"], "Load .csv as text, number array.").setVersion(1090);
		addNodeObject(input, "CSV File Out",		s_node_csv_file_write,	"Node_CSV_File_Write",		[1, Node_CSV_File_Write], ["comma separated value"], "Save array as .csv file.").setVersion(1090);
		addNodeObject(input, "JSON File In",		s_node_json_file_read,	"Node_Json_File_Read",		[1, Node_Json_File_Read],,  "Load .json file using keys.").setVersion(1090);
		addNodeObject(input, "JSON File Out",		s_node_json_file_write,	"Node_Json_File_Write",		[1, Node_Json_File_Write],, "Save data to .json file.").setVersion(1090);
		addNodeObject(input, "ASE File In",			s_node_ase_file,		"Node_ASE_File_Read",		[0, Node_create_ASE_File_Read],, "Load Aseprite file with support for layers, tags.").setVersion(1100);
		addNodeObject(input, "ASE Layer",			s_node_ase_layer,		"Node_ASE_layer",			[1, Node_ASE_layer],, "Load Aseprite project file").setVersion(1100);
		addNodeObject(input, "WAV File In",			s_node_wav_file_read,	"Node_WAV_File_Read",		[0, Node_create_WAV_File_Read],, "Load wav audio file.").setVersion(1144);
		addNodeObject(input, "WAV File Out",		s_node_wav_file_write,	"Node_WAV_File_Write",		[1, Node_WAV_File_Write],, "Save wav audio file.").setVersion(1145);
			
		ds_list_add(input, "External");
		addNodeObject(input, "Websocket Receiver",	s_node_websocket_receive,	"Node_Websocket_Receiver",	[1, Node_Websocket_Receiver],, "Create websocket server to receive data from the network.").setVersion(1145);
		addNodeObject(input, "Websocket Sender",	s_node_websocket_send,		"Node_Websocket_Sender",	[1, Node_Websocket_Sender],, "Create websocket server to send data to the network.").setVersion(1145);
		addNodeObject(input, "Spout Sender",		s_node_spout,				"Node_Spout_Send",			[1, Node_Spout_Send],, "Send surface through Spout.").setVersion(11600);
		addNodeObject(input, "MIDI In",				s_node_midi,				"Node_MIDI_In",				[1, Node_MIDI_In],, "Receive MIDI message.").setVersion(11630);
	#endregion
	
	var transform = ds_list_create(); #region
	addNodeCatagory("Transform", transform);
		ds_list_add(transform, "Transformations");
		addNodeObject(transform, "Transform",		s_node_transform,		"Node_Transform",		[1, Node_Transform], ["move", "rotate", "scale"], "Move, rotate, and scale image.");
		addNodeObject(transform, "Scale",			s_node_scale,			"Node_Scale",			[1, Node_Scale], ["resize"], "Simple node for scaling image.");
		addNodeObject(transform, "Scale Algorithm",	s_node_scale_algo,		"Node_Scale_Algo",		[0, Node_create_Scale_Algo], ["scale2x", "scale3x"], "Scale image using scale2x, scale3x algorithm.");
		addNodeObject(transform, "Flip",			s_node_flip,			"Node_Flip",			[1, Node_Flip], ["mirror"], "Flip image horizontally or vertically.");
		addNodeObject(transform, "Offset",			s_node_offset,			"Node_Offset",			[1, Node_Offset],, "Shift image with tiling.");
		
		ds_list_add(transform, "Warps");
		addNodeObject(transform, "Crop",			s_node_crop,			"Node_Crop",			[1, Node_Crop],, "Crop out image to create smaller ones.");
		addNodeObject(transform, "Crop Content",	s_node_crop_content,	"Node_Crop_Content",	[1, Node_Crop_Content],, "Crop out empty pixel pixel from the image.");
		addNodeObject(transform, "Bend",			s_node_bend,			"Node_Bend",			[1, Node_Bend], ["wrap"]).setVersion(11650);
		addNodeObject(transform, "Warp",			s_node_warp,			"Node_Warp",			[1, Node_Warp], ["warp corner"], "Warp image by freely moving the corners.");
		addNodeObject(transform, "Skew",			s_node_skew,			"Node_Skew",			[1, Node_Skew], ["shear"], "Skew image horizontally, or vertically.");
		addNodeObject(transform, "Mesh Warp",		s_node_warp_mesh,		"Node_Mesh_Warp",		[1, Node_Mesh_Warp], ["mesh wrap"], "Wrap image by converting it to mesh, and using control points.");
		addNodeObject(transform, "Polar",			s_node_polar,			"Node_Polar",			[1, Node_Polar],, "Convert image to polar coordinate.");
		addNodeObject(transform, "Area Warp",		s_node_padding,			"Node_Wrap_Area",		[1, Node_Wrap_Area],, "Wrap image to fit area value (x, y, w, h).");
		
		ds_list_add(transform, "Others");
		addNodeObject(transform, "Composite",		s_node_compose,			"Node_Composite",		[1, Node_Composite], ["merge"], "Combine multiple images with controllable position, rotation, scale.");
		addNodeObject(transform, "Nine Slice",		s_node_9patch,			"Node_9Slice",			[1, Node_9Slice], ["9 slice", "splice"], "Cut image into 3x3 parts, and scale/repeat only the middle part.");
		addNodeObject(transform, "Padding",			s_node_padding,			"Node_Padding",			[1, Node_Padding],, "Make image bigger by adding space in 4 directions.");
		//addNodeObject(transform, "Tile Random",		s_node_padding,			"Node_Tile_Random",		[1, Node_Tile_Random]);
	#endregion
	
	var filter = ds_list_create(); #region
	addNodeCatagory("Filter", filter);
		ds_list_add(filter, "Combines");
		addNodeObject(filter, "Blend",				s_node_blend,			 "Node_Blend",			  [0, Node_create_Blend], ["normal", "add", "subtract", "multiply", "screen", "maxx", "minn"], "Blend 2 images using different blendmodes.");
		addNodeObject(filter, "RGBA Combine",		s_node_RGB_combine,		 "Node_Combine_RGB",	  [1, Node_Combine_RGB],, "Combine 4 image in to one. Each image use to control RGBA channel.").setVersion(1070);
		addNodeObject(filter, "HSV Combine",		s_node_HSV_combine,		 "Node_Combine_HSV",	  [1, Node_Combine_HSV],, "Combine 4 image in to one. Each image use to control HSVA channel.").setVersion(1070);
		addNodeObject(filter, "Override Channel",	s_node_ovreride_channel, "Node_Override_Channel", [1, Node_Override_Channel],, "Replace RGBA value of one surface with anothers.").setVersion(11640);
		
		ds_list_add(filter, "Blurs");
		addNodeObject(filter, "Blur",				s_node_blur,			"Node_Blur",			[1, Node_Blur], ["gaussian blur"], "Blur image smoothly.");
		addNodeObject(filter, "Non-Uniform Blur",	s_node_blur_simple,		"Node_Blur_Simple",		[1, Node_Blur_Simple],, "Blur image using simpler algorithm. Allowing for variable blur strength.").setVersion(1070);
		addNodeObject(filter, "Directional Blur",	s_node_blur_directional,"Node_Blur_Directional",[1, Node_Blur_Directional], ["motion blur"], "Blur image given a direction.");
		addNodeObject(filter, "Slope Blur",			s_node_blur_slope,		"Node_Blur_Slope",		[1, Node_Blur_Slope], ["motion blur"], "Blur along a gradient of a slope map.").setVersion(11640);
		addNodeObject(filter, "Zoom Blur",			s_node_zoom,			"Node_Blur_Zoom",		[1, Node_Blur_Zoom],, "Blur image by zooming in/out from a mid point.");
		addNodeObject(filter, "Radial Blur",		s_node_radial,			"Node_Blur_Radial",		[1, Node_Blur_Radial],, "Blur image by rotating aroung a mid point.").setVersion(1110);
		addNodeObject(filter, "Lens Blur",			s_node_bokeh,			"Node_Blur_Bokeh",		[1, Node_Blur_Bokeh], ["bokeh"], "Create bokeh effect. Blur lighter color in a lens-like manner.").setVersion(1110);
		addNodeObject(filter, "Contrast Blur",		s_node_blur_contrast,	"Node_Blur_Contrast",	[1, Node_Blur_Contrast],, "Blur only pixel of a similiar color.");
		addNodeObject(filter, "Shape Blur",			s_node_shape_blur,		"Node_Blur_Shape",		[1, Node_Blur_Shape]).setVersion(11650);
		addNodeObject(filter, "Average",			s_node_average,			"Node_Average",			[1, Node_Average],, "Average color of every pixels in the image.").setVersion(1110);
		
		ds_list_add(filter, "Warps");
		addNodeObject(filter, "Mirror",				s_node_mirror,			"Node_Mirror",			[1, Node_Mirror],, "Reflect the image along a reflection line.").setVersion(1070);
		addNodeObject(filter, "Twirl",				s_node_twirl,			"Node_Twirl",			[1, Node_Twirl], ["twist"], "Twist the image around a mid point.");
		addNodeObject(filter, "Dilate",				s_node_dilate,			"Node_Dilate",			[1, Node_Dilate], ["inflate"], "Expand the image around a mid point.");
		addNodeObject(filter, "Spherize",			s_node_spherize,		"Node_Spherize",		[1, Node_Spherize],, "Wrap a texture on to sphere.").setVersion(11630);
		addNodeObject(filter, "Displace",			s_node_displace,		"Node_Displace",		[1, Node_Displace], ["distort"], "Distort image using another image as a map.");
		addNodeObject(filter, "Texture Remap",		s_node_texture_map,		"Node_Texture_Remap",	[1, Node_Texture_Remap],, "Remap image using texture map. Where red channel control x position and green channel control y position.");
		addNodeObject(filter, "Time Remap",			s_node_time_map,		"Node_Time_Remap",		[1, Node_Time_Remap],, "Remap image using texture as time map. Where brighter pixel means using pixel from an older frame.");
		addNodeObject(filter, "Morph Surface",		s_node_morph_surface,	"Node_Morph_Surface",	[1, Node_Morph_Surface],, "Morph pixel between two surfaces.").setVersion(1141);
		
		ds_list_add(filter, "Effects");
		addNodeObject(filter, "Outline",			s_node_border,			"Node_Outline",			[1, Node_Outline], ["border"], "Add border to the image.");
		addNodeObject(filter, "Glow",				s_node_glow,			"Node_Glow",			[1, Node_Glow],, "Apply glow to the border of the image.");
		addNodeObject(filter, "Shadow",				s_node_shadow,			"Node_Shadow",			[1, Node_Shadow],, "Apply shadow behind the image.");
		addNodeObject(filter, "Bloom",				s_node_bloom,			"Node_Bloom",			[1, Node_Bloom],, "Apply bloom effect, bluring and brighten the bright part of the image.");
		addNodeObject(filter, "Trail",				s_node_trail,			"Node_Trail",			[1, Node_Trail],, "Blend animation by filling in the pixel 'in-between' two or more frames.").setVersion(1130);
		addNodeObject(filter, "Erode",				s_node_erode,			"Node_Erode",			[1, Node_Erode],, "Remove pixel that are close to the border of the image.");
		addNodeObject(filter, "Corner",				s_node_corner,			"Node_Corner",			[1, Node_Corner], ["round corner"], "Round out sharp corner of the image.").setVersion(1110);
		addNodeObject(filter, "Blobify",			s_node_blobify,			"Node_Blobify",			[1, Node_Blobify]).setVersion(11650);
		addNodeObject(filter, "2D Light",			s_node_2d_light,		"Node_2D_light",		[1, Node_2D_light],, "Apply different shaped light on the image.");
		addNodeObject(filter, "Cast Shadow",		s_node_shadow_cast,		"Node_Shadow_Cast",		[1, Node_Shadow_Cast], ["raycast"], "Apply light that create shadow using shadow mask.").setVersion(1100);
		addNodeObject(filter, "Pixel Expand",		s_node_atlas,			"Node_Atlas",			[1, Node_Atlas], ["atlas"], "Replace transparent pixel with the closet non-transparent pixel.");
		addNodeObject(filter, "Pixel Cloud",		s_node_pixel_cloud,		"Node_Pixel_Cloud",		[1, Node_Pixel_Cloud],, "Displace each pixel of the image randomly.");
		addNodeObject(filter, "Pixel Sort",			s_node_pixel_sort,		"Node_Pixel_Sort",		[1, Node_Pixel_Sort],, "Sort pixel by brightness in horizontal, or vertial axis.");
		addNodeObject(filter, "Edge Detect",		s_node_edge_detect,		"Node_Edge_Detect",		[1, Node_Edge_Detect],, "Edge detect by applying Sobel, Prewitt, or Laplacian kernel.");
		addNodeObject(filter, "Convolution",		s_node_convolution,		"Node_Convolution",		[1, Node_Convolution], ["kernel"], "Apply convolution operation on each pixel using a custom 3x3 kernel.").setVersion(1090);
		addNodeObject(filter, "Local Analyze",		s_node_local_analyze,	"Node_Local_Analyze",	[1, Node_Local_Analyze],, "Apply non-linear operation (minimum, maximum) on each pixel locally.").setVersion(1110);
		addNodeObject(filter, "SDF",				s_node_sdf,				"Node_SDF",				[1, Node_SDF],, "Create signed distance field using jump flooding algorithm.").setVersion(1130);
		addNodeObject(filter, "Replace Image",		s_node_image_replace,	"Node_Surface_Replace",	[1, Node_Surface_Replace], ["image replace"], "Replace instances of an image with a new one.").setVersion(1140);
		addNodeObject(filter, "Chromatic Aberration",	s_node_chromatic_abarration,	"Node_Chromatic_Aberration",	[1, Node_Chromatic_Aberration],, "Apply chromatic aberration effect to the image.");
		addNodeObject(filter, "Vignette",			s_node_vignette,		"Node_Vignette",		[1, Node_Vignette],, "Apply vignette effect to the border.").setVersion(11630);
		addNodeObject(filter, "FXAA",				s_node_FXAA,			"Node_FXAA",			[1, Node_FXAA],, "Apply fast approximate anti-aliasing to the image.");
		addNodeObject(filter, "Kuwahara",			s_node_kuwahara,		"Node_Kuwahara",		[1, Node_Kuwahara]).setVersion(11660);
		//addNodeObject(filter, "Blend Edge",			s_node_FXAA,			"Node_Blend_Edge",		[1, Node_Blend_Edge]).setVersion(11640);
		
		ds_list_add(filter, "Colors");
		addNodeObject(filter, "Replace Palette",	s_node_replace_palette,	"Node_Color_replace",	[1, Node_Color_replace], ["isolate color", "select color", "palette swap", "color replace"], "Replace color that match one palette with another palette.");
		addNodeObject(filter, "Replace Colors",		s_node_color_replace,	"Node_Colors_Replace",	[1, Node_Colors_Replace], ["isolate color", "select color", "palette swap", "color replace"]);
		addNodeObject(filter, "Remove Color",		s_node_color_remove,	"Node_Color_Remove",	[1, Node_Color_Remove], ["delete color"], "Remove color that match a palette.");
		addNodeObject(filter, "Colorize",			s_node_colorize,		"Node_Colorize",		[1, Node_Colorize], ["recolor"], "Map brightness of a pixel to a color from a gradient.");
		addNodeObject(filter, "Posterize",			s_node_posterize,		"Node_Posterize",		[1, Node_Posterize],, "Reduce and remap color to match a palette.");
		addNodeObject(filter, "Dither",				s_node_dithering,		"Node_Dither",			[1, Node_Dither],, "Reduce color and use dithering to preserve original color.");
		addNodeObject(filter, "Color Adjust",		s_node_color_adjust,	"Node_Color_adjust",	[1, Node_Color_adjust], ["brightness", "contrast", "hue", "saturation", "value", "color blend", "alpha"], "Adjust brightness, contrast, hue, saturation, value, alpha, and blend image with color.");
		addNodeObject(filter, "Palette Shift",		s_node_palette_shift,	"Node_Palette_Shift",	[1, Node_Palette_Shift],, "Shift the order of color in palette.").setVersion(1147);
		addNodeObject(filter, "BW",					s_node_BW,				"Node_BW",				[1, Node_BW], ["black and white"], "Convert color image to black and white.");
		addNodeObject(filter, "Greyscale",			s_node_greyscale,		"Node_Greyscale",		[1, Node_Greyscale],, "Convert color image to greyscale.");
		addNodeObject(filter, "Invert",				s_node_invert,			"Node_Invert",			[1, Node_Invert], ["negate"], "Invert color.");
		addNodeObject(filter, "Level",				s_node_level,			"Node_Level",			[1, Node_Level],, "Adjust brightness of an image by changing its brightness range.");
		addNodeObject(filter, "Level Selector",		s_node_level_selector,	"Node_Level_Selector",	[1, Node_Level_Selector],, "Isolate part of the image that falls in the selected brightness range.");
		addNodeObject(filter, "Curve",				s_node_curve_edit,		"Node_Curve",			[1, Node_Curve],, "Adjust brightness of an image using curves.").setVersion(1120);
		addNodeObject(filter, "Threshold",			s_node_threshold,		"Node_Threshold",		[1, Node_Threshold],, "Set a threshold where pixel darker will becomes black, and brighter to white. Also works with alpha.").setVersion(1080);
		addNodeObject(filter, "Alpha Cutoff",		s_node_alpha_cut,		"Node_Alpha_Cutoff",	[1, Node_Alpha_Cutoff], ["remove alpha"], "Remove pixel with low alpha value.");
		addNodeObject(filter, "Gamma Map",			s_node_gamma_map,		"Node_Gamma_Map",		[1, Node_Gamma_Map]).setVersion(11660);
		
		ds_list_add(filter, "Conversions");
		addNodeObject(filter, "RGBA Extract",		s_node_RGB,				"Node_RGB_Channel",		[1, Node_RGB_Channel], ["channel extract"], "Extract RGBA channel on an image, each channel becomes its own image.");
		addNodeObject(filter, "HSV Extract",		s_node_HSV,				"Node_HSV_Channel",		[1, Node_HSV_Channel],, "Extract HSVA channel on an image, each channel becomes its own image.").setVersion(1070);
		addNodeObject(filter, "Alpha to Grey",		s_node_alpha_grey,		"Node_Alpha_Grey",		[1, Node_Alpha_Grey],, "Convert alpha value into solid greyscale.");
		addNodeObject(filter, "Grey to Alpha",		s_node_grey_alpha,		"Node_Grey_Alpha",		[1, Node_Grey_Alpha],, "Convert greyscale to alpha value.");
		
		ds_list_add(filter, "Fixes");
		addNodeObject(filter, "De-Corner",			s_node_decorner,		"Node_De_Corner",		[1, Node_De_Corner], ["decorner"], "Attempt to remove single pixel corner from the image.");
		addNodeObject(filter, "De-Stray",			s_node_destray,			"Node_De_Stray",		[1, Node_De_Stray], ["destray"], "Attempt to remove orphan pixel.");
	#endregion
	
	var d3d = ds_list_create(); #region
	addNodeCatagory("3D", d3d);
		ds_list_add(d3d, "2D Operations");
		addNodeObject(d3d, "Normal",			s_node_normal,			"Node_Normal",			[1, Node_Normal],, "Create normal map using greyscale value as height.");
		addNodeObject(d3d, "Normal Light",		s_node_normal_light,	"Node_Normal_Light",	[1, Node_Normal_Light],, "Light up the image using normal mapping.");
		addNodeObject(d3d, "Bevel",				s_node_bevel,			"Node_Bevel",			[1, Node_Bevel], ["shade", "auto shade"], "Apply 2D bevel on the image.");
		addNodeObject(d3d, "Sprite Stack",		s_node_stack,			"Node_Sprite_Stack",	[1, Node_Sprite_Stack],, "Create sprite stack either from repeating a single image or stacking different images using array.");
			
		ds_list_add(d3d, "3D");
		addNodeObject(d3d, "3D Camera",		s_node_3d_camera,			"Node_3D_Camera",			[1, Node_3D_Camera],, "Create 3D camera that render scene to surface.").setVersion(11510);
		addNodeObject(d3d, "3D Camera Set",	s_node_3d_camera_set,		"Node_3D_Camera_Set",		[1, Node_3D_Camera_Set],, "3D camera with build-in key and fill directional lights.").setVersion(11571);
		addNodeObject(d3d, "3D Material",	s_node_3d_meterial,			"Node_3D_Material",			[1, Node_3D_Material],, "Create 3D material with adjustable parameters.").setVersion(11510);
		addNodeObject(d3d, "3D Scene",		s_node_3d_scene,			"Node_3D_Scene",			[1, Node_3D_Scene],, "Combine multiple 3D objects into a single junction.").setVersion(11510);
		addNodeObject(d3d, "3D Repeat",		s_node_3d_array,			"Node_3D_Repeat",			[1, Node_3D_Repeat],, "Repeat the same 3D mesh multiple times.").setVersion(11510);
		addNodeObject(d3d, "Transform 3D",	s_node_image_transform_3d,	"Node_3D_Transform_Image",	[1, Node_3D_Transform_Image],, "Transform image in 3D space").setVersion(11600);
			
		ds_list_add(d3d, "Mesh");
		addNodeObject(d3d, "3D Object",		s_node_3d_obj,			"Node_3D_Mesh_Obj",			[0, Node_create_3D_Obj],, "Load .obj file from your computer as a 3D object.").setVersion(11510);
		addNodeObject(d3d, "3D Plane",		s_node_3d_plane,		"Node_3D_Mesh_Plane",		[1, Node_3D_Mesh_Plane],, "Put 2D image on a plane in 3D space.").setVersion(11510);
		addNodeObject(d3d, "3D Cube",		s_node_3d_cube,			"Node_3D_Mesh_Cube",		[1, Node_3D_Mesh_Cube]).setVersion(11510);
		addNodeObject(d3d, "3D Cylinder",	s_node_3d_cylinder,		"Node_3D_Mesh_Cylinder",	[1, Node_3D_Mesh_Cylinder]).setVersion(11510);
		addNodeObject(d3d, "3D UV Sphere",	s_node_3d_sphere_uv,	"Node_3D_Mesh_Sphere_UV",	[1, Node_3D_Mesh_Sphere_UV]).setVersion(11510);
		addNodeObject(d3d, "3D Icosphere",	s_node_3d_sphere_ico,	"Node_3D_Mesh_Sphere_Ico",	[1, Node_3D_Mesh_Sphere_Ico]).setVersion(11510);
		addNodeObject(d3d, "3D Cone",		s_node_3d_cone,			"Node_3D_Mesh_Cone",		[1, Node_3D_Mesh_Cone]).setVersion(11510);
		addNodeObject(d3d, "3D Terrain",	s_node_3d_displace,		"Node_3D_Mesh_Terrain",		[1, Node_3D_Mesh_Terrain],, "Create 3D terrain from height map.").setVersion(11560);
		addNodeObject(d3d, "Surface Extrude",	s_node_3d_extrude,	"Node_3D_Mesh_Extrude",		[1, Node_3D_Mesh_Extrude],, "Extrude 2D image into 3D object.").setVersion(11510);
			
		ds_list_add(d3d, "Light");
		addNodeObject(d3d, "Directional Light",	s_node_3d_light_directi,	"Node_3D_Light_Directional",	[1, Node_3D_Light_Directional],, "Create directional light directed at the origin point.").setVersion(11510);
		addNodeObject(d3d, "Point Light",		s_node_3d_light_point,		"Node_3D_Light_Point",			[1, Node_3D_Light_Point],, "Create point light to illuminate surrounding area.").setVersion(11510);
			
		ds_list_add(d3d, "Modify");
		addNodeObject(d3d, "Discretize vertex",	s_node_3d_discretize,		"Node_3D_Round_Vertex",		[1, Node_3D_Round_Vertex],, "Round out vertex position to a specified step.").setVersion(11560);
		addNodeObject(d3d, "Set Material",		s_node_3d_set_material,		"Node_3D_Set_Material",		[1, Node_3D_Set_Material],, "Replace mesh material with a new one.").setVersion(11560);
		addNodeObject(d3d, "Transform",			s_node_3d_transform,		"Node_3D_Transform",		[1, Node_3D_Transform],, "Transform 3D object.").setVersion(11570);
		addNodeObject(d3d, "Transform Scene",	s_node_3d_transform_scene,	"Node_3D_Transform_Scene",	[1, Node_3D_Transform_Scene],, "Transform 3D scene, accepts array of transformations for each objects.").setVersion(11570);
		addNodeObject(d3d, "UV Remap",			s_node_uv_remap,			"Node_3D_UV_Remap",			[1, Node_3D_UV_Remap],, "Remap UV map using plane.").setVersion(11570);
		///**/ addNodeObject(d3d, "3D Instancer",		s_node_3d_set_material,		"Node_3D_Instancer",	[1, Node_3D_Instancer]).setVersion(11560);
		///**/ addNodeObject(d3d, "3D Particle",		s_node_3d_set_material,		"Node_3D_Particle",		[1, Node_3D_Particle]).setVersion(11560);
			
		ds_list_add(d3d, "Points");
		addNodeObject(d3d, "Point Affector",	s_node_3d_point_affector,	"Node_3D_Point_Affector",	[1, Node_3D_Point_Affector],, "Generate array of 3D points interpolating between two values based on the distance.").setVersion(11570);
	#endregion
	
	var generator = ds_list_create(); #region
	addNodeCatagory("Generate", generator);
		ds_list_add(generator, "Colors");
		addNodeObject(generator, "Solid",				s_node_solid,				"Node_Solid",				[1, Node_Solid],, "Create image of a single color.");
		addNodeObject(generator, "Draw Gradient",		s_node_gradient,			"Node_Gradient",			[1, Node_Gradient],, "Create image from gradient.");
		addNodeObject(generator, "4 Points Gradient",	s_node_gradient_4points,	"Node_Gradient_Points",		[1, Node_Gradient_Points],, "Create image from 4 color points.");
			
		ds_list_add(generator, "Drawer");
		addNodeObject(generator, "Line",				s_node_line,				"Node_Line",				[1, Node_Line],, "Draw line on an image. Connect path data to it to draw line from path.");
		addNodeObject(generator, "Draw Text",			s_node_text_render,			"Node_Text",				[1, Node_Text],, "Draw text on an image.");
		addNodeObject(generator, "Shape",				s_node_shape,				"Node_Shape",				[1, Node_Shape],, "Draw simple shapes using signed distance field.");
		addNodeObject(generator, "Polygon Shape",		s_node_shape_polygon,		"Node_Shape_Polygon",		[1, Node_Shape_Polygon],, "Draw simple shapes using triangles.").setVersion(1130);
		addNodeObject(generator, "Interpret Number",	s_node_interpret_number,	"Node_Interpret_Number",	[1, Node_Interpret_Number],, "Convert array of number into surface.").setVersion(11530);
		addNodeObject(generator, "Random Shape",		s_node_random_shape,		"Node_Random_Shape",		[1, Node_Random_Shape],, "Generate random shape, use for testing purposes.").setVersion(1147);
		addNodeObject(generator, "Pixel Builder",		s_node_pixel_builder,		"Node_Pixel_Builder",		[1, Node_Pixel_Builder]).setVersion(11540);
		addNodeObject(generator, "Bar / Graph",			s_node_bar_graph,			"Node_Plot_Linear",			[1, Node_Plot_Linear], ["graph", "waveform", "bar chart", "plot"], "Plot graph or bar chart from array of number.").setVersion(1144);
			
		ds_list_add(generator, "Noises");
		addNodeObject(generator, "Noise",				s_node_noise,				"Node_Noise",				[1, Node_Noise],, "Generate white noise.");
		addNodeObject(generator, "Perlin Noise",		s_node_noise_perlin,		"Node_Perlin",				[1, Node_Perlin],, "Generate perlin noise.");
		addNodeObject(generator, "Simplex Noise",		s_node_noise_simplex,		"Node_Noise_Simplex",		[1, Node_Noise_Simplex], ["perlin"], "Generate simplex noise, similiar to perlin noise with better fidelity but non-tilable.").setVersion(1080);
		addNodeObject(generator, "Cellular Noise",		s_node_noise_cell,			"Node_Cellular",			[1, Node_Cellular], ["voronoi", "worley"], "Generate voronoi pattern.");
		addNodeObject(generator, "Anisotropic Noise",	s_node_noise_aniso,			"Node_Noise_Aniso",			[1, Node_Noise_Aniso],, "Generate anisotropic noise.");
		addNodeObject(generator, "Extra Perlins",		s_node_perlin_extra,		"Node_Perlin_Extra",		[1, Node_Perlin_Extra], ["noise"], "Random perlin noise made with different algorithms.").patreonExtra();
		addNodeObject(generator, "Extra Voronoi",		s_node_voronoi_extra,		"Node_Voronoi_Extra",		[1, Node_Voronoi_Extra], ["noise"], "Random voronoi noise made with different algorithms.").patreonExtra();
		addNodeObject(generator, "Gabor Noise",			s_node_gabor,				"Node_Gabor_Noise",			[1, Node_Gabor_Noise]).patreonExtra();
		addNodeObject(generator, "Shard Noise",			s_node_shard,				"Node_Shard_Noise",			[1, Node_Shard_Noise]).patreonExtra();
		addNodeObject(generator, "Wavelet Noise",		s_node_wavelet,				"Node_Wavelet_Noise",		[1, Node_Wavelet_Noise]).patreonExtra();
		addNodeObject(generator, "Caustic",				s_node_caustic,				"Node_Caustic",				[1, Node_Caustic]).patreonExtra();
		addNodeObject(generator, "Fold Noise",			s_node_fold_noise,			"Node_Fold_Noise",			[1, Node_Fold_Noise]).setVersion(11650);
		addNodeObject(generator, "Strand Noise",		s_node_strand_noise,		"Node_Noise_Strand",		[1, Node_Noise_Strand]).setVersion(11650);
		addNodeObject(generator, "Bubble Noise",		s_node_bubble_noise,		"Node_Noise_Bubble",		[1, Node_Noise_Bubble]).patreonExtra();
		
		ds_list_add(generator, "Patterns");
		addNodeObject(generator, "Stripe",				s_node_stripe,				"Node_Stripe",				[1, Node_Stripe],, "Generate stripe pattern.");
		addNodeObject(generator, "Zigzag",				s_node_zigzag,				"Node_Zigzag",				[1, Node_Zigzag],, "Generate zigzag pattern.");
		addNodeObject(generator, "Checker",				s_node_checker,				"Node_Checker",				[1, Node_Checker],, "Genearte checkerboard pattern.");
		addNodeObject(generator, "Grid",				s_node_grid,				"Node_Grid",				[1, Node_Grid], ["tile"], "Generate grid pattern.");
		addNodeObject(generator, "Triangular Grid",		s_node_grid_tri,			"Node_Grid_Tri",			[1, Node_Grid_Tri],, "Generate triangular grid pattern.");
		addNodeObject(generator, "Hexagonal Grid",		s_node_grid_hex,			"Node_Grid_Hex",			[1, Node_Grid_Hex],, "Generate hexagonal grid pattern.");
		addNodeObject(generator, "Pytagorean Tile",		s_node_pytagorean_tile,		"Node_Pytagorean_Tile",		[1, Node_Pytagorean_Tile],, "Generate Pytagorean tile pattern.").patreonExtra();
		addNodeObject(generator, "Herringbone Tile",	s_node_herringbone_tile,	"Node_Herringbone_Tile",	[1, Node_Herringbone_Tile],, "Generate Herringbone tile pattern.").patreonExtra();
		addNodeObject(generator, "Random Tile",			s_node_random_tile,			"Node_Random_Tile",			[1, Node_Random_Tile],, "Generate Random tile pattern.").patreonExtra();
		addNodeObject(generator, "Quasicrystal",		s_node_quasicircle,			"Node_Quasicrystal",		[1, Node_Quasicrystal]).setVersion(11660);
			
		ds_list_add(generator, "Populate");
		addNodeObject(generator, "Repeat",				s_node_repeat,				"Node_Repeat",				[1, Node_Repeat],, "Repeat image multiple times linearly, or in grid pattern.").setVersion(1100);
		addNodeObject(generator, "Scatter",				s_node_scatter,				"Node_Scatter",				[1, Node_Scatter],, "Scatter image randomly multiple times.");
			
		ds_list_add(generator, "Simulation");
		addNodeObject(generator, "Particle",			s_node_particle,			"Node_Particle",			[1, Node_Particle],, "Generate particle effect.");
		addNodeObject(generator, "VFX",					s_node_vfx,					"Node_VFX_Group_Inline",	[1, Node_VFX_Group_Inline],, "Create VFX group, which generate particles that can be manipulated using different force nodes.");
		addNodeObject(generator, "RigidSim",			s_node_rigidSim,			"Node_Rigid_Group_Inline",	[1, Node_Rigid_Group_Inline],, "Create group for rigidbody simulation.").setVersion(1110);
		addNodeObject(generator, "FLIP Fluid",			s_node_fluidSim_group,		"Node_FLIP_Group_Inline",	[1, Node_FLIP_Group_Inline],, "Create group for fluid simulation.").setVersion(11620);
		addNodeObject(generator, "SmokeSim",			s_node_smokeSim_group,		"Node_Fluid_Group_Inline",	[1, Node_Fluid_Group_Inline],, "Create group for smoke simulation.").setVersion(1120);
		addNodeObject(generator, "StrandSim",			s_node_strandSim,			"Node_Strand_Group_Inline",	[1, Node_Strand_Group_Inline], ["Hair"], "Create group for hair simulation.").setVersion(1140);
		addNodeObject(generator, "Diffuse",				s_node_diffuse,				"Node_Diffuse",				[1, Node_Diffuse],, "Simulate diffusion like simulation.").setVersion(11640);
		addNodeObject(generator, "Reaction Diffusion",	s_node_reaction_diffusion,	"Node_RD",					[1, Node_RD],, "Simulate reaction diffusion effect.").setVersion(11630);
			
		ds_list_add(generator, "Region");
		addNodeObject(generator, "Separate Shape",		s_node_sepearte_shape,		"Node_Seperate_Shape",		[1, Node_Seperate_Shape],, "Separate disconnected pixel each into an image in an image array.");
		addNodeObject(generator, "Region Fill",			s_node_region_fill,			"Node_Region_Fill",			[1, Node_Region_Fill],, "Fill connected pixel with colors.").setVersion(1147);		
		addNodeObject(generator, "Flood Fill",			s_node_flood_fill,			"Node_Flood_Fill",			[1, Node_Flood_Fill],, "Filled connected pixel given position and color.").setVersion(1133);
		
		ds_list_add(generator, "MK Effects");
		addNodeObject(generator, "MK Rain",				s_node_mk_rain,				"Node_MK_Rain",				[1, Node_MK_Rain]).setVersion(11600);
		addNodeObject(generator, "MK GridBalls",		s_node_mk_ball_grid,		"Node_MK_GridBalls",		[1, Node_MK_GridBalls]).setVersion(11600);
		addNodeObject(generator, "MK GridFlip",			s_node_mk_flip_grid,		"Node_MK_GridFlip",			[1, Node_MK_GridFlip]).setVersion(11600);
		addNodeObject(generator, "MK Saber",			s_node_mk_saber,			"Node_MK_Saber",			[1, Node_MK_Saber]).setVersion(11600);
		addNodeObject(generator, "MK Tile",				s_node_mk_tile,				"Node_MK_Tile",				[1, Node_MK_Tile]).setVersion(11600);
		addNodeObject(generator, "MK Flag",				s_node_mk_flag,				"Node_MK_Flag",				[1, Node_MK_Flag]).setVersion(11600);
		addNodeObject(generator, "MK Brownian",			s_node_mk_brownian,			"Node_MK_Brownian",			[1, Node_MK_Brownian]).setVersion(11630);
		addNodeObject(generator, "MK Fall",				s_node_mk_fall,				"Node_MK_Fall",				[1, Node_MK_Fall], ["Leaf", "Leaves"]).setVersion(11630);
		addNodeObject(generator, "MK Blinker",			s_node_mk_blinker,			"Node_MK_Blinker",			[1, Node_MK_Blinker]).setVersion(11630);
		addNodeObject(generator, "MK Lens Flare",		s_node_mk_flare,			"Node_MK_Flare",			[1, Node_MK_Flare]).setVersion(11630);
		//addNodeObject(generator, "MK Sparkle",			s_node_mk_sparkle,			"Node_MK_Sparkle",			[1, Node_MK_Sparkle]).patreonExtra();
	#endregion
	
	var compose = ds_list_create(); #region
	addNodeCatagory("Compose", compose);
		ds_list_add(compose, "Composes");
		addNodeObject(compose, "Blend",					s_node_blend,			"Node_Blend",				[1, Node_Blend],, "Combine 2 images using different blend modes.");
		addNodeObject(compose, "Composite",				s_node_compose,			"Node_Composite",			[1, Node_Composite],, "Combine multiple images with custom transformation.");
		addNodeObject(compose, "Stack",					s_node_image_stack,		"Node_Stack",				[1, Node_Stack],, "Place image next to each other linearly, or on top of each other.").setVersion(1070);
		addNodeObject(compose, "Image Grid",			s_node_image_grid,		"Node_Image_Grid",			[1, Node_Image_Grid],, "Place image next to each other in grid pattern.").setVersion(11640);
		addNodeObject(compose, "Camera",				s_node_camera,			"Node_Camera",				[1, Node_Camera],, "Create camera that crop image to fix dimension with control of position, zoom. Also can be use to create parallax effect.");
		addNodeObject(compose, "Render Spritesheet",	s_node_sprite_sheet,	"Node_Render_Sprite_Sheet",	[1, Node_Render_Sprite_Sheet],, "Create spritesheet from image array or animation.");
		addNodeObject(compose, "Pack Sprites",			s_node_pack_sprite,		"Node_Pack_Sprites",		[1, Node_Pack_Sprites],, "Combine array of images with different dimension using different algorithms.").setVersion(1140);
			
		ds_list_add(compose, "Armature");
		addNodeObject(compose, "Armature Create",	s_node_armature_create,	"Node_Armature",		[1, Node_Armature], ["rigging", "bone"], "Create new armature system.").setVersion(1146);
		addNodeObject(compose, "Armature Pose",		s_node_armature_pose,	"Node_Armature_Pose",	[1, Node_Armature_Pose], ["rigging", "bone"], "Pose armature system.").setVersion(1146);
		addNodeObject(compose, "Armature Bind",		s_node_armature_bind,	"Node_Armature_Bind",	[1, Node_Armature_Bind], ["rigging", "bone"], "Bind and render image to an armature system.").setVersion(1146);
		addNodeObject(compose, "Armature Path",		s_node_armature_path,	"Node_Armature_Path",	[1, Node_Armature_Path], ["rigging", "bone"], "Generate path from armature system.").setVersion(1146);
		addNodeObject(compose, "Armature Sample",	s_node_armature_sample,	"Node_Armature_Sample",	[1, Node_Armature_Sample], ["rigging", "bone"], "Sample point from armature system.").setVersion(1147);
			
		if(!DEMO) {
			ds_list_add(compose, "Export");
			addNodeObject(compose, "Export",	s_node_export,		"Node_Export",			[0, Node_create_Export],, "Export image/animation to file(s).");
		}
	#endregion
	
	var values = ds_list_create(); #region
	addNodeCatagory("Values", values);
		ds_list_add(values, "Raw data");
		addNodeObject(values, "Number",			s_node_number,		"Node_Number",			[1, Node_Number]);
		addNodeObject(values, "Text",			s_node_text,		"Node_String",			[1, Node_String]);
		addNodeObject(values, "Path",			s_node_path,		"Node_Path",			[1, Node_Path]);
		addNodeObject(values, "Area",			s_node_area,		"Node_Area",			[1, Node_Area]);
		addNodeObject(values, "Boolean",		s_node_boolean,		"Node_Boolean",			[1, Node_Boolean]).setVersion(1090);
			
		ds_list_add(values, "Numbers");
		addNodeObject(values, "Number",			s_node_number,			"Node_Number",			[1, Node_Number]);
		addNodeObject(values, "To Number",		s_node_to_number,		"Node_To_Number",		[1, Node_To_Number]).setVersion(1145);
		addNodeObject(values, "Math",			s_node_math,			"Node_Math",			[0, Node_create_Math], [ "add", "subtract", "multiply", "divide", "power", "root", "modulo", "round", "ceiling", "floor", "sin", "cos", "tan", "lerp", "abs" ]);
		addNodeObject(values, "Equation",		s_node_equation,		"Node_Equation",		[0, Node_create_Equation],, "Evaluate string of equation. With an option for setting variables.");
		addNodeObject(values, "Random",			s_node_random,			"Node_Random",			[1, Node_Random]);
		addNodeObject(values, "Statistic",		s_node_statistic,		"Node_Statistic",		[0, Node_create_Statistic], ["sum", "average", "mean", "median", "min", "max"]);
		addNodeObject(values, "Convert Base",	s_node_base_conversion,	"Node_Base_Convert",	[1, Node_Base_Convert], ["base convert", "binary", "hexadecimal"]).setVersion(1140);
		addNodeObject(values, "Vector2",		s_node_vec2,			"Node_Vector2",			[1, Node_Vector2]);
		addNodeObject(values, "Vector3",		s_node_vec3,			"Node_Vector3",			[1, Node_Vector3]);
		addNodeObject(values, "Vector4",		s_node_vec4,			"Node_Vector4",			[1, Node_Vector4]);
		addNodeObject(values, "Vector Split",	s_node_vec_split,		"Node_Vector_Split",	[1, Node_Vector_Split]);
		addNodeObject(values, "Scatter Points",	s_node_scatter_point,	"Node_Scatter_Points",	[1, Node_Scatter_Points],, "Generate array of vector 2 points for scattering.").setVersion(1120);
		addNodeObject(values, "Translate Point",s_node_translate_point,	"Node_Move_Point",		[1, Node_Move_Point]).setVersion(1141);
		addNodeObject(values, "Dot product",	s_node_dot_product,		"Node_Vector_Dot",		[1, Node_Vector_Dot]).setVersion(1141);
		addNodeObject(values, "Cross product 3D",	s_node_cross_product_2d,	"Node_Vector_Cross_3D",		[1, Node_Vector_Cross_3D]).setVersion(1141);
		addNodeObject(values, "Cross product 2D",	s_node_cross_product_3d,	"Node_Vector_Cross_2D",		[1, Node_Vector_Cross_2D]).setVersion(1141);
		addNodeObject(values, "FFT",				s_node_FFT,					"Node_FFT",					[1, Node_FFT], ["frequency analysis"], "Perform fourier transform on number array.").setVersion(1144);
		addNodeObject(values, "Transform Array",	s_node_transform_array,		"Node_Transform_Array",		[1, Node_Transform_Array]).setVersion(1146);
		
		ds_list_add(values, "Texts");
		addNodeObject(values, "Text",				s_node_text,				"Node_String",					[1, Node_String]);
		addNodeObject(values, "To Text",			s_node_to_text,				"Node_To_Text",					[1, Node_To_Text]).setVersion(1145);
		addNodeObject(values, "Unicode",			s_node_unicode,				"Node_Unicode",					[1, Node_Unicode]);
		addNodeObject(values, "Text Length",		s_node_text_length,			"Node_String_Length",			[1, Node_String_Length]).setVersion(1138);
		addNodeObject(values, "Combine Text",		s_node_text_combine,		"Node_String_Merge",			[1, Node_String_Merge]);
		addNodeObject(values, "Join Text",			s_node_text_join,			"Node_String_Join",				[1, Node_String_Join]).setVersion(1120);
		addNodeObject(values, "Split Text",			s_node_text_splice,			"Node_String_Split",			[1, Node_String_Split]);
		addNodeObject(values, "Trim Text",			s_node_text_trim,			"Node_String_Trim",				[1, Node_String_Trim]).setVersion(1080);
		addNodeObject(values, "Get Character",		s_node_text_char_get,		"Node_String_Get_Char",			[1, Node_String_Get_Char]).setVersion(1100);
		addNodeObject(values, "RegEx Match",		s_node_regex_match,			"Node_String_Regex_Match",		[1, Node_String_Regex_Match]).setVersion(1140);
		addNodeObject(values, "RegEx Search",		s_node_regex_search,		"Node_String_Regex_Search",		[1, Node_String_Regex_Search]).setVersion(1140);
		addNodeObject(values, "RegEx Replace",		s_node_regex_replace,		"Node_String_Regex_Replace",	[1, Node_String_Regex_Replace]).setVersion(1140);
		addNodeObject(values, "Separate File Path",	s_node_separate_file_path,	"Node_Path_Separate_Folder",	[1, Node_Path_Separate_Folder]).setVersion(1145);
		
		ds_list_add(values, "Arrays");
		addNodeObject(values, "Array",				s_node_array,			"Node_Array",					[1, Node_Array]);
		addNodeObject(values, "Array Range",		s_node_array_range,		"Node_Array_Range",				[1, Node_Array_Range],, "Create array of numbers by setting start, end and step length.");
		addNodeObject(values, "Array Add",			s_node_array_add,		"Node_Array_Add",				[1, Node_Array_Add], ["add array"]);
		addNodeObject(values, "Array Length",		s_node_array_length,	"Node_Array_Length",			[1, Node_Array_Length]);
		addNodeObject(values, "Array Get",			s_node_array_get,		"Node_Array_Get",				[1, Node_Array_Get], ["get array"]);
		addNodeObject(values, "Array Set",			s_node_array_set,		"Node_Array_Set",				[1, Node_Array_Set], ["set array"]).setVersion(1120);
		addNodeObject(values, "Array Find",			s_node_array_find,		"Node_Array_Find",				[1, Node_Array_Find], ["find array"]).setVersion(1120);
		addNodeObject(values, "Array Insert",		s_node_array_insert,	"Node_Array_Insert",			[1, Node_Array_Insert], ["insert array"]).setVersion(1120);
		addNodeObject(values, "Array Remove",		s_node_array_remove,	"Node_Array_Remove",			[1, Node_Array_Remove], ["remove array", "delete array", "array delete"]).setVersion(1120);
		addNodeObject(values, "Array Reverse",		s_node_array_reverse,	"Node_Array_Reverse",			[1, Node_Array_Reverse], ["reverse array"]).setVersion(1120);
		addNodeObject(values, "Array Shift",		s_node_array_shift,		"Node_Array_Shift",				[1, Node_Array_Shift]).setVersion(1137);
		addNodeObject(values, "Array Rearrange",	s_node_array_rearrange,	"Node_Array_Rearrange",			[1, Node_Array_Rearrange]).setVersion(11640);
		addNodeObject(values, "Array Zip",			s_node_array_zip,		"Node_Array_Zip",				[1, Node_Array_Zip]).setVersion(1138);
		addNodeObject(values, "Array Copy",			s_node_array_copy,		"Node_Array_Copy",				[1, Node_Array_Copy]).setVersion(1144);
		addNodeObject(values, "Array Convolute",	s_node_array_convolute,	"Node_Array_Convolute",			[1, Node_Array_Convolute]).setVersion(11540);
		addNodeObject(values, "Array Composite",	s_node_array_composite,	"Node_Array_Composite",			[1, Node_Array_Composite]).setVersion(11540);
		addNodeObject(values, "Array Sample",		s_node_array_sample,	"Node_Array_Sample",			[1, Node_Array_Sample]).setVersion(11540);
		addNodeObject(values, "Sort Number",		s_node_array_sort,		"Node_Array_Sort",				[1, Node_Array_Sort], ["array sort"]).setVersion(1120);
		addNodeObject(values, "Shuffle Array",		s_node_array_shuffle,	"Node_Array_Shuffle",			[1, Node_Array_Shuffle], ["array shuffle"]).setVersion(1120);
		addNodeObject(values, "Loop Array",			s_node_loop_array,		"Node_Iterate_Each_Inline",		[1, Node_Iterate_Each_Inline], ["iterate each", "for each", "array loop"], "Create group that iterate to each member in an array.");
		addNodeObject(values, "Filter Array",		s_node_filter_array,	"Node_Iterate_Filter_Inline",	[1, Node_Iterate_Filter_Inline],, "Filter array using condition.").setVersion(1140);
		addNodeObject(values, "Sort Array",			s_node_sort_array,		"Node_Iterate_Sort_Inline",		[1, Node_Iterate_Sort_Inline],, "Sort array using node graph.").setVersion(1143);
		addNodeObject(values, "Parse CSV",			s_node_csv_parse,		"Node_Array_CSV_Parse",			[1, Node_Array_CSV_Parse]).setVersion(1145);
		
		ds_list_add(values, "Paths");
		addNodeObject(values, "Path",			s_node_path,			"Node_Path",			[1, Node_Path]);
		addNodeObject(values, "Smooth Path",	s_node_path_smooth,		"Node_Path_Smooth",		[1, Node_Path_Smooth], ["path smooth"]).setVersion(11640);
		addNodeObject(values, "Path Anchor",	s_node_path_anchor,		"Node_Path_Anchor",		[1, Node_Path_Anchor]).setVersion(1140);
		addNodeObject(values, "Path Array",		s_node_path_array,		"Node_Path_Array",		[1, Node_Path_Array], ["array path"]).setVersion(1137);
		addNodeObject(values, "Sample Path",	s_node_path_sample,		"Node_Path_Sample",		[1, Node_Path_Sample], ["path sample"], "Sample a 2D position from a path");
		addNodeObject(values, "Blend Path",		s_node_path_blend,		"Node_Path_Blend",		[1, Node_Path_Blend],, "Blend between 2 paths.");
		addNodeObject(values, "Remap Path",		s_node_path_map,		"Node_Path_Map_Area",	[1, Node_Path_Map_Area],, "Scale path to fit a given area.").setVersion(1130);
		addNodeObject(values, "Transform Path",	s_node_path_transform,	"Node_Path_Transform",	[1, Node_Path_Transform]).setVersion(1130);
		addNodeObject(values, "Shift Path",		s_node_path_shift,		"Node_Path_Shift",		[1, Node_Path_Shift],, "Move path along its normal.").setVersion(1130);
		addNodeObject(values, "Trim Path",		s_node_path_trim,		"Node_Path_Trim",		[1, Node_Path_Trim]).setVersion(1130);
		addNodeObject(values, "Wave Path",		s_node_path_wave,		"Node_Path_Wave",		[1, Node_Path_Wave], ["zigzag path"]).setVersion(1130);
		addNodeObject(values, "Reverse Path",	s_node_path_reverse,	"Node_Path_Reverse",	[1, Node_Path_Reverse]).setVersion(1130);
		addNodeObject(values, "Path Builder",	s_node_path_builder,	"Node_Path_Builder",	[1, Node_Path_Builder],, "Create path from array of vec2 points.").setVersion(1137);
		addNodeObject(values, "L system",		s_node_path_l_system,	"Node_Path_L_System",	[1, Node_Path_L_System]).setVersion(1137);
		addNodeObject(values, "Path plot",		s_node_path_plot,		"Node_Path_Plot",		[1, Node_Path_Plot]).setVersion(1138);
		addNodeObject(values, "Path from Mask",	s_node_path_from_mask,	"Node_Path_From_Mask",	[1, Node_Path_From_Mask]).setVersion(11640);
		addNodeObject(values, "Bridge Path",	s_node_path_bridge,		"Node_Path_Bridge",		[1, Node_Path_Bridge]).setVersion(11640);
		addNodeObject(values, "Bake Path",		s_node_path_bake,		"Node_Path_Bake",		[1, Node_Path_Bake]).setVersion(11640);
		addNodeObject(values, "Map Path",		s_node_path_mapp,		"Node_Path_Map",		[1, Node_Path_Map]).setVersion(11640);
		
		ds_list_add(values, "Boolean");
		addNodeObject(values, "Boolean",		s_node_boolean,		"Node_Boolean",		[1, Node_Boolean]);
		addNodeObject(values, "Compare",		s_node_compare,		"Node_Compare",		[0, Node_create_Compare], ["equal", "greater", "lesser"]);
		addNodeObject(values, "Logic Opr",		s_node_logic_opr,	"Node_Logic",		[0, Node_create_Logic], [ "and", "or", "not", "nand", "nor" , "xor" ]);
			
		ds_list_add(values, "Trigger");
		addNodeObject(values, "Trigger",			s_node_trigger,			"Node_Trigger",			[1, Node_Trigger]).setVersion(1140);
		addNodeObject(values, "Boolean Trigger",	s_node_trigger_bool,	"Node_Trigger_Bool",	[1, Node_Trigger_Bool], ["trigger boolean"]).setVersion(1140);
			
		ds_list_add(values, "Struct");
		addNodeObject(values, "Struct",			s_node_struct,		"Node_Struct",				[1, Node_Struct]);
		addNodeObject(values, "Struct Get",		s_node_struct_get,	"Node_Struct_Get",			[1, Node_Struct_Get]);
		//addNodeObject(values, "Struct Set",		s_node_struct_get,	"Node_Struct_Set",			[1, Node_Struct_Set]);
		addNodeObject(values, "Parse JSON",		s_node_json_parse,	"Node_Struct_JSON_Parse",	[1, Node_Struct_JSON_Parse]).setVersion(1145);
			
		ds_list_add(values, "Mesh");
		addNodeObject(values, "Path to Mesh",	s_node_mesh_path,		"Node_Mesh_Create_Path",	[1, Node_Mesh_Create_Path],, "Create mesh from path.").setVersion(1140);
		addNodeObject(values, "Mesh Transform",	s_node_mesh_transform,	"Node_Mesh_Transform",		[1, Node_Mesh_Transform]).setVersion(1140);
			
		ds_list_add(values, "Atlas");
		addNodeObject(values, "Draw Atlas",		s_node_draw_atlas,	"Node_Atlas_Draw",	[1, Node_Atlas_Draw],, "Render image atlas to a surface.").setVersion(1141);
		addNodeObject(values, "Atlas Get",		s_node_atlas_get,	"Node_Atlas_Get",	[1, Node_Atlas_Get]).setVersion(1141);
		addNodeObject(values, "Atlas Set",		s_node_atlas_set,	"Node_Atlas_Set",	[1, Node_Atlas_Set]).setVersion(1141);
			
		ds_list_add(values, "Surface");
		//addNodeObject(values, "Dynamic Surface",		s_node_dynasurf,			"Node_dynaSurf",	[1, Node_dynaSurf]).setVersion(11520);
		addNodeObject(values, "IsoSurf",				s_node_isosurf,				"Node_IsoSurf",		[1, Node_IsoSurf]).setVersion(11520);
		addNodeObject(values, "Surface from Buffer",	s_node_surface_from_buffer,	"Node_Surface_From_Buffer",	[1, Node_Surface_From_Buffer], ["buffer to surface"], "Create surface from buffer.").setVersion(1146);
			
		ds_list_add(values, "Buffer");
		addNodeObject(values, "Buffer from Surface",	s_node_surface_to_buffer,	"Node_Surface_To_Buffer",	[1, Node_Surface_To_Buffer], ["surface to buffer"], "Create buffer from surface.").setVersion(1146);
	#endregion
	
	var color = ds_list_create(); #region
	addNodeCatagory("Color", color);
		ds_list_add(color, "Colors");
		addNodeObject(color, "Color",			s_node_color_out,		"Node_Color",			[1, Node_Color],, "Create color value.");
		addNodeObject(color, "RGB Color",		s_node_color_from_rgb,	"Node_Color_RGB",		[1, Node_Color_RGB],, "Create color from RGB value.");
		addNodeObject(color, "HSV Color",		s_node_color_from_hsv,	"Node_Color_HSV",		[1, Node_Color_HSV],, "Create color from HSV value.");
		addNodeObject(color, "Sampler",			s_node_sampler,			"Node_Sampler",			[1, Node_Sampler],, "Sample color from an image.");
		addNodeObject(color, "Color Data",		s_node_color_data,		"Node_Color_Data",		[1, Node_Color_Data],, "Get data (rgb, hsv, brightness) from color.");
		addNodeObject(color, "Find pixel",		s_node_pixel_find,		"Node_Find_Pixel",		[1, Node_Find_Pixel],, "Get the position of the first pixel with a given color.").setVersion(1130);
		addNodeObject(color, "Mix Color",		s_node_color_mix,		"Node_Color_Mix",		[1, Node_Color_Mix]).setVersion(1140);
			
		ds_list_add(color, "Palettes");
		addNodeObject(color, "Palette",			s_node_palette,			"Node_Palette",			[1, Node_Palette],, "Create palette value. Note that palette is simple an array of colors.");
		addNodeObject(color, "Sort Palette",	s_node_palette_sort,	"Node_Palette_Sort",	[1, Node_Palette_Sort],, "Sort palette with specified order.").setVersion(1130);
		addNodeObject(color, "Palette Extract",	s_node_palette_extract,	"Node_Palette_Extract",	[1, Node_Palette_Extract],, "Extract palette from an image.").setVersion(1100);
		addNodeObject(color, "Palette Replace",	s_node_palette_replace,	"Node_Palette_Replace",	[1, Node_Palette_Replace],, "Replace colors in a palette with new one.").setVersion(1120);
			
		ds_list_add(color, "Gradient");
		addNodeObject(color, "Gradient",			s_node_gradient_out,		"Node_Gradient_Out",			[1, Node_Gradient_Out],, "Create gradient object");
		addNodeObject(color, "Palette to Gradient",	s_node_gradient_palette,	"Node_Gradient_Palette",		[1, Node_Gradient_Palette],, "Create gradient from palette.").setVersion(1135);
		addNodeObject(color, "Gradient Shift",		s_node_gradient_shift,		"Node_Gradient_Shift",			[1, Node_Gradient_Shift],, "Move gradients keys.");
		addNodeObject(color, "Gradient Replace",	s_node_gradient_replace,	"Node_Gradient_Replace_Color",	[1, Node_Gradient_Replace_Color],, "Replace color inside a gradient.").setVersion(1135);
		addNodeObject(color, "Gradient Data",		s_node_gradient_data,		"Node_Gradient_Extract",		[1, Node_Gradient_Extract],, "Get palatte and array of key positions from gradient.").setVersion(1135);
	#endregion
	
	var animation = ds_list_create(); #region
	addNodeCatagory("Animation", animation);
		ds_list_add(animation, "Animations");
		addNodeObject(animation, "Frame Index",		s_node_counter,		"Node_Counter",		[1, Node_Counter], ["current frame", "counter"], "Output current frame as frame index, or animation progress (0 - 1).");
		addNodeObject(animation, "Wiggler",			s_node_wiggler,		"Node_Wiggler",		[1, Node_Wiggler],, "Create smooth random value.");
		addNodeObject(animation, "Evaluate Curve",	s_node_curve_eval,	"Node_Anim_Curve",	[1, Node_Anim_Curve],, "Evaluate value from an animation curve.");
		addNodeObject(animation, "Rate Remap",		s_node_rate_remap,	"Node_Rate_Remap",	[1, Node_Rate_Remap],, "Remap animation to a new framerate.").setVersion(1147);
		addNodeObject(animation, "Delay",			s_node_delay,		"Node_Delay",		[1, Node_Delay]).setVersion(11640);
		addNodeObject(animation, "Stagger",			s_node_stagger,		"Node_Stagger",		[1, Node_Stagger]).setVersion(11640);
			
		ds_list_add(animation, "Audio");
		addNodeObject(animation, "WAV File In",	 s_node_wav_file_read,	"Node_WAV_File_Read",	[0, Node_create_WAV_File_Read],, "Load wav audio file.").setVersion(1144);
		addNodeObject(animation, "WAV File Out", s_node_wav_file_write,	"Node_WAV_File_Write",	[1, Node_WAV_File_Write],, "Save wav audio file.").setVersion(1145);
		addNodeObject(animation, "FFT",			 s_node_FFT,			"Node_FFT",				[1, Node_FFT], ["frequency analysis"], "Perform fourier transform on number array.").setVersion(1144);
		addNodeObject(animation, "Bar / Graph",	 s_node_bar_graph,		"Node_Plot_Linear",		[1, Node_Plot_Linear], ["graph", "waveform", "bar chart", "plot"], "Plot graph or bar chart from array of number.").setVersion(1144);
		addNodeObject(animation, "Audio Window", s_node_audio_trim,		"Node_Audio_Window",	[1, Node_Audio_Window],, "Take a slice of an audio array based on the current frame.").setVersion(1144);
		addNodeObject(animation, "Audio Volume", s_node_audio_volume,	"Node_Audio_Loudness",	[1, Node_Audio_Loudness],, "Calculate volume of an audio bit array.").setVersion(11540);
	#endregion
	
	var node = ds_list_create(); #region
	addNodeCatagory("Misc", node);
		ds_list_add(node, "Control");
		addNodeObject(node, "Condition",			s_node_condition,			"Node_Condition",			[1, Node_Condition],, "Given a condition, output one value if true, another value is false.");
		addNodeObject(node, "Switch",				s_node_switch,				"Node_Switch",				[1, Node_Switch],, "Given an index, output a value labeled by the same index.").setVersion(1090);
		addNodeObject(node, "Animation Control",	s_node_animation_control,	"Node_Animation_Control",	[1, Node_Animation_Control],, "Control animation state with triggers.").setVersion(1145);
			
		ds_list_add(node, "Groups");
		addNodeObject(node, "Group",			s_node_group,			"Node_Group",					[1, Node_Group]);
		addNodeObject(node, "Feedback",			s_node_feedback,		"Node_Feedback",				[1, Node_Feedback],, "Create a group that reuse output from last frame to the current one.");
		addNodeObject(node, "Loop",				s_node_loop,			"Node_Iterate",					[1, Node_Iterate], ["iterate", "for"], "Create group that reuse output as input repeatedly in one frame.");
		addNodeObject(node, "Loop Array",		s_node_loop_array,		"Node_Iterate_Each_Inline",		[1, Node_Iterate_Each_Inline], ["iterate each", "for each", "array loop"], "Create group that iterate to each member in an array.");
		addNodeObject(node, "Filter Array",		s_node_filter_array,	"Node_Iterate_Filter_Inline",	[1, Node_Iterate_Filter_Inline],, "Filter array using condition.").setVersion(1140);
		
		if(OS == os_windows) {
			ds_list_add(node, "Lua");
			addNodeObject(node, "Lua Global",		s_node_lua_global,	"Node_Lua_Global",		[1, Node_Lua_Global]).setVersion(1090);
			addNodeObject(node, "Lua Surface",		s_node_lua_surface,	"Node_Lua_Surface",		[1, Node_Lua_Surface]).setVersion(1090);
			addNodeObject(node, "Lua Compute",		s_node_lua_compute,	"Node_Lua_Compute",		[1, Node_Lua_Compute]).setVersion(1090);
		
			ds_list_add(node, "Shader");
			addNodeObject(node, "HLSL",				s_node_hlsl,		"Node_HLSL",			[1, Node_HLSL],, "Execute HLSL shader on a surface.").setVersion(11520);
		}
		
		ds_list_add(node, "Organize");
		addNodeObject(node, "Pin",				s_node_pin,			"Node_Pin",				[1, Node_Pin],, "Create pin to organize your connection. Can be create by double clicking on a connection line.");
		addNodeObject(node, "Frame",			s_node_frame,		"Node_Frame",			[1, Node_Frame],, "Create frame surrounding nodes.");
		addNodeObject(node, "Tunnel In",		s_node_tunnel_in,	"Node_Tunnel_In",		[1, Node_Tunnel_In],, "Create tunnel for sending value based on key matching.");
		addNodeObject(node, "Tunnel Out",		s_node_tunnel_out,	"Node_Tunnel_Out",		[1, Node_Tunnel_Out],, "Receive value from tunnel in of the same key.");
		addNodeObject(node, "Display Text",		s_node_text_display,"Node_Display_Text",	[1, Node_Display_Text],, "Display text on the graph.");
		addNodeObject(node, "Display Image",	s_node_image,		"Node_Display_Image",	[0, Node_create_Display_Image],, "Display image on the graph.");
			
		ds_list_add(node, "Cache");
		addNodeObject(node, "Cache",		s_node_cache,		"Node_Cache",		[1, Node_Cache],, "Store current animation. Cache persisted between save.").setVersion(1134);
		addNodeObject(node, "Cache Array",	s_node_cache_array,	"Node_Cache_Array",	[1, Node_Cache_Array],, "Store current animation as array.  Cache persisted between save.").setVersion(1130);
		
		ds_list_add(node, "Debug");
		addNodeObject(node, "Print",			s_node_print,		"Node_Print",			[1, Node_Print], ["debug log"], "Display text to notification.").setVersion(1145);
		addNodeObject(node, "Widget Test",		s_node_print,		"Node_Widget_Test",		[1, Node_Widget_Test]);
		addNodeObject(node, "Graph Preview",	s_node_image,		"Node_Graph_Preview",	[1, Node_Graph_Preview]);
		//addNodeObject(node, "Module Test",	s_node_print,		"Node_Module_Test",	[1, Node_Module_Test]);
		
		ds_list_add(node, "Project");
		addNodeObject(node, "Project Data",		s_node_project_data,		"Node_Project_Data",		[1, Node_Project_Data]).setVersion(11650);
		
		ds_list_add(node, "System");
		addNodeObject(node, "Argument",			s_node_argument,			"Node_Argument",			[1, Node_Argument]).setVersion(11660);
		addNodeObject(node, "Terminal trigger",	s_node_terminal_trigger,	"Node_Terminal_Trigger",	[1, Node_Terminal_Trigger]).setVersion(11660);
		addNodeObject(node, "Execute Shell",	s_node_shell_excecute,		"Node_Shell",				[1, Node_Shell], ["terminal", "execute", "run"], "Execute shell script.").setVersion(11530);
		addNodeObject(node, "Monitor Capture",	s_node_monitor_capture,		"Node_Monitor_Capture",		[1, Node_Monitor_Capture]);
		addNodeObject(node, "GUI In",			s_node_gui_in,				"Node_Application_In",		[1, Node_Application_In]);
		addNodeObject(node, "GUI Out",			s_node_gui_out,				"Node_Application_Out",		[1, Node_Application_Out]);
	#endregion
	
	var actions = ds_list_create();
	addNodeCatagory("Action", actions);
		__initNodeActions(actions);
	
	var customs = ds_list_create();
	addNodeCatagory("Custom", customs);
		__initNodeCustom(customs);
	
	if(IS_PATREON) addNodeCatagory("Extra", SUPPORTER_NODES);
	
	//var vct = ds_list_create();
	//addNodeCatagory("VCT", vct);
	//	addNodeObject(vct, "Biterator",		s_node_print,		"Node_Biterator",		[1, Node_Biterator]);
	
	//////////////////////////////////////////////////////////// PIXEL  BUILDER ////////////////////////////////////////////////////////////
	
	var pb_group = ds_list_create(); #region
	addNodePBCatagory("Group", pb_group); 
		ds_list_add(pb_group, "Groups");
		addNodeObject(pb_group, "Input",		s_node_group_input,		"Node_Group_Input",		[1, Node_Group_Input]).hideRecent();
		addNodeObject(pb_group, "Output",		s_node_group_output,	"Node_Group_Output",	[1, Node_Group_Output]).hideRecent();
	#endregion
	
	var pb_draw = ds_list_create(); #region
	addNodePBCatagory("Draw", pb_draw);
		ds_list_add(pb_draw, "Fill");
		addNodeObject(pb_draw, "Fill",				s_node_pb_draw_fill,	"Node_PB_Draw_Fill",			[1, Node_PB_Draw_Fill]).hideRecent();
			
		ds_list_add(pb_draw, "Shape");
		addNodeObject(pb_draw, "Rectangle",			s_node_pb_draw_rectangle,		"Node_PB_Draw_Rectangle",		[1, Node_PB_Draw_Rectangle]).hideRecent();
		addNodeObject(pb_draw, "Round Rectangle",	s_node_pb_draw_roundrectangle,	"Node_PB_Draw_Round_Rectangle",	[1, Node_PB_Draw_Round_Rectangle]).hideRecent();
		addNodeObject(pb_draw, "Trapezoid",			s_node_pb_draw_trapezoid,		"Node_PB_Draw_Trapezoid",		[1, Node_PB_Draw_Trapezoid]).hideRecent();
		addNodeObject(pb_draw, "Diamond",			s_node_pb_draw_diamond,			"Node_PB_Draw_Diamond",			[1, Node_PB_Draw_Diamond]).hideRecent();
		addNodeObject(pb_draw, "Ellipse",			s_node_pb_draw_ellipse,			"Node_PB_Draw_Ellipse",			[1, Node_PB_Draw_Ellipse]).hideRecent();
		addNodeObject(pb_draw, "Semi-Ellipse",		s_node_pb_draw_semi_ellipse,	"Node_PB_Draw_Semi_Ellipse",	[1, Node_PB_Draw_Semi_Ellipse]).hideRecent();
		addNodeObject(pb_draw, "Line",				s_node_pb_draw_line,			"Node_PB_Draw_Line",			[1, Node_PB_Draw_Line]).hideRecent();
		addNodeObject(pb_draw, "Angle",				s_node_pb_draw_angle,			"Node_PB_Draw_Angle",			[1, Node_PB_Draw_Angle]).hideRecent();
		addNodeObject(pb_draw, "Blob",				s_node_pb_draw_blob,			"Node_PB_Draw_Blob",			[1, Node_PB_Draw_Blob]).hideRecent();
	#endregion
	
	var pb_box = ds_list_create(); #region
	addNodePBCatagory("Box", pb_box);
		ds_list_add(pb_box, "Layer");
		addNodeObject(pb_box, "Layer",		s_node_pb_layer,	"Node_PB_Layer",		[1, Node_PB_Layer]).hideRecent();
			
		ds_list_add(pb_box, "Box");
		addNodeObject(pb_box, "Transform",		s_node_pb_box_transform,	"Node_PB_Box_Transform",	[1, Node_PB_Box_Transform]).hideRecent();
		addNodeObject(pb_box, "Mirror",			s_node_pb_box_mirror,		"Node_PB_Box_Mirror",		[1, Node_PB_Box_Mirror]).hideRecent();
		addNodeObject(pb_box, "Inset",			s_node_pb_box_inset,		"Node_PB_Box_Inset",		[1, Node_PB_Box_Inset]).hideRecent();
		addNodeObject(pb_box, "Split",			s_node_pb_box_split,		"Node_PB_Box_Split",		[1, Node_PB_Box_Split]).hideRecent();
		addNodeObject(pb_box, "Divide",			s_node_pb_box_divide,		"Node_PB_Box_Divide",		[1, Node_PB_Box_Divide]).hideRecent();
		addNodeObject(pb_box, "Divide Grid",	s_node_pb_box_divide_grid,	"Node_PB_Box_Divide_Grid",	[1, Node_PB_Box_Divide_Grid]).hideRecent();
		addNodeObject(pb_box, "Contract",		s_node_pb_box_contract,		"Node_PB_Box_Contract",		[1, Node_PB_Box_Contract]).hideRecent();
	#endregion
	
	var pb_fx = ds_list_create(); #region
	addNodePBCatagory("Effects", pb_fx);
		ds_list_add(pb_fx, "Effect");
		addNodeObject(pb_fx, "Outline",			s_node_pb_fx_outline,	"Node_PB_Fx_Outline",		[1, Node_PB_Fx_Outline]).hideRecent();
		addNodeObject(pb_fx, "Stack",			s_node_pb_fx_stack,		"Node_PB_Fx_Stack",			[1, Node_PB_Fx_Stack]).hideRecent();
		addNodeObject(pb_fx, "Radial",			s_node_pb_fx_radial,	"Node_PB_Fx_Radial",		[1, Node_PB_Fx_Radial]).hideRecent();
			
		ds_list_add(pb_fx, "Lighting");
		addNodeObject(pb_fx, "Highlight",		s_node_pb_fx_highlight,	"Node_PB_Fx_Highlight",		[1, Node_PB_Fx_Highlight]).hideRecent();
		addNodeObject(pb_fx, "Shading",			s_node_pb_fx_shading,	"Node_PB_Fx_Shading",		[1, Node_PB_Fx_Shading]).hideRecent();
			
		ds_list_add(pb_fx, "Texture");
		addNodeObject(pb_fx, "Hashing",			s_node_pb_fx_hash,		"Node_PB_Fx_Hash",			[1, Node_PB_Fx_Hash]).hideRecent();
		addNodeObject(pb_fx, "Strip",			s_node_pb_fx_strip,		"Node_PB_Fx_Strip",			[1, Node_PB_Fx_Strip]).hideRecent();
		addNodeObject(pb_fx, "Brick",			s_node_pb_fx_brick,		"Node_PB_Fx_Brick",			[1, Node_PB_Fx_Brick]).hideRecent();
			
		ds_list_add(pb_fx, "Blend");
		addNodeObject(pb_fx, "Add",				s_node_pb_fx_add,		"Node_PB_Fx_Add",			[1, Node_PB_Fx_Add]).hideRecent();
		addNodeObject(pb_fx, "Subtract",		s_node_pb_fx_subtract,	"Node_PB_Fx_Subtract",		[1, Node_PB_Fx_Subtract]).hideRecent();
		addNodeObject(pb_fx, "Intersect",		s_node_pb_fx_interesct,	"Node_PB_Fx_Intersect",		[1, Node_PB_Fx_Intersect]).hideRecent();
	#endregion
	
	var pb_arr = ds_list_create(); #region
	addNodePBCatagory("Array", pb_arr);
		addNodeObject(pb_arr, "Array",			s_node_array,			"Node_Array",			[1, Node_Array]).hideRecent();
		addNodeObject(pb_arr, "Array Get",		s_node_array_get,		"Node_Array_Get",		[1, Node_Array_Get], ["get array"]).hideRecent();
		addNodeObject(pb_arr, "Array Set",		s_node_array_set,		"Node_Array_Set",		[1, Node_Array_Set], ["set array"]).hideRecent().setVersion(1120);
		addNodeObject(pb_arr, "Array Insert",	s_node_array_insert,	"Node_Array_Insert",	[1, Node_Array_Insert], ["insert array"]).hideRecent().setVersion(1120);
		addNodeObject(pb_arr, "Array Remove",	s_node_array_remove,	"Node_Array_Remove",	[1, Node_Array_Remove], ["remove array", "delete array", "array delete"]).hideRecent().setVersion(1120);
	#endregion
	
	/////////////////////////////////////////////////////////////// PCX NODE ///////////////////////////////////////////////////////////////
	
	var pcx_var = ds_list_create(); #region
	addNodePCXCatagory("Variable", pcx_var);
		addNodeObject(pcx_var, "Variable",		s_node_array,	"Node_PCX_var",		[1, Node_PCX_var]).hideRecent();
		addNodeObject(pcx_var, "Fn Variable",	s_node_array,	"Node_PCX_fn_var",	[1, Node_PCX_fn_var]).hideRecent();
	#endregion
	
	var pcx_fn = ds_list_create(); #region
	addNodePCXCatagory("Functions", pcx_fn);
		addNodeObject(pcx_fn, "Equation",	s_node_array,	"Node_PCX_Equation",		[1, Node_PCX_Equation]).hideRecent();
			
		ds_list_add(pcx_fn, "Numbers");
		addNodeObject(pcx_fn, "Math",		s_node_array,	"Node_PCX_fn_Math",		[1, Node_PCX_fn_Math]).hideRecent();
		addNodeObject(pcx_fn, "Random",		s_node_array,	"Node_PCX_fn_Random",	[1, Node_PCX_fn_Random]).hideRecent();
			
		ds_list_add(pcx_fn, "Surface");
		addNodeObject(pcx_fn, "Surface Width",		s_node_array,	"Node_PCX_fn_Surface_Width",	[1, Node_PCX_fn_Surface_Width]).hideRecent();
		addNodeObject(pcx_fn, "Surface Height",		s_node_array,	"Node_PCX_fn_Surface_Height",	[1, Node_PCX_fn_Surface_Height]).hideRecent();
			
		ds_list_add(pcx_fn, "Array");
		addNodeObject(pcx_fn, "Array Get",		s_node_array,	"Node_PCX_Array_Get",		[1, Node_PCX_Array_Get]).hideRecent();
		addNodeObject(pcx_fn, "Array Set",		s_node_array,	"Node_PCX_Array_Set",		[1, Node_PCX_Array_Set]).hideRecent();
	#endregion
	
	var pcx_flow = ds_list_create(); #region
	addNodePCXCatagory("Flow Control", pcx_flow);
		addNodeObject(pcx_flow, "Condition",		s_node_array,	"Node_PCX_Condition",		[1, Node_PCX_Condition]).hideRecent();
	#endregion
	
	//////////////////////////////////////////////////////////////// HIDDEN ////////////////////////////////////////////////////////////////
	
	var hid = ds_list_create(); #region
	addNodeCatagory("Hidden", hid, ["Hidden"]);
		addNodeObject(hid, "Input",				s_node_loop_input,		"Node_Iterator_Each_Input",		[1, Node_Iterator_Each_Input]).hideRecent();
		addNodeObject(hid, "Output",			s_node_loop_output,		"Node_Iterator_Each_Output",	[1, Node_Iterator_Each_Output]).hideRecent();
		addNodeObject(hid, "Input",				s_node_loop_input,		"Node_Iterator_Filter_Input",	[1, Node_Iterator_Filter_Input]).hideRecent();
		addNodeObject(hid, "Output",			s_node_loop_output,		"Node_Iterator_Filter_Output",	[1, Node_Iterator_Filter_Output]).hideRecent();
		addNodeObject(hid, "Grid Noise",		s_node_grid_noise,		"Node_Grid_Noise",				[1, Node_Grid_Noise]).hideRecent();
		addNodeObject(hid, "Triangular Noise",	s_node_grid_tri_noise,	"Node_Noise_Tri",				[1, Node_Noise_Tri]).hideRecent().setVersion(1090);
		addNodeObject(hid, "Hexagonal Noise",	s_node_grid_hex_noise,	"Node_Noise_Hex",				[1, Node_Noise_Hex]).hideRecent().setVersion(1090);
		addNodeObject(hid, "Sort Input",		s_node_grid_hex_noise,	"Node_Iterator_Sort_Input",		[1, Node_Iterator_Sort_Input]).hideRecent();
		addNodeObject(hid, "Sort Output",		s_node_grid_hex_noise,	"Node_Iterator_Sort_Output",	[1, Node_Iterator_Sort_Output]).hideRecent();
		addNodeObject(hid, "Onion Skin",		s_node_cache,			"Node_Onion_Skin",				[1, Node_Onion_Skin]).setVersion(1147).hideRecent();
		addNodeObject(hid, "RigidSim",			s_node_rigidSim,		"Node_Rigid_Group",				[1, Node_Rigid_Group],, "Create group for rigidbody simulation.").setVersion(1110).hideRecent();
		addNodeObject(hid, "RigidSim Global",	s_node_rigidSim_global,	"Node_Rigid_Global",			[1, Node_Rigid_Global]).setVersion(1110).hideRecent();
		addNodeObject(hid, "SmokeSim",			s_node_smokeSim_group,	"Node_Fluid_Group",				[1, Node_Fluid_Group],, "Create group for fluid simulation.").setVersion(1120).hideRecent();
		addNodeObject(hid, "StrandSim",			s_node_strandSim,		"Node_Strand_Group",			[1, Node_Strand_Group], ["Hair"], "Create group for hair simulation.").setVersion(1140).hideRecent();
		addNodeObject(hid, "Feedback",			s_node_feedback,		"Node_Feedback_Inline",			[1, Node_Feedback_Inline]).hideRecent();
		addNodeObject(hid, "Loop",				s_node_loop,			"Node_Iterate_Inline",			[1, Node_Iterate_Inline]).hideRecent();
		addNodeObject(hid, "VFX",				s_node_vfx,				"Node_VFX_Group",				[1, Node_VFX_Group]).hideRecent();
		
		addNodeObject(hid, "Loop Array",		s_node_loop_array,		"Node_Iterate_Each",					[1, Node_Iterate_Each]).hideRecent();
		addNodeObject(hid, "Loop Input",		s_node_loop_array,		"Node_Iterator_Each_Inline_Input",		[1, Node_Iterator_Each_Inline_Input]).hideRecent();
		addNodeObject(hid, "Loop Output",		s_node_loop_array,		"Node_Iterator_Each_Inline_Output",		[1, Node_Iterator_Each_Inline_Output]).hideRecent();
		addNodeObject(hid, "Filter Array",		s_node_filter_array,	"Node_Iterate_Filter",					[1, Node_Iterate_Filter],, "Filter array using condition.").hideRecent();
		addNodeObject(hid, "Filter Input",		s_node_filter_array,	"Node_Iterator_Filter_Inline_Input",	[1, Node_Iterator_Filter_Inline_Input]).hideRecent();
		addNodeObject(hid, "Filter Output",		s_node_filter_array,	"Node_Iterator_Filter_Inline_Output",	[1, Node_Iterator_Filter_Inline_Output]).hideRecent();
		addNodeObject(hid, "Sort Array",		s_node_sort_array,		"Node_Iterate_Sort",					[1, Node_Iterate_Sort],, "Sort array using node graph.").hideRecent();
		addNodeObject(hid, "Sort Input",		s_node_sort_array,		"Node_Iterator_Sort_Inline_Input",		[1, Node_Iterator_Sort_Inline_Input]).hideRecent();
		addNodeObject(hid, "Sort Output",		s_node_sort_array,		"Node_Iterator_Sort_Inline_Output",		[1, Node_Iterator_Sort_Inline_Output]).hideRecent();
		
		ds_list_add(hid, "DynaSurf");
		addNodeObject(hid, "Input",		s_node_pixel_builder,	"Node_DynaSurf_In",			[1, Node_DynaSurf_In]).hideRecent();
		addNodeObject(hid, "Output",	s_node_pixel_builder,	"Node_DynaSurf_Out",		[1, Node_DynaSurf_Out]).hideRecent();
		addNodeObject(hid, "getWidth",	s_node_pixel_builder,	"Node_DynaSurf_Out_Width",	[1, Node_DynaSurf_Out_Width]).hideRecent();
		addNodeObject(hid, "getHeight",	s_node_pixel_builder,	"Node_DynaSurf_Out_Height",	[1, Node_DynaSurf_Out_Height]).hideRecent();
	#endregion
}
