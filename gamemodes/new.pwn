#include <crashdetect>
#include <open.mp>
#include <foreach>
#include <streamer>
#include <a_mysql>
#include <Pawn.CMD>
#include <sscanf2>
#include <mxdate>
#include <Pawn.RakNet>

#define MYSQL_HOST 				"localhost"
#define MYSQL_USER 				"root"
#define MYSQL_PASS				"sharik22838123"
#define MYSQL_BASE 				"server"

#define SERVER_NAME 			"Drift Land | OpenMP"
#define SERVER_NAME_PLATE 		"Drift Land"
#define MODE_NAME   			"Drift / DM"

#pragma dynamic 10000
main(){}

new MySQL: mysqlHandle;

//native gpci(playerid, serial[], len);
@__getPlayerPermissions(playerid);
@__getGangInfo(playerid);
@__getPlayerTeleports(playerid);
@__getPlayerSettings(playerid);
@__getPlayerAccount(playerid);
@__loadPlayerAccount(playerid);
@__loadGangs();
@__loadGangLeader(idgang);
@__loadGangMembers(idgang);
@__getGangMembers(playerid);
@__getMemberInfo(playerid, const listitem, const mode, const inputtext[]);
@__checkChangeName(playerid, const inputtext[]);
@__OffJumping(playerid);
forward GangInfo(playerid);
forward onesec();
new str_local[1024];

enum
{
	DIALOG_NONE,
	DIALOG_REGISTER,
	DIALOG_AUTH,
	DIALOG_MENU,
	DIALOG_VEHICLES,
	DIALOG_VEHICLES_2,
	DIALOG_VEHICLES_INPUT,
	DIALOG_VEHICLES_LIST,
	DIALOG_WHEEL_ARCH_ANGELS,
	DIALOG_TELEPORTS,
	DIALOG_TELEPORTS_TO,
	DIALOG_PLAYER_TELEPORTS,
	DIALOG_PLAYER_TELEPORT_NAME,
	DIALOG_PLAYER_TELEPORT_EDIT,
	DIALOG_PLAYER_TELEPORT_CHANGE,
	DIALOG_PLAYER_PERMISSIONS,
	DIALOG_GANGS,
	DIALOG_GANG_CREATE,
	DIALOG_GANG_COLOR,
	DIALOG_GANG_MEMBERS,
	DIALOG_GANG_INVITE,
	DIALOG_GANG_INVITE_ACCEPT,
	DIALOG_GANG_MEMBERS_SWITCH,
	DIALOG_GANG_MEMBERS_RANG,
	DIALOG_GANG_LEAVE,
	DIALOG_GANG_INFO,
	DIALOG_SETTINGS_1,
	DIALOG_SETTINGS_2,
	DIALOG_CHANGE_SETTINGS,
	DIALOG_WEAPONS,
	DIALOG_WEAPONS_BUY
}

#define MAX_PLAYER_PASSWORD 	144
enum PLAYER_INFO
{
	ID,
	Name[MAX_PLAYER_NAME + 1],
	Password[MAX_PLAYER_PASSWORD],
	IP[40 + 1],
	GPCI_player[40 + 1],
	Cash,
	Vehicle,
	Skin,
	Color,
	ChatColor,
	Weather,
	Time,
	bool:Auth,
	Gang,
	Rang
}
new
	Float:PosSpawn[MAX_PLAYERS][5],
	PI[MAX_PLAYERS][PLAYER_INFO],
	TempVehicleID[MAX_PLAYERS],
	ClickedList[MAX_PLAYERS],
	nicktime[MAX_PLAYERS],
	numberdialog[MAX_PLAYERS],
	zgotoid[MAX_PLAYERS];
new bool:Jump[MAX_PLAYERS];
new LT[MAX_PLAYERS];

enum PLAYER_SETTINGS
{
	CAMMODE,
	AUTOREPAIR,
	COLLISION,
	GODMODE,
	INVITE,
	NICKS,
	SMS,
	TELEPORT,
	BUTTON
}
new bool:PS[MAX_PLAYERS][PLAYER_SETTINGS];

#define ID_PACKET_PING 7
public OnIncomingPacket(playerid, packetid, BitStream:bs)
{
    if (packetid == ID_PACKET_PING)
    {
        new Ping;
        BS_IgnoreBits(bs, 8);
        BS_ReadValue(bs,
	        PR_IGNORE_BITS, 8,
	        PR_UINT8, Ping
	    );
	    if(Ping <= 0 || Ping >= 65535)
	    {
	        BS_ResetReadPointer(bs);
			BS_ResetWritePointer(bs);
			BS_IgnoreBits(bs, 4*16);
	    }
    }
    return 1;
}

#define MAX_GANGS 			1000
#define MAX_GANG_NAME 		50
enum GANG_INFO
{
	Name[MAX_GANG_NAME + 1],
	Color[8 + 1],
	Time,
	bool:Created,
	Leader[MAX_PLAYER_NAME + 1],
	Members
}
new GI[MAX_GANGS][GANG_INFO];
getGPCI(playerid) return GPCI(playerid, PI[playerid][GPCI_player], 41);

enum TUNING_INFO
{
	SPOILER,
	HOOD,
	ROOF,
	SIDESKIRT,
	LAMPS,
	EXHAUST,
	WHEELS,
	HYDRAULICS,
	FRONT_BUMPER,
	REAR_BUMPER,
	VENT_RIGHT,
	VENT_LEFT,
	VINYL
}
new VT[MAX_PLAYERS][TUNING_INFO];
static const Wheels[17][2][] = {
    { "1025", "OffRoad" },
 	{ "1073", "Shadow" },
 	{ "1074", "Mega" },
 	{ "1075", "Rimshine" },
 	{ "1076", "Wires" },
 	{ "1077", "Classic" },
 	{ "1078", "Twist" },
 	{ "1079", "Cutter"},
 	{ "1080", "Switch" },
 	{ "1081", "Grove" },
 	{ "1082", "Import" },
 	{ "1083", "Dollar" },
 	{ "1084", "Trance" },
 	{ "1085", "Atomic" },
 	{ "1096", "Ahab" },
 	{ "1097", "Virtual" },
 	{ "1098", "Access" }
};
static const WAA[6][6][4] = {
	{//Uranus
		{1165, 1166}, //передний бампер
		{1167, 1168}, //задний бампер
		{1091, 1088}, //воздухозаборник
		{1093, 1095, 1090, 1094}, //бок.юбки
		{1163, 1164}, //спойлер
		{1089, 1092}  //выхлоп
 	},
 	{//Jester
		{1173, 1160}, //передний бампер
		{1161, 1159}, //задний бампер
		{1068, 1067}, //воздухозаборник
		{1070, 1072, 1069, 1071}, //бок.юбки
		{1158, 1162}, //спойлер
		{1066, 1065}  //выхлоп
 	},
 	{//Elegy
		{1172, 1171}, //передний бампер
		{1148, 1149}, //задний бампер
		{1035, 1038}, //воздухозаборник
		{1039, 1041, 1036, 1040}, //бок.юбки
		{1146, 1147}, //спойлер
		{1037, 1034}  //выхлоп
 	},
 	{//Sultan
		{1170, 1169}, //передний бампер
		{1140, 1141}, //задний бампер
		{1033, 1032}, //воздухозаборник
		{1030, 1031, 1026, 1027}, //бок.юбки
		{1139, 1138}, //спойлер
		{1029, 1028}  //выхлоп
 	},
 	{//Stratum
		{1157, 1155}, //передний бампер
		{1156, 1154}, //задний бампер
		{1061, 1055}, //воздухозаборник
		{1063, 1057, 1056, 1062}, //бок.юбки
		{1060, 1058}, //спойлер
		{1059, 1064}  //выхлоп
 	},
 	{//Flash
		{1152, 1153}, //передний бампер
		{1151, 1150}, //задний бампер
		{1053, 1054}, //воздухозаборник
		{1052, 1048, 1047, 1051}, //бок.юбки
		{1050, 1049}, //спойлер
		{1045, 1046}  //выхлоп
 	}
};

static const VehicleNames[212][] =
{
    "Landstalker","Bravura","Buffalo","Linerunner","Pereniel","Sentinel","Dumper","Firetruck","Trashmaster","Stretch","Manana","Infernus",
    "Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi","Washington","Bobcat","Mr Whoopee","BF Injection",
    "Hunter","Premier","Enforcer","Securicar","Banshee","Predator","Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie",
    "Stallion","Rumpo","RC Bandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder",
    "Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider",
    "Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR350","Walton","Regina",
    "Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher","FBI Rancher","Virgo","Greenwood",
    "Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson","Mesa","RC Goblin","Hotring A","Hotring B",
    "Bloodring Banger","Rancher","Super GT","Elegant","Journey","Bike","Mountain Bike","Beagle","Cropdust","Stunt","Tanker","RoadTrain",
    "Nebula","Majestic","Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck",
    "Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent","Bullet","Clover",
    "Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster A",
    "Monster B","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna","Bandito","Freight","Trailer",
    "Kart","Mower","Duneride","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","Newsvan","Tug","Trailer A","Emperor",
    "Wayfarer","Euros","Hotdog","Club","Trailer B","Trailer C","Andromada","Dodo","RC Cam","Launch","Police Car","Police Car",
    "Police Car","Police Ranger","Picador","S.W.A.T.","Alpha","Phoenix","Glendale","Sadler","L Trailer A","L Trailer B",
    "Stair Trailer","Boxville","Farm Plow","U Trailer"
};

public OnPlayerRequestClass(playerid,classid)
{
    SetSpawnInfo(playerid, 0, PI[playerid][Skin], 0.0, 0.0, 0.0, 0.0);
	if(IsPlayerNPC(playerid))
	{
	    printf("Выбор класса NPC(%d)", playerid);
		return 1;
	}
	new const vid = GetPlayerVehicleID(playerid);
	if (vid)
	{
	    new Float:x,
	        Float:y,
	        Float:z;
	    GetVehiclePos(vid, x, y, z),
	    SetPlayerPos(playerid, x, y, z-5);
	}
	SetPVarInt(playerid, "OnPlayerRequestClassFix", 1);
	SpawnPlayer(playerid);
    return 0;
}
forward DoublePlayerSpawn(playerid);
public DoublePlayerSpawn(playerid) SpawnPlayer(playerid);

public OnPlayerConnect(playerid)
{
	if(!IsPlayerNPC(playerid))
	{
	    GetPlayerName(playerid, PI[playerid][Name], MAX_PLAYER_NAME + 1);
		GetPlayerIp(playerid, PI[playerid][IP], 41);
		getGPCI(playerid);
		SetPlayerColor(playerid, 0xFF);
		zgotoid[playerid] = -1;
		format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `name` = '%s'", PI[playerid][Name]);
 		mysql_tquery(mysqlHandle, str_local, "@__getPlayerAccount", "i", playerid);
 		TogglePlayerSpectating(playerid, true);
	}
	else printf("Иницилизируется NPC(%d)", playerid);
	return 1;
}

public OnIncomingConnection(playerid, ip_address[], port)
{
    printf("Incoming connection for player ID %i [IP/port: %s:%i]", playerid, ip_address, port);
    return 1;
}


public OnGameModeExit()
{
	foreach(new i : Player)
	{
	    SavePlayer(i);
	}
    return 1;
}

static const Float:Spawns[3][4] = {
    { 1177.99, -1323.85, 14.09, 270.02 },
    { 2128.36, 1326.30, 10.81, 51.02 },
    { -1983.05, 1120.71, 53.13, 269.59 }
};

new botveh[10];
public OnPlayerSpawn(playerid)
{
    if(IsPlayerNPC(playerid))
	{
	    printf("Спавн NPC(%d)", playerid);
	    PutPlayerInVehicle(playerid, botveh[playerid], 0);
		return 1;
	}

    SetCameraBehindPlayer(playerid);
    if(GetPVarInt(playerid, "OnPlayerRequestClassFix"))
	{
	    SetPlayerPos(playerid, 0.0, 0.0, 0.0);
	    SetTimerEx("DoublePlayerSpawn", 50, false, "i", playerid);
	    DeletePVar(playerid, "OnPlayerRequestClassFix");
	    return 1;
	}
    if(PosSpawn[playerid][0] == 0.0 && PosSpawn[playerid][1] == 0.0 && PosSpawn[playerid][2] == 0.0)
    {
        new rand = random(3);
        SetPlayerPos(playerid, Spawns[rand][0], Spawns[rand][1], Spawns[rand][2]);
		SetPlayerFacingAngle(playerid, Spawns[rand][3]);
		SetPlayerInterior(playerid, 0);
    }else{
        SetPlayerPos(playerid, PosSpawn[playerid][0], PosSpawn[playerid][1], PosSpawn[playerid][2]);
		SetPlayerFacingAngle(playerid, PosSpawn[playerid][3]);
		SetPlayerInterior(playerid, int:PosSpawn[playerid][4]);
    }
    SetPlayerSkin(playerid, PI[playerid][Skin]);
    
    switch(PS[playerid][GODMODE])
	{
    	case 0: SetPlayerHealth(playerid, 100.0);
    	case 1: SetPlayerHealth(playerid, 10000000.0);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(PI[playerid][Auth])
	{
		GetPlayerPos(playerid, PosSpawn[playerid][0], PosSpawn[playerid][1], PosSpawn[playerid][2]);
		GetPlayerFacingAngle(playerid, PosSpawn[playerid][3]);
        PosSpawn[playerid][4] = GetPlayerInterior(playerid);
	}
	SavePlayer(playerid);
	PI[playerid][Auth] = false;
	if(PI[playerid][Vehicle])
	{
		DestroyVehicle(PI[playerid][Vehicle]);
		PI[playerid][Vehicle] = 0;
	}
	return 1;
}

new pLastAnimIndex[MAX_PLAYERS];
public OnPlayerDeath(playerid, killerid, reason)
{
	new animlib[32], animname[32];
	GetAnimationName(pLastAnimIndex[playerid],animlib,32,animname,32);
	if(strcmp(animlib, "PED", true) != 0) ClearAnimations(playerid);
 	foreach(new i : Player)
 	{
		if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(killerid)) SendDeathMessageToPlayer(i, killerid, playerid, reason);
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart){
	if(PS[damagedid][GODMODE])
		return 0;

	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!(0 <= damagedid < MAX_PLAYERS))
		return 0;

	if (!(weaponid >= 22 && weaponid <= 34))
		return 0;

	static
		Float: fHealth,
		Float: fArmour;

 	GetPlayerArmour(damagedid, fArmour);
  	GetPlayerHealth(damagedid, fHealth);

  	if(floatcmp(fArmour, 0.0) == 1)
    {
    	if(floatcmp(amount, fArmour) == 1)
     	{
          	SetPlayerArmour(damagedid, 0.0);
          	SetPlayerHealth(damagedid, floatsub(fHealth, floatsub(amount, fArmour)));
			return 0;
        }
       	fArmour = floatsub(fArmour, amount);
        SetPlayerArmour(damagedid, fArmour);
    }
    if(floatcmp(fArmour, 1.0) == -1) SetPlayerHealth(damagedid, floatsub(fHealth, amount));
	return 1;
}

new oldVitualWorld[MAX_PLAYERS];
new bool:InAFK[MAX_PLAYERS];
new IsAFK[MAX_PLAYERS];
public OnPlayerUpdate(playerid)
{
	pLastAnimIndex[playerid] = GetPlayerAnimationIndex(playerid);
	IsAFK[playerid] = gettime() - 25200;
	if(InAFK[playerid]) BackAFK(playerid);
 	return 1;
}

stock SavePlayer(playerid)
{
    if(!PI[playerid][Auth]) return 0;
    format(str_local, sizeof str_local, "UPDATE `players` SET `SpawnX` = '%f', `SpawnY` = '%f', `SpawnZ` = '%f', `SpawnR` = '%f', `SpawnInt` = '%d' \
	WHERE `id` = '%d'", PosSpawn[playerid][0], PosSpawn[playerid][1], PosSpawn[playerid][2], PosSpawn[playerid][3], int:PosSpawn[playerid][4], PI[playerid][ID]);
 	mysql_tquery(mysqlHandle, str_local);

    format(str_local, sizeof str_local, "UPDATE `players` SET `skin` = '%d', `gang` = '%d', `rang` = '%d', `color` = '%d', `weather` = '%d', `time` = '%d' \
	WHERE `id` = '%d'", PI[playerid][Skin], PI[playerid][Gang], PI[playerid][Rang], PI[playerid][Color], PI[playerid][Weather], PI[playerid][Time], PI[playerid][ID]);
 	mysql_tquery(mysqlHandle, str_local);
 	SaveSettings(playerid);
	return 1;
}

@__getPlayerAccount(playerid)
{
	if(cache_num_rows())
	{
		new ip[41], gpc[41];
		cache_get_value_name(0, "ip", ip);
		cache_get_value_name(0, "gpci", gpc);
		if(strcmp(PI[playerid][IP], ip, false) == 0 && strcmp(PI[playerid][GPCI_player], gpc, false) == 0)
		{
		    format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `name` = '%s'", PI[playerid][Name]);
			return mysql_tquery(mysqlHandle, str_local, "@__loadPlayerAccount", "i", playerid);
		}
		firstDialog(playerid, bool:1);
	}
	else firstDialog(playerid, bool:0);
	return 1;
}

/*public OnPlayerRequestDownload(playerid, type, crc)
{
    SendClientMessage(playerid, 0xFFFFFFFF, "Downloads request.");
    new str_local[20];
    format(str_local, 20, "Type: %d", type);
    SendClientMessage(playerid, 0xFFFFFFFF, str_local);
	return 0;
}

public OnPlayerFinishedDownloading(playerid, virtualworld)
{
	SendClientMessage(playerid, 0xFFFFFFFF, "Downloads finished.");
    return 1;
}*/

enum PERMISSIONS
{
	bool:BAN,
	bool:KICK,
	bool:MUTE,
	bool:EXPLODE,
	bool:SLAP,
	bool:HEAL,
	bool:KILL,
	bool:EJECT,
	bool:GOTO,
	bool:GET,
	bool:RESPAWN,
	bool:FREEZE,
	bool:DCARS,
	bool:SPECTATE,
	bool:BURN,
	bool:TAKEGUNS,
	bool:GIVEWEAPON,
	bool:CHECK,
	bool:ACHAT
}
new PP[MAX_PLAYERS][PERMISSIONS];

@__getPlayerPermissions(playerid)
{
	if(cache_num_rows())
	{
	    cache_get_value_bool(0, "BAN", PP[playerid][BAN]);
	    cache_get_value_bool(0, "KICK", PP[playerid][KICK]);
	    cache_get_value_bool(0, "MUTE", PP[playerid][MUTE]);
	    cache_get_value_bool(0, "EXPLODE", PP[playerid][EXPLODE]);
	    cache_get_value_bool(0, "SLAP", PP[playerid][SLAP]);
	    cache_get_value_bool(0, "HEAL", PP[playerid][HEAL]);
	    cache_get_value_bool(0, "KILL1", PP[playerid][KILL]);
	    cache_get_value_bool(0, "EJECT", PP[playerid][EJECT]);
	    cache_get_value_bool(0, "GOTO", PP[playerid][GOTO]);
	    cache_get_value_bool(0, "GET1", PP[playerid][GET]);
	    cache_get_value_bool(0, "RESPAWN", PP[playerid][RESPAWN]);
	    cache_get_value_bool(0, "FREEZE", PP[playerid][FREEZE]);
	    cache_get_value_bool(0, "DCARS", PP[playerid][DCARS]);
	    cache_get_value_bool(0, "SPECTATE", PP[playerid][SPECTATE]);
	    cache_get_value_bool(0, "BURN", PP[playerid][BURN]);
	    cache_get_value_bool(0, "TAKEGUNS", PP[playerid][TAKEGUNS]);
	    cache_get_value_bool(0, "GIVEWEAPON", PP[playerid][GIVEWEAPON]);
	    cache_get_value_bool(0, "CHECK1", PP[playerid][CHECK]);
	    cache_get_value_bool(0, "ACHAT", PP[playerid][ACHAT]);
	}else{
	    format(str_local, sizeof str_local, "INSERT INTO `permissions` (`id`) VALUES ('%d')", PI[playerid][ID]);
	    mysql_tquery(mysqlHandle, str_local);
	}
}

static const Colors[254] = {
    0xF5F5F5FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF, 0x5E7072FF,
	0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF, 0x9F9D94FF,
	0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF, 0x979592FF,
	0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF, 0x6D7A88FF,
	0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF, 0xADB0B0FF,
	0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF, 0x4E6881FF,
	0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF, 0xAB988FFF,
	0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF, 0xAE316DFF,
	0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF, 0xA7A28FFF,
	0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0xFF6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF, 0xAE9B7FFF,
	0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF, 0x525661FF,
	0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0x640D1BFF, 0xA3ADC6FF, 0x695853FF,
	0x9B8B80FF, 0x620B1CFF, 0x5B5D5EFF, 0x624428FF, 0x731827FF, 0x1B376DFF, 0xEC6AAEFF,
	0x177517FF, 0x210606FF, 0x125478FF, 0x452A0DFF, 0x571E1EFF, 0xF10701FF, 0x25225AFF, 0x2C89AAFF, 0x8A4DBDFF, 0x35963AFF,
	0xB7B7B7FF, 0x464C8DFF, 0x84888CFF, 0x817867FF, 0x817A26FF, 0x6A506FFF, 0x583E6FFF, 0x8CB972FF, 0x824F78FF, 0x6D276AFF,
	0x1E1D13FF, 0x1E1306FF, 0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF, 0x7C8499FF,
	0x992E1EFF, 0x2C1E08FF, 0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF, 0x6C3F99FF,
	0x481A0EFF, 0x7A7399FF, 0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF, 0x805B80FF,
	0x7B3E7EFF, 0x3C1737FF, 0x733517FF, 0x781818FF, 0x83341AFF, 0x8E2F1CFF, 0x7E3E53FF, 0x7C6D7CFF, 0xF20C02FF, 0xF72407FF,
	0x163012FF, 0x16301BFF, 0x642B4FFF, 0x368452FF, 0x999590FF, 0x818D96FF, 0x99991EFF, 0x7F994CFF, 0x839292FF, 0x788222FF,
	0x2B3C99FF, 0x3A3A0BFF, 0x8A794EFF, 0xFE1F49FF, 0x15371CFF, 0x15273AFF, 0x375775FF, 0xF60820FF, 0xF71326FF, 0x20394BFF,
	0x2C5089FF, 0x15426CFF, 0x103250FF, 0x241663FF, 0x692015FF, 0x8C8D94FF, 0x516013FF, 0xF90F02FF, 0x8C573AFF, 0x52888EFF,
	0x995C52FF, 0x99581EFF, 0x993A63FF, 0x998F4EFF, 0x99311EFF, 0xFD1842FF, 0x521E1EFF, 0x42420DFF, 0x4C991EFF, 0xF82A1DFF,
	0x96821DFF, 0x197F19FF, 0x3B141FFF, 0x745217FF, 0x893F8DFF, 0x7E1A6CFF, 0xFB370BFF, 0x27450DFF, 0xF71F24FF, 0x784573FF,
	0x8A653AFF, 0x732617FF, 0x319490FF, 0x56941DFF, 0x59163DFF, 0x1B8A2FFF, 0x38160BFF, 0xF41804FF, 0x355D8EFF, 0x2E3F5BFF,
	0x561A28FF, 0x4E0E27FF, 0x706C67FF, 0x3B3E42FF, 0x2E2D33FF, 0x7B7E7DFF, 0x4A4442FF, 0x28344EFF
};

SendAdminMessage(playerid, givedid, const text[], const twotext[] = "")
{
	format(str_local, sizeof(str_local), " Админ %s %s %s %s", getFullname(playerid), text, getFullname(givedid), twotext);
	return SendClientMessageToAll(-1, str_local);
}

new rainbow_timer[MAX_PLAYERS];
new rainbow_color[MAX_PLAYERS char];
new bool:is_rainbow[MAX_PLAYERS char];
forward OnPlayerTurnRainbow(playerid);
CMD:rainbow(playerid)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	    return 0;
	    
    is_rainbow{playerid} = !is_rainbow{playerid};
    switch(is_rainbow{playerid})
    {
        case true:
        {
            rainbow_color{playerid} = 128;
            rainbow_timer[playerid] = SetTimerEx("OnPlayerTurnRainbow", 350, true, "i", playerid);
            SendClientMessage(playerid, -1, "Мерцания цвета авто включено");
        }
        default:
        {
            if(rainbow_timer[playerid] != -1)
            	KillTimer(rainbow_timer[playerid]);
       		SendClientMessage(playerid, -1, "Мерцания цвета авто выключено");
        }
    }
	return 1;
}

public OnPlayerTurnRainbow(playerid)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || !IsPlayerConnected(playerid))
    {
        is_rainbow{playerid} = false;
        if(rainbow_timer[playerid] != -1)
        	KillTimer(rainbow_timer[playerid]);
		return 1;
    }
	ChangeVehicleColours(GetPlayerVehicleID(playerid), rainbow_color{playerid}, rainbow_color{playerid});
    rainbow_color{playerid}++;
    if(rainbow_color{playerid} >= 255)
        rainbow_color{playerid} = 128;
	return 1;
}

forward ReturnPlayer(playerid, Float:fx, Float:fy, Float:fz, Float:fa, const interior, const vehicleid);
CMD:refresh(playerid)
{
	new Float: fx, Float: fy, Float: fz, Float: fa;
	GetPlayerPos(playerid, fx, fy, fz);
	new const interior = GetPlayerInterior(playerid);
	switch(GetPlayerState(playerid))
	{
	    case PLAYER_STATE_ONFOOT:
	    {
	        GetPlayerFacingAngle(playerid, fa);
        	SetPlayerPos(playerid, 0, 0, 1000);
        	SetTimerEx("ReturnPlayer", 100, false, "dffffdd", playerid, fx, fy, fz, fa, interior, 0);
        	SetPlayerInterior(playerid, 1);
	    }
	    case PLAYER_STATE_DRIVER:
	    {
	        new const vehicleid = GetPlayerVehicleID(playerid);
            GetVehicleZAngle(GetPlayerVehicleID(playerid), fa);
	        SetVehiclePos(GetPlayerVehicleID(playerid), 0, 0, 1000);
	        for(new i = 0; i < MAX_PLAYERS; i++)
	        {
	            if(IsPlayerConnected(i) && GetPlayerVehicleID(i) == vehicleid) SetPlayerInterior(i, 1);
	        }
	        SetTimerEx("ReturnPlayer", 100, false, "dffffdd", playerid, fx, fy, fz, fa, interior, vehicleid);
	    }
	    default: SendClientMessage(playerid, -1, "Находясь на пассажирском сиденье - вы не можете использовать данную функцию");
	}
	return 1;
}
alias:refresh("ref")

CMD:lights(playerid, params[])
{
 	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
  		return 0;
 	new vehicleid = GetPlayerVehicleID(playerid);
 	new bool:engine, bool:lights, bool:alarm, bool:doors, bool:bonnet,bool: boot, bool:objective;
  	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
  	SetVehicleParamsEx(vehicleid, engine, !lights, alarm, doors, bonnet, boot, objective);
 	return 1;
}

new bool:collision[MAX_PLAYERS];
CMD:coll(playerid)
{
	switch(!collision[playerid])
	{
	    case 0: SendClientMessage(playerid, -1, "Коллизия была {FF2200}выключена");
	    case 1: SendClientMessage(playerid, -1, "Коллизия была {19FF19}включена");
	}
	return DisableRemoteVehicleCollisions(playerid, bool:!collision[playerid]);
}

/*
native StartRecordingPlayerData(playerid, recordtype, recordname[]);
native StopRecordingPlayerData(playerid);

new bool:isRecord[MAX_PLAYERS];
CMD:record(playerid)
{
	if(isRecord[playerid]) StopRecordingPlayerData(playerid);
	isRecord[playerid] = true;
	format(str_local, sizeof(str_local), "%d_%d", PI[playerid][ID], gettime() - 25200);
 StartRecordingPlayerData(playerid, PLAYER_RECORDING_TYPE:recordType, const recordFile[]);
	StartRecordingPlayerData(playerid, PLAYER_RECORDING_TYPE: PLAYER_RECORDING_TYPE_DRIVER, str_local);
	return 1;
}

CMD:stoprecord(playerid)
{
	if(isRecord[playerid]) StopRecordingPlayerData(playerid);
	return 1;
}*/

CMD:time(playerid, params[])
{
	new Times;
	if(!sscanf(params, "d", Times))
	{
		if(Times > 23 || Times < 0) SendPlayerError(playerid, "/time [0 - 23]");
		else{
		    PI[playerid][Time] = Times;
		    SetPlayerTime(playerid, PI[playerid][Time], 0);
		}
	}else SendPlayerError(playerid, "/time [0 - 23]");
	return 1;
}
alias:time("t")

CMD:weather(playerid, params[])
{
	new Weathers;
	if(!sscanf(params, "d", Weathers))
	{
		if(Weathers > 9999 || Weathers < 0) SendPlayerError(playerid, "/weather [0 - 9999]");
		else{
		    PI[playerid][Weather] = Weathers;
		    SetPlayerWeather(playerid, PI[playerid][Weather]);
		}
	}else SendPlayerError(playerid, "/weather [0 - 9999]");
	return 1;
}
alias:weather("w")

public ReturnPlayer(playerid, Float:fx, Float:fy, Float:fz, Float:fa, const interior, const vehicleid)
{
	switch(GetPlayerState(playerid))
	{
 		case PLAYER_STATE_ONFOOT:
		{
		    SetPlayerInterior(playerid, interior);
  			SetPlayerPos(playerid, fx, fy, fz);
        	SetPlayerFacingAngle(playerid, fa);
		}
		case PLAYER_STATE_DRIVER:
		{
		    for(new i = 0; i < MAX_PLAYERS; i++)
	        {
	            if(IsPlayerConnected(i) && GetPlayerVehicleID(i) == vehicleid) SetPlayerInterior(i, interior);
	        }
		    SetVehiclePos(GetPlayerVehicleID(playerid), fx, fy, fz);
        	SetVehicleZAngle(GetPlayerVehicleID(playerid), fa);
		}
	}
}

CMD:ban(playerid, params[])
{
	if(PP[playerid][BAN])
	{
	    new id, days, reason[40];
		if(!sscanf(params, "dds[40]", id, days, reason))
		{
			format(str_local, 30, "%s | %s", getNumEnding(days, "день", "дня", "дней"), reason);
		    SendAdminMessage(playerid, id, "забанил на", str_local);
		}else SendPlayerError(playerid, "/ban [ID] [Дни] [Причина]");
		return 1;
	}
	return 1;
}

getNumEnding(number, const ending1[], const ending2[], const ending3[])
{
	new ending[50];
	format(ending, sizeof(ending), "%d", number);
	strcat(ending, " ");
	switch(number % 100)
	{
	    case 5..20:
		{
			strcat(ending, ending3);
			return ending;
		}
	}
	switch(number % 10)
	{
		case 1:
		{
			strcat(ending, ending1);
			return ending;
		}
	 	case 2..4:
	 	{
		 	strcat(ending, ending2);
		 	return ending;
		}
	}
	strcat(ending, ending3);
	return ending;
}

cutAlpha(rgbacolor) return (rgbacolor >>> 8);
getFullname(playerid)
{
	format(str_local, sizeof(str_local), "{%0.6x}%s{FFFFFF}(%d)", cutAlpha(Colors[PI[playerid][Color]]), PI[playerid][Name], playerid);
	return str_local;
}

getFullnameChat(playerid, const bool:without = false)
{
    if(without)
    {
        format(str_local, sizeof(str_local), "{%0.6x}%s{FFFFFF}(%d)", cutAlpha(Colors[PI[playerid][Color]]), PI[playerid][Name], playerid);
        return str_local;
    }
	switch(PI[playerid][Gang])
	{
	    case 0: format(str_local, sizeof(str_local), "{%0.6x}%s{FFFFFF}(%d)", cutAlpha(Colors[PI[playerid][Color]]), PI[playerid][Name], playerid);
		default: format(str_local, sizeof(str_local), "%s {FFFFFF}| {%0.6x}%s{FFFFFF}(%d)", GI[PI[playerid][Gang] - 1][Name], cutAlpha(Colors[PI[playerid][Color]]), PI[playerid][Name], playerid);
	}
	return str_local;
}

getName(playerid, const colorid = 0)
{
	if(colorid != -1)
		format(str_local, sizeof(str_local), "{%0.6x}%s{%0.6x}", cutAlpha(Colors[PI[playerid][Color]]), PI[playerid][Name], cutAlpha(Colors[colorid]));
	else
	    format(str_local, sizeof(str_local), "{%0.6x}%s", cutAlpha(Colors[PI[playerid][Color]]), PI[playerid][Name]);
	return str_local;
}


public OnPlayerText(playerid, text[])
{
	if(!strlen(text)) return 0;
	if(!PI[playerid][Auth]) return 0;
	else
	{
	    new bool:is_mestniy;
	    if(text[0] == '!')
	    {
	        strdel(text, 0, 1);
	        is_mestniy = true;
	    }
	    
	    #define CHAT_LINES 3
		new message[CHAT_LINES * 144];
		strcat(message, text);
	    /*Поиск игрока по ID*/
	    new attemp = 0;
	    static const hash[2][2] = {"#", "№"};
		while(attemp != 2)
		{
			for(new i = strfind(message, hash[attemp][0], true), a, tmp[5]; i != -1; i = strfind(message, hash[attemp][0], true, i + 1))
			{
			    a = 0;
			    ++i;
				for(new g = i; g != i + 2; g++)
				{
				    if(message[g] == '#' || message[g] == '№' || message[g] == ' ') break;
				    if('0' <= message[g] <= '9' && a != 4)
				    {
				        tmp[a++] = message[g];
				        i++;
				    }
				}
				if(tmp[0] == EOS) continue;

				if(strval(tmp) < MAX_PLAYERS && IsPlayerConnected(strval(tmp)))
				{
				    new bool:is_symbol;
				    if(i - 1 < 180)
				    {
						for(new g = i + a; g < strlen(message); g++)
						{
						    if(message[g] == '#' || message[g] == '№') continue;
						    if(message[g] != 32)
							{
							    is_symbol = true;
							    break;
							}
						}
						
						strdel(message, i - a - 1, i);
						new color = PI[playerid][ChatColor];
						if(!is_symbol)
						    color = -1;
						FIXES_strins(message, getName(strval(tmp), color), i - a - 1, 288);
			   			a = 0;
					}
					else break;
				}
			}
		    attemp++;
		}

		new message_lines[2][200];
		new cut_pos = 143;
		new len_name = strlen(getFullnameChat(playerid)) + 8 + 1 + 2;
		if(is_mestniy)
			len_name += 3;
		new len = strlen(message);
		new cut_pos_first = cut_pos - len_name - 1;
		if(len + len_name >= cut_pos)
		{
			//Поиск места разреза #1
			for(new i = cut_pos - len_name - 1; i != cut_pos - len_name - 1 - 8; i--)
			{
				switch(message[i])
				{
				    case '{', ' ': cut_pos_first = i;
					case '}':
					{
					    if(i + 1 != 144)
							cut_pos_first = i + 1;
						else
						    cut_pos_first = i - 8;
					}
				}
			}
			//
		    strmid(message_lines[0], message, cut_pos_first, len, len);
		    strdel(message, cut_pos_first, len);
		    
			if(strlen(message_lines[0]) >= cut_pos - len_name)
			{
			    //Поиск места разреза #2
				for(new i = cut_pos; i != cut_pos - 8; i--)
				{
					switch(message[i])
					{
					    case '{', ' ': cut_pos = i;
						case '}':
						{
						    if(i + 1 != 144)
								cut_pos = i + 1;
							else
							    cut_pos = i - 8;
						}
					}
				}
				//
			    strmid(message_lines[1], message_lines[0], cut_pos, strlen(message_lines[0]), strlen(message_lines[0]));
		    	strdel(message_lines[0], cut_pos, strlen(message_lines[0]));
			}
		}
		
		if(is_mestniy)
		{
			//Ближний чат
			format(message, sizeof(message), "[!] %s: {%0.6x}%s", getFullnameChat(playerid), cutAlpha(Colors[PI[playerid][ChatColor]]), message);
			//Перепиши вывод для ближнего чата: (для вывода на дистанцию или ток стрим игрокам:
			switch(PI[playerid][Gang])
			{
	  			case 0: SendClientMessageToAll(-1, message);
				default: SendClientMessageToAll(GI[PI[playerid][Gang] - 1][Color], message);
			}
			if(strlen(message_lines[0])) SendClientMessageToAll(Colors[PI[playerid][ChatColor]], message_lines[0]);
			if(strlen(message_lines[1])) SendClientMessageToAll(Colors[PI[playerid][ChatColor]], message_lines[1]);
			SendClientMessage(playerid, -1, "%i", strlen(message));
			SendClientMessage(playerid, -1, "%i", strlen(message_lines[0]));
			SendClientMessage(playerid, -1, "%i", strlen(message_lines[1]));
			printf("%s", message);
			printf("%s", message_lines[0]);
			printf("%s", message_lines[1]);
			//
		}
		else
		{
		    //Глобальный чат
		    format(message, sizeof(message), "%s: {%0.6x}%s", getFullnameChat(playerid), cutAlpha(Colors[PI[playerid][ChatColor]]), message);
            switch(PI[playerid][Gang])
			{
	  			case 0: SendClientMessageToAll(-1, message);
				default: SendClientMessageToAll(GI[PI[playerid][Gang] - 1][Color], message);
			}
			if(strlen(message_lines[0])) SendClientMessageToAll(Colors[PI[playerid][ChatColor]], message_lines[0]);
			if(strlen(message_lines[1])) SendClientMessageToAll(Colors[PI[playerid][ChatColor]], message_lines[1]);
			SetPlayerChatBubble(playerid, text, 0xFFFFFFFF, 15.0, 5000);
		}
	}
	return 0;
}

@__loadPlayerAccount(playerid)
{
	if(cache_num_rows())
	{
	    GetPlayerIp(playerid, PI[playerid][IP], 41);
		getGPCI(playerid);
	
	    format(str_local, sizeof str_local, "UPDATE `players` SET `gpci` = '%s', `ip` = '%s' WHERE `id` = '%d'", PI[playerid][GPCI_player], PI[playerid][IP], PI[playerid][ID]);
	 	mysql_tquery(mysqlHandle, str_local);
	
	    cache_get_value_name_int(0, "id", PI[playerid][ID]);
	    cache_get_value_name_int(0, "skin", PI[playerid][Skin]);
	    cache_get_value_name_int(0, "color", PI[playerid][Color]);
	    cache_get_value_name_int(0, "chatcolor", PI[playerid][ChatColor]);
	    
	    cache_get_value_name_int(0, "cash", PI[playerid][Cash]);
	    cache_get_value_name_int(0, "gang", PI[playerid][Gang]);
	    cache_get_value_name_int(0, "rang", PI[playerid][Rang]);
	    
	    
	    cache_get_value_name_int(0, "time", PI[playerid][Time]);
	    cache_get_value_name_int(0, "weather", PI[playerid][Weather]);
	    
	    SetPlayerTime(playerid, PI[playerid][Time], 0);
		SetPlayerWeather(playerid, PI[playerid][Weather]);
	    
	    cache_get_value_name_float(0, "SpawnX", PosSpawn[playerid][0]);
	    cache_get_value_name_float(0, "SpawnY", PosSpawn[playerid][1]);
	    cache_get_value_name_float(0, "SpawnZ", PosSpawn[playerid][2]);
	    cache_get_value_name_float(0, "SpawnR", PosSpawn[playerid][3]);
	    cache_get_value_name_int(0, "SpawnInt", int:PosSpawn[playerid][4]);
	    if(PI[playerid][Color] >= sizeof(Colors)) PI[playerid][Color] = 0;
	    if(PI[playerid][ChatColor] >= sizeof(Colors)) PI[playerid][Color] = 0;
	    SetPlayerColor(playerid, Colors[PI[playerid][Color]]);
	    cache_get_value_name_int(0, "changenametime", nicktime[playerid]);
	    
	    if(PI[playerid][Gang])
	    {
		    if(!GI[PI[playerid][Gang] - 1][Created])
		    {
		        PI[playerid][Gang] = 0;
		        PI[playerid][Rang] = 0;
		        SendPlayerError(playerid, "Ваша банда была удалена администратором / расфомирована лидером");
				SavePlayer(playerid);
		    }
		}
	    
	    SetPlayerColor(playerid, Colors[PI[playerid][Color]]);
	    /* Подгрузка разрешений */
	    format(str_local, sizeof str_local, "SELECT * FROM `permissions` WHERE `id` = '%d'", PI[playerid][ID]);
		mysql_tquery(mysqlHandle, str_local, "@__getPlayerPermissions", "i", playerid);
	    /* Подгрузка телепортов */
	    format(str_local, sizeof str_local, "SELECT * FROM `teleports` WHERE `id` = '%d' ORDER BY `CreateAt` ASC;", PI[playerid][ID]);
		mysql_tquery(mysqlHandle, str_local, "@__getPlayerTeleports", "i", playerid);
        /* Подгрузка настроек */
        format(str_local, sizeof str_local, "SELECT * FROM `settings` WHERE `id` = '%d'", PI[playerid][ID]);
		mysql_tquery(mysqlHandle, str_local, "@__getPlayerSettings", "i", playerid);
		PlayerSpawn(playerid);
	}else{
	    firstDialog(playerid, bool:1);
 		return SendPlayerError(playerid, "Неправильный пароль!");
	}
	return 1;
}

stock firstDialog(playerid, bool:auth)
{
	switch(auth)
	{
	    case 1:
	    {
	        format(str_local, sizeof(str_local), "{FFFFFF}С возвращением, {FFFF99}%s{FFFFFF},\nдля продолжение введите свой пароль:", PI[playerid][Name]);
	        ShowPlayerDialog(playerid, DIALOG_AUTH, DIALOG_STYLE_PASSWORD, "Авторизация", str_local, "Далее", "Отмена");
	    }
		default:
		{
		    format(str_local, sizeof(str_local), "{FFFFFF}Приветствуем, {FFFF99}%s{FFFFFF},\nдля продолжение придумайте пароль:", PI[playerid][Name]);
	        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Регистрация", str_local, "Далее", "Отмена");
		}
	}
	return 1;
}

#define COLOR_ERROR 0xFF2400FF
stock SendPlayerError(playerid, const text[]) return SendClientMessage(playerid, COLOR_ERROR, "[Ошибка] {FFFFFF}%s", text);

stock SetServerName(const name[])
{
	format(str_local, sizeof(str_local), "hostname %s", name);
	SendRconCommand(str_local);
}

stock PlayerSpawn(playerid)
{
	TogglePlayerSpectating(playerid, false);
	PI[playerid][Auth] = true;
	SpawnPlayer(playerid);
}

public OnGameModeInit()
{
    mysqlHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_BASE);
    
   	mysql_query(mysqlHandle, "SET character_set_client = 'cp1251'", false);
	mysql_query(mysqlHandle, "SET character_set_results = 'cp1251'", false);
	mysql_query(mysqlHandle, "SET SESSION character_set_server='utf8'", false);
	//mysql_tquery(mysqlHandle, str_local, "SET NAMES 'cp1251'", "", "");
	mysql_set_charset("cp1251");
    
	if(mysql_errno())
	{
 		print("[mysql] Неверные данные подключения!");
 		return SendRconCommand("exit");
	}
	
	UsePlayerPedAnims();
	SetServerName(SERVER_NAME);
	SetGameModeText(MODE_NAME);
	DisableInteriorEnterExits();
	ManualVehicleEngineAndLights();
	EnableStuntBonusForAll(false);
	
	SetTimer("onesec", 1000, true);
	
/* 	AddCharModel(120, 20000, "triss33.dff", "triss33.txd");
	
	printf("Вызываю NPCs");
	for(new i = 0; i < 10; i++)
    {
        new name[8 + 3];
        format(name, 11, "TWINBOT_%d", i);
		ConnectNPC(name, "TWINBOT_1");
		botveh[i] = CreateVehicle(562, 0.0, 0.0, 5.0, 0.0, 1, 1, 5000);
	}*/
	
 	format(str_local, sizeof str_local, "SELECT * FROM `gangs` ORDER BY `id` ASC;");
 	mysql_tquery(mysqlHandle, str_local, "@__loadGangs");
	return 1;
}

public onesec()
{
	foreach(new i : Player)
	{
	    if(!PI[i][Auth]) continue;
		if((gettime() - 25200) - IsAFK[i] >= 10)
		{
		    new text[46];
			if((gettime() - 25200) - IsAFK[i] >= 3600) format(text, sizeof(text), "AFK: %s", date("%hh:%ii:%ss", (gettime() - 25200) - IsAFK[i] - 36000));
			else format(text, 46, "AFK: %s", date("%ii:%ss", (gettime() - 25200) - IsAFK[i] - 36000));
			if(!InAFK[i]) GotoAFK(i);
			SetPlayerChatBubble(i, text, 0x808080FF, 6.0, 999);
		}
	    if(PS[i][AUTOREPAIR])
		{
			new Float:Health;
			GetVehicleHealth(GetPlayerVehicleID(i), Health);
			if(Health <= 999.0)
  			{
	      		SetVehicleHealth(GetPlayerVehicleID(i), 1000.0);
	    		RepairVehicle(GetPlayerVehicleID(i));
			}
		}
	    foreach(new j : Player)
		{
	        if(!PS[i][NICKS]) ShowPlayerNameTagForPlayer(i, j, false);
	        else ShowPlayerNameTagForPlayer(i, j, true);
	    }
	}
}

#define AFK_WORLD 9999
GotoAFK(playerid)
{
    InAFK[playerid] = true;
    oldVitualWorld[playerid] = GetPlayerVirtualWorld(playerid);
	new const vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid)
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
		    foreach(new i : Player)
		    {
		        if(GetPlayerVehicleID(i) == vehicleid)
					SetPlayerVirtualWorld(i, AFK_WORLD);
		    }
		    SetVehicleVirtualWorld(vehicleid, AFK_WORLD);
		    if(vehicleid != PI[playerid][Vehicle])
		    {
	            foreach(new i : Player)
				{
		    		if(GetPlayerVehicleID(i) == PI[playerid][Vehicle])
						return 0;
				}
				SetVehicleVirtualWorld(PI[playerid][Vehicle], AFK_WORLD);
			}
		}
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER && vehicleid == PI[playerid][Vehicle])
		{
		    foreach(new i : Player)
			{
	    		if(GetPlayerVehicleID(i) == PI[playerid][Vehicle] && playerid != i) return 0;
	    		SetPlayerVirtualWorld(playerid, AFK_WORLD);
	    		SetVehicleVirtualWorld(vehicleid, AFK_WORLD);
			}
		}
	}else{
	    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	    {
	        SetPlayerVirtualWorld(playerid, AFK_WORLD);
	        foreach(new i : Player)
			{
	    		if(GetPlayerVehicleID(i) == PI[playerid][Vehicle] && playerid != i)
					return 0;
			}
			SetVehicleVirtualWorld(PI[playerid][Vehicle], AFK_WORLD);
	    }
	}
	return 1;
}

BackAFK(playerid)
{
    InAFK[playerid] = false;
	new const vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid)
	{
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	    {
		    foreach(new i : Player)
		    {
		        if(GetPlayerVehicleID(i) == vehicleid && GetPlayerVirtualWorld(i) == AFK_WORLD)
		       		SetPlayerVirtualWorld(i, oldVitualWorld[playerid]);
		    }
		    SetVehicleVirtualWorld(vehicleid, oldVitualWorld[playerid]);
		    if(vehicleid != PI[playerid][Vehicle])
		    {
	            if(GetVehicleVirtualWorld(PI[playerid][Vehicle]) == AFK_WORLD) SetVehicleVirtualWorld(PI[playerid][Vehicle], oldVitualWorld[playerid]);
			}
		}
		if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER && vehicleid == PI[playerid][Vehicle])
		{
		    foreach(new i : Player)
			{
	    		SetPlayerVirtualWorld(playerid, oldVitualWorld[playerid]);
	    		if(GetVehicleVirtualWorld(vehicleid) == AFK_WORLD) SetVehicleVirtualWorld(vehicleid, oldVitualWorld[playerid]);
			}
		}
	}else{
	    SetPlayerVirtualWorld(playerid, oldVitualWorld[playerid]);
   		if(GetVehicleVirtualWorld(PI[playerid][Vehicle]) == AFK_WORLD) SetVehicleVirtualWorld(PI[playerid][Vehicle], oldVitualWorld[playerid]);
	}
}

CMD:getinfo(playerid)
{
	format(str_local, sizeof(str_local), "%d", GetPlayerState(playerid));
	return SendClientMessage(playerid, -1, str_local);
}

CMD:skin(playerid, params[])
{
	new skin;
	if(!sscanf(params, "d", skin))
	{
	    switch(GetPlayerState(playerid))
	    {
	        case PLAYER_STATE_ONFOOT:
			{
			    ClearAnimations(playerid);
				SetPlayerSkin(playerid, skin);
				PI[playerid][Skin] = skin;
			}
	        default: SendPlayerError(playerid, "Вы должны быть пешком!");
	    }
	}
	else SendPlayerError(playerid, "/skin [Модель]");
	return 1;
}

CMD:veh(playerid, params[])
{
	new inputtext[60];
	if(!sscanf(params, "s[60]", inputtext))
	{
	    if(strval(inputtext) > 400 && strval(inputtext) < 611) CreatePlayerVehicle(playerid, strval(inputtext));
	    else
		{
	    	for(new i = 0; i < sizeof(VehicleNames); i++)
			{
	  			if(strfind(VehicleNames[i], inputtext, true) != -1) return CreatePlayerVehicle(playerid, i + 400);
			}
		}
	}else SendPlayerError(playerid, "/veh [Модель]");
	return 1;
}
alias:veh("car", "vehicle")

CMD:pj(playerid, params[])
{
	new vinyl;
	if(!sscanf(params, "d", vinyl))
 	{
	 	if(PI[playerid][Vehicle]) ChangeVehiclePaintjob(PI[playerid][Vehicle], vinyl);
	}
	else SendPlayerError(playerid, "/pj [Винил]");
	return 1;
}
alias:pj("paintjob")

CMD:cc(playerid, params[])
{
	new color1 = 0, color2 = 0;
	if(!sscanf(params, "d", color1)) sscanf(params, "dd", color1, color2);
	else return SendPlayerError(playerid, "/cc [Цвет1] [Цвет2]");
	if(PI[playerid][Vehicle]) ChangeVehicleColours(PI[playerid][Vehicle], color1, color2);
	else SendPlayerError(playerid, "У вас нет своего транспорта!");
	return 1;
}

CMD:kill(playerid)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_WASTED && GetPlayerState(playerid) != PLAYER_STATE_SPAWNED && GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
	{
		SetPlayerHealth(playerid, 0.0);
	}
	return 1;
}

CMD:goto(playerid, params[])
{
	new id;
	if(!sscanf(params, "d", id))
	{
	    if(id == playerid) return SendPlayerError(playerid, "Вы ввели свой ID!");
	    if(!IsPlayerConnected(id)) return SendPlayerError(playerid, "Игрок не подключён!");
	    if(PS[id][TELEPORT] || PP[playerid][GOTO])
	    {
			new Float:_pos[6];
			GetPlayerPos(id, _pos[0], _pos[1], _pos[2]);
			if(GetPlayerState(id) == PLAYER_STATE_ONFOOT) GetPlayerFacingAngle(id, _pos[3]);
			else GetVehicleZAngle(GetPlayerVehicleID(id), _pos[3]);
			_pos[4] = GetPlayerInterior(id);
			_pos[5] = GetPlayerVirtualWorld(id);
			TeleportTo(playerid, _pos[0], _pos[1], _pos[2], _pos[3], int:_pos[4], int:_pos[5]);
			format(str_local, sizeof(str_local), "%s телепортировался к вам", getFullnameChat(playerid, true));
			SendClientMessage(id, -1, str_local);
		}
		else SendPlayerError(playerid, "Игрок запретил телепорт к себе!");
	}else SendPlayerError(playerid, "/goto [ID]");
	return 1;
}

CMD:drift(playerid, params[])
{
	new id;
	if(!sscanf(params, "d", id))
	{
		if(!(id > 10) && !(id <= 0))
		{
		    switch(id)
      		{
        		case 0: TeleportTo(playerid, -382.84, 1537.49, 75.35, 255.41);
          		case 1: TeleportTo(playerid, -2399.11, -589.35, 132.64, 121.97);
            	case 2: TeleportTo(playerid, 1253.10, -2060.65, 59.81, 267.88);
             	case 3: TeleportTo(playerid, 2228.89, -2661.83, 13.54, 235.41);
              	case 4: TeleportTo(playerid, -2755.08, 2345.28, 73.30, 283.92);
               	case 5: TeleportTo(playerid, 2353.02, 1404.99, 42.82, 88.61);
               	case 6: TeleportTo(playerid, 2225.01, 1963.73, 31.77, 269.46);
                case 7: TeleportTo(playerid, 2058.36, 2374.66, 49.53, 359.43);
                case 8: TeleportTo(playerid, 1030.12, 1167.26, 10.67, 176.59);
                case 9: TeleportTo(playerid, 1488.74, 1079.23, 10.82, 177.82 );
        	}
		}
		else SendClientMessage(playerid, -1, "{FF2400}[Ошибка] {FFFFFF}/d(rift) [1 - 10]");
	}else SendClientMessage(playerid, -1, "{FF2400}[Ошибка] {FFFFFF}/d(rift) [1 - 10]");
	return 1;
}
alias:drift("d")

CMD:givemoney(playerid, params[])
{
	new id, cash;
	if(!sscanf(params, "dd", id, cash))
	{
		if(id == playerid) return SendPlayerError(playerid, "Вы ввели свой ID!");
	    if(!IsPlayerConnected(id)) return SendPlayerError(playerid, "Игрок не подключён!");
	    if(cash <= 0) return SendPlayerError(playerid, "Сумма не может быть отрицательным числом!");
	    if(PI[playerid][Cash] >= cash)
	    {
	        PI[playerid][Cash] -= cash;
			PI[id][Cash] += cash;
			SendClientMessage(id, -1, " %s передал вам {19FF19}%d$", getFullnameChat(playerid, true), cash);
			SendClientMessage(playerid, -1, " Вы передали игроку %s - {19FF19}%d$", getFullnameChat(id, true), cash);
	    }else SendPlayerError(playerid, "У вас недостаточно денег!");
	}else SendPlayerError(playerid, "/givemoney [ID] [Сумма]");
	return 1;
}
alias:givemoney("pay")

CMD:zgoto(playerid, params[])
{
	new id;
	if(!sscanf(params, "d", id))
	{
	    if(id == playerid) return SendPlayerError(playerid, "Вы ввели свой ID!");
	    if(!IsPlayerConnected(id)) return SendPlayerError(playerid, "Игрок не подключён!");
	    if(PS[id][TELEPORT] || PP[playerid][GOTO])
	    {
	        goto teleport;
			new Float:_pos[6];
			new Float:_speed[3];
		teleport:
			GetPlayerPos(id, _pos[0], _pos[1], _pos[2]);
			if(GetPlayerState(id) == PLAYER_STATE_ONFOOT) GetPlayerFacingAngle(id, _pos[3]);
			else GetVehicleZAngle(GetPlayerVehicleID(id), _pos[3]);
			_pos[4] = GetPlayerInterior(id);
			_pos[5] = GetPlayerVirtualWorld(id);
			TeleportTo(playerid, _pos[0], _pos[1], _pos[2], _pos[3], int:_pos[4], int:_pos[5]);
			if(GetPlayerVehicleID(id) && GetPlayerVehicleID(playerid))
			{
				GetVehicleVelocity(GetPlayerVehicleID(id), _speed[0], _speed[1], _speed[2]);
				SetVehicleVelocity(GetPlayerVehicleID(playerid), _speed[0], _speed[1], _speed[2]);
			}
			zgotoid[playerid] = id;
			format(str_local, sizeof(str_local), "%s записан для телепортации | {b5b5b5}/zgoto {FFFFFF}- чтобы убрать", getFullnameChat(id, true));
			SendClientMessage(playerid, -1, str_local);
			if(!PS[playerid][BUTTON]) SendClientMessage(playerid, -1, "Для телепортации используйте: {b5b5b5}Y");
			else SendClientMessage(playerid, -1, "Для телепортации используйте: {b5b5b5}2");
		}
		else SendPlayerError(playerid, "Игрок запретил телепорт к себе!");
	}else{
        zgotoid[playerid] = -1;
 		SendClientMessage(playerid, -1, "{b5b5b5}/zgoto {FFFFFF}- очищен");
	}
	return 1;
}

CMD:pm(playerid, params[])
{
	new id, text[300];
	if(!sscanf(params, "ds[250]", id, text))
	{
	    if(id == playerid) return SendPlayerError(playerid, "Вы ввели свой ID!");
	    if(!IsPlayerConnected(id)) return SendPlayerError(playerid, "Игрок не подключён!");
	    if(PS[id][SMS])
	    {
	    	goto personal;
	        new text2[300];
		personal:
		    text2[0] = EOS;
	        if(strlen(text) >= 70)
	        {
	            strmid(text2,text,67,strlen(text),strlen(text));
				strdel(text,97,strlen(text));
	        }
			SendClientMessage(id, 0xb5b5b5FF, "« %s: {ffec8b}%s", getFullnameChat(playerid, true), text);
			if(strlen(text2)) SendClientMessage(id, 0xffec8bFF, text2);
			SendClientMessage(playerid, 0xb5b5b5FF, "» %s: {ffec8b}%s", getFullnameChat(id, true), text);
			if(strlen(text2)) SendClientMessage(playerid, 0xffec8bFF, text2);
		}
	    else SendPlayerError(playerid, "У игрока выключены личные сообщения!");
	}else SendPlayerError(playerid, "/pm [ID] [Сообщение]");
	return 1;
}
alias:pm("sms")

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	if(PS[playerid][AUTOREPAIR])
	{
	    SetVehicleHealth(GetPlayerVehicleID(playerid), 1000.0);
	    RepairVehicle(GetPlayerVehicleID(playerid));
	}
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    TempVehicleID[playerid] = vehicleid;
    if(!ispassenger)
	{
	    new bool:engine, bool:lights, bool:s[4];
		GetVehicleParamsEx(vehicleid, engine, lights, s[0], s[0], s[1], s[2], s[3]);
		SetVehicleParamsEx(vehicleid, true, lights, s[0], s[0], s[1], s[2], s[3]);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    TempVehicleID[playerid] = 0;
	return 1;
}

CMD:server(playerid)
{
    new stats[400+1];
    GetNetworkStats(stats, sizeof(stats)); // get the servers networkstats
    return ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, "Server Network Stats", stats, "Close", "");
}

stock CreatePlayerVehicle(playerid, model)
{
    new Float:X, Float:Y, Float:Z, Float:R;
	GetPlayerPos(playerid, X, Y, Z);
	switch(GetPlayerState(playerid))
	{
	    case PLAYER_STATE_ONFOOT: GetPlayerFacingAngle(playerid, R);
		default: GetVehicleZAngle(GetPlayerVehicleID(playerid), R);
	}
	if(PI[playerid][Vehicle])
	{
		DestroyVehicle(PI[playerid][Vehicle]);
		PI[playerid][Vehicle] = 0;
	}
	PI[playerid][Vehicle] = CreateVehicle(model, X, Y, Z, R, random(10), 1, 10, 0);
	SetVehicleNumberPlate(PI[playerid][Vehicle], SERVER_NAME_PLATE);
	SetVehicleToRespawn(PI[playerid][Vehicle]);
	TempVehicleID[playerid] = PI[playerid][Vehicle];
	SetVehicleVirtualWorld(PI[playerid][Vehicle], GetPlayerVirtualWorld(playerid));
	LinkVehicleToInterior(PI[playerid][Vehicle], GetPlayerInterior(playerid));
	PutPlayerInVehicle(playerid, PI[playerid][Vehicle], 0);
	SetVehicleParamsEx(PI[playerid][Vehicle], true, true, false, false, false, false, false);
	
	VT[playerid][SPOILER] = 0;
	VT[playerid][HOOD] = 0;
	VT[playerid][ROOF] = 0;
	VT[playerid][SIDESKIRT] = 0;
	VT[playerid][LAMPS] = 0;
	VT[playerid][EXHAUST] = 0;
	VT[playerid][WHEELS] = 0;
	VT[playerid][HYDRAULICS] = 0;
	VT[playerid][FRONT_BUMPER] = 0;
	VT[playerid][REAR_BUMPER] = 0;
	VT[playerid][VENT_RIGHT] = 0;
	VT[playerid][VENT_LEFT] = 0;
	VT[playerid][VINYL] = 0;
	return 1;
}

public OnPlayerStateChange(playerid, t_PLAYER_STATE:newstate, t_PLAYER_STATE:oldstate)
{
	if(GetPlayerVirtualWorld(playerid) == AFK_WORLD)
	{
	    SetPlayerVirtualWorld(playerid, oldVitualWorld[playerid]);
	    foreach(new i : Player)
		{
			if(GetPlayerVehicleID(i) == PI[playerid][Vehicle] && playerid != i) return 0; //Проверяем, сидит ли кто-то в его АВТО кроме него
		}
		SetVehicleVirtualWorld(PI[playerid][Vehicle], GetPlayerVirtualWorld(playerid));
	}
	if(newstate == t_PLAYER_STATE:PLAYER_STATE_DRIVER)
	{
	    new bool:engine, bool:lights, bool:s[4];
		GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, s[0], s[0], s[1], s[2], s[3]);
		SetVehicleParamsEx(GetPlayerVehicleID(playerid), true, lights, s[0], s[0], s[1], s[2], s[3]);
	}
	return 1;
}

@__OffJumping(playerid)
{
    Jump[playerid] = false;
	return 0;
}

#define PRESSED(%0) \
        (((newkeys & (%0)) & (%0)) && ((oldkeys & (%0)) != (%0)))
#define RELEASED(%0) \
        (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) & (%0)))

public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
	format(str_local, sizeof(str_local), "newkeys: %d | oldkeys %d", newkeys, oldkeys);
	SendClientMessage(playerid, -1, str_local);

	switch(GetPlayerState(playerid))
	{
	    case PLAYER_STATE_PASSENGER:
	    {
	        switch(newkeys)
			{
				case 512:
				    if(!PS[playerid][BUTTON]) Menu(playerid);
			}
	    }
	    case PLAYER_STATE_DRIVER:
	    {
	        //if( newkeys & KEY:1 || newkeys & KEY:9 || newkeys & KEY:33 )
			if( PRESSED(KEY:1) || PRESSED(KEY:4) )
			{
			    SendClientMessage(playerid, -1, "Создал нитро");
				AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
			}
			else if ( RELEASED(KEY:1) || RELEASED(KEY:4) )
			{
			    SendClientMessage(playerid, -1, "Удалил нитро");
			    RemoveVehicleComponent(GetPlayerVehicleID(playerid), 1010);
			}
	    
	      /*  if ( RELEASED(KEY:1) || RELEASED(KEY:9) || RELEASED(KEY:33))
			{
			    
			}
	    
	        // && oldkeys != KEY:1 || oldkeys != KEY:9 || oldkeys != KEY:33 )
			{
			    
			} */
				
			if( newkeys & KEY:262144 )
			{
			    new Float:R;
			    GetVehicleZAngle(GetPlayerVehicleID(playerid), R);
				SetVehicleZAngle(GetPlayerVehicleID(playerid), R);
			}
			if(newkeys & KEY:131072)
			{
			    if(!Jump[playerid])
			    {
    				new Float:Velocity[3];
      				GetVehicleVelocity(GetPlayerVehicleID(playerid), Velocity[0], Velocity[1], Velocity[2]);
	   				SetVehicleVelocity(GetPlayerVehicleID(playerid), Velocity[0], Velocity[1], Velocity[2] + 0.23);
	   				Jump[playerid] = true;
	   				SetTimerEx("@__OffJumping", 750, false, "i", playerid);
				}
			}
			if(newkeys & KEY:512)
			{
				if(!PS[playerid][BUTTON]) Menu(playerid);
				else TeleportWithSpeed(playerid);
			}
 			if(newkeys & KEY:65536)
			{
				if(PS[playerid][BUTTON]) Menu(playerid);
				else TeleportWithSpeed(playerid);
			}
	    }
	    case PLAYER_STATE_ONFOOT:
	    {
	        switch(newkeys)
	        {
	            case 1024:
					if(!PS[playerid][BUTTON]) Menu(playerid);
				case 65536:
				    if(PS[playerid][BUTTON]) Menu(playerid);
	        }
	    }
	}
	return 1;
}

stock TeleportWithSpeed(playerid)
{
    if(zgotoid[playerid] != -1 && PS[zgotoid[playerid]][TELEPORT])
    {
		new Float:_pos[6];
		new Float:_speed[3];
		GetPlayerPos(zgotoid[playerid], _pos[0], _pos[1], _pos[2]);
		if(GetPlayerState(zgotoid[playerid]) == PLAYER_STATE_ONFOOT) GetPlayerFacingAngle(zgotoid[playerid], _pos[3]);
		else GetVehicleZAngle(GetPlayerVehicleID(zgotoid[playerid]), _pos[3]);
		_pos[4] = GetPlayerInterior(zgotoid[playerid]);
		_pos[5] = GetPlayerVirtualWorld(zgotoid[playerid]);
		TeleportTo(playerid, _pos[0], _pos[1], _pos[2], _pos[3], int:_pos[4], int:_pos[5]);
		if(GetPlayerVehicleID(zgotoid[playerid]) && GetPlayerVehicleID(playerid))
		{
			GetVehicleVelocity(GetPlayerVehicleID(zgotoid[playerid]), _speed[0], _speed[1], _speed[2]);
			SetVehicleVelocity(GetPlayerVehicleID(playerid), _speed[0], _speed[1], _speed[2]);
		}
	}
}

stock Weapons(playerid, const page = 0)
{
    LT[playerid] = page;
	switch(page)
	{
	    case 0:
	    {
         	format(str_local, sizeof(str_local), "\
         	    {b5b5b5}» {FFFFF9}Быстрая закупка\n\
			 	{b5b5b5}» {FFFFF9}Холодное оружие\n\
			 	{b5b5b5}» {FFFFF9}Пистолеты\n\
			 	{b5b5b5}» {FFFFF9}Автоматы | Пулемёты\n\
			 	{b5b5b5}» {FFFFF9}Дробовики\n\
			 	{b5b5b5}» {FFFFF9}Винтовки\n\
			 	{b5b5b5}» {FFFFF9}Предметы\n\
			 	{b5b5b5}» {FFFFF9}Разоружиться");
	        ShowPlayerDialog(playerid, DIALOG_WEAPONS, DIALOG_STYLE_LIST, "Меню » Оружие", str_local, "Далее", "Назад");
	    }
		case 1: //Быстрая закупка
		{
		    format(str_local, sizeof(str_local), "\
         	    {b5b5b5}» {FFFFF9}\n\
			 	{b5b5b5}» {FFFFF9}\n\
			 	{b5b5b5}» {FFFFF9}");
            ShowPlayerDialog(playerid, DIALOG_WEAPONS_BUY, DIALOG_STYLE_LIST, "Оружие » Быстрая закупка", str_local, "Далее", "Назад");
		}
		case 2: //Холодное оружие
		{
		    format(str_local, sizeof(str_local), "\
         	    {b5b5b5}» {FFFFF9}Нож\n\
			 	{b5b5b5}» {FFFFF9}Клюшка для гольфа\n\
			 	{b5b5b5}» {FFFFF9}Полицейская дубинка\n\
			 	{b5b5b5}» {FFFFF9}Бейсбольная бита\n\
			 	{b5b5b5}» {FFFFF9}Лопата\n\
			 	{b5b5b5}» {FFFFF9}Кий\n\
			 	{b5b5b5}» {FFFFF9}Катана\n\
			 	{b5b5b5}» {FFFFF9}Бензопила\n\
			 	{b5b5b5}» {FFFFF9}Дилдо");
            ShowPlayerDialog(playerid, DIALOG_WEAPONS_BUY, DIALOG_STYLE_LIST, "Оружие » Холодное", str_local, "Далее", "Назад");
		}
		case 3: //Пистолеты
		{
		    format(str_local, sizeof(str_local), "\
         	    {b5b5b5}» {FFFFF9}9MM\n\
			 	{b5b5b5}» {FFFFF9}9MM с глушителем\n\
			 	{b5b5b5}» {FFFFF9}Desert Eagle");
            ShowPlayerDialog(playerid, DIALOG_WEAPONS_BUY, DIALOG_STYLE_LIST, "Оружие » Пистолеты", str_local, "Далее", "Назад");
		}
		case 4: //Ручные пулемёты
		{
		    format(str_local, sizeof(str_local), "\
         	    {b5b5b5}» {FFFFF9}UZI\n\
			 	{b5b5b5}» {FFFFF9}MP5\n\
			 	{b5b5b5}» {FFFFF9}M4\n\
			 	{b5b5b5}» {FFFFF9}AK-47\n\
			 	{b5b5b5}» {FFFFF9}Tec-9");
            ShowPlayerDialog(playerid, DIALOG_WEAPONS_BUY, DIALOG_STYLE_LIST, "Оружие » Автоматы | Пулемёты", str_local, "Далее", "Назад");
		}
		case 5: //Дробовики
		{
		    format(str_local, sizeof(str_local), "\
         	    {b5b5b5}» {FFFFF9}Дробовик\n\
			 	{b5b5b5}» {FFFFF9}Обрезы\n\
			 	{b5b5b5}» {FFFFF9}Скорострельный дробовик");
            ShowPlayerDialog(playerid, DIALOG_WEAPONS_BUY, DIALOG_STYLE_LIST, "Оружие » Дробовики", str_local, "Далее", "Назад");
		}
		case 6: //Винтовки
		{
		    format(str_local, sizeof(str_local), "\
         	    {b5b5b5}» {FFFFF9}Охотничье ружьё\n\
			 	{b5b5b5}» {FFFFF9}Снайперская винтовка");
 			ShowPlayerDialog(playerid, DIALOG_WEAPONS_BUY, DIALOG_STYLE_LIST, "Оружие » Винтовки", str_local, "Далее", "Назад");
		}
		case 7: //Предметы
		{
		    format(str_local, sizeof(str_local), "\
         	    {b5b5b5}» {FFFFF9}Балончик с краской\n\
			 	{b5b5b5}» {FFFFF9}Огнетушитель\n\
			 	{b5b5b5}» {FFFFF9}Камера\n\
			 	{b5b5b5}» {FFFFF9}Парашют\n\
			 	{b5b5b5}» {FFFFF9}Кастет\n\
			 	{b5b5b5}» {FFFFF9}Вибратор\n\
			 	{b5b5b5}» {FFFFF9}Цветы\n\
			 	{b5b5b5}» {FFFFF9}Трость\n\
			 	{b5b5b5}» {FFFFF9}Гранаты\n\
			 	{b5b5b5}» {FFFFF9}Молотов\n\
			 	{b5b5b5}» {FFFFF9}Слезоточивый газ");
            ShowPlayerDialog(playerid, DIALOG_WEAPONS_BUY, DIALOG_STYLE_LIST, "Оружие » Предметы", str_local, "Далее", "Назад");
		}
		case 8: //Разоружиться
		{
			ResetPlayerWeapons(playerid);
			Weapons(playerid, 0);
		}
	}
	return 1;
}
stock Settings(playerid, const bool:mode = false)
{
	str_local[0] = EOS;
	switch(mode)
	{
	    case 0:
	    {
		    format(str_local, sizeof(str_local), "\
			{b5b5b5}» {FFFFF9}Режим съёмки\t%s\n\
		 	{b5b5b5}» {FFFFF9}Автопочинка\t%s\n\
		 	{b5b5b5}» {FFFFF9}Коллизия\t%s\n\
		 	{b5b5b5}» {FFFFF9}Бессмертие\t%s\n\
		 	{b5b5b5}» {FFFFF9}Приглашение в банду\t%s\n\
		 	{b5b5b5}» {FFFFF9}Ники игроков\t%s\n\
		 	{b5b5b5}» {FFFFF9}Личные сообщения\t%s\n\
		 	{b5b5b5}» {FFFFF9}Телепорт к Вам\t%s\n",
			gT(PS[playerid][CAMMODE]), gT(PS[playerid][AUTOREPAIR]), gT(PS[playerid][COLLISION]), gT(PS[playerid][GODMODE]),
			gT(PS[playerid][INVITE]), gT(PS[playerid][NICKS]), gT(PS[playerid][SMS]), gT(PS[playerid][TELEPORT]));
			switch(PS[playerid][BUTTON])
			{
			    case true: strcat(str_local, "{b5b5b5}» {FFFFF9}Кнопка меню\t{ffebb8}| Y");
				default: strcat(str_local, "{b5b5b5}» {FFFFF9}Кнопка меню\t{ffebb8}| ALT");
			}
			ShowPlayerDialog(playerid, DIALOG_SETTINGS_1, DIALOG_STYLE_TABLIST, "Меню » Настройки", str_local, "Далее", "Назад");
	    }
		default:
		{
		    format(str_local, sizeof(str_local), "\
	        {b5b5b5}» {FFFFF9}Стиль боя\t\n\
	        {b5b5b5}» {FFFFF9}Скин\t| ID:%d\n\
	        {b5b5b5}» {FFFFF9}Время\t| %d:00\n\
	        {b5b5b5}» {FFFFF9}Погода\t| ID:%d\n\
	        {b5b5b5}» {FFFFF9}Цвет ника\t| {%0.6x}№%d\n\
	        {b5b5b5}» {FFFFF9}Цвет чата\t| {%0.6x}№%d\n\
	        {b5b5b5}» {FFFFF9}Ник\t| %s\n\
	        {b5b5b5}» {FFFFF9}Пароль\t",
			PI[playerid][Skin], PI[playerid][Time], PI[playerid][Weather], cutAlpha(Colors[PI[playerid][Color]]), PI[playerid][Color], cutAlpha(Colors[PI[playerid][ChatColor]]), PI[playerid][ChatColor], getName(playerid));
			ShowPlayerDialog(playerid, DIALOG_SETTINGS_2, DIALOG_STYLE_TABLIST, "Меню » Персонализация", str_local, "Далее", "Назад");
		}
	}
}

gT(const value)
{
	switch(value)
	{
	    case 0: format(str_local, sizeof(str_local), "{FF3000}| OFF");
	    default: format(str_local, sizeof(str_local), "{19FF19}| ON");
	}
	return str_local;
}

stock Menu(playerid)
{
	format(str_local, sizeof(str_local), "\
    {b5b5b5}» {FFFFF9}Транспорт\n\
    {b5b5b5}» {FFFFF9}Телепорты\n\
    {b5b5b5}» {FFFFF9}Оружие\n\
    {b5b5b5}» {FFFFF9}Настройки\n\
    {b5b5b5}» {FFFFF9}Персонализация\n\
    {b5b5b5}» {FFFFF9}Банды");
	return ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST, "Меню", str_local, "Далее", "Отмена");
}

CMD:createtp(playerid, params[])
{
	new name[60];
	if(!sscanf(params, "s[60]", name))
	{
	    new Float:pos[4];
	    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) GetPlayerFacingAngle(playerid, pos[3]);
	    else GetVehicleZAngle(GetPlayerVehicleID(playerid), pos[3]);
	    printf("{ %0.2f, %0.2f, %0.2f, %0.2f }", pos[0], pos[1], pos[2], pos[3]);
	    printf("{ %s }", name);
	}
}

CMD:lsap(playerid) return TeleportTo(playerid, 1974.0, -2253.7, 13.1, 180.0);
CMD:sfap(playerid) return TeleportTo(playerid, -1276, 34.3, 13.7, 225.0);
CMD:lvap(playerid) return TeleportTo(playerid, 1632.2, 1597.0, 10.4, 103.0);
CMD:ls(playerid) return TeleportTo(playerid, 1130.005615,-1436.554687,15.96875, 0);
CMD:lv(playerid) return TeleportTo(playerid, 1677.176269, 1447.806762, 10.782345, 265);
CMD:sf(playerid) return TeleportTo(playerid, -1753.548828, 954.116516, 24.400741, 88.841140);

stock Teleports(playerid)
{
	str_local[0] = EOS;
	format(str_local, sizeof(str_local), "\
		{b5b5b5}» {FFFFF9}Дрифт места\n\
		{b5b5b5}» {FFFFF9}Дрифт трассы\n\
		{b5b5b5}» {FFFFF9}Деревни\n\
		{b5b5b5}» {FFFFF9}Города\n\
		{b5b5b5}» {FFFFF9}Разное\n");
/*	for(new i = 0; i < sizeof(TeleportInfo); i++)
	{
	    strcat(str_local, "");
	    strcat(str_local, TeleportInfo[i]);
	    strcat(str_local, "\n");
	}*/
	strcat(str_local, "{b5b5b5}» {FFFFF9}Мои телепорты\n");
	return ShowPlayerDialog(playerid, DIALOG_TELEPORTS, DIALOG_STYLE_LIST, "Меню » Телепорты", str_local, "Далее", "Назад");
}

stock Vehicles(playerid, bool:have = false)
{
    format(str_local, sizeof(str_local), "\
   	{b5b5b5}» {FFFFF9}Указать название / ID\n\
	{b5b5b5}» {FFFFF9}Спортивные\n\
	{b5b5b5}» {FFFFF9}Внедорожники\n\
	{b5b5b5}» {FFFFF9}Классические\n\
	{b5b5b5}» {FFFFF9}Мотоциклы и Велосипеды\n\
	{b5b5b5}» {FFFFF9}Самолёты и Вертолёты\n\
	{b5b5b5}» {FFFFF9}Лодки\n\
    {b5b5b5}» {FFFFF9}Остальные");
	if(PI[playerid][Vehicle] && !have)
	{
	    str_local[0] = EOS;
	    if(GetPlayerVehicleID(playerid) == PI[playerid][Vehicle]) strcat(str_local, "{b5b5b5}» {b5b5b5}Телепортировать транспорт к себе\n{b5b5b5}» {b5b5b5}Телепортироваться к транспорту\n");
     	else strcat(str_local, "{b5b5b5}» {FFFFF9}Телепортировать транспорт к себе\n{b5b5b5}» {FFFFF9}Телепортироваться к транспорту\n");
	    if(checkTuning(GetVehicleModel(PI[playerid][Vehicle])) && GetPlayerVehicleID(playerid) == PI[playerid][Vehicle]) strcat(str_local, "{b5b5b5}» {FFFFF9}Тюнинг\n");
		else strcat(str_local, "{b5b5b5}» {b5b5b5}Тюнинг\n");
		strcat(str_local, "{b5b5b5}» {FFFFF9}Выбрать другой транспорт");
	    ShowPlayerDialog(playerid, DIALOG_VEHICLES, DIALOG_STYLE_LIST, "Меню » Транспорт", str_local, "Далее", "Назад");
	}
	else ShowPlayerDialog(playerid, DIALOG_VEHICLES_2, DIALOG_STYLE_LIST, "Меню » Выбор транспорта", str_local, "Далее", "Назад");
	return 1;
}

static const ClassVehicles[7][20] = {
	{ 402, 411, 415, 429, 451, 475, 477, 494, 502, 503, 496, 506, 541, 558, 559, 565, 587, 589, 602, 603 },//Спорткары
	{ 400, 424, 444, 556, 557, 470, 489, 495, 500, 505, 568, 573, 579 },
	{ 401, 405, 410, 419, 421, 426, 436, 445, 560, 467, 474, 491, 492, 507, 518, 526, 527, 542, 549, 551 },
	{ 448, 461, 462, 463, 468, 471, 521, 522, 523, 581, 586, 481, 509, 510 },
	{ 511, 512, 513, 519, 553, 577, 592, 593, 460, 476, 548, 563, 417, 469, 487, 488, 497 },
	{ 595, 430, 446, 452, 453, 454, 472, 473, 484, 493, 595},
	{ 596, 597, 598, 599, 600, 601, 604, 605, 609, 578, 574, 572, 571, 439, 480, 533, 555, 552, 544, 407 }
};

stock VehicleInput(playerid, const error[] = "")
{
	format(str_local, sizeof(str_local), "{FFFFFF}Введите название / ID транспорта ниже:\nПример: 400 (Landstalker) или Elegy\n{FF3000}%s", error);
	ShowPlayerDialog(playerid, DIALOG_VEHICLES_INPUT, DIALOG_STYLE_INPUT, "Выбор транспорта » По названию", str_local, "Далее", "Назад");
}

stock VehicleList(playerid, const list = 1)
{
    str_local[0] = EOS;
	new title[60] = "Выбор транспорта » ";
	switch(list)
	{
	    case 1: strcat(title, "Спортивные");
	    case 2: strcat(title, "Внедорожники");
	    case 3: strcat(title, "Классические");
	    case 4: strcat(title, "Мотоциклы и Велосипеды");
		case 5: strcat(title, "Самолёты и Вертолёты");
		case 6: strcat(title, "Лодки");
		case 7: strcat(title, "Остальные");
	}
	for(new i = 0; i < sizeof(ClassVehicles[]); i++)
	{
 		if(ClassVehicles[list - 1][i]) format(str_local, sizeof(str_local), "%s{b5b5b5}» {FFFFF9}%s\n", str_local, VehicleNames[ClassVehicles[list - 1][i] - 400]);
	}
	return ShowPlayerDialog(playerid, DIALOG_VEHICLES_LIST, DIALOG_STYLE_LIST, title, str_local, "Далее", "Назад");
}

stock Slap(playerid)
{
	new Float:_pos[3];
	GetPlayerPos(playerid, _pos[0], _pos[1], _pos[2]);
	return SetPlayerPos(playerid, _pos[0], _pos[1], _pos[2] + 1);
}

checkTuning(model)
{
    switch(model)
	{
	    case 558, 559, 562, 560, 561, 565: return 1;//Wheel Arch Angels
		case 575, 576, 412, 534, 535, 536, 566, 567: return 2;//Loco Low Co
		case 400, 401, 402, 404, 405, 409, 410, 411, 415, 418, 419, 420, 421, 422, 426,
		429, 436, 438, 439, 442, 445, 451, 458, 466, 467, 474, 475, 477, 478, 479, 480,
		489, 491, 492, 496, 500, 506, 507, 516, 517, 518, 526, 527, 529, 533, 540, 541,
		542, 545, 546, 547, 549, 550, 551, 555, 579, 580, 585, 587, 589, 600, 602, 603: return 3;//Transfender
	}
	return 0;
}

AddTuning(playerid, const mode, const number, const carmodtype = 14)
{
	new const model = GetVehicleModel(PI[playerid][Vehicle]);
	new index = 0;
	switch(model)
	{
	    case 558: index = 0;
		case 559: index = 1;
		case 562: index = 2;
		case 560: index = 3;
		case 561: index = 4;
		case 565: index = 5;
	}
	if((number > 2 && carmodtype != 14) || (number > 3 && carmodtype == 14))
	{
	    switch(carmodtype)
	    {
			case 3:
			{
			    VT[playerid][SIDESKIRT] = 0;
			    RemoveVehicleComponent(PI[playerid][Vehicle], WAA[index][mode][number - 1]);
			    RemoveVehicleComponent(PI[playerid][Vehicle], WAA[index][mode][number]);
			}
			case 14:
			{
			    VT[playerid][VINYL] = 0;
				ChangeVehiclePaintjob(PI[playerid][Vehicle], 3);
			}
	        default:
			{
			    switch(carmodtype)
			    {
                    case 0: VT[playerid][SPOILER] = 0;
				    case 2: VT[playerid][ROOF] = 0;
	       			case 3: VT[playerid][SIDESKIRT] = 0;
				    case 6: VT[playerid][EXHAUST] = 0;
					case 10: VT[playerid][FRONT_BUMPER] = 0;
        			case 11: VT[playerid][REAR_BUMPER] = 0;
			    }
    			RemoveVehicleComponent(PI[playerid][Vehicle], GetVehicleComponentInSlot(PI[playerid][Vehicle], t_CARMODTYPE:carmodtype));
			}
		}
		return Tuning(playerid);
	}
	switch(mode)
	{
		case 3:
		{
	 		AddVehicleComponent(PI[playerid][Vehicle], WAA[index][mode][number - 1]);
	 		AddVehicleComponent(PI[playerid][Vehicle], WAA[index][mode][number]);
		}
		case 6: ChangeVehiclePaintjob(PI[playerid][Vehicle], number - 1);
		default:
		{
			AddVehicleComponent(PI[playerid][Vehicle], WAA[index][mode][number - 1]);
		}
	}
	return Tuning(playerid);
}

stock Tuning(playerid)
{
	new const type = checkTuning(GetVehicleModel(PI[playerid][Vehicle]));
	switch(type)
	{
		case 0:
		{
			SendPlayerError(playerid, "Ваш транспорт не подходит для установки модицикаций!");
			Vehicles(playerid);
		}
		case 1:
		{
		    format(str_local, sizeof(str_local), "\
		    {b5b5b5}» {FFFFF9}Передний бампер\t%s\n\
      		{b5b5b5}» {FFFFF9}Задний бампер\t%s\n\
      		{b5b5b5}» {FFFFF9}Воздухозаборник\t%s\n\
      		{b5b5b5}» {FFFFF9}Боковые юбки\t%s\n\
      		{b5b5b5}» {FFFFF9}Спойлер\t%s\n\
      		{b5b5b5}» {FFFFF9}Выхлоп\t%s\n\
      		{b5b5b5}» {FFFFF9}Винил\t%s\n\
      		{b5b5b5}» {FFFFF9}Диски\t%s",
			_c(VT[playerid][FRONT_BUMPER]), _c(VT[playerid][REAR_BUMPER]),
			_c(VT[playerid][ROOF]), _c(VT[playerid][SIDESKIRT]),
			_c(VT[playerid][SPOILER]), _c(VT[playerid][EXHAUST]), _c(VT[playerid][VINYL]), getWheels(VT[playerid][WHEELS] - 1) );
			ShowPlayerDialog(playerid, DIALOG_WHEEL_ARCH_ANGELS, DIALOG_STYLE_TABLIST, "Транспорт » Тюнинг (Wheel Arch Angels)", str_local, "Далее", "Назад");
		}
	}
	return 1;
}

getWheels(id)
{
	switch(id)
	{
	    case -1: str_local = "|\t {b5b5b5}Нет\t |";
	    default: format(str_local, 50, "|\t {fff7d9}%s\t |", Wheels[id][1]);
	}
	return str_local;
}
_c(t)
{
	switch(t)
 	{
	    case 0: str_local = "|\t {b5b5b5}Нет\t |";
	    default: format(str_local, sizeof(str_local), "|\t {fff7d9}#%d\t |", t);
	}
	return str_local;
}

@__loadGangLeader(idgang)
{
	if(cache_num_rows())
	{
		new name[MAX_PLAYER_NAME + 1];
		cache_get_value_name(0, "name", name);
	    format(GI[idgang][Leader], MAX_PLAYER_NAME + 1, name);
	}else format(GI[idgang][Leader], MAX_PLAYER_NAME + 1, "Нет");
}

@__loadGangMembers(idgang) return GI[idgang][Members] = cache_num_rows();

@__loadGangs()
{
	if(cache_num_rows())
	{
		printf("__________________________________________________\n");
		printf("Найдено банд в базе данных: %d", cache_num_rows());
		for(new i = 0; i < cache_num_rows(); i++)
		{
		    new time[30];//, id;
		    //cache_get_value_name_int(i, "id", id);
		    GI[i][Created] = true;
		    cache_get_value_name(i, "name", GI[i][Name]);
		    cache_get_value_name(i, "color", GI[i][Color]);
		    cache_get_value_name(i, "CreateAt", time);
		    GI[i][Time] = strval(time);
            loadGangInfo(i);
		}
		printf("__________________________________________________");
	}else printf("Банды не найдены в базе данных");
}

loadGangInfo(i)
{
    format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `gang` = '%d' AND `rang` = '3'", i + 1);
	mysql_tquery(mysqlHandle, str_local, "@__loadGangLeader", "i", i);
	format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `gang` = '%d'", i + 1);
	mysql_tquery(mysqlHandle, str_local, "@__loadGangMembers", "i", i);
}

Gangs(playerid)
{
	str_local[0] = EOS;
	if(!PI[playerid][Gang]) str_local = "{b5b5b5}» {FFFFF9}Создать банду";
	else
	{
	    strcat(str_local,"{b5b5b5}» {FFFFF9}Посмотреть участников");
	    switch(PI[playerid][Rang])
	    {
			case 2:
			{
			    strcat(str_local,"\n{b5b5b5}» {FFFFF9}Пригласить игрока");
			}
	        case 3: 
	        {
	            strcat(str_local,"\n{b5b5b5}» {FFFFF9}Пригласить игрока");
	            strcat(str_local,"\n{b5b5b5}» {FFFFF9}Изменить название");
	            strcat(str_local,"\n{b5b5b5}» {FFFFF9}Изменить цвет");
	        }
	    }
	    strcat(str_local,"\n{b5b5b5}» {FFFFF9}Информация о банде");
		strcat(str_local,"\n{b5b5b5}» {FFFFF9}Покинуть банду");
	}
	return ShowPlayerDialog(playerid, DIALOG_GANGS, DIALOG_STYLE_TABLIST, "Меню » Банды", str_local, "Далее", "Назад");
}

stock GetVehicle(playerid)
{
	new Float:_pos[4];
	GetPlayerPos(playerid, _pos[0], _pos[1], _pos[2]);
	GetPlayerFacingAngle(playerid, _pos[3]);
 	SetVehiclePos(PI[playerid][Vehicle], _pos[0], _pos[1], _pos[2]);
 	SetVehicleZAngle(PI[playerid][Vehicle], _pos[3]);
	return PutPlayerInVehicle(playerid, PI[playerid][Vehicle], 0);
}

@__getPlayerSettings(playerid)
{
	if(cache_num_rows())
	{
		cache_get_value_name_int(0, "cammode", PS[playerid][CAMMODE]);
		cache_get_value_name_int(0, "autorepair", PS[playerid][AUTOREPAIR]);
		cache_get_value_name_int(0, "collision", PS[playerid][COLLISION]);
		cache_get_value_name_int(0, "godmode", PS[playerid][GODMODE]);
		cache_get_value_name_int(0, "invite", PS[playerid][INVITE]);
		cache_get_value_name_int(0, "nicknames", PS[playerid][NICKS]);
		cache_get_value_name_int(0, "sms", PS[playerid][SMS]);
		cache_get_value_name_int(0, "teleport", PS[playerid][TELEPORT]);
		cache_get_value_name_int(0, "button", PS[playerid][BUTTON]);
		if(PS[playerid][GODMODE]) SetPlayerHealth(playerid, 10000000.0);
	}else{
	    format(str_local, sizeof str_local, "INSERT INTO `settings` (`id`) VALUES ('%d')", PI[playerid][ID]);
	    mysql_tquery(mysqlHandle, str_local);
	    PS[playerid][CAMMODE] = false;
	    PS[playerid][AUTOREPAIR] = true;
 	    PS[playerid][COLLISION] = true;
	    PS[playerid][GODMODE] = true;
	    PS[playerid][INVITE] = true;
	    PS[playerid][NICKS] = true;
	    PS[playerid][SMS] = true;
	    PS[playerid][TELEPORT] = false;
	    PS[playerid][BUTTON] = false;
	}
}

stock SaveSettings(playerid)
{
    format(str_local, sizeof str_local, "UPDATE `settings` SET `cammode` = '%d', `autorepair` = '%d', `collision` = '%d', `godmode` = '%d', `invite` = '%d', \
	`nicknames` = '%d', `sms` = '%d', `teleport` = '%d', `button` = '%d' \
	WHERE `id` = '%d'", PS[playerid][CAMMODE], PS[playerid][AUTOREPAIR], PS[playerid][COLLISION], PS[playerid][GODMODE],
	PS[playerid][INVITE], PS[playerid][NICKS], PS[playerid][SMS], PS[playerid][TELEPORT], PS[playerid][BUTTON], PI[playerid][ID]);
 	mysql_tquery(mysqlHandle, str_local);
}

stock TeleportTo(playerid, Float:X, Float:Y, Float:Z, Float:R, Interior = 0, World = 0)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
	{
	    SetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z);
	    SetVehicleZAngle(GetPlayerVehicleID(playerid), R);
	}else{
	    SetPlayerPos(playerid, X, Y, Z);
	    SetPlayerFacingAngle(playerid, R);
	}
	
	SetPlayerInterior(playerid, Interior);
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) LinkVehicleToInterior(GetPlayerVehicleID(playerid), Interior);
	if(World)
	{
	    SetPlayerVirtualWorld(playerid, World);
	    SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), World);
	}
	return 1;
}

#define MAX_PLAYER_TELEPORTS 25
enum TELEPORTS_INFO
{
	Name[50],
	Float:X,
	Float:Y,
	Float:Z,
	Float:R,
	Interior,
	ID
}
new Float:PT[MAX_PLAYERS][MAX_PLAYER_TELEPORTS][TELEPORTS_INFO];
new AllPT[MAX_PLAYERS];
@__getPlayerTeleports(playerid)
{
    for(new i = 0; i < MAX_PLAYER_TELEPORTS; i++) format(PT[playerid][i][Name], 50, "");
	if(cache_num_rows())
	{
	    AllPT[playerid] = 0;
		for(new i = 0; i < cache_num_rows(); i++)
		{
		    AllPT[playerid]++;
		    new time[30];
		    cache_get_value_name(i, "Name", PT[playerid][i][Name]);
		    cache_get_value_name_float(i, "X", PT[playerid][i][X]);
		    cache_get_value_name_float(i, "Y", PT[playerid][i][Y]);
		    cache_get_value_name_float(i, "Z", PT[playerid][i][Z]);
		    cache_get_value_name_float(i, "R", PT[playerid][i][R]);
		    cache_get_value_name_int(i, "Interior", PT[playerid][i][Interior]);
		    cache_get_value_name(i, "CreateAt", time);
		    PT[playerid][i][ID] = strval(time);
		}
	}
}

GetFreePT(playerid)
{
	for(new i = 0; i < MAX_PLAYER_TELEPORTS; i++)
	{
	    if(!strlen(PT[playerid][i][Name])) return i;
	}
	return 0;
}

EditTP(playerid, listitem)
{
	new title[50 + 13];
	LT[playerid] = FindPT(playerid, listitem);
	format(title, sizeof(title), "Телепорт %s", PT[playerid][listitem][Name]);
 	format(str_local, sizeof(str_local), "\
		{b5b5b5}» {FFFFF9}Телепортироваться\n\
	    {b5b5b5}» {FFFFF9}Изменить название\n\
	    {b5b5b5}» {FFFFF9}Удалить");
    return ShowPlayerDialog(playerid, DIALOG_PLAYER_TELEPORT_EDIT, DIALOG_STYLE_LIST, title, str_local, "Далее", "Назад");
}

FindPT(playerid, const listitem)
{
	for(new i = 0; i < MAX_PLAYER_TELEPORTS; i++)
	{
	    if(i >= listitem)
	    {
	        if(strlen(PT[playerid][i][Name])) return i;
	    }
	}
	return 0;
}

ChangeTP(playerid) return ShowPlayerDialog(playerid, DIALOG_PLAYER_TELEPORT_CHANGE, DIALOG_STYLE_INPUT, "Изменение телепорта » Название", "{FFFFF9}Ниже введите новое название телепорта:\n(Макс. 50 символов)", "Далее", "Назад");
CreateTP(playerid) return ShowPlayerDialog(playerid, DIALOG_PLAYER_TELEPORT_NAME, DIALOG_STYLE_INPUT, "Создание телепорта » Название", "{FFFFF9}Ниже введите название будущего телепорта:\n(Макс. 50 символов)", "Далее", "Назад");
MyTeleports(playerid, bool:sort = false)
{
	if(sort)
	{
 		for(new j = 0; j < MAX_PLAYER_TELEPORTS - 1; j++)
		{
			if(!strlen(PT[playerid][j][Name]) && strlen(PT[playerid][j + 1][Name]))
			{
			    format(PT[playerid][j][Name], 50, PT[playerid][j + 1][Name]);
   				PT[playerid][j + 1][Name][0] = EOS;
   				PT[playerid][j][X] = PT[playerid][j + 1][X];
   				PT[playerid][j][Y] = PT[playerid][j + 1][Y];
   				PT[playerid][j][Z] = PT[playerid][j + 1][Z];
   				PT[playerid][j][R] = PT[playerid][j + 1][R];
   				PT[playerid][j][Interior] = PT[playerid][j + 1][Interior];
   				PT[playerid][j][ID] = PT[playerid][j + 1][ID];
   				
   				PT[playerid][j + 1][X] = 0.0;
   				PT[playerid][j + 1][Y] = 0.0;
   				PT[playerid][j + 1][Z] = 0.0;
   				PT[playerid][j + 1][R] = 0.0;
   				PT[playerid][j + 1][ID] = 0;
   				PT[playerid][j + 1][Interior] = 0;
			}
		}
		return MyTeleportsMenu(playerid);
	}
	MyTeleportsMenu(playerid);
	return 1;
}

MyTeleportsMenu(playerid)
{
	new title[26];
 	strcat(title, "Телепорты » Мои телепорты");
 	str_local[0] = EOS;
    strcat(str_local, "{b5b5b5}» {ccffcc}Создать телепорт\n");
	for(new i = 0; i < MAX_PLAYER_TELEPORTS; i++)
 	{
		if(strlen(PT[playerid][i][Name]))
		{
			strcat(str_local, "{b5b5b5}» {FFFFF9}");
			strcat(str_local, PT[playerid][i][Name]);
			strcat(str_local, "\n");
		}
	}
	return ShowPlayerDialog(playerid, DIALOG_PLAYER_TELEPORTS, DIALOG_STYLE_LIST, title, str_local, "Далее", "Назад");
}

stock GetPlayerPosition(playerid, &Float:x, &Float:y, &Float:z, &Float:r)
{
    GetPlayerPos(playerid, x, y, z);
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) GetPlayerFacingAngle(playerid, r);
	else GetVehicleZAngle(GetPlayerVehicleID(playerid), r);
}

LeaveGang(playerid, bool:accept = false)
{
	if(accept)
	{
	    if(PI[playerid][Rang] >= 3)
	    {
	        format(str_local, sizeof str_local, "UPDATE `players` SET `gang` = '0', `rang` = '0' \
			WHERE `gang` = '%d'", PI[playerid][Gang]);
			mysql_tquery(mysqlHandle, str_local);

			mysql_format(mysqlHandle,str_local, sizeof(str_local), "DELETE FROM `gangs` WHERE `id` = '%d'", PI[playerid][Gang]);
			mysql_tquery(mysqlHandle, str_local);

			GI[PI[playerid][Gang]][Created] = false;
			GI[PI[playerid][Gang]][Color][0] = EOS;
			GI[PI[playerid][Gang]][Name][0] = EOS;
			GI[PI[playerid][Gang]][Time] = 0;

			for(new i = 0; i < MAX_PLAYERS; i++)
			{
			    if(PI[i][Auth] && PI[i][Gang] == PI[playerid][Gang] && playerid != i)
				{
				    PI[i][Gang] = 0;
	   				PI[i][Rang] = 0;
				}
			}
			SendClientMessage(playerid, -1, " Банда была удалена.");
	    }
	    PI[playerid][Gang] = 0;
	    PI[playerid][Rang] = 0;
	}else{
		if(PI[playerid][Rang] >= 3) ShowPlayerDialog(playerid, DIALOG_GANG_LEAVE, DIALOG_STYLE_MSGBOX, "Банды » Покинуть банду", "{FFFFFF}Вы уверены что хотите покинуть банду?\n{b5b5b5}- Банда будет полностью расформирована", "Да", "Нет");
		else ShowPlayerDialog(playerid, DIALOG_GANG_LEAVE, DIALOG_STYLE_MSGBOX, "Банды » Покинуть банду", "{FFFFFF}Вы уверены что хотите покинуть банду?", "Да", "Нет");
	}
    return 1;
}

InfoGang(playerid)
{
	if(!PI[playerid][Gang]) return 0;
	else{
	    format(str_local, sizeof str_local, "SELECT * FROM `gangs` WHERE `id` = '%d'", PI[playerid][Gang]);
 		return mysql_tquery(mysqlHandle, str_local, "@__getGangInfo", "i", playerid);
	}
}

@__getGangInfo(playerid)
{
	if(cache_num_rows())
	{
	    format(str_local, sizeof(str_local), "\
	        {b5b5b5}Название:\t{%s}%s\n\
     		{b5b5b5}Цвет:\t{%s}|||||||\n\
     		{b5b5b5}Дата создания:\t%s\n\
     		{b5b5b5}Лидер:\t{FFFFFF}%s\n\
     		{b5b5b5}Участников:\t{FFFFFF}%d\
		", GI[PI[playerid][Gang] - 1][Color], GI[PI[playerid][Gang] - 1][Name], GI[PI[playerid][Gang] - 1][Color], date("%dd.%mm.%yyyy", GI[PI[playerid][Gang] - 1][Time]), GI[PI[playerid][Gang] - 1][Leader], GI[PI[playerid][Gang] - 1][Members]);
		return ShowPlayerDialog(playerid, DIALOG_GANG_INFO, DIALOG_STYLE_TABLIST, "Информация о банде", str_local, "Назад", "");
	}
	return 0;
}

CheckMembers(playerid, const gangid)
{
	if(!gangid) return 0;
    format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `gang` = '%d' ORDER BY `invitetime` ASC;", gangid);
 	return mysql_tquery(mysqlHandle, str_local, "@__getGangMembers", "i", playerid);
}

@__getGangMembers(playerid)
{
	if(cache_num_rows())
	{
		format(str_local, sizeof(str_local), "{FFFFFF}Никнейм\t{FFFFFF}Ранг\t{FFFFFF}Дата\t{FFFFFF}Статус");
	    for(new i = 0; i < cache_num_rows(); i++)
	    {
			new name[MAX_PLAYER_NAME + 1], rang, invitetime, status[8 + 8 + 2], rangname[13];
			cache_get_value_name(i, "name", name);
			cache_get_value_name_int(i, "rang", rang);
			cache_get_value_name_int(i, "invitetime", invitetime);
			new table[MAX_PLAYER_NAME + 2 + 40 + 2];
			switch(rang)
			{
			    case 1: rangname = "Новичёк";
			    case 2: rangname = "Управляющий";
			    case 3: rangname = "Лидер";
			}
			format(table, sizeof(table), "\n{FFFFF9}%s\t{FFF333}%s\t%s", name, rangname, date("%dd.%mm.%yyyy", invitetime));
			format(status, sizeof(status), "\t{b5b5b5}OFFLINE");
			for(new j = 0; j < MAX_PLAYERS; j++)
			{
			    if(strcmp(PI[j][Name], name) != -1)
			    {
                    format(status, sizeof(status), "\t{19ff19}ONLINE");
                    break;
			    }
			}
			strcat(str_local, table);
			strcat(str_local, status);
	    }
	    switch(PI[playerid][Rang])
		{
			case 1: ShowPlayerDialog(playerid, DIALOG_GANG_MEMBERS, DIALOG_STYLE_TABLIST_HEADERS, "Банда » Посмотреть участников", str_local, "Назад", "");
			case 2,3: ShowPlayerDialog(playerid, DIALOG_GANG_MEMBERS, DIALOG_STYLE_TABLIST_HEADERS, "Банда » Посмотреть участников", str_local, "Далее", "Назад");
		}
	}
}

InviteGang(playerid, const text[] = EOS)
{
	if(GI[PI[playerid][Gang] - 1][Members] >= 100) return SendPlayerError(playerid, "Лимит участников! (100шт)");
	format(str_local, sizeof(str_local), "{FFFFFF}Введите ниже ID игрока которого хотите пригласить:\n{FF3000}%s", text);
	return ShowPlayerDialog(playerid, DIALOG_GANG_INVITE, DIALOG_STYLE_INPUT, "Банда » Пригласить", str_local, "Далее", "Назад");
}

@__getMemberInfo(playerid, const listitem, const mode, const inputtext[])
{
	if(cache_num_rows())
	{
	    new id, name[MAX_PLAYER_NAME + 1], color;
	    cache_get_value_name(listitem, "name", name);
	    new rang;
	    cache_get_value_name_int(listitem, "rang", rang);
	    if(rang >= 3) return SendPlayerError(playerid, "Невозможно взаимодействовать с лидером!");
		if(!strcmp(PI[playerid][Name], name)) SendPlayerError(playerid, "Вы не можете взаимодействовать с собой!");
		else{
		    cache_get_value_name_int(listitem, "id", id);
			cache_get_value_name_int(listitem, "color", color);
		    switch(mode)
			{
			    case 0: return ShowPlayerDialog(playerid, DIALOG_GANG_MEMBERS_SWITCH, DIALOG_STYLE_LIST, name, "{b5b5b5}» {FFFFF9}Выдать ранг\n{b5b5b5}» {FFFFF9}Кикнуть", "Далее", "Назад");//Показать информацию
			    case 1:
				{
					format(str_local, sizeof(str_local), "{FFFFFF}Выдача ранга игроку {%0.6x}%s\n\n{FFFFFF}Возможности уровней:\n\
					\n{b5b5b5}Ранг 1: (Новичок)\n\
					\t{FFFFFF}Просмотр участников\n\
					\n{b5b5b5}Ранг 2: (Управляющий)\n\
					\t{FFFFFF}Просмотр участников\n\
					\tПриглашать / Исключать участников\n\
					\n{b5b5b5}Ранг 3: (Лидер)\n\
					\t{FFFFFF}Просмотр участников\n\
					\tПриглашать / Исключать участников\n\
					\tИзменение названия банды\n\
					\tИзменение цвета банды", cutAlpha(Colors[color]), name);
					return ShowPlayerDialog(playerid, DIALOG_GANG_MEMBERS_RANG, DIALOG_STYLE_INPUT, "Выдать ранг", str_local, "Далее", "Назад");//Выдать ранг
				}
			    case 2: //Кик
				{
					format(str_local, sizeof str_local, "UPDATE `players` SET `gang` = '0', `rang` = '0' \
				 	WHERE `id` = '%d'", id);
		 			mysql_tquery(mysqlHandle, str_local);
     				for( new i = 0; i < MAX_PLAYERS; i++ )
					{
						if(PI[i][Auth])
						{
						    if(!strcmp(PI[i][Name], name))
						    {
						        switch(numberdialog[playerid])
								{
									case DIALOG_GANGS, DIALOG_GANG_MEMBERS, DIALOG_GANG_INVITE, DIALOG_GANG_INVITE_ACCEPT, DIALOG_GANG_MEMBERS_SWITCH, DIALOG_GANG_MEMBERS_RANG, DIALOG_GANG_LEAVE, DIALOG_GANG_INFO: HidePlayerDialog(i);
								}
						        PI[i][Gang] = 0;
						        PI[i][Rang] = 0;
						        SendClientMessage(i, -1, " Вы были исключены из банды");
						        break;
						    }
						}
					}
				 	format(str_local, sizeof(str_local), " %s {FFFFFF}- исключён из банды", name);
					SendClientMessage(playerid, Colors[color], str_local);
					GI[PI[playerid][Gang] - 1][Members]--;
				}
				default: //Выдача ранга
				{
				    format(str_local, sizeof str_local, "UPDATE `players` SET `rang` = '%d' \
					WHERE `id` = '%d'", strval(inputtext), id);
				 	mysql_tquery(mysqlHandle, str_local);
					for( new i = 0; i < MAX_PLAYERS; i++ )
					{
						if(PI[i][Auth])
						{
						    if(strcmp(PI[i][Name], name, false) == 0)
						    {
						        PI[i][Rang] = strval(inputtext);
						        break;
						    }
						}
					}
				 	if(PI[playerid][Rang] == 3 && strval(inputtext) >= 3)
					{
					    format(str_local, sizeof str_local, "UPDATE `players` SET `rang` = '%d'  WHERE `id` = '%d'", PI[playerid][Rang], PI[playerid][ID]);
						mysql_tquery(mysqlHandle, str_local);
						format(str_local, sizeof(str_local), " %s {FFFFFF}передал владение бандой участнику {%0.6x}%s", PI[playerid][Name], cutAlpha(Colors[color]), name);
						PI[playerid][Rang] = 2;
						format(GI[PI[playerid][Gang] - 1][Leader], MAX_PLAYER_NAME + 1, name);
					}
				 	else format(str_local, sizeof(str_local), " %s {FFFFFF}выдал ранг [%d] участнику {%0.6x}%s", PI[playerid][Name], strval(inputtext), cutAlpha(Colors[color]), name);
					for( new i = 0; i < MAX_PLAYERS; i++ )
					{
					    if(PI[i][Gang] == PI[playerid][Gang]) SendClientMessage(i, Colors[PI[playerid][Color]], str_local);
					}
				}
			}
		}
	}else SendPlayerError(playerid, "Невозможно взаимодействовать с игроком. Возможно он был исключён");
	return CheckMembers(playerid, PI[playerid][Gang]);
}

CMD:weap(playerid, params[])
{
	new idweap;
	sscanf(params, "d", idweap);
	return GivePlayerWeapon(playerid, WEAPON:idweap, 1000);
}

new TempGangName[MAX_PLAYERS][MAX_GANG_NAME + 1];
stock CreateGang(playerid, const method = 0, const text[] = "", const color[] = "{FFFFFF}")
{
	switch(method)
	{
	    case 0:
		{
		    format(str_local, sizeof(str_local), "{FFFFFF}Придумайте название для банды:\n{FF0000}%s", text);
			ShowPlayerDialog(playerid, DIALOG_GANG_CREATE, DIALOG_STYLE_INPUT, "Банды » Название", str_local, "Далее", "Назад");
		}
		case 1:
		{
		    format(str_local, sizeof(str_local), "{FFFFFF}Придумайте цвет для банды:\n{FF0000}%s", text);
			ShowPlayerDialog(playerid, DIALOG_GANG_COLOR, DIALOG_STYLE_INPUT, "Банды » Цвет", str_local, "Далее", "Назад");
		}
		default: //Создание банды
		{
			new const id = GetFreeGang();
			if(id == -1) SendPlayerError(playerid, "Лимит банд!");
			else{
			    PI[playerid][Gang] = id + 1;
			    PI[playerid][Rang] = 3;
			    SavePlayer(playerid);
			    format(GI[id][Color], 8 + 1, color);
			    format(GI[id][Name], MAX_GANG_NAME + 1, TempGangName[playerid]);
			    TempGangName[playerid][0] = EOS;
			    GI[id][Created] = true;
			    GI[id][Time] = gettime() - 25200;
			    format(str_local, sizeof str_local, "UPDATE `players` SET `invitetime` = '%d' WHERE `id` = '%d'", gettime() - 25200, PI[playerid][ID]);
				mysql_tquery(mysqlHandle, str_local);
       			format(str_local, sizeof str_local, "INSERT INTO `gangs` (`id`, `name`, `color`, `CreateAt`) VALUES ('%d', '%s', '%s', '%d')",
				id + 1,	GI[id][Name], GI[id][Color] ,GI[id][Time]);
				mysql_tquery(mysqlHandle, str_local);
				format(str_local, sizeof str_local, "SELECT * FROM `gangs` WHERE `id` = '%d'", id + 1);
     			mysql_tquery(mysqlHandle, str_local, "GangInfo", "i", playerid);
			}
		}
	}
}

public GangInfo(playerid)
{
	if(cache_num_rows())
	{
	    new id;
	    cache_get_value_name_int(0, "id", id);
	    format(str_local, sizeof(str_local), " Банда {%s}%s {FFFFFF}успешно создана {b5b5b5}| ID: %d | {FFFFFF}Дата создания: {b5b5b5}%s", GI[PI[playerid][Gang] - 1][Color], GI[PI[playerid][Gang] - 1][Name], id, date("%dd.%mm.%yyyy", GI[PI[playerid][Gang] - 1][Time]));
		SendClientMessage(playerid, -1, str_local);
		loadGangInfo(PI[playerid][Gang] - 1);
	}else SendPlayerError(playerid, "Банда не была создана, обратитесь к администрации");
}

GetFreeGang()
{
	for(new i = 0 ; i < MAX_GANGS; i++)
	{
	    if(!GI[i][Created]) return i;
	}
	return -1;
}
new inviteID[MAX_PLAYERS];

stock StyleFight(playerid)
{
    switch(GetPlayerFightingStyle(playerid))
	{
		// 
    	case FIGHT_STYLE_NORMAL: format(str_local, sizeof(str_local), "{b5b5b5}» {FFFFF9}Нормальный\t< {FF0000}Выбран\n{b5b5b5}» {FFFFF9}Бокс\t\n{b5b5b5}» {FFFFF9}Кунг-Фу\t\n{b5b5b5}» {FFFFF9}KneeHead\t\n{b5b5b5}» {FFFFF9}Grabkick\t\n{b5b5b5}» {FFFFF9}Elbow\t");
    	case FIGHT_STYLE_BOXING: format(str_local, sizeof(str_local), "{b5b5b5}» {FFFFF9}Нормальный\t\n{b5b5b5}» {FFFFF9}Бокс\t< {FF0000}Выбран\n{b5b5b5}» {FFFFF9}Кунг-Фу\t\n{b5b5b5}» {FFFFF9}KneeHead\t\n{b5b5b5}» {FFFFF9}Grabkick\t\n{b5b5b5}» {FFFFF9}Elbow\t");
    	case FIGHT_STYLE_KUNGFU: format(str_local, sizeof(str_local), "{b5b5b5}» {FFFFF9}Нормальный\t\n{b5b5b5}» {FFFFF9}Бокс\t\n{b5b5b5}» {FFFFF9}Кунг-Фу\t< {FF0000}Выбран\n{b5b5b5}» {FFFFF9}KneeHead\t\n{b5b5b5}» {FFFFF9}Grabkick\t\n{b5b5b5}» {FFFFF9}Elbow\t");
    	case FIGHT_STYLE_KNEEHEAD: format(str_local, sizeof(str_local), "{b5b5b5}» {FFFFF9}Нормальный\t\n{b5b5b5}» {FFFFF9}Бокс\t\n{b5b5b5}» {FFFFF9}Кунг-Фу\t\n{b5b5b5}» {FFFFF9}KneeHead\t< {FF0000}Выбран\n{b5b5b5}» {FFFFF9}Grabkick\t\n{b5b5b5}» {FFFFF9}Elbow\t");
    	case FIGHT_STYLE_GRABKICK: format(str_local, sizeof(str_local), "{b5b5b5}» {FFFFF9}Нормальный\t\n{b5b5b5}» {FFFFF9}Бокс\t\n{b5b5b5}» {FFFFF9}Кунг-Фу\t\n{b5b5b5}» {FFFFF9}KneeHead\t\n{b5b5b5}» {FFFFF9}Grabkick\t< {FF0000}Выбран\n{b5b5b5}» {FFFFF9}Elbow\t");
    	case FIGHT_STYLE_ELBOW: format(str_local, sizeof(str_local), "{b5b5b5}» {FFFFF9}Нормальный\t\n{b5b5b5}» {FFFFF9}Бокс\t\n{b5b5b5}» {FFFFF9}Кунг-Фу\t\n{b5b5b5}» {FFFFF9}KneeHead\t\n{b5b5b5}» {FFFFF9}Grabkick\t\n{b5b5b5}» {FFFFF9}Elbow\t< {FF0000}Выбран");
	}
	return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_TABLIST, "Персонализация » Стиль боя", str_local, "Далее", "Назад");
}

@__checkChangeName(playerid, const inputtext[])
{
	if(!cache_num_rows())
	{
	    format(str_local, 144, " %s сменил ник на {%0.6x}%s", getFullnameChat(playerid, true), cutAlpha(Colors[PI[playerid][Color]]), inputtext);
		SendClientMessageToAll(-1, str_local);
		SetPlayerName(playerid, inputtext);
		format(PI[playerid][Name], MAX_PLAYER_NAME + 1, inputtext);
		nicktime[playerid] = gettime() - 25200 + 900;
		format(str_local, sizeof str_local, "UPDATE `players` SET `changenametime` = '%d', `name` = '%s' WHERE `id` = '%d'", nicktime[playerid], inputtext, PI[playerid][ID]);
		mysql_tquery(mysqlHandle, str_local);
	}else ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Ник", "{FFFFFF}Ниже введите новый никнейм:\n{FF0000}(Примечание) Вы указали чужой ник!", "Далее", "Назад");
}

stock OpenColors(playerid, const listitem, const info[] = "")
{
	new title[40];
	new string[4096];
	switch(listitem)
	{
 		case 4: title = "Персонализация » Цвет ника";
   		case 5: title = "Персонализация » Цвет чата";
	}
	str_local[0] = EOS;
	new j = 0;
	for(new i = 0; i < sizeof(Colors); i++)
	{
		if(j >= 7)
  		{
			j = 0;
  			format(string, sizeof(string), "%s{%0.6x}%03d\t\n", string, cutAlpha(Colors[i]), i);
     		continue;
		}
		format(string, sizeof(string), "%s{%0.6x}%03d\t", string, cutAlpha(Colors[i]), i);
		j++;
	}
	format(string, sizeof(string), "%s\n\n{FFFFF9}Ниже введите номер цвета:\n{FF0000}%s", string, info);
	return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, title, string, "Далее", "Назад");//Цвет ника
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	str_local[0] = EOS;
	numberdialog[playerid] = dialogid;
	switch(dialogid)
	{
		case DIALOG_WEAPONS_BUY:
		{
		    if(response)
		    {
                if(PS[playerid][GODMODE])
				{
				    PS[playerid][GODMODE] = false;
				    SetPlayerHealth(playerid, 100);
					SendClientMessage(playerid, -1, "Режим бессмертия был {FF2300}выключен");
				}
				switch(LT[playerid])
				{
				    case 2:
					{
					    switch(listitem)
					    {
					        case 0: GivePlayerWeapon(playerid, WEAPON:4, 1);
					        case 1: GivePlayerWeapon(playerid, WEAPON:2, 1);
					        case 2: GivePlayerWeapon(playerid, WEAPON:3, 1);
					        case 3: GivePlayerWeapon(playerid, WEAPON:5, 1);
					        case 4: GivePlayerWeapon(playerid, WEAPON:6, 1);
					        case 5: GivePlayerWeapon(playerid, WEAPON:7, 1);
					        case 6: GivePlayerWeapon(playerid, WEAPON:8, 1);
					        case 7: GivePlayerWeapon(playerid, WEAPON:9, 1);
					        case 8: GivePlayerWeapon(playerid, WEAPON:10, 1);
					    }
					}
				    case 3:
				    {
				        switch(listitem)
					    {
					        case 0: GivePlayerWeapon(playerid, WEAPON:22, 150);
					        case 1: GivePlayerWeapon(playerid, WEAPON:23, 150);
					        case 2: GivePlayerWeapon(playerid, WEAPON:24, 150);
					    }
				    }
				    case 4:
				    {
				        switch(listitem)
					    {
					        case 0: GivePlayerWeapon(playerid, WEAPON:28, 350);
					        case 1: GivePlayerWeapon(playerid, WEAPON:29, 350);
					        case 2: GivePlayerWeapon(playerid, WEAPON:31, 350);
					        case 3: GivePlayerWeapon(playerid, WEAPON:30, 350);
					        case 4: GivePlayerWeapon(playerid, WEAPON:32, 350);
					    }
				    }
				    case 5:
				    {
                        switch(listitem)
					    {
					        case 0: GivePlayerWeapon(playerid, WEAPON:25, 350);
					        case 1: GivePlayerWeapon(playerid, WEAPON:26, 350);
					        case 2: GivePlayerWeapon(playerid, WEAPON:27, 350);
					    }
				    }
				    case 6:
				    {
				        switch(listitem)
					    {
					        case 0: GivePlayerWeapon(playerid, WEAPON:33, 350);
					        case 1: GivePlayerWeapon(playerid, WEAPON:34, 350);
					    }
				    }
				    case 7:
				    {
				        switch(listitem)
					    {
					        case 0: GivePlayerWeapon(playerid, WEAPON:41, 350);
					        case 1: GivePlayerWeapon(playerid, WEAPON:42, 350);
					        case 2: GivePlayerWeapon(playerid, WEAPON:43, 350);
					        case 3: GivePlayerWeapon(playerid, WEAPON:46, 1);
							case 4: GivePlayerWeapon(playerid, WEAPON:1, 1);
							case 5: GivePlayerWeapon(playerid, WEAPON:12, 1);
							case 6: GivePlayerWeapon(playerid, WEAPON:14, 1);
							case 7: GivePlayerWeapon(playerid, WEAPON:15, 1);
							case 8: GivePlayerWeapon(playerid, WEAPON:16, 10);
							case 9: GivePlayerWeapon(playerid, WEAPON:18, 10);
							case 10: GivePlayerWeapon(playerid, WEAPON:17, 10);
					    }
				    }
				}
				Weapons(playerid, LT[playerid]);
		    }else Weapons(playerid);
		}
	    case DIALOG_WEAPONS:
	    {
	        if(response) return Weapons(playerid, listitem + 1);
	        else Menu(playerid);
	    }
	    case DIALOG_SETTINGS_1:
	    {
			if(response)
			{
				switch(listitem)
				{
				    case 0..8:
				    {
				        switch(listitem + 1)
				        {
				            case 1: PS[playerid][CAMMODE] = !PS[playerid][CAMMODE];
				            case 2: PS[playerid][AUTOREPAIR] = !PS[playerid][AUTOREPAIR];
				            case 3: PS[playerid][COLLISION] = !PS[playerid][COLLISION];
				            case 4:
							{
								PS[playerid][GODMODE] = !PS[playerid][GODMODE];
								switch(PS[playerid][GODMODE])
								{
								    case 0: SetPlayerHealth(playerid, 100.0);
								    case 1: SetPlayerHealth(playerid, 10000000.0);
								}
							}
				            case 5: PS[playerid][INVITE] = !PS[playerid][INVITE];
				            case 6: PS[playerid][NICKS] = !PS[playerid][NICKS];
				            case 7: PS[playerid][SMS] = !PS[playerid][SMS];
				            case 8: PS[playerid][TELEPORT] = !PS[playerid][TELEPORT];
				            case 9: PS[playerid][BUTTON] = !PS[playerid][BUTTON];
				        }
				        Settings(playerid);
				    }
				}
			}
			else Menu(playerid);
	    }
		case DIALOG_CHANGE_SETTINGS:
		{
		    if(response)
		    {
				switch(LT[playerid])
				{
				    case 0:
					{
					    switch(listitem)
					    {
					        case 0..3: SetPlayerFightingStyle(playerid, FIGHT_STYLE:(listitem + 4));
							default: SetPlayerFightingStyle(playerid, FIGHT_STYLE:(listitem + 11));
					    }
					    StyleFight(playerid);
					}// стиль боя
				    case 1:
					{
					    if(strlen(inputtext))
					    {
					    	if(strval(inputtext) > 311 || strval(inputtext) < 0)
								return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Скин", "{FFFFFF}Ниже введите ID скина {FF0000}(От 0 до 311!){FFFFFF}:", "Далее", "Назад");
					    	PI[playerid][Skin] = strval(inputtext);
                        	SetPlayerSkin(playerid, strval(inputtext));
                        	format(str_local, sizeof str_local, "UPDATE `players` SET `skin` = '%d' WHERE `id` = '%d'", strval(inputtext), PI[playerid][ID]);
							mysql_tquery(mysqlHandle, str_local);
						}else ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Скин", "{FFFFFF}Ниже введите ID скина (От 0 до 311!):\n{FF0000}Вы ничего не указали!", "Далее", "Назад");
					}// скин
				    case 2:
					{
					    if(strlen(inputtext))
					    {
					    	if(strval(inputtext) > 23 || strval(inputtext) < 0)
								return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Время", "{FFFFFF}Ниже введите время {FF0000}(в часах от 0 до 23!){FFFFFF}:", "Далее", "Назад");
					    	PI[playerid][Time] = strval(inputtext);
                        	SetPlayerTime(playerid, strval(inputtext), 0);
                        	format(str_local, sizeof str_local, "UPDATE `players` SET `time` = '%d' WHERE `id` = '%d'", strval(inputtext), PI[playerid][ID]);
							mysql_tquery(mysqlHandle, str_local);
						}else ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Время", "{FFFFFF}Ниже введите время (в часах от 0 до 23!):\n{FF0000}Вы ничего не указали!", "Далее", "Назад");
					} // время
				    case 3:
					{
					    if(strlen(inputtext))
					    {
					    	if(strval(inputtext) > 9999 || strval(inputtext) < 0)
								return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Погода", "{FFFFFF}Ниже введите ID погоды {FF0000}(от 0 до 9999!){FFFFFF}:", "Далее", "Назад");
					    	PI[playerid][Weather] = strval(inputtext);
                        	SetPlayerWeather(playerid, strval(inputtext));
                        	format(str_local, sizeof str_local, "UPDATE `players` SET `weather` = '%d' WHERE `id` = '%d'", strval(inputtext), PI[playerid][ID]);
							mysql_tquery(mysqlHandle, str_local);
						}else ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Погода", "{FFFFFF}Ниже введите ID погоды (от 0 до 9999!):\n{FF0000}Вы ничего не указали!", "Далее", "Назад");
					}// погода
				    case 4,5:
				    {
						if(strlen(inputtext))
						{
						    new const color = strval(inputtext);
							if(color >= sizeof(Colors) || color < 0)
								return OpenColors(playerid, LT[playerid], "Такого цвета нет в списке!");
							switch(LT[playerid])
							{
							    case 4:
							    {
							        SetPlayerColor(playerid, Colors[color]);
							        PI[playerid][Color] = color;
							        format(str_local, sizeof str_local, "UPDATE `players` SET `color` = '%d' WHERE `id` = '%d'", strval(inputtext), PI[playerid][ID]);
							    }
							    case 5:
								{
									PI[playerid][ChatColor] = color;
									format(str_local, sizeof str_local, "UPDATE `players` SET `chatcolor` = '%d' WHERE `id` = '%d'", strval(inputtext), PI[playerid][ID]);
								}
							}
							mysql_tquery(mysqlHandle, str_local);
							Settings(playerid, true);
						}else OpenColors(playerid, LT[playerid], "Вы ничего не указали!");
				    }//цвет ника и чата
				    case 6:
					{
					    if(strlen(inputtext))
					    {
					        if(strcmp(PI[playerid][Name], inputtext, false) == 0)
					            return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Ник", "{FFFFFF}Ниже введите новый никнейм:\n{FF0000}(Примечание) Вы указали свой ник!", "Далее", "Назад");
							foreach(new i : Player)
							{
							    if(strcmp(PI[i][Name], inputtext, false) == 0)
							    	return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Ник", "{FFFFFF}Ниже введите новый никнейм:\n{FF0000}(Примечание) Вы указали чужой ник!", "Далее", "Назад");
							}
							if(strlen(inputtext) > 20)
								return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Ник", "{FFFFFF}Ниже введите новый никнейм:\n{FF0000}(Примечание) Длина ника максимум 20 символов!", "Далее", "Назад");
							if(strlen(inputtext) < 3)
							    return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Ник", "{FFFFFF}Ниже введите новый никнейм:\n{FF0000}(Примечание) Длина ника минимум 3 символа!", "Далее", "Назад");

                            for(new i = 0; i < strlen(inputtext); i++)
							{
								switch(inputtext[i])
								{
								    case 'A'..'Z': continue;
								    case 'a'..'z': continue;
								    case '0'..'9': continue;
								    case '_', '@', '[', ']', '(', ')', '.': continue;
								    default:
								    {
										format(str_local, sizeof(str_local), "{FFFFFF}Ниже введите новый никнейм:\n{FF0000}(Ошибка) Замечен неподходящий символ: %s", inputtext[i]);
										return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Ник", str_local, "Далее", "Назад");
								    }
								}
							}

                            format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `name` = '%s'", inputtext);
 							mysql_tquery(mysqlHandle, str_local, "@__checkChangeName", "is", playerid, inputtext);
						}else ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Ник", "{FFFFFF}Ниже введите новый никнейм:\n{FF0000}(Примечание) Длина ника максимум 20 символов!", "Далее", "Назад");
					}// ник
				    case 7:
					{
					    if(strlen(inputtext))
					    {
					        if(strlen(inputtext) > MAX_PLAYER_PASSWORD || strlen(inputtext) < 6)
						 		return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Пароль", "{FFFFFF}Ниже введите новый пароль:\n{FF0000}(Примечание) Длина пароля не может быть меньше 6 или больше 144 символов!", "Далее", "Назад");//Пароль
						 		
						    for(new i = 0; i < strlen(inputtext); i++)
						    {
						        switch(inputtext[i])
						        {
						            case '\\':
						            {
						                format(str_local, sizeof(str_local), "{FFFFFF}Ниже введите новый пароль:\n{FF0000}(Ошибка) Замечен неподходящий символ: %s", inputtext[i]);
										return ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Пароль", str_local, "Далее", "Назад");
						            }
						        }
						    }
						    
							format(str_local, sizeof str_local, "UPDATE `players` SET `password` = MD5('%s') WHERE `id` = '%d'", inputtext, PI[playerid][ID]);
							mysql_tquery(mysqlHandle, str_local);
							SendClientMessage(playerid, -1, "Вы успешно изменили свой пароль на:");
							SendClientMessage(playerid, 0xb5b5b5FF, inputtext);
					    }
					}// пароль
				}
		    }
		    else Settings(playerid, true);
		}
	    case DIALOG_SETTINGS_2:
	    {
			if(response)
			{
			    LT[playerid] = listitem;
			    switch(listitem)
			    {
			        case 0: StyleFight(playerid);
			        case 1: ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Скин", "{FFFFFF}Ниже введите ID скина (от 0 до 311!):", "Далее", "Назад");//Скин
			        case 2: ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Время", "{FFFFFF}Ниже введите время (в часах от 0 до 23!):", "Далее", "Назад");//Время
			        case 3: ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Погода", "{FFFFFF}Ниже введите ID погоды (от 0 до 9999!):", "Далее", "Назад");//Погода
			        case 4,5: OpenColors(playerid, listitem);
			        case 6:
					{
					    if(nicktime[playerid] > gettime() - 25200)
					    {
					        format(str_local, sizeof(str_local), "Вы сможете сменить ник через: %s", date("%ii:%ss", nicktime[playerid] - (gettime() - 25200)));
							return SendPlayerError(playerid, str_local);
					    }
						ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Ник", "{FFFFFF}Ниже введите новый никнейм:\n{FFFFF9}(Примечание) Длина ника максимум 20 символов!", "Далее", "Назад");//Ник
					}
					case 7: ShowPlayerDialog(playerid, DIALOG_CHANGE_SETTINGS, DIALOG_STYLE_INPUT, "Персонализация » Пароль", "{FFFFFF}Ниже введите новый пароль:\n{FFFFF9}(Примечание) Длина пароля максимум 144 символа!", "Далее", "Назад");//Пароль
			    }
			}
			else Menu(playerid);
	    }
	    case DIALOG_GANG_INFO:
		{
		    if(!PI[playerid][Gang]) return 0;
			Gangs(playerid);
		}
	    case DIALOG_GANG_LEAVE:
	    {
	        if(!PI[playerid][Gang]) return 0;
	        if(response) LeaveGang(playerid, bool:response);
	        else Gangs(playerid);
	    }
	    case DIALOG_GANG_COLOR:
	    {
	        if(response)
	        {
    			if(strlen(inputtext))
	            {
	                if(strlen(inputtext) <= 6)
					{
        				for(new i = 0; i < 6; i++)
						{
						    switch(inputtext[i])
						    {
						        case 'A'..'F', 'a'..'f', '0'..'9': continue;
						        default:
						        {
						            CreateGang(playerid, 1, "Неверный формат цвета!");
						        	return 0;
						        }
						    }
					 	}
					 	if(PI[playerid][Gang])
					 	{
					 	    if(PI[playerid][Rang] >= 3)
					 	    {
					 	        format(GI[PI[playerid][Gang] - 1][Color], 6 + 1, inputtext);
					 	        format(str_local, sizeof str_local, "UPDATE `gangs` SET `color` = '%s' \
								WHERE `id` = '%d'", inputtext, PI[playerid][Gang]);
								mysql_tquery(mysqlHandle, str_local);
								Gangs(playerid);
					 	    }
					 	}else CreateGang(playerid, 2, "", inputtext);
					}
	                else CreateGang(playerid, 1, "Длина цвета банды не может быть больше 6 символов!");
	            }else CreateGang(playerid, 1, "Вы ничего не указали!");
	        }else{
	            if(PI[playerid][Gang])
			 	{
	    			if(PI[playerid][Rang] >= 3) Gangs(playerid);
				}else CreateGang(playerid, 0);
			}
	    }
	    case DIALOG_GANG_CREATE:
	    {
	        if(response)
	        {
	            if(strlen(inputtext))
	            {
	                if(strlen(inputtext) <= 50)
					{
					    if(PI[playerid][Gang])
					 	{
					 	    if(PI[playerid][Rang] >= 3)
					 	    {
					 	        format(GI[PI[playerid][Gang] - 1][Name], MAX_GANG_NAME, inputtext);
					 	        format(str_local, sizeof str_local, "UPDATE `gangs` SET `name` = '%s' \
								WHERE `id` = '%d'", inputtext, PI[playerid][Gang]);
								mysql_tquery(mysqlHandle, str_local);
								Gangs(playerid);
					 	    }
					 	}else{
						    format(TempGangName[playerid], MAX_GANG_NAME + 1, inputtext);
	        				for(new i = 0; i < strlen(inputtext); i++)
						    {
						        switch(inputtext[i])
						        {
						            case '\\': TempGangName[playerid][i] = ' ';
						        }
						    }
					     	CreateGang(playerid, 1);
						}
					}
	                else CreateGang(playerid, 0, "Длина названия банды не может быть больше 50 символов!");
	            }else CreateGang(playerid, 0, "Вы ничего не указали!");
	        }
	        else Gangs(playerid);
	    }
	    case DIALOG_GANG_MEMBERS_RANG:
	    {
	        if(!PI[playerid][Gang]) return 0;
	        if(response)
	        {
	            if(strlen(inputtext) && (strval(inputtext) <= 3 && strval(inputtext) >= 1))
	            {
	                format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `gang` = '%d' ORDER BY `invitetime` ASC;", PI[playerid][Gang]);
					return mysql_tquery(mysqlHandle, str_local, "@__getMemberInfo", "iiis", playerid, LT[playerid], 3, inputtext);
	            }else{
	                format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `gang` = '%d' ORDER BY `invitetime` ASC;", PI[playerid][Gang]);
					return mysql_tquery(mysqlHandle, str_local, "@__getMemberInfo", "iiis", playerid, LT[playerid], 1, "");
	            }
	        }
	        else
			{
			    format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `gang` = '%d' ORDER BY `invitetime` ASC;", PI[playerid][Gang]);
				return mysql_tquery(mysqlHandle, str_local, "@__getMemberInfo", "iiis", playerid, LT[playerid], 0, "");
			}
	    }
	    case DIALOG_GANG_MEMBERS_SWITCH:
	    {
	        if(!PI[playerid][Gang]) return 0;
	        if(response)
	        {
				format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `gang` = '%d' ORDER BY `invitetime` ASC;", PI[playerid][Gang]);
				return mysql_tquery(mysqlHandle, str_local, "@__getMemberInfo", "iiis", playerid, LT[playerid], listitem + 1, "");
	        }
			else CheckMembers(playerid, PI[playerid][Gang]);
	    }
		case DIALOG_GANG_MEMBERS:
		{
		    if(!PI[playerid][Gang]) return 0;
		    if(response)
		    {
		        if(PI[playerid][Rang] >= 2)
		        {
		            LT[playerid] = listitem;
		            format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `gang` = '%d' ORDER BY `invitetime` ASC;", PI[playerid][Gang]);
 					return mysql_tquery(mysqlHandle, str_local, "@__getMemberInfo", "iiis", playerid, listitem, 0, "");
		        }
		    }
			else Gangs(playerid);
		}
		case DIALOG_GANG_INVITE_ACCEPT:
		{
		    if(response)
			{
			    PI[playerid][Gang] = inviteID[playerid];
			    PI[playerid][Rang] = 1;
			    GI[PI[playerid][Gang] - 1][Members]++;
			    format(str_local, sizeof str_local, "UPDATE `players` SET `invitetime` = '%d', `gang` = '%d', `rang` = '%d'  WHERE `id` = '%d'", gettime() - 25200, PI[playerid][Gang], PI[playerid][Rang], PI[playerid][ID]);
				mysql_tquery(mysqlHandle, str_local);
			    format(str_local, sizeof(str_local), "- %s вступил в банду", getFullname(playerid));
				for( new i = 0; i < MAX_PLAYERS; i++ )
				{
				    if(PI[i][Gang] == inviteID[playerid]) SendClientMessage(i, -1, str_local);
				}
			}
		}
		case DIALOG_GANG_INVITE:
		{
		    if(!PI[playerid][Gang]) return 0;
		    if(response)
		    {
		        if(strlen(inputtext))
				{
					if(IsPlayerConnected(strval(inputtext)))
					{
					    if(playerid != strval(inputtext))
					    {
							if(!PI[strval(inputtext)][Auth]) return InviteGang(playerid, "Игрок, которого вы указали не авторизован!");
							if(PI[strval(inputtext)][Gang]) return InviteGang(playerid, "Игрок, которого вы указали уже находится в банде!");
							if(!PS[strval(inputtext)][INVITE]) return InviteGang(playerid, "Игрок, которого вы указали отключил возможность приглашать его!");
							else{
								inviteID[strval(inputtext)] = PI[playerid][Gang];
								format(str_local, sizeof(str_local), "%s пригласил Вас в банду: {%s}%s", getFullname(playerid), GI[PI[playerid][Gang] - 1][Color], GI[PI[playerid][Gang] - 1][Name]);
								ShowPlayerDialog(strval(inputtext), DIALOG_GANG_INVITE_ACCEPT, DIALOG_STYLE_MSGBOX, "Приглашение в банду", str_local, "Принять", "Отказ");
							}
						}else InviteGang(playerid, "Вы указали себя!");
					}else InviteGang(playerid, "Игрок, которого вы указали не подключён!");
				}else InviteGang(playerid, "Вы ничего не указали!");
		    }else Gangs(playerid);
		}
		case DIALOG_GANGS:
		{
		    if(response)
			{
				if(!PI[playerid][Gang]) CreateGang(playerid, 0);
				else{
				    if(!listitem) CheckMembers(playerid, PI[playerid][Gang]);
				    switch(PI[playerid][Rang])
				    {
				        case 1:
				        {
				            switch(listitem)
				            {
				                case 1: InfoGang(playerid); //Посмотреть информацию
								case 2: LeaveGang(playerid);
				            }
				        }
				        case 2:
				        {
				            switch(listitem)
				            {
				                case 1: InviteGang(playerid);
				                case 2: InfoGang(playerid); //Посмотреть информацию
								case 3: LeaveGang(playerid);
				            }
				        }
				        case 3:
				        {
				            switch(listitem)
				            {
				                case 1: InviteGang(playerid);
				                case 2: CreateGang(playerid, 0); //Изменить название
				                case 3: CreateGang(playerid, 1); //Изменить цвет
				                case 4: InfoGang(playerid); //Посмотреть информацию
								case 5: LeaveGang(playerid);
				            }
				        }
				    }
				}
		    }else Menu(playerid);
		}
	    case DIALOG_PLAYER_TELEPORT_CHANGE:
	    {
            if(response){
			    if(!strlen(inputtext))
			    {
			        SendPlayerError(playerid, "Вы оставили поле пустым!");
			        return CreateTP(playerid);
			    }
			    if(strlen(inputtext) > 50)
				{
				    SendPlayerError(playerid, "Название не может быть больше 50 символов!");
					return CreateTP(playerid);
				}
			    format(PT[playerid][LT[playerid]][Name], 50, inputtext);
			    format(str_local, sizeof str_local, "UPDATE `teleports` SET `Name` = '%s' WHERE `CreateAt` = '%d' AND `id` = '%d'", inputtext, PT[playerid][LT[playerid]][ID], PI[playerid][ID]);
 				mysql_tquery(mysqlHandle, str_local);
			    MyTeleports(playerid);
			}else EditTP(playerid, LT[playerid]);
	    }
		case DIALOG_PLAYER_TELEPORT_EDIT:
		{
		    if(response)
		    {
				switch(listitem)
				{
				    case 0: TeleportTo(playerid, PT[playerid][LT[playerid]][X], PT[playerid][LT[playerid]][Y], PT[playerid][LT[playerid]][Z], PT[playerid][LT[playerid]][R], PT[playerid][LT[playerid]][Interior]);
					case 1: ChangeTP(playerid);
					case 2:
				    {
						mysql_format(mysqlHandle,str_local, sizeof(str_local), "DELETE FROM `teleports` WHERE `CreateAt` = '%d' AND `id` = '%d'", PT[playerid][LT[playerid]][ID], PI[playerid][ID]);
		   				mysql_tquery(mysqlHandle, str_local);
		   				//
		   				PT[playerid][LT[playerid]][X] = 0.0;
						PT[playerid][LT[playerid]][Y] = 0.0;
						PT[playerid][LT[playerid]][Z] = 0.0;
						PT[playerid][LT[playerid]][R] = 0.0;
						PT[playerid][LT[playerid]][Name][0] = EOS;
						AllPT[playerid]--;
						MyTeleports(playerid, true);
				    }
				}
		    }else MyTeleports(playerid);
		}
		
		case DIALOG_PLAYER_TELEPORT_NAME:
		{
			if(response){
			    if(!strlen(inputtext))
			    {
			        SendPlayerError(playerid, "Вы оставили поле пустым!");
			        return CreateTP(playerid);
			    }
			    if(AllPT[playerid] >= MAX_PLAYER_TELEPORTS)
			    {
			        SendPlayerError(playerid, "Вы достигнули лимита своих телепортов!");
			        return MyTeleports(playerid);
			    }
				if(strlen(inputtext) > 50) return CreateTP(playerid);
				new Float:_pos[4];
				GetPlayerPosition(playerid, _pos[0], _pos[1], _pos[2], _pos[3]);
				AllPT[playerid]++;
				new const id = GetFreePT(playerid);
				new const time = gettime() - 25200;
				format(str_local, sizeof str_local, "INSERT INTO `teleports` (`id`, `Name`, `X`, `Y`, `Z`, `R`, `Interior`, `CreateAt`) VALUES ('%d', '%s', '%f', '%f', '%f', '%f', '%d', '%d')",
				PI[playerid][ID] , inputtext, _pos[0], _pos[1], _pos[2], _pos[3], GetPlayerInterior(playerid), time);
 				
				mysql_tquery(mysqlHandle, str_local);
				PT[playerid][id][X] = _pos[0];
				PT[playerid][id][Y] = _pos[1];
				PT[playerid][id][Z] = _pos[2];
				PT[playerid][id][R] = _pos[3];
				PT[playerid][id][ID] = time;
				format(PT[playerid][id][Name], 50, inputtext);
				PT[playerid][id][Interior] = GetPlayerInterior(playerid);
				MyTeleports(playerid);
			}
			else MyTeleports(playerid);
		}
		case DIALOG_PLAYER_TELEPORTS:
		{
		    if(response)
		    {
		        if(!listitem) CreateTP(playerid);
        		else EditTP(playerid, listitem - 1);
		    }else Teleports(playerid);
		}
	    case DIALOG_TELEPORTS:
	    {
	        if(response)
			{
				new title[50];
			    switch(listitem)
			    {
			        case 0:
			        {
						format(title, sizeof(title), "Телепорты » Дрифт места");
			            format(str_local, sizeof(str_local), "\
			            	{b5b5b5}» {FFFFF9}Ухо\n\
			            	{b5b5b5}» {FFFFF9}Холм SF\n\
			            	{b5b5b5}» {FFFFF9}Холм LS\n\
			            	{b5b5b5}» {FFFFF9}Порт LS\n\
			            	{b5b5b5}» {FFFFF9}Порт SF\n\
			            	{b5b5b5}» {FFFFF9}Открытая парковка\n\
			            	{b5b5b5}» {FFFFF9}Закрытая парковка\n\
			            	{b5b5b5}» {FFFFF9}Десяти этажка\n\
			            	{b5b5b5}» {FFFFF9}Колледж\n\
			            	{b5b5b5}» {FFFFF9}Склад LV");
			        }
			        case 1:
			        {
			            format(title, sizeof(title), "Телепорты » Дрифт трассы");
			            format(str_local, sizeof(str_local), "");
			        }
			        case 2:
			        {
			            format(title, sizeof(title), "Телепорты » Деревни");
			            format(str_local, sizeof(str_local), "\
				            {b5b5b5}» {FFFFF9}Angel Paine\n\
							{b5b5b5}» {FFFFF9}Blueberry\n\
							{b5b5b5}» {FFFFF9}Dillimore\n\
							{b5b5b5}» {FFFFF9}Montgomery\n\
							{b5b5b5}» {FFFFF9}Palomino Creek\n\
							{b5b5b5}» {FFFFF9}Fort Carson\n\
							{b5b5b5}» {FFFFF9}Las Barrancas\n\
							{b5b5b5}» {FFFFF9}El Quebrados\n\
							{b5b5b5}» {FFFFF9}Причал SF\n\
							{b5b5b5}» {FFFFF9}Las Payasadas");
			        }
			        case 3:
			        {
			            format(title, sizeof(title), "Телепорты » Города");
			            format(str_local, sizeof(str_local), "\
				            {b5b5b5}» {FFFFF9}Лос-Сантос\n\
							{b5b5b5}» {FFFFF9}Лас-Вентурас\n\
							{b5b5b5}» {FFFFF9}Сан-Фиерро");
			        }
			        case 4:
			        {
			            format(title, sizeof(title), "Телепорты » Разное");
			            format(str_local, sizeof(str_local), "\
				            {b5b5b5}» {FFFFF9}Зона 51\n\
							{b5b5b5}» {FFFFF9}Вайнвуд\n\
							{b5b5b5}» {FFFFF9}Грув стрит\n\
							{b5b5b5}» {FFFFF9}Заброшенный аэропорт\n\
							{b5b5b5}» {FFFFF9}Клуб Джиззи","Карьер\n\
							{b5b5b5}» {FFFFF9}Небоскрёб LS");
			        }
			        case 5: return MyTeleportsMenu(playerid);
				}
				LT[playerid] = listitem;
				ShowPlayerDialog(playerid, DIALOG_TELEPORTS_TO, DIALOG_STYLE_LIST, title, str_local, "Далее", "Назад");
			}else Menu(playerid);
	    }
	    case DIALOG_TELEPORTS_TO:
	    {
	        if(response)
	        {
	            switch(LT[playerid])
	            {
	                case 0:
	                {
	                    switch(listitem)
	                    {
	                        case 0: TeleportTo(playerid, -382.84, 1537.49, 75.35, 255.41);
	                        case 1: TeleportTo(playerid, -2399.11, -589.35, 132.64, 121.97);
	                        case 2: TeleportTo(playerid, 1253.10, -2060.65, 59.81, 267.88);
	                        case 3: TeleportTo(playerid, 2228.89, -2661.83, 13.54, 235.41);
	                        case 4: TeleportTo(playerid, -2755.08, 2345.28, 73.30, 283.92);
	                        case 5: TeleportTo(playerid, 2353.02, 1404.99, 42.82, 88.61);
	                        case 6: TeleportTo(playerid, 2225.01, 1963.73, 31.77, 269.46);
	                        case 7: TeleportTo(playerid, 2058.36, 2374.66, 49.53, 359.43);
	                        case 8: TeleportTo(playerid, 1030.12, 1167.26, 10.67, 176.59);
	                        case 9: TeleportTo(playerid, 1488.74, 1079.23, 10.82, 177.82 );
	                    }
	                }
	                case 1: return 1;
	                case 2:
	                {
	                    switch(listitem)
	                    {
	                        case 0: TeleportTo(playerid, -2210.692382, -2496.359375, 30.531381, 318.448577);
	                        case 1: TeleportTo(playerid, 379.847930, -140.493820, 3.596879, 87.357490);
	                        case 2: TeleportTo(playerid, 684.840393, -684.282653, 16.187500, 0.980785);
	                        case 3: TeleportTo(playerid, 1191.691894, 365.944427, 20.107706, 246.427749);
	                        case 4: TeleportTo(playerid, 2134.132080, 38.863071, 26.335937, 270.891082);
	                        case 5: TeleportTo(playerid, -191.019241, 937.934936, 14.831985, 359.670745);
	                        case 6: TeleportTo(playerid, -831.893432, 1398.218627, 13.609375, 23.715492);
	                        case 7: TeleportTo(playerid, -1624.958862, 2667.903320, 54.519145, 270.288024);
	                        case 8: TeleportTo(playerid, -2514.119140, 2432.411865, 16.810758, 211.589477);
	                        case 9: TeleportTo(playerid, -447.733825, 2715.213134, 63.117965, 272.504516);
	                    }
	                }
	                case 3:
	                {
	                    switch(listitem)
	                    {
	                        case 0: TeleportTo(playerid, 1130.005615,-1436.554687, 15.96875, 0.0);
	                        case 1: TeleportTo(playerid, 1677.176269, 1447.806762, 10.782345, 265.0);
	                        case 2: TeleportTo(playerid, -1753.548828, 954.116516, 24.400741, 88.841140);
	                    }
	                }
	                case 4:
	                {
	                    switch(listitem)
	                    {
	                        case 0: TeleportTo(playerid, 92.85, 1928.97, 18.04, 177.53);
	                        case 1: TeleportTo(playerid, 1242.99, -728.06, 95.3, 114.51);
	                        case 2: TeleportTo(playerid, 2515.853027, -1674.520385, 13.863158, 72.0);
	                        case 3: TeleportTo(playerid, 402.99, 2531.62, 16.55, 130.53);
	                        case 4: TeleportTo(playerid, -2612.64, 1402.41, 7.11, 61.62);
	                        case 5: TeleportTo(playerid, 672.53, 912.41, -40.47, 124.97);
	                        case 6: TeleportTo(playerid, 1544.35, -1353.12, 329.47, 89.86);
						}
	                }
	            }
	        }else Teleports(playerid);
	    }
		case DIALOG_WHEEL_ARCH_ANGELS:
		{
		    if(response)
		    {
		        switch(checkTuning(GetVehicleModel(PI[playerid][Vehicle])))
		        {
		            case 0:
		            {
		                SendPlayerError(playerid, "Ваш транспорт не подходит для установки модицикаций!");
		                Vehicles(playerid);
		            }
					case 1:
					{
					    switch(listitem)
					    {
        					case 0:
							{
							    VT[playerid][FRONT_BUMPER]++;
								AddTuning(playerid, listitem, VT[playerid][FRONT_BUMPER], 10);
							}
             				case 1:
						 	{
						 	    VT[playerid][REAR_BUMPER]++;
							 	AddTuning(playerid, listitem, VT[playerid][REAR_BUMPER], 11);
							}
				            case 2:
							{
							    VT[playerid][ROOF]++;
								AddTuning(playerid, listitem, VT[playerid][ROOF], 2);
							}
				            case 3:
							{
							    VT[playerid][SIDESKIRT]++;
								AddTuning(playerid, listitem, VT[playerid][SIDESKIRT], 3);
							}
				            case 4:
							{
							    VT[playerid][SPOILER]++;
								AddTuning(playerid, listitem, VT[playerid][SPOILER], 0);
							}
				            case 5:
							{
                                VT[playerid][EXHAUST]++;
								AddTuning(playerid, listitem, VT[playerid][EXHAUST], 6);
							}
				            case 6:
							{
							    VT[playerid][VINYL]++;
								AddTuning(playerid, listitem, VT[playerid][VINYL]);
							}
							case 7:
							{
							    VT[playerid][WHEELS]++;
							    if(VT[playerid][WHEELS] >= sizeof(Wheels))
								{
								    RemoveVehicleComponent(GetPlayerVehicleID(playerid), GetVehicleComponentInSlot(GetPlayerVehicleID(playerid), t_CARMODTYPE:7));
									VT[playerid][WHEELS] = 0;
									return Tuning(playerid);
								}
							    AddVehicleComponent(PI[playerid][Vehicle], strval(Wheels[VT[playerid][WHEELS] - 1][0]));
								Tuning(playerid);
							}
					    }
					}
		        }
		    }else Vehicles(playerid);
		}
		case DIALOG_VEHICLES_INPUT:
		{
		    if(response)
		    {
		        if(strlen(inputtext))
				{
				    if(strval(inputtext) >= 400 && strval(inputtext) <= 611) return CreatePlayerVehicle(playerid, strval(inputtext));
					for(new i = 0; i < sizeof(VehicleNames); i++)
					{
					    if(strfind(VehicleNames[i], inputtext, true) != -1) return CreatePlayerVehicle(playerid, i + 400);
					}
					VehicleInput(playerid, "Неизвестный транспорт!");
				}else VehicleInput(playerid, "Вы ничего не ввели!");
		    }else Vehicles(playerid, bool:PI[playerid][Vehicle]);
		}
		case DIALOG_VEHICLES_LIST:
		{
		    if(response)
		    {
		        CreatePlayerVehicle(playerid, ClassVehicles[ClickedList[playerid] - 1][listitem]);
		    }else Vehicles(playerid, bool:PI[playerid][Vehicle]);
		}
		case DIALOG_VEHICLES_2:
		{
		    if(response)
		    {
		   		switch(listitem)
				{
					case 0: VehicleInput(playerid);
	    			default:{
						ClickedList[playerid] = listitem;
						VehicleList(playerid, listitem);
     				}
				}
		    }else{
		        switch(bool:PI[playerid][Vehicle])
		        {
		            case false: Menu(playerid);
		            case true: Vehicles(playerid, false);
		        }
			}
		}
	    case DIALOG_VEHICLES:
	    {
	        if(response)
	        {
         		switch(listitem)
           		{
           		    case 0, 1:
           		    {
                     	if(!PI[playerid][Vehicle]) return SendPlayerError(playerid, "У вас нет своего транспорта!");
           		        if(GetPlayerVehicleID(playerid) == PI[playerid][Vehicle]) return SendPlayerError(playerid, "Вы уже находитесь в своём транспорте!");
           		        for( new i = 0; i < MAX_PLAYERS; i++ )
						{
							if(PI[i][Auth])
							{
								if(GetPlayerVehicleID(i) == PI[playerid][Vehicle] && GetPlayerState(i) == PLAYER_STATE_DRIVER)
								{
									Slap(i);
									break;
								}
							}
						}
						SetVehicleVirtualWorld(PI[playerid][Vehicle], GetPlayerVirtualWorld(playerid));
 						LinkVehicleToInterior(PI[playerid][Vehicle], GetPlayerInterior(playerid));
						switch(listitem)
						{
						    case 0: GetVehicle(playerid);
							case 1: PutPlayerInVehicle(playerid, PI[playerid][Vehicle], 0);
						}
           		    }
                 	case 2:
					{
					    if(!PI[playerid][Vehicle])
						{
						    Vehicles(playerid);
							return SendPlayerError(playerid, "У вас нет своего транспорта!");
						}
						if(!GetPlayerVehicleID(playerid)) return SendPlayerError(playerid, "Вы должны находиться в своём транспорте!");
						Tuning(playerid);
					}
             		case 3: Vehicles(playerid, true);
               	}
	        }else Menu(playerid);
		}
		case DIALOG_MENU:
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0: Vehicles(playerid);
		            case 1: Teleports(playerid);
					case 2: Weapons(playerid);
					case 3: Settings(playerid);
					case 4: Settings(playerid, true);
		            case 5: Gangs(playerid);
		        }
		    }
		}
	    case DIALOG_AUTH:
		{
		    if(response)
			{
				if(strlen(inputtext))
				{
					if(strlen(inputtext) > MAX_PLAYER_PASSWORD) SendPlayerError(playerid, "Длина пароля не может быть больше 144 символов!");
					else
					{
					    for(new i = 0; i < strlen(inputtext); i++)
					    {
					        switch(inputtext[i])
					        {
					            case '\\':
					            {
					                format(str_local, sizeof(str_local), "Вы указали запрещённый символ: %s", inputtext[i]);
					                SendPlayerError(playerid, str_local);
					                return firstDialog(playerid, bool:1);
					            }
					        }
					    }
					    format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `name` = '%s' AND `password` = MD5('%s')", PI[playerid][Name], inputtext);
 						mysql_tquery(mysqlHandle, str_local, "@__loadPlayerAccount", "i", playerid);
 						return 1;
					}
				}else SendPlayerError(playerid, "Вы ничего не ввели!");
				firstDialog(playerid, bool:1);
			}else Kick(playerid);
		}
		case DIALOG_REGISTER:
		{
		    if(response)
			{
				if(strlen(inputtext))
				{
				    if(strlen(inputtext) > MAX_PLAYER_PASSWORD || strlen(inputtext) < 6) SendPlayerError(playerid, "Длина пароля не может быть меньше 6 или больше 144 символов!");
					else
					{
						new password[MAX_PLAYER_PASSWORD + 1];
						format(password, MAX_PLAYER_PASSWORD + 1, inputtext);
					    for(new i = 0; i < strlen(inputtext); i++)
					    {
					        switch(inputtext[i])
					        {
						        case '\\':
		            			{
	                				format(str_local, sizeof(str_local), "Вы указали запрещённый символ: %s", inputtext[i]);
				                	SendPlayerError(playerid, str_local);
					                return firstDialog(playerid, bool:0);
					            }
							}
					    }
					    PI[playerid][Skin] = random(100+1);
					    format(str_local, sizeof str_local, "INSERT INTO `players` (`name`, `password`, `ip`, `gpci`, `skin`, `color`) VALUES ('%s', MD5('%s'), '%s', '%s', '%d', '%d')", PI[playerid][Name], password, PI[playerid][IP], PI[playerid][GPCI_player], PI[playerid][Skin], random(sizeof(Colors) - 1));
                		mysql_tquery(mysqlHandle, str_local);
                		format(str_local, sizeof str_local, "SELECT * FROM `players` WHERE `name` = '%s' AND `password` = MD5('%s')", PI[playerid][Name], inputtext);
 						mysql_tquery(mysqlHandle, str_local, "@__loadPlayerAccount", "i", playerid);
                		return 1;
					}
				}else SendPlayerError(playerid, "Вы ничего не ввели!");
				firstDialog(playerid, bool:0);
			}else Kick(playerid);
		}
	}
	return 1;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(!PI[playerid][Auth])
	{
	    SendPlayerError(playerid, "Вы должны быть авторизованы, прежде чем писать команды!");
	    return 0;
	}
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{

	switch(result)
	{
	    case 1: return 1;
	    default: SendPlayerError(playerid, "Неизвестная команда");
	}
	return 0;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    SetPlayerPosFindZ(playerid, fX, fY, fZ);
    return 1;
}


stock FIXES_strins(string[], const substr[], pos, maxlength = sizeof string)
{
	if (string[0] > 255)
	{
		new
			strlength = strlen(string),
			sublength = strlen(substr),
			m4 = maxlength * 4;
		if (strlength + sublength >= m4)
		{
			if (pos + sublength >= m4)
			{
				return
					string{pos} = '\0',
					strcat(string, substr, maxlength);
			}
			else string{maxlength - sublength - 1} = '\0';
		}
		return strins(string, substr, pos, maxlength);
	}
	else if (substr[0] > 255)
	{
		new
			strlength = strlen(string),
			sublength = strlen(substr);
		if (strlength + sublength >= maxlength)
		{
			if (pos + sublength >= maxlength)
			{
				return
					string[pos] = '\0',
					strcat(string, substr, maxlength);
			}
			else string[maxlength - sublength - 1] = '\0';
		}
		return strins(string, substr, pos, maxlength);
	}
	else return format(string, maxlength, "%.*s%s%s", pos, string, substr, string[pos]);
}

#if defined _ALS_strins
	#undef strins
#else
	#define _ALS_strins
#endif
#define strins FIXES_strins