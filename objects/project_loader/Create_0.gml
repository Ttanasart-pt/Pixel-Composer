load_process = 0;
load_step    = 0;
load_total   = 0;
create_list  = [];

if(struct_has(content, "version")) {
	var _v = content.version;
	
	PROJECT.version = _v;
	LOADING_VERSION = _v;
	
	if(PREFERENCES.notify_load_version && floor(_v) != floor(SAVE_VERSION)) {
		var warn = $"File version mismatch : loading file version {_v} to Pixel Composer {SAVE_VERSION}";
		log_warning("LOAD", warn);
	}
} else {
	var warn = $"File version mismatch : loading old format to Pixel Composer {SAVE_VERSION}";
	log_warning("LOAD", warn);
}

printIf(log, $" > Load meta : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
load_process = 1;
load_delay   = 50_000;
node_length  = 0;

load_noti = new notification(NOTI_TYPE.log, noti_status($"Loading {path}..."));
load_noti.progress = 0;
array_append(STATS_PROGRESS, load_noti);

PROJECT.deserialize(content);