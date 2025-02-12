function value_map(_val, _omin, _omax, _nmin, _nmax) {
	if(_omax == _omin) return _nmin;
	return _nmin + (_val - _omin) / (_omax - _omin) * (_nmax - _nmin);
}

function triangle_area_points(x0, y0, x1, y1, x2, y2) { return abs(x0 * (y1 - y2) + x1 * (y2 - y0) + x2 * (y0 - y1)) / 2; }