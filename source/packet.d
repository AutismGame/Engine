struct Packet(int ID)
{
	int type = ID;
}

struct Packet0Handshake // dab me up
{
	Packet!(0) p;
}

struct Packet1SexPack // this may be a mistake
{
	Packet!(1) p;
}