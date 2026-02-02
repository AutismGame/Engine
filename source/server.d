import baseserver;
import std.stdio;
import std.concurrency;
import game;
import userinfo;
import user;
import std.datetime;

class Server : BaseServer
{
	Game game;
	UserInfo[sockaddr] connected_users;
	User last_userid;
	
	this()
	{
		game = new Game();
	}
	
	override ubyte[] ProcessPacket(uint packettype, ubyte[] data, sockaddr fromi)
	{	
		writeln("Server:");
		writeln(packettype);
		ubyte[] retVal;

		switch(packettype)
		{	
			case 0:
				writefln("Registering new user with id %d", last_userid);
				const UserInfo newUser = {fromi, last_userid++, Clock.currTime()};
				connected_users[fromi] = newUser;
				retVal = [0x00, 0x00, 0x00, 0x00];
				break;

			case 1:
				writefln("heartbeat from userid: ", connected_users[fromi].id);
				retVal = [];
				break;

			default:
				writeln("admin pomocy siur szczypie");
				retVal = [];
				break;
		}
		connected_users[fromi].lastPacketTime = Clock.currTime();
		return retVal;
	}
	
	override void Tick(double delta)
	{
		foreach(user; connected_users)
		{
			if(Clock.currTime() > user.lastPacketTime + 30.seconds)
			{
				writeln("spierdalaj głupi chuju ", user.id);
				connected_users.remove(user.addr);
			}
		}

		game.Tick(delta);
		super.Tick(delta);
	}
}


shared(bool) Server_run;

void Server_Loop()
{	
	Server sv = new Server();
	sv.Listen(21370); // TODO : Unhardcode port
	while(Server_run)
	{
		sv.Tick(0.016);
	}
	sv.CloseSocket();
	Server_run = false;
}

// called in main
public void Server_Init()
{
	Server_run = true;
	spawn(&Server_Loop);
}

public void Server_End()
{
	Server_run = false;
}