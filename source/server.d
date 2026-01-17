import baseserver;
import std.stdio;
import game;

class Server : BaseServer
{
	Game game;
	
	this()
	{
		game = new Game();
	}
	
	override ubyte[] ProcessPacket(uint packettype, ubyte[] data, sockaddr fromi)
	{
		return [];
	}
	
	override void Tick(double delta)
	{
		game.Tick(delta);
		super.Tick(delta);
	}
}