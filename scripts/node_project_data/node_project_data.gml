function Node_Project_Data(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Project Data";
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Name", VALUE_TYPE.text, ""))
		.setVisible(false);
	
	newOutput(1, nodeValue_Output("Description", VALUE_TYPE.text, ""))
		.setVisible(false);
	
	newOutput(2, nodeValue_Output("Author", VALUE_TYPE.text, ""))
		.setVisible(false);
	
	newOutput(3, nodeValue_Output("Contact", VALUE_TYPE.text, ""))
		.setVisible(false);
	
	newOutput(4, nodeValue_Output("Path", VALUE_TYPE.path, ""))
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