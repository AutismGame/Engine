import userdata;

enum AssetType
{
	Dummy,
	Binary,
	Texture,
	Model,
	Shader, // we will die of RCE
}

struct AssetInfo
{
	AssetType type;
	string filename;
}