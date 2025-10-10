function svg_parse(xmlStr) {
	if(!is_struct(xmlStr))							return noone;
	if(!struct_has(xmlStr, "children")) 			return noone;
	if(struct_try_get(xmlStr, "type") != "root")	return noone;
	if(array_empty(xmlStr.children))				return noone;
	
	var svg_object = xmlStr.children[0];
	if(struct_try_get(svg_object, "type") != "svg") return noone;
	
	return new SVG().setContent(svg_object);
}