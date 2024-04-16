#include <ysilib\YSI_Coding\y_hooks>

forward ProxDetector(Float:Radius, playerid, string[], col1);
public ProxDetector(Float:Radius, playerid, string[], col1)
{
	new Float:PozX, Float:PozY, Float:PozZ;
    GetPlayerPos(playerid, PozX, PozY, PozZ);
    foreach (new i : Player) 
	    if (IsPlayerConnected(i) && (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i)) && IsPlayerInRangeOfPoint(i, Radius, PozX, PozY, PozZ))
			SendClientMessage(i, col1, string);
	return true;
}
