import math;
import user;

struct Entity
{
	User owner;
	Transform3D t;
	
	ulong[] scripts;
	ulong[] children;
}