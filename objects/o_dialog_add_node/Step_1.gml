event_inherited();

if(NODE_SEARCH_INDEXED == 1) nodeIndexStep();
if(searching) {
	searchingNodes();
	if(!searching) searchNodeSort();
}