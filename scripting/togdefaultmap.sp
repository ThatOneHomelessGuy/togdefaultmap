#pragma semicolon 1
#define PLUGIN_VERSION "1.0.1"

#include <sourcemod>
#include <autoexecconfig>

#pragma newdecls required

Handle g_hMap = INVALID_HANDLE;
char g_sMap[30];

bool g_iMapStart = true;
bool g_iRoundEnd = true;

public Plugin myinfo =
{
	name = "TOG Defaul Map",
	author = "That One Guy",
	description = "Changes to default map when server is empty",
	version = PLUGIN_VERSION,
	url = "http://www.togcoding.com"
}

public void OnPluginStart()
{
	AutoExecConfig_SetFile("togdefaultmap");
	AutoExecConfig_CreateConVar("togdefaultmap_version", PLUGIN_VERSION, "TOG Defaul Map: Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	g_hMap = AutoExecConfig_CreateConVar("togdefaultmap_map", "de_dust2", "Map to change to when the server is empty.");
	HookConVarChange(g_hMap, OnCVarChange);
	GetConVarString(g_hMap, g_sMap, sizeof(g_sMap));
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
}

public void OnCVarChange(Handle hCVar, const char[] sOldValue, const char[] sNewValue)
{
	if(hCVar == g_hMap)
	{
		GetConVarString(g_hMap, g_sMap, sizeof(g_sMap));
	}
}

public void OnMapStart()
{
	g_iMapStart = true;
	CreateTimer(60.0, TimerCallback_MapStart, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action TimerCallback_MapStart(Handle hTimer)
{
	g_iMapStart = false;
	CheckCount();
}

public Action Event_RoundStart(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
	g_iRoundEnd = false;
	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle event, const char[] sName, bool bDontBroadcast)
{
	g_iRoundEnd = true;
	return Plugin_Continue;
}
public Action Event_Disconnect(Handle event, const char[] sName, bool bDontBroadcast)
{
	CheckCount();
}

void CheckCount()
{
	if(!g_iMapStart && !g_iRoundEnd)
	{
		int iCount = 0;
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i))
			{
				iCount++;
			}
		}
		
		if(!iCount)
		{
			char sMsg[128];
			Format(sMsg, sizeof(sMsg), "Server is empty! Changing to %s.", g_sMap);
			ForceChangeLevel(g_sMap, sMsg);
		}
	}
	CreateTimer(60.0, TimerCallback_Retry, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action TimerCallback_Retry(Handle hTimer)
{
	CheckCount();
}

bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || (!IsPlayerAlive(client) && !bAllowDead))
	{
		return false;
	}
	return true;
}

stock void Log(char[] sPath, const char[] sMsg, any ...)		//TOG logging function - path is relative to logs folder.
{
	char sLogFilePath[PLATFORM_MAX_PATH], sFormattedMsg[1500];
	BuildPath(Path_SM, sLogFilePath, sizeof(sLogFilePath), "logs/%s", sPath);
	VFormat(sFormattedMsg, sizeof(sFormattedMsg), sMsg, 3);
	LogToFileEx(sLogFilePath, "%s", sFormattedMsg);
}

/*
CHANGELOG:
	1.0
		*	Initial creation.
	1.0.1
		*	Updated to new syntax.
		
*/