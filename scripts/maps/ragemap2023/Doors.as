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
                    g_Utils.CKV( pOther, "$v_mikk_oldorigin_" + pOther.pev.targetname, self.Center().ToString() );

                    if( self.pev.target != '' )
                    {
                        CBaseEntity@ pTarget = g_EntityFuncs.FindEntityByTargetname( null, self.pev.target );

                        if( pTarget !is null )
                        {
                            g_EntityFuncs.SetOrigin( pOther, pTarget.Center() );
                        }
                    }
                }
            }
        }
    }