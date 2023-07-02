namespace mikk
{
    void MapInit()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'mikk_triggerradius', 'mikk_triggerradius' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'mikk::mikk_doors', 'mikk_doors' );
        GetCorner();
    }

    void Hooks( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fdelay )
    {
        if( UseType == USE_ON )
        {
            g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
            g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @ClientThink );
        }
        else if( UseType == USE_OFF )
        {
            g_Hooks.RemoveHook( Hooks::Player::PlayerKilled, @PlayerKilled );
            g_Hooks.RemoveHook( Hooks::Player::PlayerPreThink, @ClientThink );
        }
    }

    void ShowScore( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fdelay )
    {
        g_Hooks.RemoveHook( Hooks::Player::PlayerKilled, @PlayerKilled );
        g_Hooks.RemoveHook( Hooks::Player::PlayerPreThink, @ClientThink );
    }

    void SpawnStart( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fdelay )
    {
        if( pActivator !is null && pActivator.IsPlayer() )
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

            if( pPlayer !is null )
            {
                CBaseEntity@ pFireBoy = g_EntityFuncs.FindEntityByTargetname( null, 'mikk_fireboy_start' );
                CBaseEntity@ pWaterGirl = g_EntityFuncs.FindEntityByTargetname( null, 'mikk_watergirl_start' );

                if( pWaterGirl !is null && pFireBoy !is null )
                {
                    g_Utils.CKV( pPlayer, '$v_mikk_oldorigin_fireboy', pFireBoy.pev.origin.ToString() );
                    g_Utils.CKV( pPlayer, '$v_mikk_origin_fireboy', pFireBoy.pev.origin.ToString() );
                    g_Utils.CKV( pPlayer, '$v_mikk_oldorigin_watergirl', pWaterGirl.pev.origin.ToString() );
                    g_Utils.CKV( pPlayer, '$v_mikk_origin_watergirl', pWaterGirl.pev.origin.ToString() );
                }
            }
        }
    }

    HookReturnCode ClientThink( CBasePlayer@ pPlayer, uint& out uiFlags )
    {
        if( pPlayer !is null && g_Character.IsPlaying( pPlayer ) )
        {
            g_Message.Timer( pPlayer );

            g_Character.CheckCorner( pPlayer );
            g_Character.SwapCharacter( pPlayer );
            g_Character.PointOfView( pPlayer );
            g_Character.PerspectiveChanger( pPlayer );
            g_Character.SetOrigin( pPlayer );
        }
        return HOOK_CONTINUE;
    }

    CCharacter g_Character;

    final class CCharacter
    {
        void CheckCorner( CBasePlayer@ pPlayer )
        {
            if( pPlayer.pev.origin.y <= Corner )
            {
                pPlayer.pev.velocity.y = 10000;
            }
        }

        bool IsPlaying( CBasePlayer@ pPlayer )
        {
            if( pPlayer.pev.targetname != 'fireboy' && pPlayer.pev.targetname != 'watergirl' )
            {
                g_Message.PrintBind( pPlayer, 'Press +attack to start.' );

                g_EntityFuncs.SetOrigin( pPlayer, g_Utils.atov( g_Utils.CKV( pPlayer, '$v_mikk_origin_fireboy' ) ) );

                if( pPlayer.pev.button & IN_ATTACK != 0 )
                {
                    g_EntityFuncs.SetOrigin( pPlayer, g_Utils.atov( g_Utils.CKV( pPlayer, '$v_mikk_origin_fireboy' ) ) );
                    ClientExe( pPlayer, 'cam_idealyaw 90' );
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
            if( pPlayer.pev.button & IN_USE != 0 && pPlayer.pev.FlagBitSet( FL_ONGROUND ) && atoi( g_Utils.CKV( pPlayer, '$i_mikk_chardelay' ) ) == 0 )
            {
                g_Utils.CKV( pPlayer, "$i_mikk_chardelay", '1' );
                if( pPlayer.pev.targetname == 'watergirl' )
                {
                    pPlayer.pev.rendercolor = Vector( 255, 0, 0 );
                    g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), 'targetname', 'fireboy' );
                    g_EntityFuncs.SetOrigin( pPlayer, g_Utils.atov( g_Utils.CKV( pPlayer, '$v_mikk_origin_fireboy' ) ) );
                }
                else if( pPlayer.pev.targetname == 'fireboy' )
                {
                    pPlayer.pev.rendercolor = Vector( 100, 100, 255 );
                    g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), 'targetname', 'watergirl' );
                    g_EntityFuncs.SetOrigin( pPlayer, g_Utils.atov( g_Utils.CKV( pPlayer, '$v_mikk_origin_watergirl' ) ) );
                }
                g_Scheduler.SetTimeout( "CharacterDelay", 0.6f, @pPlayer );
            }
        }

        void PointOfView( CBasePlayer@ pPlayer )
        {
            // New POV based in client's commands
            if( pPlayer.pev.button & IN_MOVELEFT != 0  )
            {
                ClientExe( pPlayer, 'cam_idealyaw 270' );
            }
            if( pPlayer.pev.button & IN_MOVERIGHT != 0  )
            {
                ClientExe( pPlayer, 'cam_idealyaw 90' );
            }
            ClientExe( pPlayer, 'thirdperson' );
            ClientExe( pPlayer, 'cam_idealdist 256' );

            // Old POV based on a trigger_camera
            /*
            CBaseEntity@ pCamera = g_EntityFuncs.FindEntityByTargetname( null, g_Utils.SteamID( pPlayer ) );

            if( pCamera !is null )
            {
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
            */
        }

        void PerspectiveChanger( CBasePlayer@ pPlayer )
        {
            pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;

            if( pPlayer.pev.button & IN_MOVELEFT != 0  )
            {
                pPlayer.pev.angles = Vector( 0, 180, 0 );
            }

            if( pPlayer.pev.button & IN_MOVERIGHT != 0  )
            {
                pPlayer.pev.angles = Vector( 0, 0, 0 );
            }
        }

        void SetOrigin( CBasePlayer@ pPlayer )
        {
            if( pPlayer.IsAlive() )
            {
                g_Utils.CKV( pPlayer, '$v_mikk_origin_' + pPlayer.pev.targetname, pPlayer.pev.origin.ToString() );
            }
        }
    }

    void CharacterDelay( CBasePlayer@ pPlayer )
    {
        g_Utils.CKV( pPlayer, "$i_mikk_chardelay", '0' );
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

        g_Scheduler.SetTimeout( "DelayedRespawnCharacters", 2.0f, @pPlayer );
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

    void ClientExe( CBasePlayer@ pPlayer, string_t iszCommand )
    {
        NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
            msg.WriteString( ';' + iszCommand + ';' );
        msg.End();
    }

    HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
    {
        if( pPlayer !is null )
        {
            g_Scheduler.SetTimeout( "DelRev", 0.0f, @pPlayer );
        }
        return HOOK_CONTINUE;
    }

    void DelRev( CBasePlayer@ pPlayer )
    {
        pPlayer.Revive();
        CharacterDie( pPlayer );
    }

    void TimeInit( CBaseEntity@ trigger_script )
    {
        int minuto = atoi( trigger_script.pev.message );
        int segundo = ( trigger_script.pev.iuser2 <= 0 ) ? 59 : trigger_script.pev.iuser2;

        CBaseEntity@ text = g_EntityFuncs.FindEntityByTargetname( null, trigger_script.pev.target );

        if( text !is null )
        {
            text.pev.message = 'Time Left: \'' + string( minuto ) + ':' + ( segundo > 9 ? string( segundo ) : '0' + string( segundo ) ) + '\'\n';
            text.Use( trigger_script, trigger_script, USE_ON, 0.0f );
        }

        if( minuto < 1 && segundo < 1 )
        {
            g_EntityFuncs.FireTargets( string( trigger_script.pev.netname ), null, null, USE_ON, 0.0f );
            trigger_script.Use( null, null, USE_OFF, 0.0f );
            return;
        }
        else if( segundo == 0 )
        {
            trigger_script.pev.message = string( minuto + 1 );
            trigger_script.pev.iuser2 = 59;
        }
        else
        {
            trigger_script.pev.iuser2 = segundo - 1;
        }
    }/*



    namespace FLUIDS
    {
            //g_Game.AlertMessage( at_console, '"' + string( pPlayer.pev.waterlevel ) + '"\n' );

        class CFluids : ScriptBaseEntity
        {
            void Spawn()
            {
                //self.pev.effects |= EF_NODRAW;
                self.pev.movetype = MOVETYPE_NONE;
                self.pev.solid = SOLID_TRIGGER;

                g_EntityFuncs.SetOrigin( self, self.pev.origin );
                g_EntityFuncs.SetModel( self, string( self.pev.model ) );
                g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
			    SetTouch( TouchFunction( this.Touch ) );

                dictionary g_Water;
                g_Water['origin'] = self.pev.origin.ToString();
                g_Water['WaveHeight'] ='3.0';
                g_Water['model'] =string( self.pev.model );
                g_EntityFuncs.CreateEntity( "func_water", g_Water, true );
            }
            void Touch( CBaseEntity@ pOther )
            {
                        g_Game.AlertMessage( at_console, 'si sexo fluido ekisde' );
                if( pOther !is null && pOther.IsPlayer() && pOther.IsAlive() )
                {
                    if( self.pev.classname == 'watergirl_fluid' && pOther.pev.targetname != 'watergirl'
                    or  self.pev.classname == 'fireboy_fluid' && pOther.pev.targetname != 'fireboy'
                    or  self.pev.classname == 'acid_fluid'  )
                    {
                    }
                }
            }
        }
    }*/

    class mikk_doors : ScriptBaseEntity
    {
        void Spawn()
        {
            self.pev.movetype = MOVETYPE_NONE;
            self.pev.solid = SOLID_TRIGGER;

            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            g_EntityFuncs.SetModel( self, string( self.pev.model ) );
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );

            SetTouch( TouchFunction( this.Touch ) );
        }

        void Touch( CBaseEntity@ pOther )
        {
            if( pOther !is null && pOther.IsPlayer() && pOther.IsAlive() )
            {
                if( atoi( self.pev.message ) == ( pOther.pev.targetname == 'watergirl' ? 0 : 1 ) )
                {
                    g_Utils.CKV( pOther, "$v_mikk_oldorigin_" + pOther.pev.targetname, self.pev.origin.ToString() );

                    if( self.pev.target != '' )
                    {
                        CBaseEntity@ pTarget = g_EntityFuncs.FindEntityByTargetname( null, self.pev.target );

                        if( pTarget !is null )
                        {
                            g_EntityFuncs.SetOrigin( pOther, pTarget.pev.origin );
                        }
                    }
                }
            }
        }
    }

    CMessager g_Message;
    final class CMessager
    {
        void PrintBind( CBasePlayer@ pPlayer, string iszmsg )
        {
            g_PlayerFuncs.PrintKeyBindingString( pPlayer, iszmsg + "\n"  );
        }

        void Timer( CBasePlayer@ pPlayer )
        {
            HUDSpriteParams params;
            params.y = 0.05;
            params.x = 0.45;
            params.holdTime = 1.0;
            params.fadeinTime = 0.0;
            params.color1 = RGBA( 255, 255, 255, 255 );
            params.spritename = 'ragemap2023/mikk/timer.spr';
            g_PlayerFuncs.HudCustomSprite( pPlayer, params );
        }
    }

    class mikk_triggerradius : ScriptBaseEntity
    {
        void Spawn()
        {
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.1f;
        }

        void Think()
        {
            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null && ( self.pev.origin - pPlayer.pev.origin ).Length() <= ( self.pev.netname != '' ? atoi( self.pev.netname ) : 512 ) )
                {
                    if( self.pev.message != '' ) g_Message.PrintBind( pPlayer, string( self.pev.message ) );
                    if( self.pev.target != '' ) g_EntityFuncs.FireTargets( self.pev.target, pPlayer, self, USE_TOGGLE, 0.0f );
                }
            }
            self.pev.nextthink = g_Engine.time + ( self.pev.frags > 0 ? self.pev.frags : 0.1f );
        }
    }

    float Corner;

    void GetCorner()
    {
        CBaseEntity@ pCorner = g_EntityFuncs.FindEntityByTargetname( null, 'mikk_corner_barrier' );
        if( pCorner !is null ) { Corner = pCorner.pev.origin.y; }
        else { g_Scheduler.SetTimeout( 'GetCorner', 0.5f ); }
    }

    CUtils g_Utils;
    final class CUtils
    {
        string CKV( CBaseEntity@ pPlayer, string szKey, string iszValue = String::INVALID_INDEX )
        {
            string sget = String::INVALID_INDEX;

            if( iszValue != String::INVALID_INDEX )
            {
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), szKey, iszValue );
                //g_Game.AlertMessage( at_console, 'Set key "' + szKey + '" to "' + iszValue + '"' + '\n' );
            }
            else
            {
                sget = pPlayer.GetCustomKeyvalues().GetKeyvalue( szKey ).GetString();
                //g_Game.AlertMessage( at_console, 'Get key "' + szKey + '" at "' + sget + '"' + '\n' );
            }
            return sget;
        }

        Vector atov( string VectIn )
        {
            Vector VectOut;
            g_Utility.StringToVector( VectOut, VectIn );
            return VectOut;
        }

        string SteamID( CBaseEntity@ pPlayer )
        {
            return ( pPlayer is null ? '' : g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) );
        }
    }
}