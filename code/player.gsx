init()
{		
	thread code\events::addConnectEvent( ::onConnect );
	thread code\events::addSpawnEvent( ::onSpawn );
}

onSpawn()
{
	self endon( "disconnect" );
	
	waittillframeend;
	
	if( isDefined( level.nukeInProgress ) && level.tacticalNuke.owner.team != self.team )
		self thread nukePlayerLogic();
}

nukePlayerLogic()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "endRadationZone" );
	
	self.pers[ "rads" ] = 0;
	
	while( 1 )
	{ 
		while( isDefined( self.spawnprotected ) )
			wait .25;
		
		if( self.pers[ "rads" ] == 11 )
		{
			self iprintlnbold( "RADIATION LEVELS CRITICAL!" );
			
			self.sWeaponForKillcam = "nuke_rad";
			
			self thread [[level.callbackPlayerDamage]](
														level.tacticalNuke,
														level.tacticalNuke.owner, 
														100,
														0,
														"MOD_PROJECTILE_SPLASH", 
														"artillery_mp", 
														level.tacticalNuke.origin,
														vectornormalize( level.tacticalNuke.origin - self.origin ),
														"none",
														0 
														);
		}
			
		else if( self.pers[ "rads" ] == 7 )
		{
			self iprintlnbold( "RADIATION LEVELS APPROACHING CRITICAL!" );
			self shellshock( "radiation_high", 8 );
		}
			
		else if( self.pers[ "rads" ] == 4 )
		{
			self iprintlnbold( "RADIATION EXPOSURE WARNING!" );
			self shellshock( "radiation_med", 8 );
		}
			
		else if( self.pers[ "rads" ] == 1 )
			self iprintlnbold( "RADIATION WARNING!" );
		
		wait .5;
	}
}

onConnect()
{
	self endon( "disconnect" );	
	
	if( !isDefined( self.pers[ "fullbright" ] ) )
	{
		self.pers[ "fullbright" ] = self getStat( 3160 );
		self.pers[ "fov" ] = self getStat( 3161 );
		self.pers[ "promodTweaks" ] = self getStat( 3162 );
	}
	
	if( !isDefined( self.pers[ "meleekills" ] ) )
		self.pers[ "meleekills" ] = 0;
	
	if( !isArray( self.pers[ "youVSfoe" ] ) )
	{
		self.pers[ "youVSfoe" ] = [];
		self.pers[ "youVSfoe" ][ "killedBy" ] = [];
		self.pers[ "youVSfoe" ][ "killed" ] = [];
	}
	
	self.pers[ "rads" ] = 0;
	
	/////////////////////////////////////////////////
	// Things we need to do on spawn but only once //
	/////////////////////////////////////////////////
	self waittill( "spawned_player" );
	
	if( !isDefined( self.pers[ "welcomed" ] ) )
		self thread welcome();
	
	self thread userSettings();
	
	waittillframeend;
	
	if( level.dvar[ "gun_position" ] )
		self setClientDvars( "cg_gun_move_u", "1.5",
							 "cg_gun_move_f", "-1",
							 "cg_gun_ofs_u", "1",
							 "cg_gun_ofs_r", "-1",
							 "cg_gun_ofs_f", "-2" );
						 
	if( level.dvar[ "promod_sniper" ] )
		self setClientDvars( "player_breath_gasp_lerp", "0",
						 	 "player_breath_gasp_time", "0",
							 "player_breath_gasp_scale", "0", 
							 "cg_drawBreathHint", "0" );
}

userSettings()
{
	self endon( "disconnect" );
	
	if( abs( self.pers[ "fov" ] > 2 ) )
	{
		self.pers[ "fov" ] = 0;
		self setstat( 3161, 0 );
		self setClientDvar( "cg_fovscale", 1.0 );
		self setClientDvar( "cg_fov", 80 );
		self iprintlnbold( "Error: illegal fov value, setting 3161 to 0" );
	}
	
	switch( self.pers[ "fov" ] )
	{
		case 0:
			self setClientDvar( "cg_fovscale", 1.0 );
			self setClientDvar( "cg_fov", 80 );
			break;
		case 1:
			self setClientDvar( "cg_fovscale", 1.125 );
			self setClientDvar( "cg_fov", 80 );
			break;
		case 2:
			self setClientDvar( "cg_fovscale", 1.25 );
			self setClientDvar( "cg_fov", 80 );
			break;
		default:
			self.pers[ "fov" ] = 0;
			self setstat( 3161, 0 );
			self setClientDvar( "cg_fovscale", 1.0 );
			self setClientDvar( "cg_fov", 80 );
			self iprintlnbold( "Error: illegal fov value, setting 3161 to 0" );
			break;
	}
	
	if( self.pers[ "fullbright" ] != 1 && self.pers[ "fullbright" ] != 0 )
	{
		self setstat( 3160, 0 );
		self.pers[ "fullbright" ] = 0;
		self iprintlnbold( "Error: illegal fullbright value, setting 3160 to 0" );
	}
	
	if( self.pers[ "fullbright" ] == 1 )
		self setClientDvar( "r_fullbright", 1 );
		
	if( self.pers[ "promodTweaks" ] != 1 && self.pers[ "promodTweaks" ] != 0 )
	{
		self setstat( 3162, 0 );
		self.pers[ "promodTweaks" ] = 0;
		self iprintlnbold( "Error: illegal promod value, setting 3162 to 0" );
	}
	
	if( self.pers[ "promodTweaks" ] == 1 )
		self SetClientDvars( "r_filmTweakInvert", "0",
                     	     "r_filmTweakBrightness", "0",
                     	     "r_filmusetweaks", "1",
                     	     "r_filmTweakenable", "1",
                      	     "r_filmtweakLighttint", "0.8 0.8 1",
                       	     "r_filmTweakContrast", "1.2",
                       	     "r_filmTweakDesaturation", "0",
                       	     "r_filmTweakDarkTint", "1.8 1.8 2" );
}

welcome()
{
	self endon( "disconnect" );
	
	dvar = "welcome_" + self getEntityNumber();
	
	if( getDvar( dvar ) == self getPlayerID() ) // Player is already welcomed
	{
		self.pers[ "welcomed" ] = true;
		return;
	}
	
	exec( "say Welcome^5 " + self.name + " ^7from ^5" + self getGeoLocation( 2 ) );
	
	setDvar( dvar, self getPlayerID() );
	
	self.pers[ "welcomed" ] = true;
}

isVIP()
{
	self endon( "disconnect" );
	
	vips = [];
	vips[ vips.size ] = "[U:12:345678]";
	
	player = self getPlayerID();
	
	for( i = 0; i < vips.size; i++ )
	{
		if( player == vips[ i ] )
			return true;
	}
	
	return false;
}