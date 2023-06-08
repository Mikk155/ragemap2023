namespace mikk
{
    CScheduledFunction@ g_Think = g_Scheduler.SetInterval( "CThink", 0.0f );

    const string GameMode = ( g_PlayerFuncs.GetNumPlayers() < 2 'singleplayer' : 'multiplayer' );

    void CThink()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
            CBaseEntity@ camera = @g_GetCamera( pPlayer );

            if( camera is null || pPlayer is null )
                continue;

            camera.pev.origin = pPlayer.pev.origin + Vector( 0, -150, 0 ); 
            pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
            pPlayer.pev.angles = Vector( 0, -90, 0 );

            camera.Use( pPlayer, pPlayer, ( pPlayer.IsAlive() ? USE_ON : USE_OFF ), 0.0f );

            if( GameMode == 'singleplayer' && pPlayer.pev.button & IN_SCORE != 0 )
            {
                CambiarCharacter( pPlayer );
            }
        }
    }

    void CambiarCharacter( CBasePlayer@ pPlayer )
    {
        Vector vecOut = g_EntityFuncs.FindEntityByTargetname( null, "mikk_waterpoint" ).pev.origin;
        Vector auxVectorOrigin = pPlayer.pev.origin;
        
        if(!pPlayer.GetUserData().exists( "old_player_origin" ) || !pPlayer.GetUserData().exists( "player_delay_teleport" ))
        {
			pPlayer.SetOrigin( vecOut );
			pPlayer.GetUserData( "old_player_origin" ) = auxVectorOrigin.ToString(); 
			pPlayer.GetUserData( "player_delay_teleport" ) = g_Engine.time + 1.5; 
		}

		if(float(pPlayer.GetUserData( "player_delay_teleport" )) <= g_Engine.time)
		{
			g_Utility.StringToVector( vecOut, string(pPlayer.GetUserData( "old_player_origin" )) );
			pPlayer.SetOrigin( vecOut );
			pPlayer.GetUserData( "old_player_origin" ) = auxVectorOrigin.ToString(); 
			pPlayer.GetUserData( "player_delay_teleport" ) = g_Engine.time + 1.5; 
		}
    }

    CBaseEntity@ g_GetCamera( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            string m_iszPlayerID = string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) );

            CBaseEntity@ cam = g_EntityFuncs.FindEntityByTargetname( g_EntityFuncs.Instance( Players ), m_iszPlayerID );

            if( cam is null )
            {
                dictionary g_kz;
                g_kz[ 'angles' ] = '0 90 0';
                g_kz['spawnflags'] = '512';
                g_kz['max_player_count'] = '1';
                g_kz['targetname'] = m_iszPlayerID;
                g_EntityFuncs.CreateEntity( "trigger_camera", g_kz );
                return null;
            }
            return cam;
        }
        return null;
    }

    string CKV( CBaseEntity@ pEntity, string szKey ){ return pEntity.GetCustomKeyvalues().GetKeyvalue( '$s_' + szKey ).GetString(); }
    int CKV( CBaseEntity@ pEntity, string szKey ){ return pEntity.GetCustomKeyvalues().GetKeyvalue( '$i_' + szKey ).GetInteger(); }

    enum firenwater_water_flags
    {
        WATER_ACID = 0,
        WATER_LAVA = 1,
        WATER_WATER = 2
    }
/*
    class firenwater_wate : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private bool IsValid( CBaseEntity@ p ){ return ( p !is null && p.ISAlive() && p.IsPlayer() ) }

        void Touch( CBaseEntity@ pOther )
        {
            if( IsValid ( pOther ) )
            {
                if(self.pev.iuser1 == WATER_LAVA && CKV( pOther, 'element' ) == WATER_LAVA
                or self.pev.iuser1 == WATER_WATER && CKV( pOther, 'element' ) == WATER_WATER )
                {
                    return;
                }
                pOther.TakeDamage( self, self, 100.0f, ( CKV( pOther, 'element' ) == WATER_LAVA ) ? DMG_BURN : ( CKV( pOther, 'element' ) == WATER_WATER ) ? DMG_DROWN : DMG_RADIATION );
            }
        }
    }*/
}