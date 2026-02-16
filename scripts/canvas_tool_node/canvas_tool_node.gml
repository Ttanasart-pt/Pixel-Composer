function canvas_tool_node(_canvas, _node) : canvas_tool() constructor {
	
	canvas   = _canvas;
	node     = _node;
	override = true;
	panel    = noone;
	
	applySelection = false;
	sourceSurface  = noone;
	
	targetSurface  = noone;
	maskedSurface  = noone;
	sw = 0;
	sh = 0;
	
	nodeObject     = noone;
	inputSurface   = noone;
	inputDimension = noone;
	outputJunction = noone;
	setColor       = true;

	static destroy = function() {
		if(applySelection) canvas.selection.apply();
		cleanUp();
	}
	
	static cleanUp = function() {
		UNDO_HOLDING = true;
		surface_free_safe(targetSurface);
		surface_free_safe(maskedSurface);
		
		if(is_struct(nodeObject)) {
			if(is(nodeObject, Node))
				nodeObject.destroy();
			
			else {
				var keys = struct_get_names(nodeObject);
				for (var i = 0, n = array_length(keys); i < n; i++) 
					if(is(nodeObject[$ keys[i]], Node))
						nodeObject[$ keys[i]].destroy();
			}
		}
		
		if(panel && instance_exists(panel)) panel.remove();
		node.nodeTool = noone;
		UNDO_HOLDING = false;
	}
	
	static init = function() {
		
		applySelection = canvas.selection.is_selected;
		sourceSurface  = applySelection? canvas.selection.selection_surface : canvas.getCanvasSurface();
		if(!is_surface(sourceSurface)) return noone;
		
		sw = surface_get_width(sourceSurface);
		sh = surface_get_height(sourceSurface);
		targetSurface = surface_create(sw, sh);
		maskedSurface = surface_create(sw, sh);
		
		surface_set_shader(targetSurface, noone);
			draw_surface_safe(sourceSurface);
		surface_reset_shader();
		
		nodeObject = node.build(0, 0, canvas);
		
		if(nodeObject == noone || !is(nodeObject, Node)) { noti_warning("Tools only supports single node operation."); destroy(); return noone; }
		
		for( var i = 0, n = array_length(nodeObject.inputs); i < n; i++ ) {
			var _in = nodeObject.inputs[i];
			
			if(inputSurface   == noone && _in.type == VALUE_TYPE.surface) inputSurface = _in;
			if(inputDimension == noone && _in.name == "Dimension")      inputDimension = _in;
				
			if(_in.type == VALUE_TYPE.color && setColor) {
				_in.setValue(CURRENT_COLOR);
				setColor = false;
			}
			
		}
		
		for( var i = 0, n = array_length(nodeObject.outputs); i < n; i++ ) {
			var _in = nodeObject.outputs[i];
			if(_in.type == VALUE_TYPE.surface) {
				outputJunction = _in;
				break;
			}
		}
		
		if(outputJunction == noone) { noti_warning("Selected node has no surface output."); destroy(); return noone; }
		
		panel = New_Inspect_Node_Panel(nodeObject);
		panel.content.title_actions = [
			[ "Apply",  [ THEME.toolbar_check, 0, c_white ], function() /*=>*/ {return apply()}  ], 
			[ "Cancel", [ THEME.toolbar_check, 1, c_white ], function() /*=>*/ {return cancel()} ], 
		];
		
		return self;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	static apply = function(_repl = true) {
		var _surf = surface_create(sw, sh);
		
		if(applySelection) {
			var _fore = canvas.selection.selection_surface;
			
			if(_repl) {
				surface_set_shader(_surf, noone);
					draw_surface_safe(maskedSurface);
				surface_reset_shader();
				
			} else {
				surface_set_shader(_surf, sh_blend_normal);
					shader_set_surface("fore",	maskedSurface);
					shader_set_f("dimension",	1, 1);
					shader_set_f("opacity",		1);
					
					draw_surface_safe(_fore);
				surface_reset_shader();
			}
			
			surface_free(_fore);
			canvas.selection.selection_surface = _surf;
			canvas.selection.apply();
			
		} else {
			var _fore = canvas.getCanvasSurface();
			canvas.storeAction();
			
			if(_repl) {
				surface_set_shader(_surf, noone);
					draw_surface_safe(maskedSurface);
				surface_reset_shader();
				
			} else {
				surface_set_shader(_surf, sh_blend_normal);
					shader_set_surface("fore",	maskedSurface);
					shader_set_f("dimension",	1, 1);
					shader_set_f("opacity",		1);
					
					draw_surface_safe(_fore);
				surface_reset_shader();
			}
			
			canvas.setCanvasSurface(_surf);
			canvas.surface_store_buffer();
		}
		
		PANEL_PREVIEW.tool_current = noone;
		cleanUp();
	}
	
	static cancel = function() { 
		destroy(); 
	}
	
	static step = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _px, _py, _pw, _ph;
		
		if(applySelection) {
			_px = canvas.selection.selection_position[0];
			_py = canvas.selection.selection_position[1];
			_pw = canvas.selection.selection_size[0];
			_ph = canvas.selection.selection_size[1];
			
		} else {
			_px = 0;
			_py = 0;
			_pw = canvas.attributes.dimension[0];
			_ph = canvas.attributes.dimension[1];
			
		}
		
		var _dx = _x + _px * _s;
		var _dy = _y + _py * _s;
		
		if(inputSurface)   inputSurface.setValue(targetSurface);
		if(inputDimension) inputDimension.setValue(targetSurface);
		
		if(is(nodeObject, Node_Collection)) RenderList(nodeObject.nodes);
		else nodeObject.doUpdate();
		
		var _surf = outputJunction.getValue();
		
		if(applySelection) {
			maskedSurface = surface_verify(maskedSurface, sw, sh);
			surface_set_shader(maskedSurface);
				draw_surface_safe(_surf);
				BLEND_MULTIPLY
					draw_surface_safe(canvas.selection.selection_mask);
				BLEND_NORMAL
			surface_reset_shader();
			
		} else
			maskedSurface = _surf;
		
		draw_surface_ext_safe(maskedSurface, _dx, _dy, _s, _s);
		
		nodeObject.drawOverlay(hover, active, _x, _y, _s, _mx, _my);
		
		if(WIDGET_CURRENT == undefined) {
			if(key_press(vk_enter))  apply();
			if(key_press(vk_escape)) cancel();
		}
	}
	
}