import user;
import userdata;
import sex;
import world;
import crypto;

public enum PACKET_FLAGS : uint {
	Error      = 0x80000000,
	Processing = 0x40000000,
	Registry   = 0x20000000,
	User       = 0x10000000
	// Encryption?
}

struct Packet(uint ID)
{ align(1):
	static const uint Type = ID;
	uint type = ID;
	// TODO : we prolly want entries for CRC, incrementing packet id (for out-of-order fixups and responses)
}

struct RegistryPacket(uint ID)
{ align(1):
	static const uint Type = PACKET_FLAGS.Registry | ID;
	uint type = ID;
	// TODO : ditto
}

mixin template PackAsType(T, alias packet)
{
	T pack = *cast(T*)(packet.ptr);
}

//! server packets

// dab me up
struct Packet0Handshake
{ align(1):
	Packet!(0) p;
}

// sent 25 seconds after last packet, if isnt set for 30 secs you get kicke
struct Packet1Heartbeat
{ align(1):
	Packet!(1) p;
}

// after handshake client gets his User
struct Packet2SetUserId
{ align(1):
	Packet!(2) p;
	
	User id;
}

struct Packet3Userdata
{ align(1):
	Packet!(3) p;
	
	enum UserdataOp : byte
	{
		Create,
		Modify,
		SetName,
		Remove
	};
	
	UserdataOp type;
	
	union
	{
		struct CreateArg
		{
			string name;
		};
		CreateArg create;
		
		struct ModifyArg
		{
			UserdataRef id;
			uint pos;
			ushort length;
			ubyte[] data;
		};
		ModifyArg modify;
		
		struct SetNameArg
		{
			UserdataRef id;
			string name;
		};
		SetNameArg setname;
		
		UserdataRef remove;
	}
	
	void[] Serialize()
	{
		void[] ret;
		p.Serialize(ret);
		type.Serialize(ret);
		switch(type)
		{
			case UserdataOp.Create:
				create.name.Serialize(ret);
				break;
			case UserdataOp.Modify:
				modify.id.Serialize(ret);
				modify.pos.Serialize(ret);
				modify.length.Serialize(ret);
				modify.data.Serialize(ret);
				break;
			case UserdataOp.SetName:
				setname.id.Serialize(ret);
				setname.name.Serialize(ret);
				break;
			case UserdataOp.Remove:
				remove.Serialize(ret);
				break;
			default: assert(0);
		}
		return ret;
	}
	
	Packet3Userdata Deserialize(void[] input)
	{
		Packet3Userdata ret;
		input.Deserialize(ret.p);
		input.Deserialize(ret.type);
		switch(type)
		{
			case UserdataOp.Create:
				input.Deserialize(ret.create.name);
				break;
			case UserdataOp.Modify:
				input.Deserialize(ret.modify.id);
				input.Deserialize(ret.modify.pos);
				input.Deserialize(ret.modify.length);
				input.Deserialize(ret.modify.data);
				break;
			case UserdataOp.SetName:
				input.Deserialize(ret.setname.id);
				input.Deserialize(ret.setname.name);
				break;
			case UserdataOp.Remove:
				input.Deserialize(ret.remove);
				break;
			default: assert(0);
		}
		return ret;
	}
}

struct Packet4CreateWorld
{ align(1):
	Packet!(4) p;
	
	WorldInfo info;
}

//! end server packets
//! registry packets
enum Information : ubyte { // this enum has been moved outside because its used so often
	Success, // yay
	Heartbeat,

	ErrorInternal, // we fucked up
	ErrorExternal, // your recieved data sucks (malformed)
	RateLimit,
}

struct RegistryPacket_B0_Info
{ align(1):
	RegistryPacket!(0) p;

	
	Information info;
}

struct RegistryPacket_S4_Advertise
{ align(1):
	RegistryPacket!(4) p;
}



struct RegistryPacket_C10_Account
{ align(1):
	RegistryPacket!(PACKET_FLAGS.User | 10) p;
	enum UserOperation : byte {
		Create,
		Modify,
		Remove
	}

	UserOperation operation;

	union {
		struct CreateArg {
			// metadata about user
		};
		CreateArg create;

		struct ModifyArg {
			ulong accountid;
			Key accountkey;

			// metadata about user
		};
		ModifyArg modify;

		struct RemoveArg {
			ulong accountid;
			Key accountkey;
		};
		RemoveArg remove;
	}

	void[] Serialize() {
		void[] ret;
		p.Serialize(ret);
		operation.Serialize(ret);
		switch(operation)
		{
			case UserOperation.Create:
				break;
			case UserOperation.Modify:
				modify.accountid.Serialize(ret);
				modify.accountkey.Serialize(ret);
				break;
			case UserOperation.Remove:
				remove.accountid.Serialize(ret);
				remove.accountkey.Serialize(ret);
				break;
				default: assert(0);
		}
		return ret;
	}

	RegistryPacket_C10_Account Deserialize(void[] input) {
		RegistryPacket_C10_Account ret;

		input.Deserialize(ret.p);
		input.Deserialize(ret.operation);

		switch(operation) {
			case UserOperation.Create:
				break;
			case UserOperation.Modify:
				input.Deserialize(ret.modify.accountid);
				input.Deserialize(ret.modify.accountkey);
				break;
			case UserOperation.Remove:
				input.Deserialize(ret.remove.accountid);
				input.Deserialize(ret.remove.accountkey);
				break;
				default: assert(0);
		}
		return ret;
	}
}

struct RegistryPacket_R10_Account // Response
{ align(1):
	RegistryPacket!(10) p;
	Information info;

	ulong accountid;
	Key accountkey;
}

struct RegistryPacket_C18_NewSession
{ align(1):
	RegistryPacket!(PACKET_FLAGS.User | 18) p;
	ulong userkey;
}

struct RegistryPacket_C19_EndSession
{ align(1):
	RegistryPacket!(PACKET_FLAGS.User | 19) p;
}

//! end registry packets

