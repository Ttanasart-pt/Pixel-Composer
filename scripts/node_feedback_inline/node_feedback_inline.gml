function Node_Feedback_Inline(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name    = "Feedback";
	color   = COLORS.node_blend_feedback;
	icon    = THEME.feedback;
	icon_24 = THEME.feedback_24;
	update_on_frame = true;
	
	w = 0;
	h = 0;
	
	is_root         = false;
	selectable      = false;
	feedback_active = true;
	feedback_frame  = 0;
	
	newInput( 0, nodeValue_Bool( "Active", true ));
	
	attributes.junc_in  = [0,0];
	attributes.junc_out = [0,0];
	
	attributes.node_in  = "";
	attributes.node_out = "";
	
	input_node  = noone;
	output_node = noone;
	
	////- Rendering
	
	static connectJunctions = function(jFrom, jTo) {
		var nfrom = jFrom.node;
		var nto   = jTo.node;
		
		var input  = nodeBuild("Node_Feedback_Inline_Input",  nfrom.x - 32 - 96,  nfrom.y);
		var output = nodeBuild("Node_Feedback_Inline_Output", nto.x + nto.w + 32, nto.y);
		
		input.inputs[0].setFrom(jFrom.value_from);
		jFrom.setFrom(input.outputs[0]);
		output.inputs[0].setFrom(jTo);
		
		input_node  = input;
		output_node = output;
		
		input_node.loop  = self;
		output_node.loop = self;
		
		attributes.node_in  = input_node.node_id;
		attributes.node_out = output_node.node_id;
		return self;
	}
	
	static update = function() {
		if(input_node == noone || output_node == noone) {
			if(input_node)  input_node.destroy();
			if(output_node) output_node.destroy();
			destroy();
			return;
		}
		
		var _active = inputs[0].getValue();
		
		if(IS_FIRST_FRAME) {
			feedback_active = false;
			feedback_frame  = CURRENT_FRAME + 1;
			
		} else if(CURRENT_FRAME == feedback_frame) {
			feedback_active = true;
			feedback_frame  = CURRENT_FRAME + 1;
			
		} else {
			feedback_active = false;
			feedback_frame  = FIRST_FRAME;
		}
	}
	
	////- Draw
	
	static drawDimension = undefined
	static drawBadge     = function(_x, _y, _s) {}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {}
	
	static pointIn = function(_x, _y, _mx, _my, _s) { return false; }
	
	static drawConnections = function(params = {}, _draw = true) {
		var hovering = undefined;
		params.dashed = true; params.loop   = true;
		if(input_node && output_node) drawJuncConnection(output_node.outputs[0], input_node.inputs[0], params);
		params.dashed = false; params.loop   = false;
		return undefined;
	}
	
	////- Action
	
	static onDestroy = function() { 
		if(input_node)  input_node.destroy(); 
		if(output_node) output_node.destroy(); 
	}
	
	////- Serialize
	
	static postLoad = function() /*=>*/ {
		if(LOADING_VERSION < 1_21_06_1) return;
		
		input_node  = project.nodeMap[? attributes[$ "node_in"]  ?? ""];
		output_node = project.nodeMap[? attributes[$ "node_out"] ?? ""];
		
		if(input_node)  input_node.loop  = self;
		if(output_node) output_node.loop = self;
	}
	
	static afterLoad = function() /*=>*/ {
		if(LOADING_VERSION >= 1_21_06_1) return;
		
		var node_in  = project.nodeMap[? attributes.junc_in[0]];
		var node_out = project.nodeMap[? attributes.junc_out[0]];
		
		var junc_in  = node_in?  array_safe_get(node_in.inputs,   attributes.junc_in[1])  : noone;
		var junc_out = node_out? array_safe_get(node_out.outputs, attributes.junc_out[1]) : noone;
		
		if(junc_in && junc_out) connectJunctions(junc_in, junc_out);
	}
	
}