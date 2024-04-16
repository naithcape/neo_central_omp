#include <ysilib\YSI_Coding\y_hooks>

stock Name_( playerid )
{
	new pName[MAX_PLAYER_NAME], usPos;
	GetPlayerName( playerid, pName, MAX_PLAYER_NAME );
	usPos = strfind( pName, "_" );
	if ( usPos != -1 ) pName[ usPos ] = ' ';
	return pName;
}

stock IsPlayerNearPlayer(Float:radi, playerid, targetid)
{
    if (IsPlayerConnected(playerid) && IsPlayerConnected(targetid))
	{
	    if ( GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld( targetid ) )
		{
			new Float:posx, Float:posy, Float:posz,
			    Float:oldposx, Float:oldposy, Float:oldposz,
			    Float:tempposx, Float:tempposy, Float:tempposz;

			GetPlayerPos( playerid, oldposx, oldposy, oldposz);

			GetPlayerPos(targetid, posx, posy, posz);
			tempposx = (oldposx -posx);
			tempposy = (oldposy -posy);
			tempposz = (oldposz -posz);

			if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) { return 1; }
		}
	}
	return 0;
}

YCMD:b(playerid, const string: params[], help)
{
        new string[258];
        if (isnull(params)) { return SendClientMessage(playerid, -1,  "/b [ TEXT ]" ); }
        format(string, sizeof string, "|| OOC || %s: %s", ReturnPlayerName(playerid), params); 
		ProxDetector(20.0, playerid, string, 0xC4C4C4FF);
        return 1;
}

YCMD:me(playerid, const string: params[], help)
{
     new string[128];
     if (isnull(params)) { return SendClientMessage(playerid, -1,  "/me [ AKCIJA ]"); }
     format(string, sizeof string, "* %s %s.", Name_(playerid), params);
	 ProxDetector(30.0, playerid, string, embcolor_pink);
     return 1;
}

YCMD:do(playerid, const string: params[], help)
{
     new string[128];
     if (isnull(params)) return SendClientMessage(playerid, -1,  "/do [ AKCIJA ] || "color_red"NPR:"color_white" /do sjeo bi bez problema. (prije toga /me otvara vrata i ulazi u auto.)" );
     format(string, sizeof string, "* %s (( %s )).", params, Name_(playerid));
	 ProxDetector(30.0, playerid, string, embcolor_pink);
     return 1;
}

