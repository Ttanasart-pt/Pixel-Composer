function value_map(_val, _omin, _omax, _nmin, _nmax) {
	if(_omax == _omin) return _nmin;
	
	return _nmin + (_val - _omin) / (_omax - _omin) * (_nmax - _nmin);
}