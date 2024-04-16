#include <ysilib\YSI_Coding\y_hooks>

#define SQL_SERVER 0 

#if SQL_SERVER == 0
	#define MYSQL_HOST 			"localhost"
	#define	MYSQL_USER 			"root"
	#define	MYSQL_PASSWORD 		""
	#define	MYSQL_DATABASE 		"neocentral_db"
#elseif SQL_SERVER == 1
	#define	MYSQL_HOST 			""
	#define	MYSQL_USER 			""
	#define	MYSQL_PASSWORD 		""
	#define	MYSQL_DATABASE 		"neocentral_db"
#endif

new MySQL: SQL_DB;

hook OnGameModeInit()
{
	new MySQLOpt: MYSQL_OPTION = mysql_init_options();
	mysql_set_option(MYSQL_OPTION, AUTO_RECONNECT, true);
	
	SQL_DB = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE);
	if(SQL_DB == MYSQL_INVALID_HANDLE || mysql_errno(SQL_DB) != 0)
	{
		printf("[MySQL]: Connection to %s@%s %s failed!", MYSQL_USER, MYSQL_HOST, MYSQL_DATABASE);
		return 1;
	}
	printf("[MySQL]: Connected to %s@%s %s successfully!", MYSQL_USER, MYSQL_HOST, MYSQL_DATABASE);

	CreatePlayerTable();

	return 1;
}

hook OnGameModeExit()
{
	foreach (new i : Player) { SaveAccount(i); }

	mysql_close(SQL_DB);

	return 1;
}

