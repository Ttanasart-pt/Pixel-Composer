function canvas_tool_with_selector(_tool) : canvas_tool() constructor {
	tool = _tool;
	
	static init = function(_node) {
		_node.selection_tool_after  = tool;
	}
	
	static getTool = function() { return node.tool_sel_magic; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {
		var _tObj = tool.getToolObject();
		_tObj.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny );
	}
}