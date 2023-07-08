#include "mikk/CFluids"
class trigger_fluid : ScriptBaseEntity, CFluids {}

#include "mikk/CDoors"
class trigger_door_fire : ScriptBaseEntity, CDoors {}
class trigger_door_water : ScriptBaseEntity, CDoors {}

#include "mikk/CRadius"
class trigger_radius : ScriptBaseEntity, CRadius {}

#include "mikk/CUtils"
CUtils mikk_util;

#include "mikk/CCharacter"
CCharacter mikk_Character;

#include "mikk/CMessager"
CMessager mikk_Message;

#include "mikk/GMap"
GMap mikk_Map;

/*
Ctrl+f "-TODO"

- Add cooldown to "Swap movement mode"
- first trigger_radius message is wrong
- make CDoors animations and teleport logic once both characters are facing the proper doors.
- Fix trigger_fluid not killing characters
- Add music by code per sections
- create logic for buttons and boxes
- create a entity for rotating chain
. create a entity for steel ball run
- Add secrets
- Attempt to create a final boss
- Create logic for score based on level finished and crystals
- Create an alternative camera mode (static) as i've did with the movement.
- Add skybox
- Merge all in one script
*/


namespace mikk
{
    void MapInit()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'mikk::trigger_fluid', 'trigger_fluid' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'mikk::trigger_radius', 'trigger_radius' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'mikk::trigger_door_fire', 'trigger_door_fire' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'mikk::trigger_door_water', 'trigger_door_water' );
    }

    void Hooks( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fdelay )
    {
        if( UseType == USE_ON )
        {
            g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
            g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @ClientThink );
            mikk_Map.GetCorner();
        }
        else if( UseType == USE_OFF )
        {
            g_Hooks.RemoveHook( Hooks::Player::PlayerKilled, @PlayerKilled );
            g_Hooks.RemoveHook( Hooks::Player::PlayerPreThink, @ClientThink );
            g_CustomEntityFuncs.UnRegisterCustomEntity( 'trigger_fluid' );
            g_CustomEntityFuncs.UnRegisterCustomEntity( 'trigger_radius' );
            g_CustomEntityFuncs.UnRegisterCustomEntity( 'trigger_door_fire' );
            g_CustomEntityFuncs.UnRegisterCustomEntity( 'trigger_door_water' );
        }
    }

    void ShowScore( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float fdelay )
    {
    }

    HookReturnCode ClientThink( CBasePlayer@ pPlayer, uint& out uiFlags )
    {
        if( pPlayer !is null && mikk_Character.IsPlaying( pPlayer ) )
        {
            mikk_Message.Timer( pPlayer );

            mikk_Map.CheckCorner( pPlayer );
            mikk_Character.SwapCharacter( pPlayer );
            mikk_Character.PointOfView( pPlayer );
            mikk_Character.PerspectiveChanger( pPlayer );
            mikk_Character.SetOrigin( pPlayer );
        }
        return HOOK_CONTINUE;
    }


    HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
    {
        if( pPlayer !is null )
        {
            g_Scheduler.SetTimeout( @mikk_Character, "DelRev", 0.0f, @pPlayer );
        }
        return HOOK_CONTINUE;
    }

    string iszTimerMessage;

    void TimeInit( CBaseEntity@ trigger_script )
    {
        int minuto = atoi( trigger_script.pev.message );
        int segundo = ( trigger_script.pev.iuser2 <= 0 ) ? 59 : trigger_script.pev.iuser2;

        CBaseEntity@ text = g_EntityFuncs.FindEntityByTargetname( null, trigger_script.pev.target );

        if( text !is null )
        {
            if( iszTimerMessage == '' )
            {
                iszTimerMessage = text.pev.message;
            }

            string newmsg = iszTimerMessage;
            newmsg.Replace( '!time', string( minuto ) + ':' + ( segundo > 9 ? string( segundo ) : '0' + string( segundo ) ) );

            // text.pev.message = 'Time Left: \'' + string( minuto ) + ':' + ( segundo > 9 ? string( segundo ) : '0' + string( segundo ) ) + '\'\n';
            text.pev.message = newmsg + '\n';
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
    }
}