#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bot_utility;

//#inline scripts\zm\pluto_sys;
//#define PLUTO scripts\zm\pluto_sys
//#define GOAL_TYPE_NONE 0
//#define GOAL_TYPE_ENT 1
//#define GOAL_TYPE_NODE 2
//#define GOAL_TYPE_POS 3

//#define INVALID_POS ( -999999, -999999, -999999 )
//#define INVALID_ANGLES ( -999999, -999999, -999999 )

/*
struct script_goal_t
{
	entity_t ent = undefined;
	node_t node = undefined;
	vector_t offset = ( 0, 0, 0 );
	vector_t origin = ( -999999, -999999, -999999 );
	vector_t angles = ( -999999, -999999, -999999 );
	float_t dist = -1.0;
	script_goal_type_t type = GOAL_TYPE_NONE;
};
*/

/*
	Returns if the player is a bot.
*/
is_bot()
{
	return self istestclient();
}

/*
	Set the bot's stance
*/
BotSetStance( stance )
{
	switch ( stance )
	{
		case "stand":
			self maps\mp\bots\_bot_internal::stand();
			break;
			
		case "crouch":
			self maps\mp\bots\_bot_internal::crouch();
			break;
			
		case "prone":
			self maps\mp\bots\_bot_internal::prone();
			break;
	}
}

/*
	Bot presses the button for time.
*/
BotPressAttack( time )
{
	self maps\mp\bots\_bot_internal::pressFire( time );
}

/*
	Bot presses the ads button for time.
*/
BotPressADS( time )
{
	self maps\mp\bots\_bot_internal::pressADS( time );
}

/*
	Bot presses the use button for time.
*/
BotPressUse( time )
{
	self maps\mp\bots\_bot_internal::use( time );
}

/*
	Bot presses the frag button for time.
*/
BotPressFrag( time )
{
	self maps\mp\bots\_bot_internal::frag( time );
}

/*
	Bot presses the smoke button for time.
*/
BotPressSmoke( time )
{
	self maps\mp\bots\_bot_internal::smoke( time );
}

/*
	Bot jumps
*/
BotJump()
{
	self maps\mp\bots\_bot_internal::jump();
}

/*
	Returns the bot's random assigned number.
*/
BotGetRandom()
{
	return self.bot.rand;
}

/*
	Returns a random number thats different everytime it changes target
*/
BotGetTargetRandom()
{
	if ( !isdefined( self.bot.target ) )
	{
		return undefined;
	}
	
	return self.bot.target.rand;
}

/*
	Returns if the bot is fragging.
*/
IsBotFragging()
{
	return self.bot.isfraggingafter;
}

/*
	Returns if the bot is pressing smoke button.
*/
IsBotSmoking()
{
	return self.bot.issmokingafter;
}

/*
	Returns if the bot is sprinting.
*/
IsBotSprinting()
{
	return self.bot.issprinting;
}

/*
	Returns if the bot is reloading.
*/
IsBotReloading()
{
	return self.bot.isreloading;
}

/*
	Is bot knifing
*/
IsBotKnifing()
{
	return self.bot.isknifingafter;
}

/*
	Freezes the bot's controls.
*/
BotFreezeControls( what )
{
	self.bot.isfrozen = what;
	
	if ( what )
	{
		self notify( "kill_goal" );
	}
}

/*
	Returns if the bot is script frozen.
*/
BotIsFrozen()
{
	return self.bot.isfrozen;
}

/*
	Bot will stop moving
*/
BotStopMoving( what )
{
	self.bot.stop_move = what;
	
	if ( what )
	{
		self notify( "kill_goal" );
	}
}

/*
	Waits till frame end so that if two notifies happen in the same frame, the other will not be missed.
*/
BotNotifyBotEvent_( msg, a, b, c, d, e, f, g )
{
	self endon( "disconnect" );
	waittillframeend; // wait for the waittills to setup again
	self notify( "bot_event", msg, a, b, c, d, e, f, g );
}

/*
	Notify the bot chat message
*/
BotNotifyBotEvent( msg, a, b, c, d, e, f, g )
{
	self thread BotNotifyBotEvent_( msg, a, b, c, d, e, f, g );
}

/*
	Does the bot have an objective?
*/
BotHasObjective()
{
	return self maps\mp\bots\objectives\_utility::HasBotObjective();
}

/*
	Returns if the bot has a script goal.
	(like t5 gsc bot)
*/
HasScriptGoal()
{
	return self.bot.script_goal.type != 0;
}

/*
	Returns if the pos is valid
*/
IsValidPos( pos )
{
	return pos != ( -999999, -999999, -999999 );
}

/*
	Returns the pos of the bot's goal
*/
GetScriptGoalPos()
{
	if ( !self HasScriptGoal() )
	{
		return ( -999999, -999999, -999999 );
	}

	switch ( self.bot.script_goal.type )
	{
		case 1:
			return self.bot.script_goal.ent.origin;
		case 2:
			return self.bot.script_goal.node.origin;
		case 3:
			return self.bot.script_goal.origin;
	}

	return ( -999999, -999999, -999999 );
}

/*
	Sets the bot's goal, will acheive it when dist away from it.
*/
SetScriptGoalEnt( ent, dist, offset, angles )
{
	if ( !isdefined( dist ) )
	{
		dist = 16;
	}
	
	self.bot.script_goal.ent = ent;
	self.bot.script_goal.node = undefined;
	self.bot.script_goal.dist = dist;
	self.bot.script_goal.offset = offset;
	self.bot.script_goal.type = 1;
	self.bot.script_goal.origin = ( -999999, -999999, -999999 );
	self.bot.script_goal.angles = isdefined( angles ) ? angles : ( -999999, -999999, -999999 );
	self.bot.script_goal.goal_oriented = true;
	waittillframeend;
	self notify( "new_goal_internal" );
	self notify( "new_goal" );
}

/*
	Sets the bot's goal, will acheive it when dist away from it.
*/
SetScriptGoalPos( pos, dist, offset, angles )
{
	if ( !isdefined( dist ) )
	{
		dist = 16;
	}
	
	self.bot.script_goal.ent = undefined;
	self.bot.script_goal.node = undefined;
	self.bot.script_goal.dist = dist;
	self.bot.script_goal.offset = offset;
	self.bot.script_goal.type = 3;
	self.bot.script_goal.origin = pos;
	self.bot.script_goal.angles = isdefined( angles ) ? angles : ( -999999, -999999, -999999 );
	self.bot.script_goal.goal_oriented = true;
	waittillframeend;
	self notify( "new_goal_internal" );
	self notify( "new_goal" );
}

/*
	Sets the bot's goal, will acheive it when dist away from it.
*/
SetScriptGoalNode( node, dist, offset, angles )
{
	if ( !isdefined( dist ) )
	{
		dist = 16;
	}
	
	self.bot.script_goal.ent = undefined;
	self.bot.script_goal.node = node;
	self.bot.script_goal.dist = dist;
	self.bot.script_goal.offset = offset;
	self.bot.script_goal.type = 2;
	self.bot.script_goal.origin = ( -999999, -999999, -999999 );
	self.bot.script_goal.angles = isdefined( angles ) ? angles : ( -999999, -999999, -999999 );
	self.bot.script_goal.goal_oriented = true;
	waittillframeend;
	self notify( "new_goal_internal" );
	self notify( "new_goal" );
}

/*
	Clears the bot's goal.
*/
ClearScriptGoal()
{
	self.bot.script_goal.ent = undefined;
	self.bot.script_goal.node = undefined;
	self.bot.script_goal.dist = 0;
	self.bot.script_goal.offset = ( 0, 0, 0 );
	self.bot.script_goal.type = 0;
	self.bot.script_goal.origin = ( -999999, -999999, -999999 );
	self.bot.script_goal.angles = ( -999999, -999999, -999999 );
	self.bot.script_goal.goal_oriented = false;
	waittillframeend;
	self notify( "new_goal_internal" );
	self notify( "new_goal" );
}

/*
	Returns whether the bot has a priority objective
*/
HasPriorityObjective()
{
	return self.bot.prio_objective;
}

/*
	Sets the bot to prioritize the objective over targeting enemies
*/
SetPriorityObjective()
{
	self.bot.prio_objective = true;
	self notify( "kill_goal" );
}

/*
	Clears the bot's priority objective to allow the bot to target enemies automatically again
*/
ClearPriorityObjective()
{
	self.bot.prio_objective = false;
	self notify( "kill_goal" );
}

/*
	Sets the aim position of the bot
*/
SetScriptAimPos( pos )
{
	self.bot.script_aimpos = pos;
}

/*
	Clears the aim position of the bot
*/
ClearScriptAimPos()
{
	self SetScriptAimPos( undefined );
}

/*
	Returns the aim position of the bot
*/
GetScriptAimPos()
{
	return self.bot.script_aimpos;
}

/*
	Returns if the bot has a aim pos
*/
HasScriptAimPos()
{
	return isdefined( self GetScriptAimPos() );
}

/*
	Sets the bot's target to be this ent.
*/
SetAttacker( att )
{
	self.bot.target_this_frame = att;
}

/*
	Sets the script enemy for a bot.
*/
SetScriptEnemy( enemy, offset )
{
	self.bot.script_target = enemy;
	self.bot.script_target_offset = offset;
}

/*
	Removes the script enemy of the bot.
*/
ClearScriptEnemy()
{
	self SetScriptEnemy( undefined, undefined );
}

/*
	Returns the entity of the bot's target.
*/
GetThreat()
{
	if ( !isdefined( self.bot.target ) )
	{
		return undefined;
	}
	
	return self.bot.target.entity;
}

/*
	Returns if the bot has a script enemy.
*/
HasScriptEnemy()
{
	return ( isdefined( self.bot.script_target ) );
}

/*
	Returns if the bot has a threat.
*/
HasThreat()
{
	return ( isdefined( self GetThreat() ) );
}

/*
	Returns a valid grenade launcher weapon
*/
getValidTube()
{
	weaps = self getweaponslist();
	
	for ( i = 0; i < weaps.size; i++ )
	{
		weap = weaps[ i ];
		
		if ( !self getammocount( weap ) )
		{
			continue;
		}
		
		if ( issubstr( weap, "gl_" ) && !issubstr( weap, "_gl_" ) )
		{
			return weap;
		}
	}
	
	return undefined;
}

/*
	Returns a random grenade in the bot's inventory.
*/
getValidGrenade()
{
	grenadeTypes = [];
	grenadeTypes[ grenadeTypes.size ] = "stielhandgranate";
	
	possibles = [];
	
	for ( i = 0; i < grenadeTypes.size; i++ )
	{
		if ( !self hasweapon( grenadeTypes[ i ] ) )
		{
			continue;
		}
		
		if ( !self getammocount( grenadeTypes[ i ] ) )
		{
			continue;
		}
		
		possibles[ possibles.size ] = grenadeTypes[ i ];
	}
	
	return PickRandom( possibles );
}