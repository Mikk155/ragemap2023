mixin class CRadius
{
    void Spawn()
    {
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        SetThink( ThinkFunction( this.Think ) );
        self.pev.nextthink = g_Engine.time + 0.1f;
    }

    bool FireBy( CBasePlayer@ pPlayer )
    {
        if( int( self.pev.health ) == 0 || int( self.pev.health ) == 1 && pPlayer.pev.targetname == 'watergirl' || int( self.pev.health ) == 2 && pPlayer.pev.targetname == 'fireboy' )
        {
            return true;
        }
        return false;
    }

    void Think()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && ( self.pev.origin - pPlayer.pev.origin ).Length() <= ( self.pev.netname != '' ? atoi( self.pev.netname ) : 512 ) && FireBy( pPlayer ) )
            {
                if( self.pev.message != '' )
                {
                    mikk_Message.PrintBind( pPlayer, string( self.pev.message ) );
                }

                if( self.pev.target != '' )
                {
                    g_EntityFuncs.FireTargets( self.pev.target, pPlayer, self, USE_TOGGLE, 0.0f );
                }
            }
        }
        self.pev.nextthink = g_Engine.time + ( self.pev.frags > 0 ? self.pev.frags : 0.1f );
    }
}