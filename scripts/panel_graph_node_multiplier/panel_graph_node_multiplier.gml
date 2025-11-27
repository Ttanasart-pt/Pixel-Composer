function Panel_Graph_Node_Multiplier(_node) : Panel_Linear_Setting() constructor {
	title  = __txt("Node Multiplier");
	node   = _node;
	amount = [2,2];
	spacing = [16,16];
	
	function apply() {
		if(!is(node, Node)) { close(); return; }
		
		var x0 = node.x;
		var y0 = node.y;
		var ww = node.w + spacing[0];
		var hh = node.h + spacing[1];
		var nn = instanceof(node);
		
		for( var i = 0; i < amount[0]; i++ )
		for( var j = 0; j < amount[1]; j++ ) {
			if(i == 0 && j == 0) continue;
			
			var xx = x0 + ww * i;
			var yy = y0 + hh * j;
			
			nodeBuild(nn, xx, yy, node.group);
		}
		
		close();
	}
	
	title_actions = [
		[ "Apply",  [ THEME.toolbar_check, 0, c_white ], function() /*=>*/ {return apply()} ], 
		[ "Cancel", [ THEME.toolbar_check, 1, c_white ], function() /*=>*/ {return close()} ], 
	];
	
	properties = [
		new __Panel_Linear_Setting_Item( __txt("Repeat"),  new vectorBox(2, function(v,i) /*=>*/ { amount[i]  = v; }), function() /*=>*/ {return amount}  ),
		new __Panel_Linear_Setting_Item( __txt("Spacing"), new vectorBox(2, function(v,i) /*=>*/ { spacing[i] = v; }), function() /*=>*/ {return spacing} ),
	];
	
	setHeight();
}