event_inherited();

if(NODE_SEARCH_INDEXED == 1) {
	nodeIndexStep();
	if(NODE_SEARCH_INDEXED == 2)
		nodeIndexComplete();
}

if(searching) {
	searchingNodes();
	searchNodeSort();
}