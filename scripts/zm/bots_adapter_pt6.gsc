init()
{
	level.bot_builtins[ "printconsole" ] = ::do_printconsole;
	level.bot_builtins[ "botbuttonoverride" ] = ::do_botbuttonoverride;
	level.bot_builtins[ "botmovementoverride" ] = ::do_botmovementoverride;
	level.bot_builtins[ "botmeleeparams" ] = ::do_botmeleeparams;
	level.bot_builtins[ "botangles" ] = ::do_botangles;
	level.bot_builtins[ "isbot" ] = ::do_isbot;
	level.bot_builtins[ "generatepath" ] = ::do_generatepath;
	level.bot_builtins[ "getfunction" ] = ::do_getfunction;
	level.bot_builtins[ "setallowedtraversals" ] = ::do_setallowedtraversals;
	level.bot_builtins[ "setignoredlinks" ] = ::do_setignoredlinks;
	level.bot_builtins[ "getnodenumber" ] = ::do_getnodenumber;
	level.bot_builtins[ "getlinkednodes" ] = ::do_getlinkednodes;
	level.bot_builtins[ "addtestclient" ] = ::do_addtestclient;
	level.bot_builtins[ "notifyonplayercommand" ] = ::do_notifyonplayercommand;
	level.bot_builtins[ "cmdexec" ] = ::do_cmdexec;
	level.bot_builtins[ "ishost" ] = ::do_ishost;
}

do_printconsole( s )
{
	println( s );
}

do_botbuttonoverride( action )
{
	self botbuttonoverride( action );
}

do_botmovementoverride( left, forward )
{
	self botmovementoverride( left, forward );
}

do_botmeleeparams( yaw, dist )
{
	//nop for now
	//self botmeleeparams( yaw, dist );
}

do_botangles( angles )
{
	self setplayerangles( angles );
	// self botangles( angles[ 0 ], angles[ 1 ], angles[ 2 ] );
}

do_isbot()
{
	return self istestclient();
}

do_generatepath( from, to, team, ignore_ent, best_effort )
{
	return generatepath( from, to, team, ignore_ent, best_effort );
}

do_getfunction( file, threadname )
{
	return getfunction( file, threadname );
}

do_setallowedtraversals( a )
{
	setallowedtraversals( a );
}

do_setignoredlinks( a )
{
	setignoredlinks( a );
}

do_getnodenumber()
{
	return self getnodenumber();
}

do_getlinkednodes()
{
	return self getlinkednodes();
}

do_addtestclient()
{
	return addtestclient();
}

do_notifyonplayercommand( a, b )
{
	self notifyonplayercommand( a, b );
}

do_cmdexec( a )
{
	cmdexec( a );
}

do_ishost()
{
	return self ishost();
}
