function canvas_tool_with_selector(_tool, _sel) : canvas_tool() constructor {
	tool     = _tool;
	selector = _sel;
	
	static init = function(_node) {
		selector.tool_after = tool;
	}
	
	static getTool = function() /*=>*/ {return selector};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my ) {
		var _tObj = tool.getToolObject();
		_tObj.drawOverlay(hover, active, _x, _y, _s, _mx, _my );
	}
}