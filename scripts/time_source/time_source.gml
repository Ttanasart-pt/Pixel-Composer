function run_in(frame, func, args = []) {
	var ts = time_source_create(time_source_global, frame, time_source_units_frames, func, args);
	time_source_start(ts);
}