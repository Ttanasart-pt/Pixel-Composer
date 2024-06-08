function svg_parse(xmlStr) {
	if(!is_struct(xmlStr)) return noone;
	
	if(struct_try_get(xmlStr, "type") != "root") return noone;
	if(array_empty(xmlStr.children)) return noone;
	
	var svg_object = xmlStr.children[0];
	
	if(struct_try_get(svg_object, "type") != "svg") return noone;
	
	var attr = svg_object.attributes;
	
	var ww   = struct_try_get(attr, "width",  1);
	var hh   = struct_try_get(attr, "height", 1);
	
	var svg = new SVG();
	svg.width  = toNumber(string_digits(ww));
	svg.height = toNumber(string_digits(hh));
	
	if(struct_has(attr, "viewBox")) {
		var bbox = attr.viewBox;
		bbox = string_splice(bbox);
		for (var i = 0, n = array_length(bbox); i < n; i++)
			bbox[i] = real(bbox[i])
		svg.bbox   = bbox;
	}
	
	if(struct_has(attr, "fill")) {
		var _f = attr.fill;
		_f = string_replace_all(_f, "#", "");
		svg.fill = color_from_rgb(_f);
	}
	
	if(struct_has(svg_object, "children")) {
		var _ind = 0;
		
		for (var i = 0, n = array_length(svg_object.children); i < n; i++) {
			var _ch = svg_object.children[i];
			
			switch(_ch.type) {
				case "path" : svg.contents[_ind++] = svg_parse_path(_ch, svg); break;
			}
		}
	}
	
	return svg;
}

function svg_parse_path(pathStr, svgObj) {
	var _path = new SVG_path(svgObj);
	var attr  = pathStr.attributes;
	
	if(struct_has(attr, "d"))
		_path.setDef(attr.d)
	
	return _path;
}