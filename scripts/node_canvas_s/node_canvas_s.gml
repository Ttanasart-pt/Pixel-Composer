#region global
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Canvas_S", "Pencil", "B");
		hotkeyCustom("Node_Canvas_S", "Eraser", "E");
	});
	
	globalvar CANVAS_PANEL_LAYOUT; CANVAS_PANEL_LAYOUT = {
        content: [
        	{ 
	            content: "Panel_Canvas_Tool_Settings"
	        }, 
	        {
	        	content: [
	        		{
	        			content: "Panel_Canvas_Tool"
	        		},
	        		{
	        			content: [
	        				{
					            content: "Panel_Canvas",
					            main: true, 
	        				},
	        				{
	        					// content: "Panel_Canvas_Color"
			        			content: [
			        				{ content: "Panel_Canvas_Palette" },
			        				{ content: "Panel_Canvas_Color"   }
		        				],
					    		split: "v",
				        		width: -240
			        		}
        				],
				        split: "h",
				        width: -200
			        }
	    		],
	    		split: "h",
        		width: 40
	        }
        ],
        split: "v",
        width: 40,
        
        main: "Panel_Canvas",
        pref_w: 1200,
        pref_h: 800,
        
	}
#endregion 

function Node_Canvas_S(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Canvas";
	color = COLORS.node_blend_canvas;
	preview_select_surface = false;
	preview_select_boxable = false;
	
	////- =Surface
	newInput( 0, nodeValue_Vec2("Dimension", DEF_SURF)).setAnimable(false);
	// newInput( 0, nodeValue_Dimension()).setAnimable(false);
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",    false ], 0, 
		[ "Resources", false ], 
	]
	
	input_display_dynamic = [ 0 ];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		newInput(index, nodeValue_Surface("Resource")).setVisible(true, true);
		
		refreshDynamicDisplay();
		postCreateNewInput(index);
		return inputs[index];
	} 
	
	setDynamicInput(1);
	
	////- Node
	
	attributes.dimension  = [0,0];
	
	pixel_data  = undefined;
	editorPanel = undefined;
	resources   = [];
	
	static refreshNodes = function() /*=>*/ {};
	static getNodeList  = function() /*=>*/ {return []};
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _dim = getInputData( 0);
			resources = [];
		#endregion
		
		var amo = getInputAmount();
		for( var i = 0; i < amo; i++ ) {
			var _ind = input_fix_len + i;
			resources[i] = getInputData(_ind);
		}
		
		var _outSurf = outputs[0].getValue();
		
		if(!buffer_exists(pixel_data))
			pixel_data = buffer_create(_dim[0] * _dim[1] * 4, buffer_grow, 1); 
		
		if(attributes.dimension[0] != _dim[0] || attributes.dimension[1] != _dim[1]) {
			var newPxd = buffer_create(_dim[0] * _dim[1] * 4, buffer_grow, 1); 
			
			buffer_to_start(pixel_data);
			buffer_to_start(newPxd);
			
			for( var i = 0; i < _dim[1]; i++ ) 
			for( var j = 0; j < _dim[0]; j++ ) {
				var val = 0;
				if(i < attributes.dimension[1] && j < attributes.dimension[0])
					val = buffer_read(pixel_data, buffer_u32);
				
				buffer_write(newPxd, buffer_u32, val);
			}
			
			pixel_data = newPxd;
			attributes.dimension[0] = _dim[0];
			attributes.dimension[1] = _dim[1];
		}
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		buffer_set_surface(pixel_data, _outSurf, 0);
		
		outputs[0].setValue(_outSurf);
	}
	
	function onDoubleClick(panel) {
		NewCanvasPanel(self);
	}
	
	////- Actions
	
	static setSurface = function(_surf, _free = false) {
		if(!is_just_surface(_surf)) return self;
		
		var _sw = surface_get_width(_surf);
		var _sh = surface_get_height(_surf);
		
		attributes.dimension = [_sw, _sh];
		inputs[0].setValue([_sw, _sh]);
		
		var buff = buffer_create(1, buffer_grow, 1);
		buffer_get_surface(buff, _surf, 0);
		pixel_data = buff;
		triggerRender();
		if(_free) surface_free(_surf);
		
		return self;
	}
	
	on_drop_file = function(path) { loadImagePath(path); return true; }
	static loadImagePath = function(path) {
		if(!file_exists_empty(path)) return noone;
		
		var _spr = sprite_add(sprite_path_check_format(path), 0, 0, 0, 0, 0);
		if(_spr == -1) return noone;
		
		var _sw = sprite_get_width(_spr);
		var _sh = sprite_get_height(_spr);
		var _s  = surface_create(_sw, _sh);
		
		surface_set_shader(_s, noone)
			draw_sprite(_spr, 0, 0, 0);
		surface_reset_shader();
		sprite_delete(_spr);
		setSurface(_s, true);
		
		return self;
	} 
	
	////- Serialize
	
	static attributeSerialize = function() {
		_map = { pixel_data: buffer_serialize(pixel_data) }
		return _map;
	}
	
	static doAttributeDeserialize = function(_attr) {
		if(has(_attr, "pixel_data"))
			pixel_data = buffer_deserialize(_attr.pixel_data);
	}
	
	static postDeserialize = function() {
		if(CLONING) return;
		
		if(LOADING_VERSION < 1_21_09_2) {
			var _inp = load_map.inputs[0];
			if(_inp.attri.use_project_dimension) {
				var _rel = _inp.r.d;
				_inp.r.d[0] *= DEF_SURF_W;
				_inp.r.d[1] *= DEF_SURF_H;
			}
		}
	}
	
}