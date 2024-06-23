function svg_parse(xmlStr) {
	if(!is_struct(xmlStr)) return noone;
	
	if(struct_try_get(xmlStr, "type") != "root") return noone;
	if(array_empty(xmlStr.children)) return noone;
	
	var svg_object = xmlStr.children[0];
	
	if(struct_try_get(svg_object, "type") != "svg") return noone;
	
	var attr = svg_object.attributes;
	var svg  = new SVG().setAttr(attr);
	
	if(struct_has(attr, "viewBox")) {
		var bbox = attr.viewBox;
		bbox = string_splice(bbox);
		for (var i = 0, n = array_length(bbox); i < n; i++)
			bbox[i] = real(bbox[i])
		svg.bbox   = bbox;
	}
	
	if(struct_has(svg_object, "children")) {
		var _ind = 0;
		
		for (var i = 0, n = array_length(svg_object.children); i < n; i++) {
			var _ch = svg_object.children[i];
			
			switch(_ch.type) {
				case "path" :	  svg.contents[_ind++] = new SVG_path(svg).setAttr(_ch.attributes);		break;
				case "rect" :	  svg.contents[_ind++] = new SVG_rect(svg).setAttr(_ch.attributes);		break;
				case "circle" :   svg.contents[_ind++] = new SVG_circle(svg).setAttr(_ch.attributes);	break;
				case "ellipse" :  svg.contents[_ind++] = new SVG_ellipse(svg).setAttr(_ch.attributes);	break;
				case "line" :	  svg.contents[_ind++] = new SVG_line(svg).setAttr(_ch.attributes);		break;
				case "polyline" : svg.contents[_ind++] = new SVG_polyline(svg).setAttr(_ch.attributes);	break;
				case "polygon" :  svg.contents[_ind++] = new SVG_polygon(svg).setAttr(_ch.attributes);	break;
			}
		}
	}
	
	return svg;
}