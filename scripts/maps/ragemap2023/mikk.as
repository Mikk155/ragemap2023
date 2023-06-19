#include 'Messager'
#include 'Characters'
#include 'Doors'
#include 'utils'
#include 'inputs'
#include 'trigger_multiple'

namespace mikk
{
    void MapInit()
    {
        g_Game.PrecacheModel( 'sprites/bubble.spr' );

        g_Game.PrecacheGeneric( 'sprites/bubble.spr' );

        g_Game.PrecacheModel( 'sprites/ragemap2023/mikk/timer.spr' );
        g_Game.PrecacheGeneric( 'sprites/ragemap2023/mikk/timer.spr' );

        g_CustomEntityFuncs.RegisterCustomEntity( 'mikk_triggerradius', 'mikk_triggerradius' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'mikk_doors', 'mikk_doors' );
    }

    void MyPartStarts( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fdelay )
    {
        g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
        g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @ClientThink );
    }

    void MyPartEnds( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fdelay )
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
                g_Utils.CKV( pPlayer, '$v_mikk_oldorigin_fireboy', pPlayer.pev.origin.ToString() );
                g_Utils.CKV( pPlayer, '$v_mikk_oldorigin_watergirl', pPlayer.pev.origin.ToString() );
                g_Utils.CKV( pPlayer, '$v_mikk_origin_fireboy', pPlayer.pev.origin.ToString() );
                g_Utils.CKV( pPlayer, '$v_mikk_origin_watergirl', pPlayer.pev.origin.ToString() );
                pPlayer.pev.renderfx = kRenderFxGlowShell;
                pPlayer.pev.rendercolor = Vector( 255, 0, 0 );
            }
        }
    }

    HookReturnCode ClientThink( CBasePlayer@ pPlayer, uint& out uiFlags )
    {
        if( pPlayer !is null )
        {
            g_Imputs.Jump( pPlayer );
            g_Imputs.DontExploitSpeed( pPlayer );

            g_Message.ShowTimer( pPlayer );

            g_Characters.TrackCamera( pPlayer );
            g_Characters.SwapCharacter( pPlayer );
        }
        return HOOK_CONTINUE;
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
        g_Characters.CharacterDie( pPlayer );
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
}