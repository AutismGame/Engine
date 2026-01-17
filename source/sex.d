// SErialized X data

void SerializeSexString(ref void[] output, string v)
{
	output ~= [cast(ulong)v.length];
	output ~= cast(ubyte[])v;
}

void SerializeSexMap(ref void[] output, void[][string] data)
{
	output ~= [cast(ulong)data.length];
	foreach(k,v; data)
	{
		SerializeSexString(output,k);
		output ~= v;
	}
}