struct File
{
	ubyte[] data;
	// prolly some metadata aswell
}

class Storage
{
	File[string] files;
}
