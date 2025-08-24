#pragma once

// Since GML cannot easily exchange 64-bit integers with native extensions,
// a map+vector pair is used to provide sequentially generated 32-bit integers.
// Also ensures that raw API is not called with unexpected values.
/*

template<class T> class steam_gml_map {
private:
	map<T, int> t2i;
	vector<T> i2t;
	int next = 0;
public:
	// Clears the internal data structures.
	void clear() {
		t2i.clear();
		i2t.clear();
		next = 0;
	}
	// Returns whether the value exists in this map.
	bool exists(T key) {
		return t2i.find(key) != t2i.end();
	}
	// Adds a value to the map, returns it's index.
	int add(T item) {
		auto pair = t2i.find(item);
		if (pair != t2i.end()) return pair->second;
		t2i[item] = next;
		i2t.push_back(item);
		return next++;
	}
	// If index is valid, fetches value to &out and returns true.
	bool get(int index, T* out) {
		if (index >= 0 && index < next) {
			*out = i2t[index];
			return true;
		} else return false;
	}
	bool get(double index, T* out) {
		return get((int)index, out);
	}
};


// Same as steam_gml_map, but with tools for caching by name.
template<class T> class steam_gml_namedmap {
private:
	map<string, int> s2i;
	map<T, int> t2i;
	vector<T> i2t;
	int next;
public:
	void clear() {
		s2i.clear();
		i2t.clear();
		next = 0;
	}
	// If name exists in map, fetches index to &out and returns true.
	bool find_name(char* name, int* out) {
		auto pair = s2i.find(name);
		if (pair != s2i.end()) {
			*out = pair->second;
			return true;
		} else return false;
	}
	// If value exists in map, fetches index to &out and returns true.
	bool find_value(T value, int* out) {
		auto pair = t2i.find(value);
		if (pair != t2i.end()) {
			*out = pair->second;
			return true;
		} else return false;
	}
	// Sets up name->index and value->index pairs, returns index.
	int set(char* name, T value) {
		i2t.push_back(value);
		s2i[name] = next;
		t2i[value] = next;
		return next++;
	}
	// Sets up a "invalid name" pair (value is GML-specific `noone` constant)
	int set_noone(char* name) {
		s2i[name] = -4;
		return -4;
	}
	// If index exists in map, fetches value to &out and returns true.
	bool get(int index, T* out) {
		if (index >= 0 && index < next) {
			*out = i2t[index];
			return true;
		} else return false;
	}
	bool get(double index, T* out) {
		return get((int)index, out);
	}
};

*/