function value_snap(val, snap) {
	if(snap == 0) return val;
	return round(val / snap) * snap;
}