
function FirebaseFirestore_operationFromSymbol(opStr)
{
	switch (opStr) 
	{
		case ">=": return Firestore_Query_greater_than_or_equal;
		case ">": return Firestore_Query_greater_than;
		case "<=": return Firestore_Query_less_than_or_equal;
		case "<": return Firestore_Query_less_than;
		case "==": return Firestore_Query_equal;
		case "!=": return Firestore_Query_not_equal;
		default: throw "[ERROR] Firestore: invalid query operation.";
	}
}
