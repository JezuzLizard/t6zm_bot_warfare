#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bot_utility;
#include maps\mp\bots\_bot_api;

//#inline scripts\zm\pluto_sys;
//#define PLUTO scripts\zm\pluto_sys
/*
	Initiates the whole bot scripts.
*/
init()
{
	level.bw_version = "2.3.0 PR 1";
	
	if ( getdvar( "bots_main" ) == "" )
	{
		setdvar( "bots_main", true );
	}
	
	if ( !getdvarint( "bots_main" ) )
	{
		return;
	}
	
	if ( !wait_for_builtins() )
	{
		println( "FATAL: NO BUILT-INS FOR BOTS" );
	}
	
	thread load_waypoints();
	thread hook_callbacks();
	
	if ( getdvar( "bots_main_GUIDs" ) == "" )
	{
		setdvar( "bots_main_GUIDs", "" ); // guids of players who will be given host powers, comma seperated
	}
	
	if ( getdvar( "bots_main_firstIsHost" ) == "" )
	{
		setdvar( "bots_main_firstIsHost", false ); // first player to connect is a host
	}
	
	if ( getdvar( "bots_main_waitForHostTime" ) == "" )
	{
		setdvar( "bots_main_waitForHostTime", 10.0 ); // how long to wait to wait for the host player
	}
	
	if ( getdvar( "bots_main_kickBotsAtEnd" ) == "" )
	{
		setdvar( "bots_main_kickBotsAtEnd", false ); // kicks the bots at game end
	}
	
	if ( getdvar( "bots_manage_add" ) == "" )
	{
		setdvar( "bots_manage_add", 0 ); // amount of bots to add to the game
	}
	
	if ( getdvar( "bots_manage_fill" ) == "" )
	{
		setdvar( "bots_manage_fill", 0 ); // amount of bots to maintain
	}
	
	if ( getdvar( "bots_manage_fill_mode" ) == "" )
	{
		setdvar( "bots_manage_fill_mode", 0 ); // fill mode, 0 adds everyone, 1 just bots, 2 maintains at maps, 3 is 2 with 1
	}
	
	if ( getdvar( "bots_manage_fill_kick" ) == "" )
	{
		setdvar( "bots_manage_fill_kick", false ); // kick bots if too many
	}
	
	if ( getdvar( "bots_manage_fill_watchplayers" ) == "" )
	{
		setdvar( "bots_manage_fill_watchplayers", false ); // add bots when player exists, kick if not
	}
	
	if ( getdvar( "bots_skill" ) == "" )
	{
		setdvar( "bots_skill", 0 ); // 0 is random, 1 is easy 7 is hard, 8 is custom, 9 is completely random
	}
	
	if ( getdvar( "bots_skill_hard" ) == "" )
	{
		setdvar( "bots_skill_hard", 0 ); // amount of hard bots on axis team
	}
	
	if ( getdvar( "bots_skill_med" ) == "" )
	{
		setdvar( "bots_skill_med", 0 );
	}
	
	if ( getdvar( "bots_loadout_rank" ) == "" ) // what rank the bots should be around, -1 is around the players, 0 is all random
	{
		setdvar( "bots_loadout_rank", -1 );
	}
	
	if ( getdvar( "bots_loadout_prestige" ) == "" ) // what pretige the bots will be, -1 is the players, -2 is random
	{
		setdvar( "bots_loadout_prestige", -1 );
	}
	
	if ( getdvar( "bots_play_move" ) == "" ) // bots move
	{
		setdvar( "bots_play_move", true );
	}
	
	if ( getdvar( "bots_play_knife" ) == "" ) // bots knife
	{
		setdvar( "bots_play_knife", true );
	}
	
	if ( getdvar( "bots_play_fire" ) == "" ) // bots fire
	{
		setdvar( "bots_play_fire", true );
	}
	
	if ( getdvar( "bots_play_nade" ) == "" ) // bots grenade
	{
		setdvar( "bots_play_nade", true );
	}
	
	if ( getdvar( "bots_play_ads" ) == "" ) // bot ads
	{
		setdvar( "bots_play_ads", true );
	}
	
	if ( getdvar( "bots_play_aim" ) == "" )
	{
		setdvar( "bots_play_aim", true );
	}
	
	if ( getdvar( "bots_t8_mode" ) == "" )
	{
		setdvar( "bots_t8_mode", false );
	}
	
	if ( getdvar( "bots_play_opendoors" ) == "" )
	{
		setdvar( "bots_play_opendoors", true );
	}
	
	if ( !isdefined( game[ "botWarfare" ] ) )
	{
		game[ "botWarfare" ] = true;
		game[ "botWarfareInitTime" ] = gettime();
	}
	
	level.bot_inittime = gettime();
	
	level.bots_minsprintdistance = 315;
	level.bots_minsprintdistance *= level.bots_minsprintdistance;
	level.bots_mingrenadedistance = 256;
	level.bots_mingrenadedistance *= level.bots_mingrenadedistance;
	level.bots_maxgrenadedistance = 1024;
	level.bots_maxgrenadedistance *= level.bots_maxgrenadedistance;
	level.bots_maxknifedistance = 128;
	level.bots_maxknifedistance *= level.bots_maxknifedistance;
	level.bots_goaldistance = 27.5;
	level.bots_goaldistance *= level.bots_goaldistance;
	level.bots_noadsdistance = 200;
	level.bots_noadsdistance *= level.bots_noadsdistance;
	level.bots_maxshotgundistance = 500;
	level.bots_maxshotgundistance *= level.bots_maxshotgundistance;
	
	//level.players = [];
	level.bots = [];
	
	level.bots_fullautoguns = [];
	level.bots_fullautoguns[ "thompson" ] = true;
	level.bots_fullautoguns[ "mp40" ] = true;
	level.bots_fullautoguns[ "type100smg" ] = true;
	level.bots_fullautoguns[ "ppsh" ] = true;
	level.bots_fullautoguns[ "stg44" ] = true;
	level.bots_fullautoguns[ "30cal" ] = true;
	level.bots_fullautoguns[ "mg42" ] = true;
	level.bots_fullautoguns[ "dp28" ] = true;
	level.bots_fullautoguns[ "bar" ] = true;
	level.bots_fullautoguns[ "fg42" ] = true;
	level.bots_fullautoguns[ "type99lmg" ] = true;
	
	level thread onPlayerConnect();
	level thread handleBots();
	level thread onPlayerChat();
	
	level thread maps\mp\bots\_bot_script::bot_script_init();


	//zm specific
	level.powerup_player_valid_original = level.powerup_player_valid;
	level.powerup_player_valid = ::handle_bot_powerup_hud;

	level.givecustomloadout_original = level.givecustomloadout;
	level.givecustomloadout = ::givecustomloadout;
}

handle_bot_powerup_hud( player )
{
	if ( player istestclient() )
	{
		//don't do powerup hud for bots
		return false;
	}

	if ( !isdefined( level.powerup_player_valid_original ) )
	{
		return true;
	}

	return [[ level.powerup_player_valid_original ]]( player );
}

givecustomloadout( takeallweapons, alreadyspawned )
{
	self [[ level.givecustomloadout_original ]]( takeallweapons, alreadyspawned );
}

/*
	Starts the threads for bots.
*/
handleBots()
{
	level thread diffBots();
	level addBots();
	
	while ( !isdefined( level.intermission ) || !level.intermission )
	{
		wait 0.05;
	}
	
	setdvar( "bots_manage_add", getBotArray().size );
	
	if ( !getdvarint( "bots_main_kickBotsAtEnd" ) )
	{
		return;
	}
	
	bots = getBotArray();
	
	for ( i = 0; i < bots.size; i++ )
	{
		scripts\zm\pluto_sys::cmdexec( "clientkick " + bots[ i ] getentitynumber() );
	}
}

/*
	The hook callback for when any player becomes damaged.
*/
onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if ( self is_bot() && getdvarint( "bots_t8_mode" ) )
	{
		if ( ( level.script == "nazi_zombie_asylum" || level.script == "nazi_zombie_sumpf" ) && self hasperk( "specialty_armorvest" ) )
		{
			iDamage = int( iDamage * 0.333 );
		}
		else
		{
			iDamage = int( iDamage * 0.1 );
		}
	}
	
	if ( self is_bot() )
	{
		self maps\mp\bots\_bot_internal::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime );
		self maps\mp\bots\_bot_script::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime );
	}
	
	self [[ level.prevcallbackplayerdamage ]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime );
}

onActorDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, iModelIndex, iTimeOffset )
{
	if ( isdefined( eAttacker ) && isplayer( eAttacker ) && eAttacker is_bot() && getdvarint( "bots_t8_mode" ) && ( !isdefined( self.magic_bullet_shield ) || !self.magic_bullet_shield ) )
	{
		iDamage += int( self.maxhealth * randomfloatrange( 0.25, 1.25 ) );
	}
	
	self [[ level.prevcallbackactordamage ]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, iModelIndex, iTimeOffset );
}

/*
	Starts the callbacks.
*/
hook_callbacks()
{
	wait 0.05;
	level.prevcallbackplayerdamage = level.callbackplayerdamage;
	level.callbackplayerdamage = ::onPlayerDamage;
	
	level.prevcallbackactordamage = level.callbackactordamage;
	level.callbackactordamage = ::onActorDamage;
}

/*
	Thread when any player connects. Starts the threads needed.
*/
onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		
		player thread connected();
	}
}

/*
	When a bot disconnects.
*/
onDisconnectAll()
{
	name = self.playername;
	
	self waittill( "disconnect" );
	
	//level.players = arrayremovevalue( level.players, self );
	
	waittillframeend;
	
	for ( i = 0; i < level.bots.size; i++ )
	{
		bot = level.bots[ i ];
		bot BotNotifyBotEvent( "connection", "disconnected", self, name );
	}
}

/*
	When any client spawns
*/
onSpawnedAll()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		self waittill( "spawned_player" );
		
		self.lastspawntime = gettime();
		
		if ( getdvarint( "bots_main_debug" ) )
		{
			self.score = 100000;
		}
	}
}

/*
	When a bot disconnects.
*/
onDisconnect()
{
	self waittill( "disconnect" );
	
	level.bots = arrayremovevalue( level.bots, self );

	if ( !isdefined( level.bots ) )
	{
		level.bots = [];
	}
}

/*
	Called when a player connects.
*/
connected()
{
	self endon( "disconnect" );
	
	if ( !isdefined( self.pers[ "bot_host" ] ) )
	{
		self thread doHostCheck();
	}
	
	level.players[ level.players.size ] = self;
	
	for ( i = 0; i < level.bots.size; i++ )
	{
		bot = level.bots[ i ];
		bot BotNotifyBotEvent( "connection", "connected", self, self.playername );
	}
	
	self thread onDisconnectAll();
	
	self thread onSpawnedAll();
	
	if ( !self is_bot() )
	{
		return;
	}
	
	if ( !isdefined( self.pers[ "isBot" ] ) )
	{
		// fast restart...
		self.pers[ "isBot" ] = true;
	}
	
	if ( !isdefined( self.pers[ "isBotWarfare" ] ) )
	{
		self.pers[ "isBotWarfare" ] = true;
		self thread added();
	}

	//zm specific
	self.equipment_enabled = 0;
	//bot.team = "allies";
	self._player_entnum = self getentitynumber();
	self botclearoverride( true ); //disable engine code
	self botweaponoverride( true );

	self thread maps\mp\bots\_bot_internal::connected();
	self thread maps\mp\bots\_bot_script::connected();
	
	level.bots[ level.bots.size ] = self;
	self thread onDisconnect();
	self thread watchBotDebugEvent();

	waittillframeend; // wait for waittills to process
	level notify( "bot_connected", self );
}

/*
	DEBUG
*/
watchBotDebugEvent()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		self waittill( "bot_event", msg, str, b, c, d, e, f, g );
		
		if ( getdvarint( "bots_main_debug" ) >= 2 )
		{
			big_str = "Bot Warfare debug: " + self.playername + ": " + msg;
			
			if ( isdefined( str ) && isstring( str ) )
			{
				big_str += ", " + str;
			}
			
			if ( isdefined( b ) && isstring( b ) )
			{
				big_str += ", " + b;
			}
			
			if ( isdefined( c ) && isstring( c ) )
			{
				big_str += ", " + c;
			}
			
			if ( isdefined( d ) && isstring( d ) )
			{
				big_str += ", " + d;
			}
			
			if ( isdefined( e ) && isstring( e ) )
			{
				big_str += ", " + e;
			}
			
			if ( isdefined( f ) && isstring( f ) )
			{
				big_str += ", " + f;
			}
			
			if ( isdefined( g ) && isstring( g ) )
			{
				big_str += ", " + g;
			}
			
			scripts\zm\pluto_sys::PrintConsole( big_str );
		}
		else if ( msg == "debug" && getdvarint( "bots_main_debug" ) )
		{
			scripts\zm\pluto_sys::PrintConsole( "Bot Warfare debug: " + self.playername + ": " + str );
		}
	}
}

/*
	When a bot gets added into the game.
*/
added()
{
	self endon( "disconnect" );
	
	self thread maps\mp\bots\_bot_internal::added();
	self thread maps\mp\bots\_bot_script::added();
}

/*
	Adds a bot to the game.
*/
add_bot()
{
	bot = scripts\zm\pluto_sys::addtestclient(); //0x43,0x55,0x4D,0x49,0x4E,0x20,0x4D,0x45
	
	if ( isdefined( bot ) )
	{
		bot.pers[ "isBot" ] = true;
		bot.pers[ "isBotWarfare" ] = true;
		bot thread added();

		//zm specific hack to handle Treyarch cringe not waiting for the player be ready
		bot maps\mp\zombies\_zm::reset_rampage_bookmark_kill_times();
	}
}

/*
	A server thread for monitoring all bot's difficulty levels for custom server settings.
*/
diffBots_loop()
{
	var_hard = getdvarint( "bots_skill_hard" );
	var_med = getdvarint( "bots_skill_med" );
	var_skill = getdvarint( "bots_skill" );
	
	hard = 0;
	med = 0;
	
	if ( var_skill == 8 )
	{
		playercount = level.players.size;
		
		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];
			
			if ( !isdefined( player.pers[ "team" ] ) )
			{
				continue;
			}
			
			if ( !player is_bot() )
			{
				continue;
			}
			
			if ( hard < var_hard )
			{
				hard++;
				player.pers[ "bots" ][ "skill" ][ "base" ] = 7;
			}
			else if ( med < var_med )
			{
				med++;
				player.pers[ "bots" ][ "skill" ][ "base" ] = 4;
			}
			else
			{
				player.pers[ "bots" ][ "skill" ][ "base" ] = 1;
			}
		}
	}
	else if ( var_skill != 0 && var_skill != 9 )
	{
		playercount = level.players.size;
		
		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];
			
			if ( !player is_bot() )
			{
				continue;
			}
			
			player.pers[ "bots" ][ "skill" ][ "base" ] = var_skill;
		}
	}
}

/*
	A server thread for monitoring all bot's difficulty levels for custom server settings.
*/
diffBots()
{
	for ( ;; )
	{
		wait 1.5;
		
		diffBots_loop();
	}
}

/*
	A server thread for monitoring all bot's in game. Will add and kick bots according to server settings.
*/
addBots_loop()
{
	botsToAdd = getdvarint( "bots_manage_add" );
	
	if ( botsToAdd > 0 )
	{
		setdvar( "bots_manage_add", 0 );
		
		if ( botsToAdd > 4 )
		{
			botsToAdd = 4;
		}
		
		for ( ; botsToAdd > 0; botsToAdd-- )
		{
			level add_bot();
			wait 0.25;
		}
	}
	
	fillMode = getdvarint( "bots_manage_fill_mode" );
	
	if ( fillMode == 2 || fillMode == 3 )
	{
		setdvar( "bots_manage_fill", getGoodMapAmount() );
	}
	
	fillAmount = getdvarint( "bots_manage_fill" );
	
	players = 0;
	bots = 0;
	
	playercount = level.players.size;
	
	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];
		
		if ( player is_bot() )
		{
			bots++;
		}
		else
		{
			players++;
		}
	}

	if ( !randomint( 999 ) )
	{
		setdvar( "testclients_doreload", true );
		wait 0.1;
		setdvar( "testclients_doreload", false );
		// doExtraCheck();
	}
	
	amount = bots;
	
	if ( fillMode == 0 || fillMode == 2 )
	{
		amount += players;
	}

	if ( players <= 0 && getdvarint( "bots_manage_fill_watchplayers" ) )
	{
		amount = fillAmount + bots;
	}

	if ( amount < fillAmount )
	{
		setdvar( "bots_manage_add", fillAmount - amount );
	}
	else if ( amount > fillAmount && getdvarint( "bots_manage_fill_kick" ) )
	{
		botsToKick = amount - fillAmount;
		
		if ( botsToKick > 64 )
		{
			botsToKick = 64;
		}
		
		for ( i = 0; i < botsToKick; i++ )
		{
			tempBot = getBotToKick();
			
			if ( isdefined( tempBot ) )
			{
				scripts\zm\pluto_sys::cmdexec( "clientkick " + tempBot getentitynumber() + " EXE_PLAYERKICKED" );
				
				wait 0.25;
			}
		}
	}
}

/*
	A server thread for monitoring all bot's in game. Will add and kick bots according to server settings.
*/
addBots()
{
	level endon( "game_ended" );
	
	bot_wait_for_host();
	
	while ( !isdefined( level.intermission ) || !level.intermission )
	{
		wait 1.5;
		
		addBots_loop();
	}
}

/*
	When a player chats
*/
onPlayerChat()
{
	for ( ;; )
	{
		level waittill( "say", message, player, is_hidden );
		
		for ( i = 0; i < level.bots.size; i++ )
		{
			bot = level.bots[ i ];
			
			bot BotNotifyBotEvent( "chat", "chat", message, player, is_hidden );
		}
	}
}
