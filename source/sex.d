// SErialized X data
T Read(T)(ref void[] input)
{
	T ret = *cast(T*)(input.ptr);
	input = input[T.sizeof..$];
	return ret;
}

void Serialize(T)(T v,ref void[] output)
{
	output ~= [v];
}

void Deserialize(T)(ref void[] input, ref T output)
{
	output = input.Read!(T);
}

void Serialize(T : T[])(T[] v, ref void[] output)
{
	output ~= [cast(ulong)v.length];
	output ~= cast(ubyte[])v;
}

void Deserialize(T : T[])(ref void[] input, ref T[] output)
{
	ulong arraylength = Deserialize!ulong(input);
	output = new T[](arraylength);
	foreach(ref T v; output)
	{
		v = input.Read!(T);
	}
}

void Serialize(T : string)(string v,ref void[] output)
{
	output ~= [cast(ulong)v.length];
	output ~= cast(ubyte[])v;
}
