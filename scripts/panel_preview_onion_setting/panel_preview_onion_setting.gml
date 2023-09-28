function Panel_Preview_Onion_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("preview_onion_skin_settings", "Onion skin Settings");
	
	w = ui(380);
	
	#region data
		properties = [
			[
				new checkBox(function() {
					PROJECT.onion_skin.enabled = !PROJECT.onion_skin.enabled;
				}),
				__txt("Enabled"),
				function() { return PROJECT.onion_skin.enabled; }
			],
			[
				new checkBox(function() {
					PROJECT.onion_skin.on_top = !PROJECT.onion_skin.on_top;
				}),
				__txtx("onion_skin_top", "Draw on top"),
				function() { return PROJECT.onion_skin.on_top; }
			],
			[
				new textBox(TEXTBOX_INPUT.number, function(str) {
					PROJECT.onion_skin.step = max(1, round(real(str)));	
				}),
				__txtx("onion_skin_frame_step", "Frame step"),
				function() { return PROJECT.onion_skin.step; }
			],
			[
				new buttonColor(function(color) {
					PROJECT.onion_skin.color[0] = color;
				}, self),
				__txtx("onion_skin_pre_color", "Pre Color"),
				function() { return PROJECT.onion_skin.color[0]; }
			],
			[
				new buttonColor(function(color) {
					PROJECT.onion_skin.color[1] = color;
				}, self),
				__txtx("onion_skin_post_color", "Post Color"),
				function() { return PROJECT.onion_skin.color[1]; }
			],
			[
				new slider(0, 1, .05, function(str) {
					PROJECT.onion_skin.alpha = clamp(real(str), 0, 1);
				}),
				__txt("Opacity"),
				function() { return PROJECT.onion_skin.alpha; }
			]
		];
		
		setHeight();
	#endregion
}