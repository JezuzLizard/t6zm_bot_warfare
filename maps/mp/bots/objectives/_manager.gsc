#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bot_utility;
#include maps\mp\bots\_bot_api;
#include maps\mp\bots\objectives\_utility;

//#inline scripts\zm\pluto_sys;
//#define PLUTO scripts\zm\pluto_sys
init()
{
	level.bot_objectives = [];
	level.bot_objectives[ level.bot_objectives.size ] = CreateObjectiveForManger( "revive", maps\mp\bots\objectives\_revive::Finder, maps\mp\bots\objectives\_revive::Priority, maps\mp\bots\objectives\_revive::Executer, 1000 );
	level.bot_objectives[ level.bot_objectives.size ] = CreateObjectiveForManger( "powerup", maps\mp\bots\objectives\_powerup::Finder, maps\mp\bots\objectives\_powerup::Priority, maps\mp\bots\objectives\_powerup::Executer, 2500 );
	level.bot_objectives[ level.bot_objectives.size ] = CreateObjectiveForManger( "wallweapon", maps\mp\bots\objectives\_wallweapon::Finder, maps\mp\bots\objectives\_wallweapon::Priority, maps\mp\bots\objectives\_wallweapon::Executer, 7500 );
	level.bot_objectives[ level.bot_objectives.size ] = CreateObjectiveForManger( "treasurechest", maps\mp\bots\objectives\_treasurechest::Finder, maps\mp\bots\objectives\_treasurechest::Priority, maps\mp\bots\objectives\_treasurechest::Executer, 7000 );
	maps\mp\bots\objectives\_perkmachine::init();
	level.bot_objectives[ level.bot_objectives.size ] = CreateObjectiveForManger( "perkmachine", maps\mp\bots\objectives\_perkmachine::Finder, maps\mp\bots\objectives\_perkmachine::Priority, maps\mp\bots\objectives\_perkmachine::Executer, 10000 );
}

connected()
{
	self.bot_current_objective = undefined;
}

spawned()
{
	self.bot_current_objective = undefined;
	
	self thread clean_objective_on_completion();
	self thread watch_for_objective_canceled();
}

watch_for_objective_canceled()
{
	self endon( "disconnect" );
	level endon( "intermission" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		self waittill( "cancel_bot_objective", reason );
		
		obj_name = "undefined";
		
		if ( isdefined( self.bot_current_objective ) )
		{
			obj_name = self.bot_current_objective.sname;
		}
		
		self BotNotifyBotEvent( "debug", "watch_for_objective_canceled: " + obj_name + ": " + reason );
	}
}

clean_objective_on_completion()
{
	self endon( "disconnect" );
	level endon( "intermission" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		self waittill( "completed_bot_objective", successful, reason );
		
		obj_name = "undefined";
		
		if ( isdefined( self.bot_current_objective ) )
		{
			obj_name = self.bot_current_objective.sname;
			
			self.bot_current_objective.eparentobj.abotprocesstimes[ self getentitynumber() + "" ] = gettime();
		}
		
		self BotNotifyBotEvent( "debug", "clean_objective_on_completion: " + obj_name + ": " + successful + ": " + reason );
		
		waittillframeend;
		self.bot_current_objective = undefined;
	}
}

start_bot_threads()
{
	self endon( "disconnect" );
	level endon( "intermission" );
	self endon( "zombified" );
	
	self thread bot_objective_think();
}

bot_objective_think()
{
	self endon( "disconnect" );
	level endon( "intermission" );
	self endon( "zombified" );
	
	for ( ;; )
	{
		wait 1;
		
		// find all avail objectives
		objectives = [];
		now = gettime();
		our_key = self getentitynumber() + "";
		
		for ( i = 0; i < level.bot_objectives.size; i++ )
		{
			objective = level.bot_objectives[ i ];
			
			// check the process rate
			if ( isdefined( objective.abotprocesstimes[ our_key ] ) && now - objective.abotprocesstimes[ our_key ] < objective.iprocessrate )
			{
				continue;
			}
			
			objectives = arraycombine( objectives, self [[ objective.fpfinder ]]( objective ), 1, 0 );
			objective.abotprocesstimes[ our_key ] = now;
		}
		
		if ( objectives.size <= 0 )
		{
			continue;
		}
		
		// sort according to priority
		heap = NewHeap( ::HeapPriority );
		
		for ( i = 0; i < objectives.size; i++ )
		{
			if ( objectives[ i ].fpriority <= -100 )
			{
				continue;
			}
			
			heap HeapInsert( objectives[ i ] );
		}
		
		// pop the top!
		best_prio = heap.data[ 0 ];
		
		if ( !isdefined( best_prio ) )
		{
			continue;
		}
		
		// already on a better obj
		if ( isdefined( self.bot_current_objective ) && ( best_prio.guid == self.bot_current_objective.guid || best_prio.fpriority < self [[ self.bot_current_objective.eparentobj.fppriorty ]]( self.bot_current_objective.eparentobj, self.bot_current_objective.eent ) ) )
		{
			continue;
		}
		
		// DO THE OBJ
		// cancel the old obj
		if ( isdefined( self.bot_current_objective ) )
		{
			// cancel it
			self CancelObjective( "new obj: " + best_prio.sname );
			
			// wait for it to clean up
			self waittill( "completed_bot_objective" );
			
			// redo the loop, should do the obj next iteration
			best_prio.eparentobj.abotprocesstimes[ our_key ] = undefined;
			continue;
		}
		
		// ready to execute
		self BotNotifyBotEvent( "debug", "bot_objective_think: " + best_prio.sname );
		
		self.bot_current_objective = best_prio;
		self thread [[ best_prio.eparentobj.fpexecuter ]]( best_prio );
	}
}
