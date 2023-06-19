CInputs g_Imputs;
final class CInputs
{
    void Jump( CBasePlayer@ pPlayer )
    {
        if( pPlayer.pev.button & IN_FORWARD != 0 && pPlayer.pev.target != 'jump' )
        {
            JumpDelayed( pPlayer, '+' );
            g_Game.AlertMessage( at_console, 'Pressed' +'\n' );
            g_Scheduler.SetTimeout( @this, "JumpDelayed", 0.1f, @pPlayer, '-' );
            pPlayer.pev.target = 'jump';
        }
    }

    void JumpDelayed( CBasePlayer@ pPlayer, string Jump )
    {
        NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
            msg.WriteString( Jump + 'jump' );
        msg.End();
        if( Jump == '-' ) { pPlayer.pev.target = 'notjump'; }
    }

    void DontExploitSpeed( CBasePlayer@ pPlayer )
    {
        if( pPlayer.pev.button & IN_BACK != 0 )
        {
            pPlayer.pev.velocity.x = pPlayer.pev.velocity.x / 2;
        }
    }
}