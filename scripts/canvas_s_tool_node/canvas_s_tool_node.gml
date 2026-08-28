function canvas_s_tool_node() : canvas_s_tool() constructor {
	icon = THEME.canvas_tools_node;
	tooltip = "Node";
	
	nodeObject     = undefined;
	input_junc     = undefined;
	dimension_junc = undefined;
	output_junc    = undefined;
	
	process_surface = undefined;
	inspector       = undefined;
	
	blend = 0;
	
	settings = [
		new __Simple_Editor( "", button(function() /*=>*/ {
			if(nodeObject == undefined) return;
			
			if(inspector && instance_exists(inspector)) {
				instance_destroy(inspector);
				inspector = undefined;
				
			} else openInspector();
			
		}).setTooltip("Open Inspector").setBaseSprite(THEME.button_hide_fill).setIcon(THEME.node, 0, c_white, .75), function() /*=>*/ {return 0}, function() /*=>*/ {} ),
		
		new __Simple_Editor( "Blend", new scrollBox([ "Normal", "Override", "Multiply", "Add" ], function(i) /*=>*/ { blend = i; }).setMinWidth(ui(128)),
			function() /*=>*/ {return blend}, function(i) /*=>*/ { blend = i; }),
		
		-1, 
		
		new __Simple_Editor( "", button(function() /*=>*/ {return apply()}).setTooltip("Apply")
			.setBaseSprite(THEME.button_hide_fill).setIcon(THEME.accept, 0, COLORS._main_value_positive, .75), function() /*=>*/ {return 0}, function() /*=>*/ {} ),
			
		new __Simple_Editor( "", button(function() /*=>*/ {return canvas.resetTool()}).setTooltip("Cancel")
			.setBaseSprite(THEME.button_hide_fill).setIcon(THEME.cross,  0, COLORS._main_value_negative, .75), function() /*=>*/ {return 0}, function() /*=>*/ {} ),
	];
	
	function init() {
		var _ctx = self;
		
		var _add = dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: _ctx });
		if(_add) _add.canvas = true;
	}
	
	function addNodeTool(_node) {
		nodeObject = _node.build(0, 0, canvas.node);
		
		if(!is(nodeObject, Node)) {
			nodeObject = undefined;
			noti_warning("Not a valid node.");
			return;
		}
		
		var node = canvas.node;
		var inj  = nodeObject.getInput(0,  node.outputs[0]);
		
		dimension_junc = undefined;
		input_junc     = undefined;
		output_junc    = nodeObject.getOutput();
		
		if(nodeObject.dimension_index >= 0)
			dimension_junc = nodeObject.inputs[nodeObject.dimension_index];
			
		if(is(inj, NodeValue)) {
			if(inj.name == "Surface In")
				input_junc = inj;
		}
		
		if(!is(output_junc, NodeValue)) {
			nodeObject.destroy();
			nodeObject = undefined;
			noti_warning("Can't find io junctions.");
			return;
		}
		
		openInspector();
	}
	
	function openInspector() {
		if(!is(nodeObject, Node)) return;
		
		inspector = dialogPanelCall(new Panel_Inspector().setInspecting(nodeObject, true));
		inspector.destroy_on_click_out = false;
		
		if(MULTI_WINDOWS) {
			var inWin = inspector.window;
			var cnWin = canvas.window;
			
			if(is_winwin(inWin) && is_winwin(cnWin))
				winwin_set_owner(inWin, cnWin);
		}
	}
	
	function destroy() {
		if(nodeObject) nodeObject.destroy();
		nodeObject = undefined;
		
		if(inspector && instance_exists(inspector)) {
			instance_destroy(inspector);
			inspector = undefined;
		}
		
	}
	
	function drawing(_drawingSurface) {
		preview_override = undefined;
		
		if(nodeObject == undefined) {
			if(inspector && instance_exists(inspector)) {
				instance_destroy(inspector);
				inspector = undefined;
			}
			return;
		}
		
		var content = content_surface;
		if(canvas.selecting)
			content = canvas.selection_cont;
		
		if(!is_surface(content)) { destroy(); return; }
		
		var dim = surface_get_dimension(content);
		
		process_surface = surface_verify(process_surface, dim[0], dim[1]);
		surface_set_shader(process_surface, noone, true, BLEND.over);
			draw_surface(content, 0, 0);
		surface_reset_shader();
		
		if(dimension_junc) dimension_junc.setValue(dim);
		if(input_junc) input_junc.setValue(process_surface);
		
		nodeObject.doUpdate();
		var _outS = output_junc.getValue();
		
		if(is_surface(_outS)) {
			surface_set_shader(process_surface, sh_canvas_tool_node_mask, true, BLEND.over);
				shader_set_i( "selecting",  canvas.selecting      );
				shader_set_s( "selectMask", canvas.selection_mask );
				shader_set_s( "origSurf",   content_surface       );
				
				shader_set_i( "blending",   blend                 );
						
				draw_surface(_outS, 0, 0);
			surface_reset_shader();
			
			draw_surface_ext(process_surface, preview_x, preview_y, preview_s, preview_s, 0, c_white, 1);
		}
		
		preview_override = process_surface;
	}
	
	function apply() {
		canvas.deleteSelection(false);
		canvas.applyToNode(process_surface);
		canvas.resetTool();
		
		preview_override = undefined;
		if(inspector && instance_exists(inspector)) {
			instance_destroy(inspector);
			inspector = undefined;
		}
	}
	
}