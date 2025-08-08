function Node_Canvas_Group(_x, _y, _group) : Node_Collection(_x, _y, _group) constructor {
	name  = "Canvas Group";
	color = COLORS.node_blend_canvas;
	icon  = THEME.icon_canvas;
	
	timeline_item_group = new timelineItemGroup_Canvas(self);
	PROJECT.timelines.addItem(timeline_item_group);
	
	modifiable = false;
	
	newInput( 0, nodeValue_Dimension());
	
	custom_input_index = array_length(inputs);
	
	attributes.show_slope_check = true;
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, [ "Draw Guide", function() /*=>*/ {return attributes.show_slope_check}, new checkBox(function() /*=>*/ {return toggleAttribute("show_slope_check")}) ]);
	
	#region layers 
		layers     = {};
		canvases   = [];
		composite  = noone;
		canvas_sel = noone;
		
		frame_renderer_x     = 0;
		frame_renderer_x_to  = 0;
		frame_renderer_x_max = 0;
		
		b_layer_add = button(function() /*=>*/ {return layerAdd()}).setIcon(THEME.add_16, 0, COLORS._main_value_positive);
		
		layer_height = 0;
		layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
			var _h  = ui(4);
			if(composite == noone) return _h;
			
			composite.canvas_draw = self;
			var _layer_ren = composite.layer_renderer;
		    _layer_ren.register(layer_renderer.parent);
		    _layer_ren.rx = layer_renderer.rx;
		    _layer_ren.ry = layer_renderer.ry;
			
			var _yy = _y + _h;
			var _wdh = _layer_ren.draw(_x, _yy, _w, _m, _hover, _focus);
			if(!is_undefined(_wdh)) _h += _wdh;
			
			return _h;
		});
		
		frame_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel) {
			var _h  = 0;
			var _yy = _y;
			
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, frame_renderer.h, COLORS.node_composite_bg_blend, 1);
			var _cnt_hover = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + frame_renderer.h);
			
			frame_renderer_x_max = 0;
			
			for (var i = array_length(canvases) - 1; i >= 0; i--) {
				var _canvas = canvases[i];
				
				var _frame_render = _canvas.frame_renderer;
			    _frame_render.register(frame_renderer.parent);
			    _frame_render.rx = frame_renderer.rx;
			    _frame_render.ry = frame_renderer.ry;
			    
			    var _wdh = _frame_render.draw(_x, _yy, _w, _m, _hover, _focus, _panel, false, frame_renderer_x);
				if(is_undefined(_wdh)) continue;
				
				frame_renderer_x_max = max(frame_renderer_x_max, _frame_render.node.frame_renderer_x_max);
				_h  += _wdh - ui(2);
				_yy += _wdh - ui(2);
			}
			_h += ui(2);
			
			frame_renderer_x = lerp_float(frame_renderer_x, frame_renderer_x_to, 3);
			
			if(_cnt_hover && MOUSE_WHEEL != 0)
				frame_renderer_x_to = clamp(frame_renderer_x_to - 80 * MOUSE_WHEEL, 0, frame_renderer_x_max);
			
			frame_renderer.h = _h;
			return _h;
		});
		
		group_input_display_list = [ 0, 
			["Layers", false, noone, b_layer_add], layer_renderer, 
			["Frames",  true], frame_renderer, 
			["Inputs", false], 
		];
	#endregion
		
	////- Layers
	
	static refreshNodes = function() {
		canvases  = [];
		composite = noone;
		
		for (var i = 0, n = array_length(nodes); i < n; i++) {
			var _node = nodes[i];
			
			if(is_instanceof(_node, Node_Canvas))
				array_push(canvases, _node);
			else if(is_instanceof(_node, Node_Composite))
				composite = _node;
		}
		
		refreshLayer();
	}
	
	static refreshLayer = function() {
		layers = {};
		if(composite == noone) return;
		
		var _amo = composite.getInputAmount();
		for(var i = 0; i < _amo; i++) {
			var index = composite.input_fix_len + i * composite.data_length;
			
			var _can = composite.inputs[index].value_from;
			if(_can == noone) continue;
			
			var _nod = _can.node;
			var _lay = _can.node;
			var _modStack = [ _nod ];
			
			while(!is_instanceof(_nod, Node_Canvas)) {
				if(_nod.inputs[0].type != VALUE_TYPE.surface) 
					break;
				if(_nod.inputs[0].value_from == noone) 
					break;
				
				_nod = _nod.inputs[0].value_from.node;
				array_push(_modStack, _nod);
			}
			
			if(!is_instanceof(_nod, Node_Canvas)) continue;
			array_pop(_modStack);
			
			layers[$ _lay.node_id] = {
				input    : _lay,
				canvas   : _nod,
				modifier : _modStack,
			};
		}
		
	}
	
	static onAdd = function(node) {
	    if(is_instanceof(node, Node_Canvas))    {
     		array_push(canvases, node);
     		node.timeline_item.removeSelf();
			timeline_item_group.addItem(node.timeline_item);
		
		} else if(is_instanceof(node, Node_Composite)) {
			composite = node;
			composite.canvas_group = self;
		}
		
		refreshLayer();
		onLayerChanged();
	}
	
	static layerAdd = function() {
		var _l = undefined;
		var _b = undefined;
		
		if(array_empty(nodes)) {
			_l = x;
			_b = y;
		} 
		
		for (var i = 0, n = array_length(nodes); i < n; i++) {
			var _node = nodes[i];
			
			_l = _l == undefined? _node.x : min(_l, _node.x);
			_b = _b == undefined? _node.y + _node.h : max(_b, _node.y + _node.h);
		}
		
		_b += 32;
		var _canvas = nodeBuild("Node_Canvas", _l, _b);
		_canvas.setDisplayName($"Layer {array_length(canvases)}", false);
		_canvas.inputs[12].setValue(true);
		
		composite.dummy_input.setFrom(_canvas.outputs[0]);
		
		add(_canvas);
		return _canvas;
	}
	
	static deleteLayer = function(index) {
		if(composite == noone) return;
		
		var idx = composite.input_fix_len + index * composite.data_length;
		var inp = composite.inputs[idx];
		var nod = inp.value_from? inp.value_from.node : noone;
		if(!nod) return;
		
		nod.destroy();
		onLayerChanged();
	}
	
	static onLayerChanged = function() {
		if(composite == noone) return;
		
		var imageAmo   = composite.getInputAmount();
		var _canvas_tm = [];
		var _grp_cont  = timeline_item_group.contents;
		
		for(var i = 0; i < imageAmo; i++) {
			var _ind  = composite.input_fix_len + i * composite.data_length;
			var _inp  = composite.inputs[_ind];
			var _junc = _inp.value_from? _inp.value_from.node : noone;
			
			if(_junc == noone) continue;
			if(!struct_has(layers, _junc.node_id)) continue;
			
			var _jun_layer   = layers[$ _junc.node_id];
			var _junc_canvas = _jun_layer.canvas;
			
			array_remove(_grp_cont,    _junc_canvas.timeline_item);
			array_insert(_grp_cont, 0, _junc_canvas.timeline_item);
		}
	}
	
	if(NODE_NEW_MANUAL) {
		var _canvas  = nodeBuild("Node_Canvas", x - 160, y);
		_canvas.inputs[12].setValue(true);
		_canvas.setDisplayName($"Background", false);
		
		var _compose = nodeBuild("Node_Composite", x, y);
		_compose.dummy_input.setFrom(_canvas.outputs[0]);
		_compose.dynamic_input_inspecting = 0;
		
		add(_canvas);
		add(_compose);
		
		var _output = nodeBuild("Node_Group_Output", x + 160, y, self);
		_output.inputs[0].setFrom(_compose.outputs[0]);
	}
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		if(composite != noone) {
			var _outSurf = composite.outputs[0].getValue();
			draw_surface_ext_safe(_outSurf, _x, _y, _s, _s);
		}
		
		if(canvas_sel) return canvas_sel.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
		return false;
	}
	
	static drawTools = function(_mx, _my, xx, yy, tool_size, hover, focus) {
		if(canvas_sel) return canvas_sel.drawTools(_mx, _my, xx, yy, tool_size, hover, focus);
		return 0;
	}
	
	////- Update
	
	static step = function() {
		tools      = -1;
		rightTools = -1;
		canvas_sel = noone;
		
		if(composite == noone) return;
		
		if(composite.getInputAmount()) {
			var _ind = composite.dynamic_input_inspecting;
			
			if(_ind != noone) {
			    _ind = composite.input_fix_len + _ind * composite.data_length;
				
				var _inp = composite.inputs[_ind];
				var _can = _inp? _inp.value_from : noone;
				if(_can && has(layers, _can.node.node_id))
					canvas_sel = layers[$ _can.node.node_id].canvas;
			}
		}
		
		if(canvas_sel) {
			tools      = canvas_sel.tools;
			rightTools = canvas_sel.rightTools;
		}
		
		if(timeline_item_group) {
			timeline_item_group.name  = getDisplayName();
			timeline_item_group.color = getColor();
		}
		
		for (var i = 0, n = array_length(canvases); i < n; i++)
			canvases[i].attributes.show_slope_check = attributes.show_slope_check;
	}
	
	static update = function() {
		refreshLayer();
		
		var _dim = getInputData(0);
		
		for (var i = 0, n = array_length(canvases); i < n; i++)
			canvases[i].inputs[0].setValue(_dim);
	}
	
	static getPreviewValues = function() { 
		if(canvas_sel != noone) return canvas_sel.getPreviewValues(); 
		if(composite != noone)  return composite.getPreviewValues();
		
		return noone;
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {return getPreviewValues()};
	
	////- Serialize
	
	static postDeserialize = function() {
		refreshNodes();
	}
	
	////- Actions
	
	static dropPath = function(path) {
		if(canvas_sel) canvas_sel.dropPath(path);
	}
		
	sortIO();
}

function timelineItemGroup_Canvas(node = noone) : timelineItemGroup() constructor {
	self.node = node;
	
	static onSerialize = function(_map) {
		_map.node_id = is_struct(node)? node.node_id : -4;
	}
	
	static onDeserialize = function(_map) {
		var _node_id = _map.node_id;
		
		if(ds_map_exists(PROJECT.nodeMap, _node_id)) {
			node = PROJECT.nodeMap[? _node_id];
			node.timeline_item_group = self;
		}
	}
}
