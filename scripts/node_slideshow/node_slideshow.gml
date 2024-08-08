function Node_Slideshow(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name    = "Slideshow";
	project = PROJECT;
	
	is_controller = true;
	
	setDimension(128, 32);
	
	inputs[0] = nodeValue_Int("Order", self, 0);
	
	inputs[1] = nodeValue_Text("Title", self, "");
	
	inputs[2] = nodeValue_Enum_Scroll("Anchor", self,  0, [ "Center", "Top left" ]);
	
	slide_title  = "";
	slide_anchor = 0;
	
	static step = function() {
		var _ord = inputs[0].getValue();
		project.slideShow[$ _ord] = self;
		
		slide_title  = inputs[1].getValue();
		slide_anchor = inputs[2].getValue();
		
		setDisplayName($"Slide-{slide_title}");
	}
}