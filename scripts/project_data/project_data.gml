#region global
	globalvar PROJECTS, PROJECT;
#endregion

#region project
	function Project() constructor {
		active	= true; /// @is {bool}
		
		meta      = __getdefaultMetaData();	
		path	  = ""; /// @is {string}								
		thumbnail = "";													
		version   = SAVE_VERSION; /// @is {number}						
		seed      = irandom_range(100000, 999999); /// @is {number}		
		
		modified = false; /// @is {bool}
		readonly = false; /// @is {bool} 
		safeMode = false;
		
		nodes	    = ds_list_create();
		nodeArray   = [];
		nodeMap	    = ds_map_create();
		nodeNameMap = ds_map_create();
		nodeTopo    = ds_list_create();
		
		animator	   = new AnimationManager();
		globalNode	   = new Node_Global();
		nodeController = new __Node_Controller(self);
		
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
		
		#region =================== ATTRIBUTES ===================
			attributes = {
				surface_dimension : [ 32, 32 ],
				palette           : [ cola(c_black), cola(c_white) ],
				palette_fix       : false,
			}
			
			var _bpal = new buttonPalette(function(pal) { setPalette(pal); RENDER_ALL return true; });
			
			//_bpal.side_button = button(function() { attributes.palette_fix = !attributes.palette_fix; RENDER_ALL return true; })
			//	.setIcon( THEME.project_fix_palette, [ function() { return attributes.palette_fix; } ], COLORS._main_icon )
			//	.setTooltip("Fix palette");
			
			attributeEditor = [
				[ "Default Surface",	"surface_dimension", new vectorBox(2, function(ind, val) { attributes.surface_dimension[ind] = val; RENDER_ALL return true; }) ],
				[ "Palette",			"palette",			 _bpal ],
			];
			
			static setPalette = function(pal = noone) { 
				if(pal != noone) attributes.palette = pal; 
				palettes = paletteToArray(attributes.palette); 
			} setPalette();
		#endregion
		
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