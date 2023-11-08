#region global
	globalvar PROJECTS, PROJECT;
#endregion

#region project
	function Project() constructor {
		active	= true; /// @is {bool}
		
		path	= ""; /// @is {string}
		version = SAVE_VERSION; /// @is {number}
		seed    = irandom_range(100000, 999999); /// @is {number}
		
		modified = false; /// @is {bool}
		readonly = false; /// @is {bool} 
		safeMode = false;
		
		nodes	    = ds_list_create();
		nodeArray   = [];
		nodeMap	    = ds_map_create();
		nodeNameMap = ds_map_create();
		nodeTopo    = ds_list_create();
		
		animator	= new AnimationManager();
		
		globalNode	= new Node_Global();
		
		previewGrid = { #region
			show	: false,
			snap	: false,
			size	: [ 16, 16 ],
			opacity : 0.5,
			color   : COLORS.panel_preview_grid,
		} #endregion
		
		graphGrid = { #region
			show	: true,
			show_origin : false,
			snap	: true,
			size	: 16,
			opacity : 0.05,
			color   : c_white,
			highlight : 12,
		} #endregion
		
		addons = {};
		
		onion_skin = { #region
			enabled: false,
			range: [ -1, 1 ],
			step: 1,
			color: [ c_red, c_blue ],
			alpha: 0.5,
			on_top: true,
		}; #endregion
		
		attributes = { #region
			surface_dimension: [ 32, 32 ],
			palette: [ c_black, c_white ]
		} #endregion
		
		attributeEditor = [ #region
			[ "Default Surface",	"surface_dimension", new vectorBox(2, function(ind, val) { attributes.surface_dimension[ind] = val; return true; }) ],
			[ "Palette",			"palette",			 new buttonPalette(function(pal) { attributes.palette = pal; return true; }) ],
		]; #endregion
		
		timelines = new timelineItemGroup();
		
		notes = [];
		
		static cleanup = function() { #region
			if(!ds_map_empty(nodeMap))
				array_map(ds_map_keys_to_array(nodeMap), function(_key, _ind) { 
					var _node = nodeMap[? _key];
					_node.active = false; 
					_node.cleanUp(); 
				});
			
			ds_list_destroy(nodes);
			ds_map_destroy(nodeMap);
			ds_map_destroy(nodeNameMap);
			
			gc_collect();
		} #endregion
	}
	
	function __initProject() {
		PROJECT  = new Project();
		PROJECTS = [ PROJECT ];
	}
#endregion