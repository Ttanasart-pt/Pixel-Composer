function canvas_tool_with_selector(_tool) : canvas_tool() constructor {
	tool = _tool;
	
	function init(_node) {
		_node.selection_tool_after  = tool;
	}
	
	function getTool() { return node.tool_sel_magic; }
	
	function drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {
		var _tObj = tool.getToolObject();
		_tObj.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny );
	}
}