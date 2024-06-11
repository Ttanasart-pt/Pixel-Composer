function Node_Canvas_Group(_x, _y, _group) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "Canvas Group";
	color = COLORS.node_blend_canvas;
	
	modifiable = false;
	
	inputs[|  0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	canvases   = [];
	composite  = noone;
	canvas_sel = noone;
	
	layer_height = 0;
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h  = ui(4);
		var _yy = _y;
		
		if(composite == noone) return _h;
		
		composite.canvas_draw = true;
		var _layer_ren = composite.layer_renderer;
	    _layer_ren.register(layer_renderer.parent);
	    _layer_ren.rx = layer_renderer.rx;
	    _layer_ren.ry = layer_renderer.ry;
		
		var bx = _x;
		var by = _y;
		var bs = ui(24);
		if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) 
			layerAdd();
			
		_h  += ui(32);
		_yy += ui(32);
		
		var _wdh = _layer_ren.draw(_x, _yy, _w, _m, _hover, _focus);
		if(!is_undefined(_wdh)) _h += _wdh;
		
		return _h;
	});
	
	input_display_list = [ 0, 
		["Layers", false], layer_renderer, 
	];
	
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
	}
	
	static onAddNode = function(node) { 
		node.modifiable    = false;
		node.modify_parent = self;
		refreshNodes(); 
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
		composite.dummy_input.setFrom(_canvas.outputs[| 0]);
		
		addNode(_canvas);
		return _canvas;
	}
	
	if(NODE_NEW_MANUAL) {
		var _canvas  = nodeBuild("Node_Canvas",    x,       y);
		var _compose = nodeBuild("Node_Composite", x + 160, y);
		
		_compose.dummy_input.setFrom(_canvas.outputs[| 0]);
		
		addNode(_canvas);
		addNode(_compose);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(canvas_sel) canvas_sel.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static step = function() {
		tools         = -1;
		tool_settings = [];
		rightTools    = -1;
		drawTools     = -1;
		
		canvas_sel = noone;
		
		if(composite == noone) return;
		
		if(composite.getInputAmount()) {
			var _ind = composite.surface_selecting;
			if(_ind == noone) 
				_ind = composite.input_fix_len;
			
			var _can = composite.inputs[| _ind].value_from;
			
			if(_can) {
				var _nod   = _can.node;
				canvas_sel = _nod;
			}
		}
		
		if(canvas_sel) {
			tools         = canvas_sel.tools;
			tool_settings = canvas_sel.tool_settings;
			rightTools    = canvas_sel.rightTools;
			drawTools     = canvas_sel.drawTools;
		}
	}
	
	static getPreviewValues = function() { return composite == noone? noone : composite.getPreviewValues(); }
	
	static postDeserialize = function() {
		refreshMember();
		refreshNodes();
	}
}