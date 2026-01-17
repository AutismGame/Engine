enum ExprPieceType
{
	None,
	True,
	False,
	And,
	Or,
	Xor,
	Not
}

struct ExprPiece
{
	ExprPieceType type;
}

struct Permission
{
	string name;
	
}

class PermissionGroup
{
	Permission[ulong] perms;
}