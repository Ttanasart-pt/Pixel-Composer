function array_safe_get(arr, index) {
	if(index >= array_length(arr)) return 0;
	return arr[index];
}