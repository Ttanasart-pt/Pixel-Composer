function json_try_parse(text, def = {}) {
	try {
		return json_parse(text);
	} catch(e) {}
	
	return def;
}