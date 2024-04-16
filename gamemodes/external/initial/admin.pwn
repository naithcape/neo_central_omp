#include <ysilib\YSI_Coding\y_hooks>

new vCanDrive[MAX_VEHICLES];
new AdmVeh[MAX_PLAYERS] = { INVALID_VEHICLE_ID, ... };

IsPlayerAdminLevel(const playerid, const level)
{

	if (PlayerInfo[playerid][pAdmin] < level) 
	{ 
		SendClientMessage(playerid, -1, "Samo Admin Team moze ovo da uradi!"); 
		return 0;
	}

	else return 1;
}

new_RepairVehicle(vehicleid)
{
	RepairVehicle(vehicleid);
	SetVehicleHealth(vehicleid, 1000);
	return 1;
}

stock LoadObjects(playerid)
{
	TogglePlayerControllable(playerid, false);
	SendClientMessage(playerid, -1,  "Ucitavanje objekata, molimo sacekajte...");
    SetTimerEx("SlobodnoSada", 6000, false, "i", playerid );
	return 1;
}

hook OnPlayerConnect(playerid)
{
	AdmVeh[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	if (AdmVeh[playerid] != INVALID_VEHICLE_ID)
	{
		DestroyVehicle(AdmVeh[playerid]);
		AdmVeh[playerid] = INVALID_VEHICLE_ID;
	}

	return 1;
}

getPolForString(playerid, const string: str1[], const string: str2[])
{
	new str[5];
	switch(PlayerInfo[playerid][pSpol])
	{
		case 0: format(str, sizeof str, "%s", str1);
		case 1: format(str, sizeof str, "%s", str2);
	}
	return str;
}


hook CheckPlayerRename(renameid, playerid, string: newname[])
{
    if (cache_num_rows()) { SendClientMessage(playerid,  -1, "Novo ime vec postoji u bazi podataka!"); }
    else
	{
		SetPlayerName(renameid, newname);
		SendClientMessage(renameid,  -1,  "Admin %s vam je promeni%s ime u %s.", ReturnPlayerName(playerid), getPolForString(playerid, "o", "la"), ReturnPlayerName(renameid));
    }
    return 1;
}

fNumber(number, const separator[] = ".")
{
	new output[15];
	format(output, sizeof output, "%d", number);
 
	for(new i = strlen(output) - 3; i > 0 && output[i-1] != '-'; i -= 3) { strins(output, separator, i); }
	return output;
}

YCMD:a(playerid, const string: params[], help)
{
	if (help) { SendClientMessage(playerid, -1, ""color_yellow"HELP >> "color_white"Ova komanda je za Admin chat."); }

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	if (isnull(params)) { return SendClientMessage(playerid, -1,  "/a [tekst]"); }

	foreach (new i : Player)
		if (PlayerInfo[i][pAdmin])
			SendClientMessage(playerid, -1,  "[A] | %s(%d): "color_white"%s", ReturnPlayerName(playerid), playerid, params);
    return 1;
}

YCMD:goto(playerid, params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  ""color_yellow"HELP >> "color_white"Ovom komandom se teleportujete do drugog igraca."); }

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	static giveplayerid,
		   Float:plx, Float:ply, Float:plz;

	if (!sscanf(params, "u", giveplayerid))
	{	
		GetPlayerPos(giveplayerid, plx, ply, plz);
			
		if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, plx, ply+4, plz);
		}
		else { SetPlayerPos(playerid, plx, ply+2, plz); }
		SetPlayerInterior(playerid, GetPlayerInterior(giveplayerid));

		new string[128];
		format(string, sizeof string, "GOTO LOG: Igrac %s se /goto do %s", ReturnPlayerName(playerid), ReturnPlayerName(giveplayerid));

	}
    return 1;
}

YCMD:cc(playerid, params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  ""color_yellow"HELP >> "color_white"Ova komanda ce svima ocistiti chat."); }


	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	for (new cc; cc < 110; cc++)
	SendClientMessageToAll(-1, "");
	SendClientMessageToAll(0xFFFFFFFF, "** CC | Chat ociscen od strane Administratora.");

    return 1;
}
YCMD:fv(playerid, params[], help) = fixveh;
YCMD:fixveh(playerid, params[], help)
{
	if (help)
        return SendClientMessage(playerid, -1,  ""color_yellow"HELP >> "color_white"Ovom komandom fixate sebi vozilo.");

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	if (!IsPlayerInAnyVehicle(playerid)) { return SendClientMessage(playerid, -1,  "Nisi u vozilu!"); }

	new_RepairVehicle(GetPlayerVehicleID(playerid));

	return 1;
}

YCMD:gethere(playerid, const params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  ""color_yellow"HELP >> "color_white"Ovom komandom teleportujete odredjenog igraca do sebe."); }

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	new targetid = INVALID_PLAYER_ID;

	if (sscanf(params, "u", targetid)) { return SendClientMessage(playerid, -1,  "/gethere [id]"); }

	if (targetid == INVALID_PLAYER_ID) { return SendClientMessage(playerid, -1,  "Taj igrac nije konektovan!"); }

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(targetid, x+1, y, z+1);

	SetPlayerInterior(targetid, GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));

	SendClientMessage(playerid, -1,  "Teleportovao si igraca %s do sebe.", ReturnPlayerName(targetid));
	SendClientMessage(playerid, -1,  "Admin %s Vas je teleportovao do sebe.", ReturnPlayerName(playerid));

    return 1;
}

YCMD:nitro(playerid, params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  ""color_yellow"HELP >> "color_white"Ova komanda vam seta nitro u vozilo."); }

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);

	SendClientMessage(playerid, -1,  "Stavili ste u vase vozilo nitro!");

	return 1;
}

YCMD:jp(playerid, const string: params[], help) = jetpack;
YCMD:jetpack(playerid, const string: params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  "HELP >> "color_white"Uzmi/skini jetpack."); }

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	SetPlayerSpecialAction(playerid, (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) ? (SPECIAL_ACTION_NONE) : (SPECIAL_ACTION_USEJETPACK));

	return 1;
}

YCMD:setskin(playerid, const string: params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  ""color_yellow"HELP >> "color_white"Ovom komandom setas odredjenom igracu odredjeni skin."); }

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	static targetid, skinid;

	if (sscanf(params, "ri", targetid, skinid)) { return SendClientMessage(playerid, -1,  "/setskin [targetid] [skinid (1-311)]"); }

	if (!(1 <= skinid <= 311)) { return SendClientMessage(playerid, -1,  "Taj skin ne postoji!"); }

	if (GetPlayerSkin(targetid) == skinid) { return SendClientMessage(playerid, -1,  "Igrac vec ima taj skin!"); }

	SetPlayerSkin(targetid, skinid);

	PlayerInfo[targetid][pSkin] = skinid;

	new query[54];
    mysql_format(SQL_DB, query, sizeof query, "UPDATE `players` SET `Skin` = '%i' WHERE `ID` = '%i'", PlayerInfo[playerid][pSkin], PlayerInfo[playerid][pID]);
    mysql_tquery(SQL_DB, query);

    return 1;
}

YCMD:setweapon(playerid, const string: params[], help) 
{
	if (help) { return SendClientMessage(playerid, -1,  "HELP >> "color_white"Seta odredjeno oruzje igracu."); }

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	static targetid, weaponid, ammo;
	if (sscanf(params, "uk<weapon>i", playerid, weaponid, ammo)) { return SendClientMessage(playerid, -1,  "/setweapon [targetid] [weaponid] [ammo]"); }
	if (!(1 <= weaponid <= 46)) { return SendClientMessage(playerid, -1,  "Nisi unijeo validan weapon ID!"); }

	GivePlayerWeapon(targetid, WEAPON: weaponid, ammo);

	return 1;
}

YCMD:xgoto(playerid, params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  ""color_yellow"HELP >> "color_white"Ovom komandom se teleportujes to odredjenih koordinata."); }

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	new Float:x, Float:y, Float:z;

	if (sscanf(params, "fff", x, y, z)) { SendClientMessage(playerid, -1,  "xgoto <X Float> <Y Float> <Z Float>"); }
	else
	{
		if (IsPlayerInAnyVehicle(playerid)) { SetVehiclePos(GetPlayerVehicleID(playerid), x,y,z); }
		else { SetPlayerPos(playerid, x, y, z); }
		SendClientMessage(playerid, -1,  "Teleporoti si se do koordinata %f, %f, %f", x, y, z);
	}
 	return 1;
}

YCMD:setadmin(playerid, const string: params[], help) = makeadmin;
YCMD:makeadmin(playerid, const string: params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  ""color_yellow"HELP >> "color_white"0 - Revoke Admin | 1. Assistent | 2. Admin | 3.Assistent Manager | 4. Head Admin.| 5. Head Manager.| 6. Director.| 7. Founder/Developer."); }

	if (!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, -1,  "You Must Be RCON!");

	static targetid, level;

	if (sscanf(params, "ri", targetid, level)) { return SendClientMessage(playerid, -1,  "/makeadmin [targetid] [0-7]"); }

	if (!level && !PlayerInfo[targetid][pAdmin]) { return SendClientMessage(playerid, -1,  "Taj igrac vise nije dio Admin team-a."); }

	if (level == PlayerInfo[targetid][pAdmin]) { return SendClientMessage(playerid, -1,  "Taj igrac je vec Admin %i", level); }

	PlayerInfo[targetid][pAdmin] = level;
	
	if (!level)
	{
		SendClientMessage(targetid, -1, "%s vas je izbacio iz Admin Team-a", ReturnPlayerName(playerid));

		SendClientMessage(playerid, -1,  "Izbacio si %s iz Admin Team-a", ReturnPlayerName(targetid));
	}
	else if (level < 0 || level > 7) { return SendClientMessage(playerid, -1,  "Molimo vas da koristite "color_blue"-/help setadmin- "color_white"da vidite sve Admin levele."); }
	{

		SendClientMessage(targetid, -1, "%s vam je dao Admin Rank Level : %i", ReturnPlayerName(playerid), PlayerInfo[targetid][pAdmin]);

		SendClientMessage(playerid, -1,  "Dao si %s, Admin Rank Level : %i", ReturnPlayerName(targetid), PlayerInfo[targetid][pAdmin]);
	}

	new query[55];
    mysql_format(SQL_DB, query, sizeof query, "UPDATE `players` SET `Admin` = '%i' WHERE `ID` = '%i'", PlayerInfo[playerid][pAdmin], PlayerInfo[playerid][pID]);
    mysql_tquery(SQL_DB, query);
	
    return 1;
}

YCMD:kick(playerid, params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  ""color_yellow"HELP >> "color_white"Ovom komandom kikate odredjenog igraca sa servera."); }

	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	static targetid;

	if (sscanf(params, "r", targetid)) { return SendClientMessage(playerid, -1,  "/kick [targetid]"); }

	SendClientMessage(playerid, -1,  "%s vas je kick-a%s sa servera.", ReturnPlayerName(playerid), getPolForString(playerid, "o", "la"));

	SendClientMessage(playerid, -1,  "Kick-ali ste %s sa servera.", ReturnPlayerName(targetid));

	SetTimerEx("DelayedKick", 250, false, "i", targetid);

    return 1;
}

YCMD:veh(playerid, params[], help)
{
	if (help) { return SendClientMessage(playerid, -1,  "HELP >> "color_white"Sa ovom komandu spawnujete si vozilo koje zelite."); }


	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	if (AdmVeh[playerid] == INVALID_VEHICLE_ID) 
	{
		if (isnull(params))
			return SendClientMessage(playerid, -1, ""color_white"/veh [Model ID]");

		new modelid = strval(params);

		if (400 > modelid > 611)
			return SendClientMessage(playerid, -1,  ""color_white"* Ispravni ID Vozila od 400 do 611.");

		new vehicleid = AdmVeh[playerid] = CreateVehicle(modelid, x, y, z, 0.0, 1, 0, -1);

		SetVehicleNumberPlate(vehicleid, "APM");
		PutPlayerInVehicle(playerid, vehicleid, 0);
		
	    new bool:engine, bool:lights, bool:alarm, bool:doors, bool:bonnet, bool:boot, bool:objective;
	    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

	    if (IsVehicleBicycle(GetVehicleModel(vehicleid))) { SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, doors, bonnet, boot, objective); }
	    else { SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, doors, bonnet, boot, objective); }
		SendClientMessage(playerid, -1,  ""color_white"Kreirali ste vozilo, za unistenje vozila koristite "color_server"'/veh'.");
	}
	else 
	{
		DestroyVehicle(AdmVeh[playerid]);
		AdmVeh[playerid] = INVALID_VEHICLE_ID;
		SendClientMessage(playerid, -1,  ""color_white"Unistili ste vozilo, za kreiranje novog koristite "color_server"'/veh'.");
	}
	
    return 1;
}

YCMD:fvp( playerid, const string:params[], help )
{
    if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }

    new idigraca;
	if (sscanf( params, "r", idigraca)) { return SendClientMessage(playerid, -1,  "/fvp [id]"); }
	if (idigraca == INVALID_PLAYER_ID) { return SendClientMessage(playerid, -1,  "Pogresan ID igraca."); }
	if (!IsPlayerInAnyVehicle(idigraca)) { return SendClientMessage(playerid, -1,  "Igrac nije u vozilu!"); }
	if (GetPlayerState(idigraca) != PLAYER_STATE_DRIVER) { return SendClientMessage(playerid, -1,  "Igrac nije na mestu vozaca !"); }

	new Float:X, Float:Y, Float:Z, Float:A;
	GetPlayerPos( idigraca, X, Y, Z );
	GetVehicleZAngle(GetPlayerVehicleID(idigraca), A);
	SetVehicleZAngle(GetPlayerVehicleID(idigraca), A);
	new_RepairVehicle(GetPlayerVehicleID(idigraca));
	vCanDrive[GetPlayerVehicleID(idigraca)] = 1;

	SendClientMessage( idigraca, -1, "Admin {FFFFFF}%s {4282C0}vam je popravi%s vozilo.", ReturnPlayerName(playerid), getPolForString(playerid, "o", "la"));
	return 1;
}

YCMD:specnick(playerid, const string: params[], help)
{
	if (!IsPlayerAdminLevel(playerid, 1)) { return 1; }


	new id, newname[ MAX_PLAYER_NAME ];
	if (sscanf(params, "us[24]", id, newname)) { return SendClientMessage(playerid, -1,  "/specnick [id] [Ime_Prezime]"); }
    if (id == INVALID_PLAYER_ID) { return SendClientMessage(playerid, -1,  "Pogresan ID." ); }

    new query[128];
	mysql_format( SQL_DB, query, sizeof query, "SELECT `ID` FROM `players` WHERE `Username` = '%e' LIMIT 1", newname );
	mysql_tquery( SQL_DB, query, "CheckPlayerRename", "iis", id, playerid, newname );
	return 1;
}

YCMD:givemoney(playerid, const params[], help)
{
    if (PlayerInfo[playerid][pAdmin] < 7)
		return SendClientMessage(playerid, -1,   ""color_red"Nemas autorizaciju za koristenje ove komande!");

	new id, ammout;
    if (sscanf(params, "ui", id, ammout)) { return SendClientMessage(playerid, -1,  "/givemoney [id] [novac]"); }
	if (id == INVALID_PLAYER_ID ) { return SendClientMessage(playerid, -1,  "Taj igrac nije na serveru."); }
	if (ammout < -100_000_000 || ammout > 100_000_000) { return SendClientMessage(playerid, -1,  "Ne mozete ispod 100.000.000$ i preko 100.000.000$."); }
 

	GivePlayerMoney( id, ammout );
	SendClientMessage( id, -1, "#GIVEMONEY: {FFFFFF}Admin {33CCFF}%s {FFFFFF}vam je dao {33CCFF}($%s).", ReturnPlayerName(playerid), fNumber(ammout));

	return 1;
}