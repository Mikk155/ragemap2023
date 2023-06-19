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