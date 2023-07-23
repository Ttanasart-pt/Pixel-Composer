function run_in(frame, func, args = []) {
	var ts = time_source_create(time_source_global, frame, time_source_units_frames, func, args);
	time_source_start(ts);
}

function run_in_s(sec, func, args = []) {
	var ts = time_source_create(time_source_global, sec, time_source_units_seconds, func, args);
	time_source_start(ts);
}