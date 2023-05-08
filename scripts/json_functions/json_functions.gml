function json_try_parse(text, def = noone) {
	try {
		return json_parse(text);
	} catch(e) {
		return def;
	}
	
	return def;
}