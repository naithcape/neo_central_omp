#include <ysilib\YSI_Coding\y_hooks>

const MAX_LOGIN_ATTEMPTS = 3;

static enum
{
	e_SPAWN_TYPE_REGISTER = 1,
    e_SPAWN_TYPE_LOGIN
};

hook OnAccountRegister(playerid)
{
	PlayerInfo[playerid][pID] = cache_insert_id();

	return 1;
}

hook OnAccountCheck(playerid)
{
	if (cache_num_rows())
	{
		cache_get_value_name(0, "Password", PlayerInfo[playerid][pLozinka], BCRYPT_HASH_LENGTH);
		Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
			"Login",
			"Dobro dosli natrag %s! Unesite vasu lozinku: ",
			"Nastavi", "Izadji", ReturnPlayerName(playerid)
		);
	}
	else
	{
		if (!HasRPName(playerid, true, false)) { Kick(playerid); }
		Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT,
			"Register - Password",
			"Dobro dosli %s! Unesite vasu zeljenu lozinku: ",
			"Nastavi", "Izadji", ReturnPlayerName(playerid)
		);
	}

	return 1;
}

hook OnAccountLoad(playerid, const string: name[], const string: value[])
{
    if (cache_num_rows())
	{
		cache_get_value_name_int(0, "ID", PlayerInfo[playerid][pID]);
		cache_get_value_name(0, "Password", PlayerInfo[playerid][pLozinka], BCRYPT_HASH_LENGTH);
		cache_get_value_name(0, "EMail", PlayerInfo[playerid][pEmail], 50);
		cache_get_value_name_int(0, "Level", PlayerInfo[playerid][pLevel]);
		cache_get_value_name_int(0, "Skin", PlayerInfo[playerid][pSkin]);
		cache_get_value_name_int(0, "Spol", PlayerInfo[playerid][pSpol]);
		cache_get_value_name_int(0, "Godine", PlayerInfo[playerid][pGodine]);
		cache_get_value_name_int(0, "Novac", PlayerInfo[playerid][pNovac]);
		cache_get_value_name_int(0, "Admin", PlayerInfo[playerid][pAdmin]);
	}
	else return 0;

	return 1;
}

hook OnPlayerConnect(playerid)
{
	new query[128];
	mysql_format(SQL_DB, query, sizeof query, "SELECT * FROM `players` WHERE `Username` = '%e' LIMIT 1", ReturnPlayerName(playerid));
	mysql_tquery(SQL_DB, query, "OnAccountCheck", "i", playerid);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{	
	SaveAccount(playerid);

	return 1;
}

timer Spawn_Player[100](playerid, type)
{
	if (type == e_SPAWN_TYPE_REGISTER)
	{
		SendClientMessage(playerid, -1,  "Dobro dosao na server!");
		SetSpawnInfo(playerid, NO_TEAM, PlayerInfo[playerid][pSkin],
			1765.0421, -1343.2664, 15.7555, 179.7101,
			WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0
		);
		SpawnPlayer(playerid);

		SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
		GivePlayerMoney(playerid, PlayerInfo[playerid][pNovac]);
		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
	}

	else if (type == e_SPAWN_TYPE_LOGIN)
	{
		SendClientMessage(playerid, -1,  "Dobro dosao na server!");
		SetSpawnInfo(playerid, NO_TEAM, PlayerInfo[playerid][pSkin],
			1765.0421, -1343.2664, 15.7555, 179.7101,
			WEAPON_FIST, 0, WEAPON_FIST, 0,	WEAPON_FIST, 0
		);
		SpawnPlayer(playerid);

		SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
		GivePlayerMoney(playerid, PlayerInfo[playerid][pNovac]);
		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
	}

}

Dialog: dialog_regpassword(playerid, response, listitem, string: inputtext[])
{
	if (!response) { return Kick(playerid); }

	bcrypt_hash(playerid, "OnPlayerPasswordHash", inputtext, BCRYPT_COST);

	//HidePlayerDialog(playerid);
	Dialog_Show(playerid, "dialog_regemail", DIALOG_STYLE_INPUT,
		"Register - EMail",
		"Unesite Vas E-Mail:",
		"Nastavi", "Izadji"
	);

	return 1;
}

Dialog: dialog_regemail(playerid, response, listitem, string: inputtext[])
{
	TogglePlayerSpectating(playerid, false);

	if (!response) { return Kick(playerid); }

	if (strfind(inputtext, "@", true) == -1 || strfind(inputtext, ".", true) == -1)
	{
		Dialog_Show(playerid, "dialog_regemail", DIALOG_STYLE_INPUT,
			"Register - EMail",
			"Unesite Vas E-Mail:",
			"Nastavi", "Izadji"
		);
		SendClientMessage(playerid, -1,  "Nepravilan E-Mail, pokusajte ponovo.");
	}
	else
	{
		strmid(PlayerInfo[playerid][pEmail], inputtext, 0, strlen(inputtext), 50);

		Dialog_Show(playerid, "dialog_reggender", DIALOG_STYLE_MSGBOX,
			"Register - Spol",
			"Izaberite Vas spol:",
			"Musko", "Zensko"
		);
	}

	return 1;
}

Dialog: dialog_reggender(playerid, response, listitem, string: inputtext[])
{
	TogglePlayerSpectating(playerid, false);

	PlayerInfo[playerid][pSpol] = response;
	switch (response)
	{
		case 0:	PlayerInfo[playerid][pSkin] = 12;
		case 1: PlayerInfo[playerid][pSkin] = 26;
	}

	Dialog_Show(playerid, "dialog_regage", DIALOG_STYLE_INPUT,
		"Register - Godine",
		"Unesite koliko imate godina (13-60):",
		"Nastavi", "Izadji"
	);

	return 1;
}

Dialog: dialog_regage(playerid, response, listitem, string: inputtext[])
{
	TogglePlayerSpectating(playerid, false);

	if (!response) { return Kick(playerid); }

	if (!(13 <= strval(inputtext) <= 60))
	{
		Dialog_Show(playerid, "dialog_regage", DIALOG_STYLE_INPUT,
			"Register - Godine",
			"Unesite koliko imate godina (13-60):",
			"Nastavi", "Izadji"
		);
		SendClientMessage(playerid, -1,  "Godine mogu samo biti 13-60!");
	}

	PlayerInfo[playerid][pGodine] = strval(inputtext);

	PlayerInfo[playerid][pNovac] = 5000;
	PlayerInfo[playerid][pLevel] = 1;
	PlayerInfo[playerid][pAdmin] = 0;

	new query[265];
	mysql_format(SQL_DB, query, sizeof query, "INSERT INTO `players` (`Username`, `Password`, `EMail`, `Level`, `Skin`, `Spol`, `Godine`, `Novac`, `Admin`) \
												  VALUES ('%e', '%e', '%s', '%i', '%i', '%i', '%i', '%i', '%i')",
												  ReturnPlayerName(playerid), PlayerInfo[playerid][pLozinka], PlayerInfo[playerid][pEmail], PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pSkin], PlayerInfo[playerid][pSpol], PlayerInfo[playerid][pGodine], PlayerInfo[playerid][pNovac], PlayerInfo[playerid][pAdmin]);
	mysql_tquery(SQL_DB, query, "OnAccountRegister", "i", playerid);

	defer Spawn_Player(playerid, 1);

	return 1;
}

Dialog: dialog_login(const playerid, response, listitem, string: inputtext[])
{
	bcrypt_verify(playerid, "OnPlayerVerifyHash", inputtext, PlayerInfo[playerid][pLozinka]);

	return 1;
}

forward OnPlayerPasswordHash(playerid);
public OnPlayerPasswordHash(playerid)
{
	new hash[BCRYPT_HASH_LENGTH];
	bcrypt_get_hash(hash);

	PlayerInfo[playerid][pLozinka] = hash;

    return 1;
}

forward OnPlayerVerifyHash(playerid, bool: success);
public OnPlayerVerifyHash(playerid, bool: success)
{
	if (success)
	{
		new query[128];
		mysql_format(SQL_DB, query, sizeof query, "SELECT * FROM `players` WHERE `Username` = '%e'", ReturnPlayerName(playerid));
		mysql_tquery(SQL_DB, query, "OnAccountLoad", "i", playerid);

		defer Spawn_Player(playerid, 2);
	}
    else
    {
        if (player_LoginAttempts[playerid] == MAX_LOGIN_ATTEMPTS)
            return Kick(playerid);

        ++player_LoginAttempts[playerid];

        Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
            "Login",
            "%s, pogresna lozinka, pokusajte ponovo: ",
            "Nastavi", "Izadji", ReturnPlayerName(playerid)
        );
    }
    return 1;
}

CreatePlayerTable()
{
	mysql_tquery(SQL_DB, "CREATE TABLE `players` \
						  ( \
							  `ID` tinyint(3) NOT NULL AUTO_INCREMENT, \
							  `Username` varchar(25) NOT NULL, \
							  `Password` varchar(73) NOT NULL, \
							  `EMail` varchar(50) NOT NULL, \
							  `Level` tinyint(3) NOT NULL, \
							  `Skin` tinyint(3) NOT NULL, \
							  `Spol` tinyint(1) NOT NULL, \
							  `Godine` tinyint(2) NOT NULL, \
							  `Novac` mediumint(8) NOT NULL, \
							  `Admin` tinyint(1) NOT NULL, \
							  PRIMARY KEY (`ID`) \
						  )");
	return 1;
}

stock SaveAccount(playerid)
{
	new query[256];
	mysql_format(SQL_DB, query, sizeof query, "UPDATE `players` \
												SET `Level` = '%i', `Skin` = '%i', `Spol` = '%i', `Godine` = '%i', `Novac` = '%i', `Admin` = '%i' WHERE `Username` = '%e'",
												GetPlayerScore(playerid), GetPlayerSkin(playerid), PlayerInfo[playerid][pSpol], PlayerInfo[playerid][pGodine], GetPlayerMoney(playerid), PlayerInfo[playerid][pAdmin], ReturnPlayerName(playerid));
	mysql_tquery(SQL_DB, query);
}