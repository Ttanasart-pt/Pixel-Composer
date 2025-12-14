function Node_Smoke_Render_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Render Domain";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	
	setCacheAuto();
	previewable = true;
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Dimension());
		
	newInput(2, nodeValue_Bool("Interpolate", false));
		
	newInput(3, nodeValue_Bool("Draw Domain", false));
		
	newInput(4, nodeValue_Bool("Auto Update", true));
	
	input_display_list = [
		["Domain",	false], 0, 
		["Render",	false], 4, 1, 2, 3,
	];
	
	attribute_surface_depth();
	
	onSetDisplayName = noone;
	
	static createOutput = function() {
		if(group == noone) return;
		if(!is_struct(group)) return;
			
		if(!is_undefined(outParent))
			array_remove(group.outputs, outParent);
			
		outParent = new __NodeValue_Output("Rendered", group, VALUE_TYPE.surface, noone).uncache().setVisible(true, true);
		outParent.from = self;
		
		array_push(group.outputs, outParent);
		group.refreshNodeDisplay();
		group.sortIO();
	} if(!LOADING && !APPENDING) createOutput();
	
	static step = function() {
		if(!is_instanceof(outParent, NodeValue)) return noone;
		outParent.name = display_name;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(!is_instanceof(outParent, NodeValue)) return noone;
		
		var _dim = getInputData(1);
		var _outSurf = outParent.getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outParent.setValue(_outSurf);
		
		var _dom = getInputData(0);
		var _int = getInputData(2);
		var _drw = getInputData(3);
		var _upd = getInputData(4);
		
		SMOKE_DOMAIN_CHECK
		
		var fSurf = _dom.sf_material;
		if(!is_surface(fSurf)) return;
		
		if(_upd) _dom.update();
		
		surface_set_shader(_outSurf, sh_fd_visualize);
			gpu_set_texfilter(_int);
			draw_surface_stretched_safe(fSurf, 0, 0, _dim[0], _dim[1]);
			gpu_set_texfilter(false);
			
			if(_drw) draw_surface_stretched_safe(_dom.sf_world, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		group.outputNode = self;
		cacheCurrentFrame(_outSurf);
	}
	
	static recoverCache = function(frame = CURRENT_FRAME) {
		if(!is_instanceof(outParent, NodeValue)) return false;
		if(!cacheExist(frame)) return false;
		
		var _s = cached_output[CURRENT_FRAME];
		outParent.setValue(_s);
			
		return true;
	}
	
	static getGraphPreviewSurface = function() {
		if(!is_instanceof(outParent, NodeValue)) return noone;
		return outParent.getValue();
	}
	
	static getPreviewValues = function() {
		if(!is_instanceof(outParent, NodeValue)) return noone;
		return outParent.getValue();
	}
}