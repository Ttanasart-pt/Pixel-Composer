function RogueTD_Entity() constructor {
	x = 0;
	y = 0;
}

function Panel_RogueTD() : PanelContent() constructor {
	title = "RogueTD";
	w = ui(640);
	h = ui(480);
	
	towers   = [];
	entities = [];
	enemies  = [];
	
	function drawContent(panel) {
		draw_clear(COLORS.panel_bg_clear);
		
		
	}
}