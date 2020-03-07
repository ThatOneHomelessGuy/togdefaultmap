#pragma semicolon 1
#define PLUGIN_VERSION "1.0.2"

#include <sourcemod>
#include <autoexecconfig>

#pragma newdecls required

Handle g_hMap = INVALID_HANDLE;
char g_sMap[PLATFORM_MAX_PATH];

int g_iTimerValidation = 0;

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
	ReplaceString(g_sMap, sizeof(g_sMap), ".bsp", "", false);
	
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
		ReplaceString(g_sMap, sizeof(g_sMap), ".bsp", "", false);
	}
}

public void OnMapStart()
{
	g_iTimerValidation++;
	g_iMapStart = true;
	CreateTimer(60.0, TimerCallback_MapStart, g_iTimerValidation, TIMER_FLAG_NO_MAPCHANGE);
}

public Action TimerCallback_MapStart(Handle hTimer, any iTimerValidation)
{
	if(iTimerValidation == g_iTimerValidation)
	{
		g_iMapStart = false;
		CheckCount();
	}
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
			char g_sMapName[PLATFORM_MAX_PATH], sMsg[128];
			GetCurrentMap(g_sMapName, sizeof(g_sMapName));
			ReplaceString(g_sMapName, sizeof(g_sMapName), ".bsp", "", false);
			if(!StrEqual(g_sMapName, g_sMap, false))
			{
				Format(sMsg, sizeof(sMsg), "Server is empty! Changing to %s.", g_sMap);
				ForceChangeLevel(g_sMap, sMsg);
			}
		}
	}
	CreateTimer(60.0, TimerCallback_Retry, g_iTimerValidation, TIMER_FLAG_NO_MAPCHANGE);
}

public Action TimerCallback_Retry(Handle hTimer, any iTimerValidation)
{
	if(iTimerValidation == g_iTimerValidation)
	{
		CheckCount();
	}
}

bool IsValidClient(int client)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client)))
	{
		return false;
	}
	return true;
}

/*
CHANGELOG:
	1.0
		*	Initial creation.
	1.0.1
		*	Updated to new syntax.
	1.0.2
		*	Added check for if current map is the default to ensure it doesnt try to map change if it is already on the correct map.
		*	Added timer validation to make sure that timers from the previous map dont fire in the next.
			They shouldnt due to flag TIMER_FLAG_NO_MAPCHANGE, but there is documentation out there than notes that TIMER_FLAG_NO_MAPCHANGE has some bugs.
		
*/