function value_snap(val, snap = 1) {
	if(snap == 0) return val;
	return round(val / snap) * snap;
}