enum PACKAGE_BYTES : uint {
	Error      = 0x80000000,
	Processing = 0x40000000,
	Registry   = 0x20000000
	// Encryption?
}

//! server packets

struct Packet(uint ID)
{
	uint type = ID;
}

struct Packet0Handshake // dab me up
{
	Packet!(0) p;
}

struct Packet1Heartbeat // this may NOT be a mistake
{
	Packet!(1) p;
}

//! end server packets
//! registry packets

struct PacketR0Get {
	Packet!(PACKAGE_BYTES.Registry | 0) p;
}

struct PacketR1Status {
	Packet!(PACKAGE_BYTES.Registry | 1) p;
}

//! end registry packets

