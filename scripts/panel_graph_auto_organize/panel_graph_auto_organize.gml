function Panel_Graph_Auto_Organize(_nodes) : Panel_Linear_Setting() constructor {
	title = __txt("Auto Organize");
	nodes = _nodes;
	param = new node_auto_organize_parameter();
	
	static node_organize = function() {
	    param.snap_size = PANEL_GRAPH.project.graphGrid.size;
	    node_auto_organize(nodes, param);
	} node_organize();
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Horzontal padding"),
			textBox_Number(function(v) /*=>*/ { param.padd_w = v; node_organize(); }),
			function() /*=>*/ {return param.padd_w}
		),
		new __Panel_Linear_Setting_Item(
			__txt("Vertical padding"),
			textBox_Number(function(v) /*=>*/ { param.padd_h = v; node_organize(); }),
			function() /*=>*/ {return param.padd_h}
		),
		new __Panel_Linear_Setting_Item(
			__txt("Snap to grid"),
			new checkBox(function() /*=>*/ { param.snap = !param.snap; node_organize(); }),
			function() /*=>*/ {return param.snap}
		),
	];
	
	setHeight();
}