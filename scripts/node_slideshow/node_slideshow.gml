function Node_Slideshow(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name    = "Slideshow";
	project = PROJECT;
	color   = COLORS._main_accent;
	setDimension(128, 32);
	
	is_controller = true;
	slide_title   = "";
	slide_anchor  = 0;
	slide_speed   = 32;
	slide_zoom    = 0;
	
	////- =Display
	newInput(1, nodeValue_Text(    "Title"            ));
	newInput(0, nodeValue_Int(     "Order",         0 ));
	
	////- =Transition
	newInput(2, nodeValue_EScroll( "Anchor",        0, [ "Center", "Top left" ]));
	newInput(3, nodeValue_Float(   "Arrival Speed", 4 ));
	newInput(4, nodeValue_Float(   "Zoom Level",    0 ));
	
	input_display_list = [ 
		[ "Display",    false ], 0, 1, 
		[ "Transition", false ], 2, 3, 4, 
	];
	
	static step = function() {
		var _ord = inputs[0].getValue();
		project.slideShow[$ _ord] = self;
		
		slide_title  = inputs[1].getValue();
		slide_anchor = inputs[2].getValue();
		slide_speed  = max(1, 100 / inputs[3].getValue());
		slide_zoom   = inputs[4].getValue();
		
		setDisplayName($"Slide-{slide_title}", false);
	}
}