function Node_Project_Data(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Project Data";
	setDimension(96, 48);;
	
	outputs[0] = nodeValue_Output("Name", self, VALUE_TYPE.text, "")
		.setVisible(false);
	
	outputs[1] = nodeValue_Output("Description", self, VALUE_TYPE.text, "")
		.setVisible(false);
	
	outputs[2] = nodeValue_Output("Author", self, VALUE_TYPE.text, "")
		.setVisible(false);
	
	outputs[3] = nodeValue_Output("Contact", self, VALUE_TYPE.text, "")
		.setVisible(false);
	
	outputs[4] = nodeValue_Output("Path", self, VALUE_TYPE.path, "")
		.setVisible(false);
	
	static update = function() { 
		outputs[0].setValue(filename_name_only(PROJECT.path));
		outputs[1].setValue(PROJECT.meta.description);
		outputs[2].setValue(PROJECT.meta.author);
		outputs[3].setValue(PROJECT.meta.contact);
		
		outputs[4].setValue(PROJECT.path);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var txt  = outputs[0].getValue();
		
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, txt);
	}
}