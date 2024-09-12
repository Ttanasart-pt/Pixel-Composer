function winwin(_ptr) constructor {
    __ptr__ = _ptr;
}

function winwin_config_ext(caption = "", kind = winwin_kind_normal, topmost = false, resize = false, owner = winwin_main) {
	var cnf = new winwin_config();
	
	cnf.caption = caption;
	cnf.kind    = kind;
	cnf.topmost = topmost;
	cnf.resize  = resize;
	cnf.owner   = owner;
	cnf.per_pixel_alpha = true;
	
	return cnf;
}