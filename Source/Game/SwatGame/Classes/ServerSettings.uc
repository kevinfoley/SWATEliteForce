class ServerSettings extends Engine.ReplicationInfo
    config(SwatGuiState);

import enum EEntryType from SwatStartPointBase;
import enum EMPMode from Engine.Repo;

const MAX_MAPS = 40;
var(ServerSettings) config String         Maps[MAX_MAPS];
var(ServerSettings) config int            NumMaps;

var(ServerSettings) config EMPMode        GameType "What game type the server is running";
var(ServerSettings) config int            MapIndex "What map is currently being used";
var(ServerSettings) config int            NumRounds "How many rounds to play per map";
var(ServerSettings) config int            MaxPlayers "Maximum number of players allowed on this server";
var(ServerSettings) config int            RoundNumber "What is the current round number";
var(ServerSettings) config int            Unused "Not used.";
var(ServerSettings) config int            PostGameTimeLimit "Time between the end of the round and server loading the next level";
var(ServerSettings) config int            Unused2 "Not used.";
var(ServerSettings) config int            MPMissionReadyTime "Time (in seconds) for players to ready themselves in between rounds in a MP game";
var(ServerSettings) config bool           bShowTeammateNames "If true, will display teammates names";
var(ServerSettings) config bool           Unused3 "Not used.";
var(ServerSettings) config bool           bAllowReferendums "If true, allow players to start referendums";
var(ServerSettings) config bool           bNoRespawn "If true, the server will not respawn players";
var(ServerSettings) config bool           bQuickRoundReset "If true, the server will perform a quick reset in between rounds on the same map; if false, the server will do a full SwitchLevel between rounds";
var(ServerSettings) config float          FriendlyFireAmount "The damage modifier for friendly fire [0...1]";
var(ServerSettings) config float          Unused4 "Not used.";
var(ServerSettings) config float          CampaignCOOP "Contains Campaign CO-OP settings (bitpacked)";
var(ServerSettings) config int            AdditionalRespawnTime "Time (in seconds) added to the delay time between respawn waves.";
var(ServerSettings) config bool           bNoLeaders "If true, new 'leader' functionality in SWAT 4 expansion is disabled.";
var(ServerSettings) config bool           Unused5 "Not used.";
var(ServerSettings) config bool           bEnableSnipers "Enable snipers?";

var(ServerSettings) config String         ServerName "Name of the server for display purposes";
var(ServerSettings) localized config String DefaultServerName "Default name of the server for display purposes";
var                 config String         Password "Password for the server for authenticating users";
var(ServerSettings) config bool           bPassworded "If true, the server is passworded";
var(ServerSettings) config bool           bLAN "If true, the server is hosted only over the LAN (not internet)";

var(ServerSettings)        bool           bDirty;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

replication
{
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		GameType, Maps, NumMaps, MapIndex, NumRounds,
        MaxPlayers, RoundNumber, Unused, PostGameTimeLimit,
        Unused2, MPMissionReadyTime, bShowTeammateNames, Unused3, bAllowReferendums, bNoRespawn,
        bQuickRoundReset, FriendlyFireAmount, Unused4,
        ServerName, Password, bPassworded, bLAN, AdditionalRespawnTime, CampaignCOOP,
		bNoLeaders, Unused5, bEnableSnipers;
}

///////////////////////////////////////////////////////////////////////////////
// Initialize the Server settings - load the map list for the game type
///////////////////////////////////////////////////////////////////////////////

function PreBeginPlay()
{
    Super.PreBeginPlay();

    LoadMapListForGameType();

	if (ServerName == "")
		ServerName = DefaultServerName;
}

///////////////////////////////////////////////////////////////////////////////
// Set the ServerSettings on the server
///////////////////////////////////////////////////////////////////////////////

function SetAdminServerSettings( PlayerController PC,
                            String newServerName,
                            String newPassword,
                            bool newbPassworded,
                            bool newbLAN )
{
log( self$"::SetAdminServerSettings( "$PC$", ServerName="$newServerName$", Password="$newPassword$", bPassworded="$newbPassworded$", bLAN="$newbLAN$" )" );
    if( Level.Game.IsA( 'SwatGameInfo' ) && !SwatGameInfo(Level.Game).Admin.IsAdmin( PC ) ) {
      log("Couldn't set admin settings: not an admin");
      return;
    }

    ServerName = newServerName;
    Password = newPassword;
    bPassworded = newbPassworded;
    bLAN = newbLAN;
}

function SetServerSettings( PlayerController PC,
                            EMPMode newGameType,
                            int newMapIndex,
                            int newNumRounds,
                            int newMaxPlayers,
                            int newUnused,
                            int newPostGameTimeLimit,
                            int newUnused2,
                            int newMPMissionReadyTime,
                            bool newbShowTeammateNames,
                            bool newUnused3,
							bool newbAllowReferendums,
                            bool newbNoRespawn,
                            bool newbQuickRoundReset,
                            float newFriendlyFireAmount,
                            float newUnused4,
							float newCampaignCOOP,
							int newAdditionalRespawnTime,
							bool newbNoLeaders,
							bool newUnused5,
							bool newbEnableSnipers)
{
log( self$"::SetServerSettings( "$PC$", newGameType="$GetEnum(EMPMode,newGameType)$", newMapIndex="$newMapIndex$", newNumRounds="$newNumRounds$", newMaxPlayers="$newMaxPlayers$", newUnused="$newUnused$", newPostGameTimeLimit="$newPostGameTimeLimit$", newUnused2="$newUnused2$", newMPMissionReadyTime="$newMPMissionReadyTime$", newbShowTeammateNames="$newbShowTeammateNames$", newUnused4="$newUnused4$", newbAllowReferendums="$newbAllowReferendums$", newbNoRespawn="$newbNoRespawn$", newbQuickRoundReset="$newbQuickRoundReset$", newFriendlyFireAmount="$newFriendlyFireAmount$", newUnused3="$newUnused3$" )" );
    if( Level.Game.IsA( 'SwatGameInfo' ) && PC != None && !SwatGameInfo(Level.Game).Admin.IsAdmin( PC ) )
        return;

    GameType = newGameType;
    MapIndex = newMapIndex;
    NumRounds = newNumRounds;
    MaxPlayers = newMaxPlayers;
    Unused = newUnused;
    PostGameTimeLimit = newPostGameTimeLimit;
    Unused2 = newUnused2;
    MPMissionReadyTime = newMPMissionReadyTime;
    bShowTeammateNames = newbShowTeammateNames;
    Unused3 = newUnused3;
	  bAllowReferendums = newbAllowReferendums;
    bNoRespawn = newbNoRespawn;
    bQuickRoundReset = newbQuickRoundReset;
    FriendlyFireAmount = newFriendlyFireAmount;
    Unused4 = newUnused4;
	  CampaignCOOP = newCampaignCOOP;
	  AdditionalRespawnTime = newAdditionalRespawnTime;
	  bNoLeaders = newbNoLeaders;
	  Unused5 = newUnused5;
	  bEnableSnipers = newbEnableSnipers;

    RoundNumber=0;

log( self$"::SetServerSettings(...) ... saving config" );
    SaveMapListForGameType();
    SaveConfig();


    // notify clients the settings were updated by the admin
	if (PC != None)
		SwatGameInfo(Level.Game).OnServerSettingsUpdated( PC );
}

///////////////////////////////////////////////////////////////////////////////
// Set a map at a specific index on the server
///////////////////////////////////////////////////////////////////////////////

function AddMap( PlayerController PC, string MapName )
{
    if( Level.Game.IsA( 'SwatGameInfo' ) && !SwatGameInfo(Level.Game).Admin.IsAdmin( PC ) )
        return;

    if( NumMaps >= MAX_MAPS )
        return;

    Maps[NumMaps] = MapName;

    NumMaps++;
}

function ClearMaps( PlayerController PC )
{
    local int i;

    if( Level.Game.IsA( 'SwatGameInfo' ) && !SwatGameInfo(Level.Game).Admin.IsAdmin( PC ) )
        return;

    for( i = 0; i < MAX_MAPS; i++ )
    {
        Maps[i] = "";
    }

    NumMaps=0;
}

///////////////////////////////////////////////////////////////////////////////
// Set the settings to bDirty - basically ensures a fresh reset for next round
///////////////////////////////////////////////////////////////////////////////

function SetDirty( PlayerController PC )
{
    if( Level.Game.IsA( 'SwatGameInfo' ) && !SwatGameInfo(Level.Game).Admin.IsAdmin( PC ) )
        return;

    bDirty = true;
}

function MapChangingByVote(EMPMode VotedGameType)
{
	if (GameType == VotedGameType)
		return;

	GameType = VotedGameType;

	LoadMapListForGameType();

	MapIndex = 0;

	SaveConfig();
}

///////////////////////////////////////////////////////////////////////////////
// Save/Load Maplist utilities
///////////////////////////////////////////////////////////////////////////////

private function SaveMapListForGameType()
{
    local MapRotation MapRotation;
    local int i;

    MapRotation = SwatRepo(Level.GetRepo()).GuiConfig.MapList[GameType];

    for( i = 0; i < MAX_MAPS; i++ )
    {
        MapRotation.Maps[i] = Maps[i];
    }

    MapRotation.SaveConfig();
}

private function LoadMapListForGameType()
{
    local MapRotation MapRotation;
    local int i;

    MapRotation = SwatRepo(Level.GetRepo()).GuiConfig.MapList[GameType];

    for( i = 0; i < MAX_MAPS; i++ )
    {
        Maps[i] = MapRotation.Maps[i];
    }
}

///////////////////////////////////////////////////////////////////////////////

function bool IsCampaignCoop()
{
	return CampaignCOOP != (-1^0);
}

function SetCampaignCoopSettings(PlayerController PC, int CampaignPath, int AvailableIndex)
{
  local int CampaignSettings;
  local int RetrievedAvailableIndex;
  local int RetrievedCampaignPath;

  CampaignSettings = 666 ^ 666;
  CampaignSettings = (AvailableIndex << 16) | CampaignPath;
  CampaignCOOP = CampaignSettings;

  RetrievedCampaignPath = CampaignSettings & 65535;
  RetrievedAvailableIndex = (CampaignSettings & -65536) >> 16;

  log("SetCampaignCoopSettings: CampaignPath="$RetrievedCampaignPath$", AvailableIndex="$RetrievedAvailableIndex$"");
}

///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
    bShouldReplicateDefaultProperties=true
	DefaultServerName="Swat4X Server"
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
