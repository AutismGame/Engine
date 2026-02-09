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
	ulong arraylength;
	input.Deserialize!ulong(arraylength);
	output = new T[](arraylength);
	foreach(ref T v; output)
	{
		v = input.Read!(T);
	}
}

void Serialize(Key, T : T[Key])(T[Key] a, ref void[] output)
{
	output ~= [cast(ulong)a.length];
	foreach(k, v; a)
	{
		k.Serialize(output);
		v.Serialize(output);
	}
}

void Deserialize(Key, T : T[Key])(ref void[] input, ref T[Key] output)
{
	ulong arraylength;
	input.Deserialize!ulong(arraylength);
	foreach(_; arraylength)
	{
		Key k;
		input.Deserialize!Key(k);
		T t;
		input.Deserialize!T(t);
		output[k] = t;
	}
}

void Serialize(T : string)(string v,ref void[] output)
{
	output ~= [cast(ulong)v.length];
	output ~= cast(ubyte[])v;
}
