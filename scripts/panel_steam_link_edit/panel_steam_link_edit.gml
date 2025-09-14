function Panel_Steam_Link_Edit(_author) : PanelContent() constructor {
	title     = "Edit Links";
	auto_pin  = true;
	author    = _author;
	
	w = ui(240);
	h = ui(480);
	
	function drawContent(panel) {
		var _links = _author.links;
	}
}