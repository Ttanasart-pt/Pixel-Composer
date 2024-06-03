function Panel_Preview_View_Setting(previewPanel) : Panel_Linear_Setting() constructor {
	title = __txtx("preview_view_settings", "View Settings");
	
	w = ui(380);
	self.previewPanel = previewPanel;
	
	#region data
		properties = [
			new __Panel_Linear_Setting_Item(
				__txt("Info"),
				new checkBox(function() { previewPanel.show_info = !previewPanel.show_info; }),
				function() { return previewPanel.show_info },
				function(val) { previewPanel.show_info = val; },
				true,
			),
			new __Panel_Linear_Setting_Item(
				__txt("View Control"),
				new buttonGroup([ "None", "Left", "Right" ], function(val) { previewPanel.show_view_control = val; }),
				function() { return previewPanel.show_view_control },
				function(val) { previewPanel.show_view_control = val; },
				1,
			),
		];
		
		setHeight();
	#endregion
}