import user;

struct Userdata
{
	string name;
	User owner;
	void[] data;
}

struct UserdataRef
{
	User owner;
	ulong id;
}