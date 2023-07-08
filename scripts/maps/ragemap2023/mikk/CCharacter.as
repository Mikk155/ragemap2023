final class CCharacter
{
    void CharacterDie( CBasePlayer@ pPlayer )
    {
        pPlayer.pev.rendermode = kRenderTransTexture;
        pPlayer.pev.renderamt = 0;
        pPlayer.pev.renderfx = kRenderFxNone;
        pPlayer.pev.rendercolor = Vector( 0, 0, 0 );
        pPlayer.pev.flags |= FL_FROZEN;

        Vector v = pPlayer.pev.origin;

        NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            m.WriteByte( TE_STREAK_SPLASH );
            m.WriteCoord( v.x );
            m.WriteCoord( v.y );
            m.WriteCoord( v.z );
            m.WriteCoord( 0 );
            m.WriteCoord( 0 );
            m.WriteCoord( 180 );
            m.WriteByte( 0 );
            m.WriteShort( 120 );
            m.WriteShort( 2 );
            m.WriteShort( 300 );
        m.End();

        NetworkMessage m2( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
            m2.WriteByte( TE_FIREFIELD );
            m2.WriteCoord( v.x );
            m2.WriteCoord( v.y );
            m2.WriteCoord( v.z );
            m2.WriteShort( 4 );
            m2.WriteShort( g_EngineFuncs.ModelIndex( 'sprites/bubble.spr' ) );
            m2.WriteByte( 128 );
            m2.WriteByte( 30 );
            m2.WriteByte( 5 );
        m2.End();

        g_Scheduler.SetTimeout( @this, "DelayedRespawnCharacters", 2.0f, @pPlayer );
    }

    void DelayedRespawnCharacters( CBasePlayer @pPlayer )
    {
        if( pPlayer.pev.targetname == 'watergirl' )
        {
            pPlayer.pev.rendercolor = Vector( 100, 100, 255 );
            g_EntityFuncs.SetOrigin( pPlayer, mikk_util.atov( mikk_util.CKV( pPlayer, '$v_mikk_oldorigin_watergirl' ) ) );
            mikk_util.CKV( pPlayer, '$v_mikk_origin_fireboy', mikk_util.CKV( pPlayer, '$v_mikk_oldorigin_fireboy' ) );
        }
        else if( pPlayer.pev.targetname == 'fireboy' )
        {
            pPlayer.pev.rendercolor = Vector( 255, 0, 0 );
            g_EntityFuncs.SetOrigin( pPlayer, mikk_util.atov( mikk_util.CKV( pPlayer, '$v_mikk_oldorigin_fireboy' ) ) );
            mikk_util.CKV( pPlayer, '$v_mikk_origin_watergirl', mikk_util.CKV( pPlayer, '$v_mikk_oldorigin_watergirl' ) );
        }
        pPlayer.pev.renderfx = kRenderFxGlowShell;
        pPlayer.pev.rendermode = kRenderNormal;
        pPlayer.pev.flags *= FL_FROZEN;
    }

    string VecSpawnFire;
    string VecSpawnWater;

    bool IsPlaying( CBasePlayer@ pPlayer )
    {
        if( pPlayer.pev.targetname != 'fireboy' && pPlayer.pev.targetname != 'watergirl' )
        {
            mikk_Message.PrintBind( pPlayer, 'Press +attack to start.' );

            if( pPlayer.pev.button & IN_ATTACK != 0 )
            {
                mikk_util.CKV( pPlayer, '$v_mikk_oldorigin_fireboy', VecSpawnFire );
                mikk_util.CKV( pPlayer, '$v_mikk_origin_fireboy', VecSpawnFire );
                mikk_util.CKV( pPlayer, '$v_mikk_oldorigin_watergirl', VecSpawnWater );
                mikk_util.CKV( pPlayer, '$v_mikk_origin_watergirl', VecSpawnWater );
                g_EntityFuncs.SetOrigin( pPlayer, mikk_util.atov( VecSpawnFire ) );

                // ClientExe( pPlayer, 'cam_idealyaw 90' );
                pPlayer.pev.angles = Vector( 0, 0, 0 );
                pPlayer.pev.renderfx = kRenderFxGlowShell;
                pPlayer.pev.rendercolor = Vector( 255, 0, 0 );
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), 'targetname', 'fireboy' );
            }
            return false;
        }
        return true;
    }

    void SwapCharacter( CBasePlayer@ pPlayer )
    {
        if( pPlayer.pev.button & IN_USE != 0 && pPlayer.pev.FlagBitSet( FL_ONGROUND ) && atoi( mikk_util.CKV( pPlayer, '$i_mikk_chardelay' ) ) == 0 )
        {
            mikk_util.CKV( pPlayer, "$i_mikk_chardelay", '1' );
            if( pPlayer.pev.targetname == 'watergirl' )
            {
                pPlayer.pev.rendercolor = Vector( 255, 0, 0 );
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), 'targetname', 'fireboy' );
                g_EntityFuncs.SetOrigin( pPlayer, mikk_util.atov( mikk_util.CKV( pPlayer, '$v_mikk_origin_fireboy' ) ) );
            }
            else if( pPlayer.pev.targetname == 'fireboy' )
            {
                pPlayer.pev.rendercolor = Vector( 100, 100, 255 );
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), 'targetname', 'watergirl' );
                g_EntityFuncs.SetOrigin( pPlayer, mikk_util.atov( mikk_util.CKV( pPlayer, '$v_mikk_origin_watergirl' ) ) );
            }
            g_Scheduler.SetTimeout( "CharacterDelay", 0.6f, @pPlayer );
        }
    }

    void PointOfView( CBasePlayer@ pPlayer )
    {
        CBaseEntity@ pCamera = g_EntityFuncs.FindEntityByTargetname( null, mikk_util.SteamID( pPlayer ) );

        if( pCamera !is null )
        {
            pCamera.pev.origin = pPlayer.pev.origin + Vector( 0, -180, +30 );
            pCamera.Use( pPlayer, null, USE_ON, 0.0f );

            if( pPlayer.IsAlive() )
            {
                mikk_util.CKV( pPlayer, '$v_mikk_origin_' + pPlayer.pev.targetname, pPlayer.pev.origin.ToString() );
            }
        }
        else
        {
            dictionary g_kz;
            g_kz[ 'angles' ] = '0 90 0';
            g_kz['spawnflags'] = '512';
            g_kz['max_player_count'] = '1';
            g_kz['targetname'] = mikk_util.SteamID( pPlayer ) ;
            g_EntityFuncs.CreateEntity( "trigger_camera", g_kz );
        }
    }

    void PerspectiveChanger( CBasePlayer@ pPlayer )
    {
        int iMode = atoi( mikk_util.CKV( pPlayer, '$i_mikk_perspective' ) );

        if( pPlayer.pev.button & IN_SCORE != 0  )
        {
            if( iMode == 0 ) { mikk_util.CKV( pPlayer, '$i_mikk_perspective', 1 ); } else { mikk_util.CKV( pPlayer, '$i_mikk_perspective', 0 ); }
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, 'Perspective mode [' + ( atoi( mikk_util.CKV( pPlayer, '$i_mikk_perspective' ) ) == 1 ? '1] move to the left and to the right.' : '2] move forward and backwards, change view point with left and right.' ) + '\n' );
        }

        pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;

        if( iMode == 0 )
        {
            if( pPlayer.pev.button & IN_MOVELEFT != 0  )
            {
                pPlayer.pev.angles = Vector( 0, 180, 0 );
            }

            if( pPlayer.pev.button & IN_MOVERIGHT != 0  )
            {
                pPlayer.pev.angles = Vector( 0, 0, 0 );
            }
        }
        else
        {
            pPlayer.pev.angles = Vector( 0, 90, 0 );
        }
    }

    void SetOrigin( CBasePlayer@ pPlayer )
    {
        if( pPlayer.IsAlive() )
        {
            mikk_util.CKV( pPlayer, '$v_mikk_origin_' + pPlayer.pev.targetname, pPlayer.pev.origin.ToString() );
        }
    }

    void DelRev( CBasePlayer@ pPlayer )
    {
        pPlayer.Revive();
        mikk_Character.CharacterDie( pPlayer );
    }
}