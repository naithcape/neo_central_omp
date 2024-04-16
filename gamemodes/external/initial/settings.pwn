#include <ysilib\YSI_Coding\y_hooks>

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))


hook OnPlayerConnect(playerid)
{
	TogglePlayerSpectating(playerid, false);
	SetPlayerColor(playerid, -1);

	return 1;
}

hook OnPlayerSpawn(playerid)
{
	SetPlayerTeam(playerid, NO_TEAM);

	return 1;
}
