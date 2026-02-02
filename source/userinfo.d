import std.socket;
import user;
import std.datetime;

struct UserInfo
{
	sockaddr addr;
	User id;
	SysTime lastPacketTime;
}