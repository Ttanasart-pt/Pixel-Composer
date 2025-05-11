function Node_Smoke_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "SmokeSim";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	
	output_node_types   = [ Node_Smoke_Render ];
	
	is_simulation = true;
	
	if(NODE_NEW_MANUAL) {
		var _domain = nodeBuild("Node_Smoke_Domain", x,       y, self);
		var _render = nodeBuild("Node_Smoke_Render", x + 320, y, self);
		
		_render.inputs[0].setFrom(_domain.outputs[0]);
		
		addNode(_domain);
		addNode(_render);
	}
	
	static getPreviewingNode = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ )
			if(is(nodes[i], Node_Smoke_Render)) return nodes[i];
		return self;
	}
	
	static getPreviewValues = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ )
			if(is(nodes[i], Node_Smoke_Render)) return nodes[i].getPreviewValues();
		return noone;
	}
	
}