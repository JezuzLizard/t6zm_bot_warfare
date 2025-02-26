#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bot_utility;
#include maps\mp\bots\_bot_api;
#include maps\mp\zombies\_zm_utility;

////#define PLUTO scripts\zm\pluto_sys


//#inline scripts\zm\pluto_sys;
/*
	When a bot is added (once ever) to the game (before connected).
	We init all the persistent variables here.
*/
added()
{
	self endon( "disconnect" );
	
	self.pers[ "bots" ] = [];
	
	self.pers[ "bots" ][ "skill" ] = [];
	self.pers[ "bots" ][ "skill" ][ "base" ] = 7; // a base knownledge of the bot
	self.pers[ "bots" ][ "skill" ][ "aim_time" ] = 0.05; // how long it takes for a bot to aim to a location
	self.pers[ "bots" ][ "skill" ][ "init_react_time" ] = 0; // the reaction time of the bot for inital targets
	self.pers[ "bots" ][ "skill" ][ "reaction_time" ] = 0; // reaction time for the bots of reoccuring targets
	self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ] = 2500; // how long a bot ads's when they cant see the target
	self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ] = 10000; // how long a bot will look at a target's last position
	self.pers[ "bots" ][ "skill" ][ "remember_time" ] = 25000; // how long a bot will remember a target before forgetting about it when they cant see the target
	self.pers[ "bots" ][ "skill" ][ "fov" ] = -1; // the fov of the bot, -1 being 360, 1 being 0
	self.pers[ "bots" ][ "skill" ][ "dist_max" ] = 100000 * 2; // the longest distance a bot will target
	self.pers[ "bots" ][ "skill" ][ "dist_start" ] = 100000; // the start distance before bot's target abilitys diminish
	self.pers[ "bots" ][ "skill" ][ "spawn_time" ] = 0; // how long a bot waits after spawning before targeting, etc
	self.pers[ "bots" ][ "skill" ][ "help_dist" ] = 10000; // how far a bot has awareness
	self.pers[ "bots" ][ "skill" ][ "semi_time" ] = 0.05; // how fast a bot shoots semiauto
	self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ] = 1; // how long a bot shoots after target dies/cant be seen
	self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] = 1; // how long a bot correct's their aim after targeting
	self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ] = 1; // how far a bot's incorrect aim is
	self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] = 0.05; // how often a bot changes their bone target
	self.pers[ "bots" ][ "skill" ][ "bones" ] = "j_head"; // a list of comma seperated bones the bot will aim at
	self.pers[ "bots" ][ "skill" ][ "ads_fov_multi" ] = 0.5; // a factor of how much ads to reduce when adsing
	self.pers[ "bots" ][ "skill" ][ "ads_aimspeed_multi" ] = 0.5; // a factor of how much more aimspeed delay to add
	
	self.pers[ "bots" ][ "behavior" ] = [];
	self.pers[ "bots" ][ "behavior" ][ "strafe" ] = 50; // percentage of how often the bot strafes a target
	self.pers[ "bots" ][ "behavior" ][ "nade" ] = 50; // percentage of how often the bot will grenade
	self.pers[ "bots" ][ "behavior" ][ "sprint" ] = 50; // percentage of how often the bot will sprint
	self.pers[ "bots" ][ "behavior" ][ "camp" ] = 50; // percentage of how often the bot will camp
	self.pers[ "bots" ][ "behavior" ][ "follow" ] = 50; // percentage of how often the bot will follow
	self.pers[ "bots" ][ "behavior" ][ "crouch" ] = 10; // percentage of how often the bot will crouch
	self.pers[ "bots" ][ "behavior" ][ "switch" ] = 1; // percentage of how often the bot will switch weapons
	self.pers[ "bots" ][ "behavior" ][ "jump" ] = 100; // percentage of how often the bot will jumpshot and dropshot
	
	self.pers[ "bots" ][ "behavior" ][ "quickscope" ] = false; // is a quickscoper
	self.pers[ "bots" ][ "behavior" ][ "initswitch" ] = 10; // percentage of how often the bot will switch weapons on spawn
}

/*
	We clear all of the script variables and other stuff for the bots.
*/
resetBotVars()
{
	self.bot.script_target = undefined;
	self.bot.script_target_offset = undefined;
	self.bot.target = undefined;
	self.bot.targets = [];
	self.bot.target_this_frame = undefined;
	self.bot.after_target = undefined;
	self.bot.after_target_pos = undefined;
	self.bot.moveto = self.origin;
	
	self.bot.script_aimpos = undefined;
	
	//script_goal_t
	self.bot.script_goal = spawnstruct();
	self.bot.script_goal.ent = undefined;
	self.bot.script_goal.node = undefined;
	self.bot.script_goal.origin = ( -999999, -999999, -999999 );
	self.bot.script_goal.angles = ( -999999, -999999, -999999 );
	self.bot.script_goal.offset = ( 0, 0 , 0 );
	self.bot.script_goal.dist = -1.0;
	self.bot.script_goal.type = 0;
	self.bot.script_goal.goal_oriented = false;
	
	self.bot.next_wp = -1;
	self.bot.second_next_wp = -1;
	self.bot.towards_goal = undefined;
	self.bot.astar = [];
	self.bot.stop_move = false;
	self.bot.climbing = false;
	self.bot.wantsprint = false;
	self.bot.last_next_wp = -1;
	self.bot.last_second_next_wp = -1;
	
	self.bot.isfrozen = false;
	self.bot.sprintendtime = -1;
	self.bot.isreloading = false;
	self.bot.issprinting = false;
	self.bot.isfragging = false;
	self.bot.issmoking = false;
	self.bot.isfraggingafter = false;
	self.bot.issmokingafter = false;
	self.bot.isknifing = false;
	self.bot.isknifingafter = false;
	self.bot.knifing_target = undefined;
	
	self.bot.semi_time = false;
	self.bot.jump_time = undefined;
	self.bot.last_fire_time = -1;
	
	self.bot.is_cur_full_auto = false;
	self.bot.cur_weap_dist_multi = 1;
	self.bot.is_cur_sniper = false;
	
	self.bot.prio_objective = false;
	
	self.bot.rand = randomint( 100 );
}

/*
	The callback hook when the bot gets damaged.
*/
onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
}

/*
	When a bot connects to the game.
	This is called when a bot is added and when multiround gamemode starts.
*/
connected()
{
	self endon( "disconnect" );
	
	self.bot = spawnstruct();
	self resetBotVars();
	
	self thread onPlayerSpawned();
}

/*
	When the bot spawns.
*/
onPlayerSpawned()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		self waittill( "spawned_player" );
		
		self resetBotVars();
		self thread onWeaponChange();
		
		self thread reload_watch();
		self thread sprint_watch();
		
		self thread spawned();
	}
}

/*
	Is the weap a sniper
*/
IsWeapSniper( weap )
{
	if ( weap == "none" )
	{
		return false;
	}
	
	if ( false /*maps\mp\gametypes\_missions::getWeaponClass( weap ) != "weapon_sniper"*/ )
	{
		return false;
	}
	
	return true;
}

/*
	When the bot changes weapon.
*/
onWeaponChange()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	first = true;
	
	for ( ;; )
	{
		newWeapon = undefined;
		
		if ( first )
		{
			first = false;
			newWeapon = self getcurrentweapon();
			
			// hack fix for botstop overridding weapon
			if ( newWeapon != "none" )
			{
				self switchtoweapon( newWeapon );
			}
		}
		else
		{
			self waittill( "weapon_change", newWeapon );
		}
		
		self.bot.is_cur_full_auto = WeaponIsFullAuto( newWeapon );
		self.bot.cur_weap_dist_multi = SetWeaponDistMulti( newWeapon );
		self.bot.is_cur_sniper = IsWeapSniper( newWeapon );
	}
}

/*
	Sets the factor of distance for a weapon
*/
SetWeaponDistMulti( weap )
{
	if ( weap == "none" )
	{
		return 1;
	}
	
	switch ( weaponclass( weap ) )
	{
		case "rifle":
			return 0.9;
			
		case "smg":
			return 0.7;
			
		case "pistol":
			return 0.5;
			
		default:
			return 1;
	}
}

/*
	Update's the bot if it is reloading.
*/
reload_watch()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		self waittill( "reload_start" );
		
		self reload_watch_loop();
	}
}

/*
	Update's the bot if it is reloading.
*/
reload_watch_loop()
{
	self.bot.isreloading = true;
	
	while ( true )
	{
		ret = self waittill_any_timeout( 7.5, "reload" );
		
		if ( ret == "timeout" )
		{
			break;
		}
		
		weap = self getcurrentweapon();
		
		if ( weap == "none" )
		{
			break;
		}
		
		if ( self getweaponammoclip( weap ) >= weaponclipsize( weap ) )
		{
			break;
		}
	}
	
	self.bot.isreloading = false;
}

/*
	Updates the bot if it is sprinting.
*/
sprint_watch()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		self waittill( "sprint_begin" );
		self.bot.issprinting = true;
		self waittill( "sprint_end" );
		self.bot.issprinting = false;
		self.bot.sprintendtime = gettime();
	}
}

/*
	We wait for a time defined by the bot's difficulty and start all threads that control the bot.
*/
spawned()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	wait self.pers[ "bots" ][ "skill" ][ "spawn_time" ];
	
	self thread doBotMovement();
	self thread walk();
	self thread target();
	self thread target_cleanup();
	self thread updateBones();
	self thread aim();
	self thread watchHoldBreath();
	self thread stance();
	self thread onNewEnemy();
	self thread check_reload();

	//self thread seizure();

	self notify( "bot_spawned" );
}

seizure()
{
	for ( ;; )
	{
		dir = ( randomintrange( -127, 127 ), randomintrange( -127, 127 ), 0 );
		self scripts\zm\pluto_sys::botmovementoverride( int( dir[ 0 ] ), int( dir[ 1 ] ) );
		wait 0.2;
	}
}

/*
	When the bot gets a new enemy.
*/
onNewEnemy()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		self waittill( "new_enemy" );
		
		if ( !isdefined( self.bot.target ) )
		{
			continue;
		}
		
		if ( !isdefined( self.bot.target.entity ) || !isai( self.bot.target.entity ) )
		{
			continue;
		}
		
		if ( self.bot.target.didlook )
		{
			continue;
		}
		
		self thread watchToLook();
	}
}

/*
	Bots will jump or dropshot their enemy player.
*/
watchToLook()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "new_enemy" );
	
	for ( ;; )
	{
		while ( isdefined( self.bot.target ) && self.bot.target.didlook )
		{
			wait 0.05;
		}
		
		while ( isdefined( self.bot.target ) && self.bot.target.no_trace_time )
		{
			wait 0.05;
		}
		
		if ( !isdefined( self.bot.target ) )
		{
			break;
		}
		
		self.bot.target.didlook = true;
		
		if ( self.bot.isfrozen )
		{
			continue;
		}
		
		if ( self.bot.target.dist > level.bots_maxshotgundistance * 2 )
		{
			continue;
		}
		
		if ( self.bot.target.dist <= level.bots_maxknifedistance )
		{
			continue;
		}
		
		if ( !self canFire( self getcurrentweapon() ) )
		{
			continue;
		}
		
		if ( !self isInRange( self.bot.target.dist, self getcurrentweapon() ) )
		{
			continue;
		}
		
		if ( self.bot.is_cur_sniper )
		{
			continue;
		}
		
		if ( randomint( 100 ) > self.pers[ "bots" ][ "behavior" ][ "jump" ] )
		{
			continue;
		}
		
		if ( !getdvarint( "bots_play_jumpdrop" ) )
		{
			continue;
		}
		
		if ( isdefined( self.bot.jump_time ) && gettime() - self.bot.jump_time <= 5000 )
		{
			continue;
		}
		
		if ( self.bot.target.rand <= self.pers[ "bots" ][ "behavior" ][ "strafe" ] )
		{
			if ( self getstance() != "stand" )
			{
				continue;
			}
			
			self.bot.jump_time = gettime();
			self jump();
		}
		else
		{
			if ( getConeDot( self.bot.target.last_seen_pos, self.origin, self getplayerangles() ) < 0.8 || self.bot.target.dist <= level.bots_noadsdistance )
			{
				continue;
			}
			
			self.bot.jump_time = gettime();
			self prone();
			self notify( "kill_goal" );
			wait 2.5;
			self crouch();
		}
	}
}

/*
	Bots will update its needed stance according to the nodes on the level. Will also allow the bot to sprint when it can.
*/
stance_loop()
{
	self.bot.climbing = false;
	
	if ( self.bot.isfrozen )
	{
		return;
	}
	
	toStance = "stand";
	
	if ( self.bot.next_wp != -1 )
	{
		toStance = level.waypoints[ self.bot.next_wp ].type;
	}
	
	if ( !isdefined( toStance ) )
	{
		toStance = "stand";
	}
	
	if ( toStance == "stand" && randomint( 100 ) <= self.pers[ "bots" ][ "behavior" ][ "crouch" ] )
	{
		toStance = "crouch";
	}
	
	if ( toStance == "climb" )
	{
		self.bot.climbing = true;
		toStance = "stand";
	}
	
	if ( toStance != "stand" && toStance != "crouch" && toStance != "prone" )
	{
		toStance = "crouch";
	}
	
	toStance = "stand"; // Hack to make the bots never crouch
	
	if ( toStance == "stand" )
	{
		self stand();
	}
	else if ( toStance == "crouch" )
	{
		self crouch();
	}
	else
	{
		self prone();
	}
	
	curweap = self getcurrentweapon();
	time = gettime();
	chance = self.pers[ "bots" ][ "behavior" ][ "sprint" ];
	
	if ( time - self.lastspawntime < 5000 )
	{
		chance *= 2;
	}
	
	target_pos = GetScriptGoalPos();
	if ( self HasScriptGoal() && IsValidPos( target_pos ) && distancesquared( self.origin, target_pos ) > 256 * 256 )
	{
		chance *= 2;
	}
	
	if ( toStance != "stand" || self.bot.isreloading || self.bot.issprinting || self.bot.isfraggingafter || self.bot.issmokingafter )
	{
		return;
	}
	
	if ( randomint( 100 ) > chance )
	{
		return;
	}
	
	if ( isdefined( self.bot.target ) && self canFire( curweap ) && self isInRange( self.bot.target.dist, curweap ) )
	{
		return;
	}
	
	if ( self.bot.sprintendtime != -1 && time - self.bot.sprintendtime < 2000 )
	{
		return;
	}
	
	trace = physicstrace( self geteye(), self geteye() + anglestoforward( self getplayerangles() ) * 1024, ( 0, 0, 0 ), ( 0, 0, 0 ) );
	if ( !isdefined( self.bot.towards_goal ) || distancesquared( self.origin, trace[ "position" ] ) < level.bots_minsprintdistance || getConeDot( self.bot.towards_goal, self.origin, self getplayerangles() ) < 0.75 )
	{
		return;
	}
	
	self thread sprint();
	self thread setBotWantSprint();
}

/*
	Stops the sprint fix when goal is completed
*/
setBotWantSprint()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	self notify( "setBotWantSprint" );
	self endon( "setBotWantSprint" );
	
	self.bot.wantsprint = true;
	
	self waittill_notify_or_timeout( "kill_goal", 10 );
	
	self.bot.wantsprint = false;
}

/*
	Bots will update its needed stance according to the nodes on the level. Will also allow the bot to sprint when it can.
*/
stance()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		self waittill_either( "finished_static_waypoints", "new_static_waypoint" );
		
		self stance_loop();
	}
}

/*
	Bot will wait until firing.
*/
check_reload()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		self waittill_notify_or_timeout( "weapon_fired", 5 );
		self thread reload_thread();
	}
}

/*
	Bot will reload after firing if needed.
*/
reload_thread()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "weapon_fired" );
	
	wait 2.5;
	
	if ( isdefined( self.bot.target ) || self.bot.isreloading || self.bot.isfraggingafter || self.bot.issmokingafter || self.bot.isfrozen )
	{
		return;
	}
	
	cur = self getcurrentweapon();
	
	if ( cur == "" || cur == "none" )
	{
		return;
	}
	
	if ( isweaponcliponly( cur ) || !self getweaponammostock( cur ) )
	{
		return;
	}
	
	maxsize = weaponclipsize( cur );
	cursize = self getweaponammoclip( cur );
	
	if ( cursize / maxsize < 0.5 )
	{
		self thread reload();
	}
}

target_cleanup()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	while ( true )
	{
		wait 10;
		curTime = gettime();
		targetKeys = getarraykeys( self.bot.targets );
		
		for ( i = 0; i < targetKeys.size; i++ )
		{
			obj = self.bot.targets[ targetKeys[ i ] ];
			
			if ( ( curTime - obj.time ) > 30000 )
			{
				self.bot.targets[ targetKeys[ i ] ] = undefined;
			}
		}
	}
}

/*
	The hold breath thread.
*/
watchHoldBreath()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		wait 1;
		
		if ( self.bot.isfrozen )
		{
			continue;
		}
		
		self holdbreath( self playerads() > 0 );
	}
}

/*
	Bot moves towards the point
*/
doBotMovement()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	data = spawnstruct();
	data.wasmantling = false;
	
	for ( data.i = 0; true; data.i += 0.05 )
	{
		wait 0.05;
		
		waittillframeend;
		self doBotMovement_loop( data );
	}
}

/*
	Bot moves towards the point
*/
doBotMovement_loop( data )
{
	move_To = self.bot.moveto;
	angles = self getplayerangles();
	dir = ( 0, 0, 0 );
	
	//iprintln( "Bot origin: " + self.origin + " bot goal: " + move_To );
	//print( "Bot origin: " + self.origin + " bot goal: " + move_To + "\n" );
	if ( distancesquared( self.origin, move_To ) >= 49 )
	{
		cosa = cos( 0 - angles[ 1 ] );
		sina = sin( 0 - angles[ 1 ] );
		
		// get the direction
		dir = move_To - self.origin;
		
		// rotate our direction according to our angles
		dir = ( dir[ 0 ] * cosa - dir[ 1 ] * sina,
				dir[ 0 ] * sina + dir[ 1 ] * cosa,
				0 );
				
		// make the length 127
		dir = vectornormalize( dir ) * 127;
		
		// invert the second component as the engine requires this
		dir = ( dir[ 0 ], 0 - dir[ 1 ], 0 );
	}
	else
	{
		iprintlnbold("CUMIN ME");
	}
	
	startPos = self.origin + ( 0, 0, 50 );
	startPosForward = startPos + anglestoforward( ( 0, angles[ 1 ], 0 ) ) * 25;
	bt = bullettrace( startPos, startPosForward, false, self );
	
	if ( bt[ "fraction" ] >= 1 )
	{
		// check if need to jump
		bt = bullettrace( startPosForward, startPosForward - ( 0, 0, 40 ), false, self );
		
		if ( bt[ "fraction" ] < 1 && bt[ "normal" ][ 2 ] > 0.9 && data.i > 1.5 )
		{
			data.i = 0;
			self thread jump();
		}
	}
	// check if need to knife glass
	else if ( bt[ "surfacetype" ] == "glass" )
	{
		if ( data.i > 1.5 )
		{
			data.i = 0;
			self thread knife();
		}
	}
	else
	{
		// check if need to crouch
		if ( bullettracepassed( startPos - ( 0, 0, 25 ), startPosForward - ( 0, 0, 25 ), false, self ) && !self.bot.climbing )
		{
			self crouch();
		}
	}
	
	// move!
	if ( ( self.bot.wantsprint && self.bot.issprinting ) || isdefined( self.bot.knifing_target ) )
	{
		dir = ( 127, dir[ 1 ], 0 );
	}
	
	self scripts\zm\pluto_sys::botmovementoverride( int( dir[ 0 ] ), int( dir[ 1 ] ) );
}

/*
	Bots will look at the pos
*/
bot_lookat( pos, time, vel, doAimPredict )
{
	self notify( "bots_aim_overlap" );
	self endon( "bots_aim_overlap" );
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "spawned_player" );
	level endon ( "intermission" );
	
	if ( ( isdefined( level.intermission ) && level.intermission ) || self.bot.isfrozen || !getdvarint( "bots_play_aim" ) )
	{
		return;
	}
	
	if ( !isdefined( pos ) )
	{
		return;
	}
	
	if ( !isdefined( doAimPredict ) )
	{
		doAimPredict = false;
	}
	
	if ( !isdefined( time ) )
	{
		time = 0.05;
	}
	
	if ( !isdefined( vel ) )
	{
		vel = ( 0, 0, 0 );
	}
	
	steps = int( time * 20 );
	
	if ( steps < 1 )
	{
		steps = 1;
	}
	
	myEye = self geteye(); // get our eye pos
	
	if ( doAimPredict )
	{
		myEye += ( self getvelocity() * 0.05 ) * ( steps - 1 ); // account for our velocity
		
		pos += ( vel * 0.05 ) * ( steps - 1 ); // add the velocity vector
	}
	
	myAngle = self getplayerangles();
	angles = vectortoangles( ( pos - myEye ) - anglestoforward( myAngle ) );
	
	X = angleclamp180( angles[ 0 ] - myAngle[ 0 ] );
	X = X / steps;
	
	Y = angleclamp180( angles[ 1 ] - myAngle[ 1 ] );
	Y = Y / steps;
	
	for ( i = 0; i < steps; i++ )
	{
		myAngle = ( angleclamp180( myAngle[ 0 ] + X ), angleclamp180( myAngle[ 1 ] + Y ), 0 );
		self setplayerangles( myAngle );
		wait 0.05;
	}
}

/*
	Returns true if the bot can fire their current weapon.
*/
canFire( curweap )
{
	if ( curweap == "none" )
	{
		return false;
	}
	
	return self getweaponammoclip( curweap );
}

/*
	Returns true if the bot is in range of their target.
*/
isInRange( dist, curweap )
{
	if ( curweap == "none" )
	{
		return false;
	}
	
	weapclass = weaponclass( curweap );
	
	if ( weapclass == "spread" && dist > level.bots_maxshotgundistance )
	{
		return false;
	}
	
	if ( curweap == "m2_flamethrower_mp" && dist > level.bots_maxshotgundistance )
	{
		return false;
	}
	
	return true;
}

/*
	Returns true if the bot can ads their current gun.
*/
canAds( dist, curweap )
{
	if ( curweap == "none" )
	{
		return false;
	}
	
	if ( !getdvarint( "bots_play_ads" ) )
	{
		return false;
	}
	
	far = level.bots_noadsdistance;
	
	if ( self hasperk( "specialty_bulletaccuracy" ) )
	{
		far *= 1.4;
	}
	
	if ( dist < far )
	{
		return false;
	}
	
	weapclass = ( weaponclass( curweap ) );
	
	if ( weapclass == "spread" || weapclass == "grenade" )
	{
		return false;
	}
	
	return true;
}

/*
	Returns true if myEye can see the bone of self
*/
checkTraceForBone( myEye, bone )
{
	if ( !self targetIsDog() && self targetIsGibbed() )
	{
		bone = "j_spinelower";
	}
	
	boneLoc = self gettagorigin( bone );
	
	if ( !isdefined( boneLoc ) )
	{
		return false;
	}
	
	trace = bullettrace( myEye, boneLoc, false, undefined );
	
	return ( sighttracepassed( myEye, boneLoc, false, undefined ) && ( trace[ "fraction" ] >= 1.0 || trace[ "surfacetype" ] == "glass" ) );
}

/*
	The main target thread, will update the bot's main target. Will auto target enemy players and handle script targets.
*/
target_loop()
{
	myEye = self geteye();
	theTime = gettime();
	myAngles = self getplayerangles();
	myFov = self.pers[ "bots" ][ "skill" ][ "fov" ];
	bestTargets = [];
	bestTime = 2147483647;
	rememberTime = self.pers[ "bots" ][ "skill" ][ "remember_time" ];
	initReactTime = self.pers[ "bots" ][ "skill" ][ "init_react_time" ];
	hasTarget = isdefined( self.bot.target );
	adsAmount = self playerads();
	adsFovFact = self.pers[ "bots" ][ "skill" ][ "ads_fov_multi" ];
	
	if ( hasTarget && !isdefined( self.bot.target.entity ) )
	{
		self.bot.target = undefined;
		hasTarget = false;
	}
	
	// reduce fov if ads'ing
	if ( adsAmount > 0 )
	{
		myFov *= 1 - adsFovFact * adsAmount;
	}
	
	enemies = getaispeciesarray( "axis", "all" );
	
	enemycount = enemies.size;
	
	for ( i = -1; i < enemycount; i++ )
	{
		obj = undefined;
		
		if ( i == -1 )
		{
			if ( !isdefined( self.bot.script_target ) )
			{
				continue;
			}
			
			ent = self.bot.script_target;
			key = ent getentitynumber() + "";
			daDist = distancesquared( self.origin, ent.origin );
			obj = self.bot.targets[ key ];
			isObjDef = isdefined( obj );
			entOrigin = ent.origin;
			
			if ( isdefined( self.bot.script_target_offset ) )
			{
				entOrigin += self.bot.script_target_offset;
			}
			
			if ( bullettracepassed( myEye, entOrigin, false, ent ) )
			{
				if ( !isObjDef )
				{
					obj = self createTargetObj( ent, theTime );
					obj.offset = self.bot.script_target_offset;
					
					self.bot.targets[ key ] = obj;
				}
				
				self targetObjUpdateTraced( obj, daDist, ent, theTime, true );
			}
			else
			{
				if ( !isObjDef )
				{
					continue;
				}
				
				self targetObjUpdateNoTrace( obj );
				
				if ( obj.no_trace_time > rememberTime )
				{
					self.bot.targets[ key ] = undefined;
					continue;
				}
			}
		}
		else
		{
			enemy = enemies[ i ];
			
			key = enemy getentitynumber() + "";
			obj = self.bot.targets[ key ];
			daDist = distancesquared( self.origin, enemy.origin );
			isObjDef = isdefined( obj );
			
			canTargetEnemy = ( ( enemy checkTraceForBone( myEye, "j_head" ) ||
						enemy checkTraceForBone( myEye, "j_ankle_le" ) ||
						enemy checkTraceForBone( myEye, "j_ankle_ri" ) )
						
					&& ( getConeDot( enemy.origin, self.origin, myAngles ) >= myFov ||
						( isObjDef && obj.trace_time ) )
						
					&& ( !isdefined( enemy.magic_bullet_shield ) || !enemy.magic_bullet_shield ) );
					
			if ( isdefined( self.bot.target_this_frame ) && self.bot.target_this_frame == enemy )
			{
				self.bot.target_this_frame = undefined;
				
				canTargetEnemy = true;
			}
			
			if ( canTargetEnemy )
			{
				if ( !isObjDef )
				{
					obj = self createTargetObj( enemy, theTime );
					
					self.bot.targets[ key ] = obj;
				}
				
				self targetObjUpdateTraced( obj, daDist, enemy, theTime, false );
			}
			else
			{
				if ( !isObjDef )
				{
					continue;
				}
				
				self targetObjUpdateNoTrace( obj );
				
				if ( obj.no_trace_time > rememberTime )
				{
					self.bot.targets[ key ] = undefined;
					continue;
				}
			}
		}
		
		if ( !isdefined( obj ) )
		{
			continue;
		}
		
		if ( theTime - obj.time < initReactTime )
		{
			continue;
		}
		
		timeDiff = theTime - obj.trace_time_time;
		
		if ( timeDiff < bestTime )
		{
			bestTargets = [];
			bestTime = timeDiff;
		}
		
		if ( timeDiff == bestTime )
		{
			bestTargets[ key ] = obj;
		}
	}
	
	if ( hasTarget && isdefined( bestTargets[ self.bot.target.entity getentitynumber() + "" ] ) )
	{
		return;
	}
	
	closest = 2147483647;
	toBeTarget = undefined;
	
	bestKeys = getarraykeys( bestTargets );
	
	for ( i = bestKeys.size - 1; i >= 0; i-- )
	{
		theDist = bestTargets[ bestKeys[ i ] ].dist;
		
		if ( theDist > closest )
		{
			continue;
		}
		
		closest = theDist;
		toBeTarget = bestTargets[ bestKeys[ i ] ];
	}
	
	beforeTargetID = -1;
	newTargetID = -1;
	
	if ( hasTarget && isdefined( self.bot.target.entity ) )
	{
		beforeTargetID = self.bot.target.entity getentitynumber();
	}
	
	if ( isdefined( toBeTarget ) && isdefined( toBeTarget.entity ) )
	{
		newTargetID = toBeTarget.entity getentitynumber();
	}
	
	if ( beforeTargetID != newTargetID )
	{
		self.bot.target = toBeTarget;
		self notify( "new_enemy" );
	}
}

/*
	The main target thread, will update the bot's main target. Will auto target enemy players and handle script targets.
*/
target()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		wait 0.05;
		
		self target_loop();
	}
}

/*
	Picks a valid bone for enemy
*/

selectBoneForTarget( enemy, bones )
{
	if ( enemy targetIsDog() )
	{
		return "j_head";
	}
	else if ( !enemy targetIsGibbed() )
	{
		return PickRandom( bones );
	}
	else
	{
		return "j_spineupper";
	}
}

/*
	Updates the bot's target bone
*/
updateBones()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		oldbones = self.pers[ "bots" ][ "skill" ][ "bones" ];
		bones = strtok( oldbones, "," );
		
		while ( oldbones == self.pers[ "bots" ][ "skill" ][ "bones" ] )
		{
			self waittill_notify_or_timeout( "new_enemy", self.pers[ "bots" ][ "skill" ][ "bone_update_interval" ] );
			
			if ( !isdefined( self.bot.target ) || !isdefined( self.bot.target.entity ) )
			{
				continue;
			}
			
			self.bot.target.bone = selectBoneForTarget( self.bot.target.entity, bones );
		}
	}
}

/*
	Creates the base target obj
*/
createTargetObj( ent, theTime )
{
	obj = spawnstruct();
	obj.entity = ent;
	obj.last_seen_pos = ( 0, 0, 0 );
	obj.dist = 0;
	obj.time = theTime;
	obj.trace_time = 0;
	obj.no_trace_time = 0;
	obj.trace_time_time = 0;
	obj.rand = randomint( 100 );
	obj.didlook = false;
	obj.offset = undefined;
	obj.bone = undefined;
	obj.aim_offset = undefined;
	obj.aim_offset_base = undefined;
	
	return obj;
}

/*
	Updates the target object's difficulty missing aim, inaccurate shots
*/
updateAimOffset( obj )
{
	if ( !isdefined( obj.aim_offset_base ) )
	{
		diffAimAmount = self.pers[ "bots" ][ "skill" ][ "aim_offset_amount" ];
		
		if ( diffAimAmount > 0 )
		{
			obj.aim_offset_base = ( randomfloatrange( 0 - diffAimAmount, diffAimAmount ),
						randomfloatrange( 0 - diffAimAmount, diffAimAmount ),
						randomfloatrange( 0 - diffAimAmount, diffAimAmount ) );
		}
		else
		{
			obj.aim_offset_base = ( 0, 0, 0 );
		}
	}
	
	aimDiffTime = self.pers[ "bots" ][ "skill" ][ "aim_offset_time" ] * 1000;
	objCreatedFor = obj.trace_time;
	
	if ( objCreatedFor >= aimDiffTime )
	{
		offsetScalar = 0;
	}
	else
	{
		offsetScalar = 1 - objCreatedFor / aimDiffTime;
	}
	
	obj.aim_offset = obj.aim_offset_base * offsetScalar;
}

/*
	Updates the target object to be traced Has LOS
*/
targetObjUpdateTraced( obj, daDist, ent, theTime, isScriptObj )
{
	distClose = self.pers[ "bots" ][ "skill" ][ "dist_start" ];
	distClose *= self.bot.cur_weap_dist_multi;
	distClose *= distClose;
	
	distMax = self.pers[ "bots" ][ "skill" ][ "dist_max" ];
	distMax *= self.bot.cur_weap_dist_multi;
	distMax *= distMax;
	
	timeMulti = 1;
	
	if ( !isScriptObj )
	{
		if ( daDist > distMax )
		{
			timeMulti = 0;
		}
		else if ( daDist > distClose )
		{
			timeMulti = 1 - ( ( daDist - distClose ) / ( distMax - distClose ) );
		}
	}
	
	obj.no_trace_time = 0;
	obj.trace_time += int( 50 * timeMulti );
	obj.dist = daDist;
	obj.last_seen_pos = ent.origin;
	obj.trace_time_time = theTime;
	
	self updateAimOffset( obj );
}

/*
	Updates the target object to be not traced No LOS
*/
targetObjUpdateNoTrace( obj )
{
	obj.no_trace_time += 50;
	obj.trace_time = 0;
	obj.didlook = false;
}

/*
	Assigns the bot's after target (bot will keep firing at a target after no sight or death)
*/
start_bot_after_target( who )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	self.bot.after_target = who;
	self.bot.after_target_pos = who.origin;
	
	self notify( "kill_after_target" );
	self endon( "kill_after_target" );
	
	wait self.pers[ "bots" ][ "skill" ][ "shoot_after_time" ];
	
	self.bot.after_target = undefined;
}

/*
	Clears the bot's after target
*/
clear_bot_after_target()
{
	self.bot.after_target = undefined;
	self notify( "kill_after_target" );
}

/*
	This is the bot's main aimming thread. The bot will aim at its targets or a node its going towards. Bots will aim, fire, ads, grenade.
*/
aim_loop()
{
	aimspeed = self.pers[ "bots" ][ "skill" ][ "aim_time" ];
	
	eyePos = self geteye();
	curweap = self getcurrentweapon();
	angles = self getplayerangles();
	adsAmount = self playerads();
	adsAimSpeedFact = self.pers[ "bots" ][ "skill" ][ "ads_aimspeed_multi" ];
	
	// reduce aimspeed if ads'ing
	if ( adsAmount > 0 )
	{
		aimspeed *= 1 + adsAimSpeedFact * adsAmount;
	}
	
	if ( isdefined( self.bot.target ) && isdefined( self.bot.target.entity ) && !( self.bot.prio_objective && isdefined( self.bot.script_aimpos ) ) )
	{
		no_trace_time = self.bot.target.no_trace_time;
		no_trace_look_time = self.pers[ "bots" ][ "skill" ][ "no_trace_look_time" ];
		
		if ( no_trace_time <= no_trace_look_time )
		{
			trace_time = self.bot.target.trace_time;
			last_pos = self.bot.target.last_seen_pos;
			target = self.bot.target.entity;
			conedot = 0;
			isact = isai( self.bot.target.entity );
			
			offset = self.bot.target.offset;
			
			if ( !isdefined( offset ) )
			{
				offset = ( 0, 0, 0 );
			}
			
			aimoffset = self.bot.target.aim_offset;
			
			if ( !isdefined( aimoffset ) )
			{
				aimoffset = ( 0, 0, 0 );
			}
			
			dist = self.bot.target.dist;
			rand = self.bot.target.rand;
			no_trace_ads_time = self.pers[ "bots" ][ "skill" ][ "no_trace_ads_time" ];
			reaction_time = self.pers[ "bots" ][ "skill" ][ "reaction_time" ];
			nadeAimOffset = 0;
			
			bone = self.bot.target.bone;
			
			if ( !isdefined( bone ) )
			{
				bone = "j_spineupper";
			}
			
			if ( self.bot.isfraggingafter || self.bot.issmokingafter )
			{
				nadeAimOffset = dist / 3000;
			}
			else if ( curweap != "none" && weaponclass( curweap ) == "grenade" )
			{
				if ( true /*maps\mp\gametypes\_missions::getWeaponClass( curweap ) == "weapon_projectile"*/ )
				{
					nadeAimOffset = dist / 16000;
				}
				else
				{
					nadeAimOffset = dist / 3000;
				}
			}
			
			if ( no_trace_time && ( !isdefined( self.bot.after_target ) || self.bot.after_target != target ) )
			{
				if ( no_trace_time > no_trace_ads_time )
				{
					if ( isact )
					{
						// better room to nade? cook time function with dist?
						if ( !self.bot.isfraggingafter && !self.bot.issmokingafter )
						{
							nade = self getValidGrenade();
							
							if ( isdefined( nade ) && rand <= self.pers[ "bots" ][ "behavior" ][ "nade" ] && bullettracepassed( eyePos, eyePos + ( 0, 0, 75 ), false, self ) && bullettracepassed( last_pos, last_pos + ( 0, 0, 100 ), false, target ) && dist > level.bots_mingrenadedistance && dist < level.bots_maxgrenadedistance && getdvarint( "bots_play_nade" ) )
							{
								time = 0.5;
								
								if ( nade == "stielhandgranate" )
								{
									time = 2;
								}
								
								if ( !isSecondaryGrenade( nade ) )
								{
									self thread frag( time );
								}
								else
								{
									self thread smoke( time );
								}
								
								self notify( "kill_goal" );
							}
						}
					}
				}
				else
				{
					if ( self canFire( curweap ) && self isInRange( dist, curweap ) && self canAds( dist, curweap ) )
					{
						if ( !self.bot.is_cur_sniper || !self.pers[ "bots" ][ "behavior" ][ "quickscope" ] )
						{
							self thread pressADS();
						}
					}
				}
				
				self thread bot_lookat( last_pos + ( 0, 0, self getplayerviewheight() + nadeAimOffset ), aimspeed );
				return;
			}
			
			if ( trace_time )
			{
				if ( isact )
				{
					aimpos = target gettagorigin( bone );
					
					if ( !isdefined( aimpos ) )
					{
						return;
					}
					
					aimpos += offset;
					aimpos += aimoffset;
					aimpos += ( 0, 0, nadeAimOffset );
					
					conedot = getConeDot( aimpos, eyePos, angles );
					
					if ( isdefined( self.bot.knifing_target ) && self.bot.knifing_target == target )
					{
						self thread bot_lookat( target gettagorigin( "j_spine4" ), 0.05 );
					}
					else if ( !nadeAimOffset && conedot > 0.999995 && lengthsquared( aimoffset ) < 0.05 )
					{
						self thread bot_lookat( aimpos, 0.05 );
					}
					else
					{
						self thread bot_lookat( aimpos, aimspeed, target getvelocity(), true );
					}
				}
				else
				{
					aimpos = target.origin;
					aimpos += offset;
					aimpos += aimoffset;
					aimpos += ( 0, 0, nadeAimOffset );
					
					conedot = getConeDot( aimpos, eyePos, angles );
					
					if ( !nadeAimOffset && conedot > 0.999995 && lengthsquared( aimoffset ) < 0.05 )
					{
						self thread bot_lookat( aimpos, 0.05 );
					}
					else
					{
						self thread bot_lookat( aimpos, aimspeed );
					}
				}
				
				if ( isact && !self.bot.isknifingafter && conedot > 0.9 && dist < level.bots_maxknifedistance && trace_time > reaction_time && !self.bot.isreloading && getdvarint( "bots_play_knife" ) )
				{
					self clear_bot_after_target();
					self thread knife( target );
					return;
				}
				
				if ( !self canFire( curweap ) || !self isInRange( dist, curweap ) )
				{
					return;
				}
				
				canADS = ( self canAds( dist, curweap ) && conedot > 0.75 );
				
				if ( canADS )
				{
					stopAdsOverride = false;
					
					if ( self.bot.is_cur_sniper )
					{
						if ( self.pers[ "bots" ][ "behavior" ][ "quickscope" ] && self.bot.last_fire_time != -1 && gettime() - self.bot.last_fire_time < 1000 )
						{
							stopAdsOverride = true;
						}
						else
						{
							self notify( "kill_goal" );
						}
					}
					
					if ( !stopAdsOverride )
					{
						self thread pressADS();
					}
				}
				
				if ( trace_time > reaction_time )
				{
					if ( ( !canADS || adsAmount >= 1.0 || self inLastStand() || self getstance() == "prone" ) && ( conedot > 0.99 || dist < level.bots_maxknifedistance ) && getdvarint( "bots_play_fire" ) )
					{
						self botFire();
					}
					
					if ( isact )
					{
						self thread start_bot_after_target( target );
					}
				}
				
				return;
			}
		}
	}
	
	if ( isdefined( self.bot.after_target ) )
	{
		nadeAimOffset = 0;
		last_pos = self.bot.after_target_pos;
		dist = distancesquared( self.origin, last_pos );
		
		if ( self.bot.isfraggingafter || self.bot.issmokingafter )
		{
			nadeAimOffset = dist / 3000;
		}
		else if ( curweap != "none" && weaponclass( curweap ) == "grenade" )
		{
			if ( true /*maps\mp\gametypes\_missions::getWeaponClass( curweap ) == "weapon_projectile"*/ )
			{
				nadeAimOffset = dist / 16000;
			}
			else
			{
				nadeAimOffset = dist / 3000;
			}
		}
		
		aimpos = last_pos + ( 0, 0, self getplayerviewheight() + nadeAimOffset );
		conedot = getConeDot( aimpos, eyePos, angles );
		
		self thread bot_lookat( aimpos, aimspeed );
		
		if ( !self canFire( curweap ) || !self isInRange( dist, curweap ) )
		{
			return;
		}
		
		canADS = ( self canAds( dist, curweap ) && conedot > 0.75 );
		
		if ( canADS )
		{
			stopAdsOverride = false;
			
			if ( self.bot.is_cur_sniper )
			{
				if ( self.pers[ "bots" ][ "behavior" ][ "quickscope" ] && self.bot.last_fire_time != -1 && gettime() - self.bot.last_fire_time < 1000 )
				{
					stopAdsOverride = true;
				}
				else
				{
					self notify( "kill_goal" );
				}
			}
			
			if ( !stopAdsOverride )
			{
				self thread pressADS();
			}
		}
		
		if ( ( !canADS || adsAmount >= 1.0 || self inLastStand() || self getstance() == "prone" ) && ( conedot > 0.95 || dist < level.bots_maxknifedistance ) && getdvarint( "bots_play_fire" ) )
		{
			self botFire();
		}
		
		return;
	}
	
	if ( self.bot.next_wp != -1 && isdefined( level.waypoints[ self.bot.next_wp ].angles ) && false )
	{
		forwardPos = anglestoforward( level.waypoints[ self.bot.next_wp ].angles ) * 1024;
		
		self thread bot_lookat( eyePos + forwardPos, aimspeed );
	}
	else if ( isdefined( self.bot.script_aimpos ) )
	{
		self thread bot_lookat( self.bot.script_aimpos, aimspeed );
	}
	else
	{
		lookat = undefined;
		
		if ( self.bot.second_next_wp != -1 && !self.bot.issprinting && !self.bot.climbing )
		{
			lookat = level.waypoints[ self.bot.second_next_wp ].origin;
		}
		else if ( isdefined( self.bot.towards_goal ) )
		{
			lookat = self.bot.towards_goal;
		}
		
		if ( isdefined( lookat ) )
		{
			self thread bot_lookat( lookat + ( 0, 0, self getplayerviewheight() ), aimspeed );
		}
	}
}

/*
	This is the bot's main aimming thread. The bot will aim at its targets or a node its going towards. Bots will aim, fire, ads, grenade.
*/
aim()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		wait 0.05;
		waittillframeend;
		
		if ( ( isdefined( level.intermission ) && level.intermission ) || self.bot.isfrozen )
		{
			continue;
		}
		
		self aim_loop();
	}
}

/*
	This is the main walking logic for the bot.
*/
walk()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		wait 0.05;
		
		self botSetMoveTo( self.origin );
		
		if ( !getdvarint( "bots_play_move" ) )
		{
			continue;
		}
		
		if ( ( isdefined( level.intermission ) && level.intermission ) || self.bot.isfrozen || self.bot.stop_move )
		{
			continue;
		}
		
		self walk_loop();
	}
}

/*
	This is the main walking logic for the bot.
*/
walk_loop()
{
	shouldTarget = isdefined( self.bot.target ) && isdefined( self.bot.target.entity ) && !self.bot.prio_objective;
	
	if ( shouldTarget )
	{
		curweap = self getcurrentweapon();
		
		if ( self.bot.isfraggingafter || self.bot.issmokingafter )
		{
			return;
		}
		
		if ( isai( self.bot.target.entity ) && self.bot.target.trace_time && self canFire( curweap ) && self isInRange( self.bot.target.dist, curweap ) )
		{
			if ( self inLastStand() || self getstance() == "prone" || ( self.bot.is_cur_sniper && self playerads() > 0 ) )
			{
				return;
			}
			
			if ( self.bot.target.rand <= self.pers[ "bots" ][ "behavior" ][ "strafe" ] )
			{
				self strafe( self.bot.target.entity );
			}
			
			return;
		}
	}
	
	dist = 16;
	
	//goal = self getRandomGoal();
	goal = level.players[ 0 ].origin;
	
	isScriptGoal = false;
	
	if ( self HasScriptGoal() && !shouldTarget )
	{
		goal = self GetScriptGoalPos();
		dist = self.bot.script_goal.dist;
		
		isScriptGoal = true;
	}
	else
	{
		if ( shouldTarget )
		{
			goal = self.bot.target.last_seen_pos;
		}
		
		self notify( "new_goal_internal" );
	}
	
	self doWalk( goal, dist, isScriptGoal );
	self.bot.towards_goal = undefined;
	self.bot.next_wp = -1;
	self.bot.second_next_wp = -1;
}

/*
	Will walk to the given goal when dist near. Uses AStar path finding with the level's nodes.
*/
doWalk( goal, dist, isScriptGoal )
{
	level endon( "intermission" );
	self endon( "kill_goal" );
	self endon( "goal_internal" ); // so that the watchOnGoal notify can happen same frame, not a frame later
	
	dist *= dist;
	
	if ( isScriptGoal )
	{
		self thread doWalkScriptNotify();
	}
	
	self thread killWalkOnEvents();
	self thread watchOnGoal( goal, dist );
	
	current = self initAStar( goal );
	
	path_was_truncated = ( current + 1 ) >= 32;
	
	if ( current <= -1 )
	{
		self notify( "bad_path_internal" );
		return;
	}
	
	// skip waypoints we already completed to prevent rubber banding
	if ( current > 0 && self.bot.astar[ current ] == self.bot.last_next_wp && self.bot.astar[ current - 1 ] == self.bot.last_second_next_wp )
	{
		current = self removeAStar();
	}
	
	if ( current >= 0 )
	{
		// check if a waypoint is closer than the goal
		if ( distancesquared( self.origin, level.waypoints[ self.bot.astar[ current ] ].origin ) < distancesquared( self.origin, goal ) || distancesquared( level.waypoints[ self.bot.astar[ current ] ].origin, playerphysicstrace( self.origin + ( 0, 0, 32 ), level.waypoints[ self.bot.astar[ current ] ].origin ) ) > 1.0 )
		{
			while ( current >= 0 )
			{
				self.bot.next_wp = self.bot.astar[ current ];
				self.bot.second_next_wp = -1;
				
				if ( current > 0 )
				{
					self.bot.second_next_wp = self.bot.astar[ current - 1 ];
				}
				
				self notify( "new_static_waypoint" );
				
				self movetowards( level.waypoints[ self.bot.next_wp ].origin );
				self.bot.last_next_wp = self.bot.next_wp;
				self.bot.last_second_next_wp = self.bot.second_next_wp;
				
				current = self removeAStar();
			}
		}
	}
	
	if ( path_was_truncated )
	{
		self notify( "kill_goal" );
		return;
	}
	
	self.bot.next_wp = -1;
	self.bot.second_next_wp = -1;
	self notify( "finished_static_waypoints" );
	
	if ( distancesquared( self.origin, goal ) > dist )
	{
		self.bot.last_next_wp = -1;
		self.bot.last_second_next_wp = -1;
		self movetowards( goal ); // any better way??
	}
	
	self notify( "finished_goal" );
	
	wait 1;
	
	if ( distancesquared( self.origin, goal ) > dist )
	{
		self notify( "bad_path_internal" );
	}
}

/*
	Will move towards the given goal. Will try to not get stuck by crouching, then jumping and then strafing around objects.
*/
movetowards( goal )
{
	if ( !isdefined( goal ) )
	{
		return;
	}
	
	self.bot.towards_goal = goal;
	
	lastOri = self.origin;
	stucks = 0;
	timeslow = 0;
	time = 0;
	
	if ( self.bot.issprinting )
	{
		tempGoalDist = level.bots_goaldistance * 2;
	}
	else
	{
		tempGoalDist = level.bots_goaldistance;
	}
	
	//iprintln( "Bot origin: " + self.origin + " bot goal: " + goal + " tempgoaldist: " + tempGoalDist );
	//print( "Bot origin: " + self.origin + " bot goal: " + goal + " tempgoaldist: " + tempGoalDist );
	while ( distancesquared( self.origin, goal ) > tempGoalDist )
	{
		self botSetMoveTo( goal );
		
		if ( time > 3000 )
		{
			time = 0;
			
			if ( distancesquared( self.origin, lastOri ) < 32 * 32 )
			{
				self thread knife();
				wait 0.5;
				
				stucks++;
				
				randomDir = self getRandomLargestStafe( stucks );
				
				self BotNotifyBotEvent( "stuck" );
				
				self botSetMoveTo( randomDir );
				wait stucks;
				self stand();
				
				self.bot.last_next_wp = -1;
				self.bot.last_second_next_wp = -1;
			}
			
			lastOri = self.origin;
		}
		else if ( timeslow > 0 && ( timeslow % 1000 ) == 0 )
		{
			self thread doMantle();
		}
		else if ( time == 2000 )
		{
			if ( distancesquared( self.origin, lastOri ) < 32 * 32 )
			{
				self crouch();
			}
		}
		else if ( time == 1750 )
		{
			if ( distancesquared( self.origin, lastOri ) < 32 * 32 )
			{
				// check if directly above or below
				if ( abs( goal[ 2 ] - self.origin[ 2 ] ) > 64 && getConeDot( goal + ( 1, 1, 0 ), self.origin + ( -1, -1, 0 ), vectortoangles( ( goal[ 0 ], goal[ 1 ], self.origin[ 2 ] ) - self.origin ) ) < 0.64 && distancesquared2D( self.origin, goal ) < 32 * 32 )
				{
					stucks = 2;
				}
			}
		}
		
		wait 0.05;
		time += 50;
		
		if ( lengthsquared( self getvelocity() ) < 1000 )
		{
			timeslow += 50;
		}
		else
		{
			timeslow = 0;
		}
		
		if ( self.bot.issprinting )
		{
			tempGoalDist = level.bots_goaldistance * 2;
		}
		else
		{
			tempGoalDist = level.bots_goaldistance;
		}
		
		if ( stucks >= 2 )
		{
			self notify( "bad_path_internal" );
		}
	}
	
	self.bot.towards_goal = undefined;
	self notify( "completed_move_to" );
}

/*
	The bot will strafe left or right from their enemy.
*/
strafe( target )
{
	self endon( "kill_goal" );
	self thread killWalkOnEvents();
	
	angles = vectortoangles( vectornormalize( target.origin - self.origin ) );
	anglesLeft = ( 0, angles[ 1 ] + 90, 0 );
	anglesRight = ( 0, angles[ 1 ] - 90, 0 );
	
	myOrg = self.origin + ( 0, 0, 16 );
	left = myOrg + anglestoforward( anglesLeft ) * 500;
	right = myOrg + anglestoforward( anglesRight ) * 500;
	
	traceLeft = bullettrace( myOrg, left, false, self );
	traceRight = bullettrace( myOrg, right, false, self );
	
	strafe = traceLeft[ "position" ];
	
	if ( traceRight[ "fraction" ] > traceLeft[ "fraction" ] )
	{
		strafe = traceRight[ "position" ];
	}
	
	self.bot.last_next_wp = -1;
	self.bot.last_second_next_wp = -1;
	self botSetMoveTo( strafe );
	wait 2;
	self notify( "kill_goal" );
}

/*
	Will return the pos of the largest trace from the bot.
*/
getRandomLargestStafe( dist )
{
	// find a better algo?
	traces = NewHeap( ::HeapTraceFraction );
	myOrg = self.origin + ( 0, 0, 16 );
	
	traces HeapInsert( bullettrace( myOrg, myOrg + ( -100 * dist, 0, 0 ), false, self ) );
	traces HeapInsert( bullettrace( myOrg, myOrg + ( 100 * dist, 0, 0 ), false, self ) );
	traces HeapInsert( bullettrace( myOrg, myOrg + ( 0, 100 * dist, 0 ), false, self ) );
	traces HeapInsert( bullettrace( myOrg, myOrg + ( 0, -100 * dist, 0 ), false, self ) );
	traces HeapInsert( bullettrace( myOrg, myOrg + ( -100 * dist, -100 * dist, 0 ), false, self ) );
	traces HeapInsert( bullettrace( myOrg, myOrg + ( -100 * dist, 100 * dist, 0 ), false, self ) );
	traces HeapInsert( bullettrace( myOrg, myOrg + ( 100 * dist, -100 * dist, 0 ), false, self ) );
	traces HeapInsert( bullettrace( myOrg, myOrg + ( 100 * dist, 100 * dist, 0 ), false, self ) );
	
	toptraces = [];
	
	top = traces.data[ 0 ];
	toptraces[ toptraces.size ] = top;
	traces HeapRemove();
	
	while ( traces.data.size && top[ "fraction" ] - traces.data[ 0 ][ "fraction" ] < 0.1 )
	{
		toptraces[ toptraces.size ] = traces.data[ 0 ];
		traces HeapRemove();
	}
	
	return toptraces[ randomint( toptraces.size ) ][ "position" ];
}

/*
	Calls the astar search algorithm for the path to the goal.
*/
initAStar( goal )
{
	nodes = scripts\zm\pluto_sys::generatepath( self.origin, goal, self.team, undefined );
	
	if ( !isdefined( nodes ) || nodes.size <= 0 )
	{
		// Try again to find a path to the origin using best effort algo
		nodes = scripts\zm\pluto_sys::generatepath( self.origin, goal, self.team, undefined, 192.0 );
		
		if ( !isdefined( nodes ) || nodes.size <= 0 )
		{
			self.bot.astar = [];
			return -1;
		}
	}
	
	node_indexes = [];
	
	for ( i = nodes.size - 1; i >= 0; i-- )
	{
		node_indexes[ node_indexes.size ] = nodes[ i ] scripts\zm\pluto_sys::getnodenumber();
	}
	
	self.bot.astar = node_indexes;
	
	return self.bot.astar.size - 1;
}

/*
	Cleans up the astar nodes for one node.
*/
removeAStar()
{
	remove = self.bot.astar.size - 1;
	
	self.bot.astar[ remove ] = undefined;
	
	return self.bot.astar.size - 1;
}

/*
	Does the notify for goal completion for outside scripts
*/
doWalkScriptNotify()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "kill_goal" );
	
	if ( self waittill_either_return( "goal_internal", "bad_path_internal" ) == "goal_internal" )
	{
		self notify( "goal" );
	}
	else
	{
		self notify( "bad_path" );
	}
}

/*
	Will stop the goal walk when an enemy is found or flashed or a new goal appeared for the bot.
*/
killWalkOnEvents()
{
	self endon( "kill_goal" );
	self endon( "disconnect" );
	self endon( "zombified" );
	
	self waittill_any( "new_enemy", "new_goal_internal", "goal_internal", "bad_path_internal" );
	
	waittillframeend;
	
	self notify( "kill_goal" );
}

/*
	Will kill the goal when the bot made it to its goal.
*/
watchOnGoal( goal, dis )
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "kill_goal" );
	
	while ( distancesquared( self.origin, goal ) > dis )
	{
		wait 0.05;
	}
	
	self notify( "goal_internal" );
}

/*
	Bot will move towards here
*/
botSetMoveTo( where )
{
	self.bot.moveto = where;
}

/*
	Bot will press ADS for a time.
*/
pressADS( time )
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self notify( "bot_ads" );
	self endon( "bot_ads" );
	
	if ( !isdefined( time ) )
	{
		time = 0.05;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "+ads" );
	
	if ( time )
	{
		wait time;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "-ads" );
}

/*
	Bot will hold the frag button for a time
*/
frag( time )
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self notify( "bot_frag" );
	self endon( "bot_frag" );
	
	if ( !isdefined( time ) )
	{
		time = 0.05;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "+frag" );
	self.bot.isfragging = true;
	self.bot.isfraggingafter = true;
	
	if ( time )
	{
		wait time;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "-frag" );
	self.bot.isfragging = false;
	
	wait 1.25;
	self.bot.isfraggingafter = false;
}

/*
	Bot will hold breath if true or not
*/
holdbreath( what )
{
	if ( what )
	{
		self scripts\zm\pluto_sys::botbuttonoverride( "+holdbreath" );
	}
	else
	{
		self scripts\zm\pluto_sys::botbuttonoverride( "-holdbreath" );
	}
}

/*
	Bot will hold the 'smoke' button for a time.
*/
smoke( time )
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self notify( "bot_smoke" );
	self endon( "bot_smoke" );
	
	if ( !isdefined( time ) )
	{
		time = 0.05;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "+smoke" );
	self.bot.issmoking = true;
	self.bot.issmokingafter = true;
	
	if ( time )
	{
		wait time;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "-smoke" );
	self.bot.issmoking = false;
	
	wait 1.25;
	self.bot.issmokingafter = false;
}

/*
	Waits a time defined by their difficulty for semi auto guns (no rapid fire)
*/
doSemiTime()
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self notify( "bot_semi_time" );
	self endon( "bot_semi_time" );
	
	self.bot.semi_time = true;
	wait self.pers[ "bots" ][ "skill" ][ "semi_time" ];
	self.bot.semi_time = false;
}

/*
	Bots will fire their gun.
*/
botFire()
{
	self.bot.last_fire_time = gettime();
	
	if ( self.bot.is_cur_full_auto )
	{
		self thread pressFire();
		return;
	}
	
	if ( self.bot.semi_time )
	{
		return;
	}
	
	self thread pressFire();
	self thread doSemiTime();
}

/*
	Bots do the mantle
*/
doMantle()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "kill_goal" );
	
	self jump();
	
	wait 0.35;
	
	self jump();
}

/*
	Bot will fire for a time.
*/
pressFire( time )
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self notify( "bot_fire" );
	self endon( "bot_fire" );
	
	if ( !isdefined( time ) )
	{
		time = 0.05;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "+attack" );
	
	if ( time )
	{
		wait time;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "-attack" );
}

/*
	Bot will reload.
*/
reload()
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_reload" );
	self endon( "bot_reload" );
	
	self scripts\zm\pluto_sys::botbuttonoverride( "+reload" );
	wait 0.05;
	self scripts\zm\pluto_sys::botbuttonoverride( "-reload" );
}

/*
	Performs melee target
*/
do_knife_target( target )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "bot_knife" );
	
	// dedi doesnt have this registered
	if ( getdvar( "aim_automelee_enabled" ) == "" )
	{
		setdvar( "aim_automelee_enabled", 1 );
	}
	
	if ( getdvar( "aim_automelee_range" ) == "" )
	{
		setdvar( "aim_automelee_range", 128 );
	}
	
	if ( !getdvarint( "aim_automelee_enabled" ) || !self isonground() || self getstance() == "prone" || self inLastStand() )
	{
		self.bot.knifing_target = undefined;
		self scripts\zm\pluto_sys::botmeleeparams( 0, 0 );
		return;
	}
	
	if ( !isdefined( target ) || ( !isplayer( target ) && !isai( target ) ) )
	{
		self.bot.knifing_target = undefined;
		self scripts\zm\pluto_sys::botmeleeparams( 0, 0 );
		return;
	}
	
	dist = distance( target.origin, self.origin );
	
	if ( dist > getdvarfloat( "aim_automelee_range" ) )
	{
		self.bot.knifing_target = undefined;
		self scripts\zm\pluto_sys::botmeleeparams( 0, 0 );
		return;
	}
	
	self.bot.knifing_target = target;
	
	angles = vectortoangles( target.origin - self.origin );
	self scripts\zm\pluto_sys::botmeleeparams( angles[ 1 ], dist );
	
	wait 1;
	
	self.bot.knifing_target = undefined;
	self scripts\zm\pluto_sys::botmeleeparams( 0, 0 );
}

/*
	Bot will knife.
*/
knife( target )
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self notify( "bot_knife" );
	self endon( "bot_knife" );
	
	self thread do_knife_target( target );
	
	self.bot.isknifing = true;
	self.bot.isknifingafter = true;
	
	self scripts\zm\pluto_sys::botbuttonoverride( "+melee" );
	wait 0.05;
	self scripts\zm\pluto_sys::botbuttonoverride( "-melee" );
	
	self.bot.isknifing = false;
	
	wait 1;
	
	self.bot.isknifingafter = false;
}

/*
	Bot will press use for a time.
*/
use( time )
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self notify( "bot_use" );
	self endon( "bot_use" );
	
	if ( !isdefined( time ) )
	{
		time = 0.05;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "+activate" );
	
	if ( time )
	{
		wait time;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "-activate" );
}

/*
	Bot will jump.
*/
jump()
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self notify( "bot_jump" );
	self endon( "bot_jump" );
	
	if ( self getstance() != "stand" )
	{
		self stand();
		wait 1;
	}
	
	self scripts\zm\pluto_sys::botbuttonoverride( "+gostand" );
	wait 0.05;
	self scripts\zm\pluto_sys::botbuttonoverride( "-gostand" );
}

/*
	Bot will stand.
*/
stand()
{
	self scripts\zm\pluto_sys::botbuttonoverride( "-crouch" );
	self scripts\zm\pluto_sys::botbuttonoverride( "-prone" );
}

/*
	Bot will crouch.
*/
crouch()
{
	self scripts\zm\pluto_sys::botbuttonoverride( "+crouch" );
	self scripts\zm\pluto_sys::botbuttonoverride( "-prone" );
}

/*
	Bot will prone.
*/
prone()
{
	self scripts\zm\pluto_sys::botbuttonoverride( "-crouch" );
	self scripts\zm\pluto_sys::botbuttonoverride( "+prone" );
}

/*
	Bot will sprint.
*/
sprint()
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self notify( "bot_sprint" );
	self endon( "bot_sprint" );
	
	self scripts\zm\pluto_sys::botbuttonoverride( "+sprint" );
	wait 0.05;
	self scripts\zm\pluto_sys::botbuttonoverride( "-sprint" );
}
