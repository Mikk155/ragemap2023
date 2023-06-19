CCharacters g_Characters;

final class CCharacters
{
    void SwapCharacter( CBasePlayer@ pPlayer ) 
    {
        if( pPlayer.pev.button & IN_USE != 0 && pPlayer.pev.FlagBitSet( FL_ONGROUND ) && atoi( g_Utils.CKV( pPlayer, '$i_mikk_chardelay' ) ) == 0 )
        {
            g_Utils.CKV( pPlayer, "$i_mikk_chardelay", '1' );
            g_Scheduler.SetTimeout( @this, "CharacterDelay", 0.6f, @pPlayer );
            if( pPlayer.pev.targetname == 'watergirl' )
            {
                pPlayer.pev.rendercolor = Vector( 255, 0, 0 );
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), 'targetname', 'fireboy' );
                g_EntityFuncs.SetOrigin( pPlayer, g_Utils.atov( g_Utils.CKV( pPlayer, '$v_mikk_origin_fireboy' ) ) );
            }
            else
            {
                pPlayer.pev.rendercolor = Vector( 100, 100, 255 );
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), 'targetname', 'watergirl' );
                g_EntityFuncs.SetOrigin( pPlayer, g_Utils.atov( g_Utils.CKV( pPlayer, '$v_mikk_origin_watergirl' ) ) );
            }
        }
    }

    void CharacterDelay( CBasePlayer@ pPlayer )
    {
        g_Utils.CKV( pPlayer, "$i_mikk_chardelay", '0' );
    }

    void TrackCamera( CBasePlayer@ pPlayer )
    {
        CBaseEntity@ pCamera = g_EntityFuncs.FindEntityByTargetname( null, g_Utils.SteamID( pPlayer ) );

        if( pCamera !is null )
        {
            pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
            pPlayer.pev.angles = Vector( 0, 90, 0 );
            pCamera.pev.origin = pPlayer.pev.origin + Vector( 0, -180, +30 );
            pCamera.Use( pPlayer, null, USE_ON, 0.0f );
            if( pPlayer.IsAlive() ) g_Utils.CKV( pPlayer, '$v_mikk_origin_' + pPlayer.pev.targetname, pPlayer.pev.origin.ToString() );
        }
        else
        {
            dictionary g_kz;
            g_kz[ 'angles' ] = '0 90 0';
            g_kz['spawnflags'] = '512';
            g_kz['max_player_count'] = '1';
            g_kz['targetname'] = g_Utils.SteamID( pPlayer ) ;
            g_EntityFuncs.CreateEntity( "trigger_camera", g_kz );
        }
    }

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
            g_EntityFuncs.SetOrigin( pPlayer, g_Utils.atov( g_Utils.CKV( pPlayer, '$v_mikk_oldorigin_watergirl' ) ) );
            g_Utils.CKV( pPlayer, '$v_mikk_origin_fireboy', g_Utils.CKV( pPlayer, '$v_mikk_oldorigin_fireboy' ) );
        }
        else if( pPlayer.pev.targetname == 'fireboy' )
        {
            pPlayer.pev.rendercolor = Vector( 255, 0, 0 );
            g_EntityFuncs.SetOrigin( pPlayer, g_Utils.atov( g_Utils.CKV( pPlayer, '$v_mikk_oldorigin_fireboy' ) ) );
            g_Utils.CKV( pPlayer, '$v_mikk_origin_watergirl', g_Utils.CKV( pPlayer, '$v_mikk_oldorigin_watergirl' ) );
        }
        pPlayer.pev.renderfx = kRenderFxGlowShell;
        pPlayer.pev.rendermode = kRenderNormal;
        pPlayer.pev.flags *= FL_FROZEN;
    }
}