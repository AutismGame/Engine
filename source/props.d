struct Property(Type)
{
	Type _value;
	
	alias this = _value;
}

class PropertyGroup(Prop: Property!(Type), Type)
{
	Prop[] props;
	ulong[] dirty;
	
	pragma(inline) void Mark(ulong index)
	{
		dirty ~= index;
	}
	
	
}