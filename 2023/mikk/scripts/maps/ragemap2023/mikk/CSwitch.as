mixin class CSwitch
{
    private dictionary dict_switch;
    private CBaseEntity@ m_pDoor = null;
    private bool m_IsMoving = false;

    void Spawn()
    {
        dict_switch[ 'wait' ] = '-1';
        dict_switch[ 'angles' ] = '90 0 0';
        dict_switch[ 'lip' ] = '-1';
        dict_switch[ 'origin' ] = self.pev.origin.ToString();
        dict_switch[ 'targetname' ] = string( self.entindex() );
        
        g_EntityFuncs.SetOrigin( self, self.pev.origin );

        self.pev.movetype = MOVETYPE_NONE;

        self.pev.solid = SOLID_TRIGGER;
        g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, -32 ), Vector( 32, 32, 32 ) );
        SetTouch( TouchFunction( this.Touch ) );

        BaseClass.Spawn();
    }

    void PostSpawn()
    {
        CBaseEntity@ ent_switch = mikk_util.FindPropModel( 'switch' );
        CBaseEntity@ ent_base = mikk_util.FindPropModel( 'swbase' );

        if( ent_switch !is null && ent_base !is null )
        {
            string model_switch = ent_switch.pev.model;
            string model_Base = ent_base.pev.model;

            dict_switch[ 'model' ] = model_switch;
            dict_switch[ 'spawnflags' ] = '170';
            dict_switch[ 'distance' ] = '80';
            dict_switch[ 'wait' ] = '-1';
            dict_switch[ 'fireonclosed' ] = string( self.pev.netname );
            dict_switch[ 'fireonopened' ] = string( self.pev.message );
            dict_switch[ 'fireonopened_triggerstate' ] = string( atoi( self.pev.health ) );
            dict_switch[ 'fireonclosed_triggerstate' ] = string( atoi( self.pev.max_health ) );
            dict_switch[ 'targetname' ] = string(  self.entindex() ) + '_door';
            self.pev.targetname = self.entindex();
  
            @m_pDoor = g_EntityFuncs.CreateEntity( "func_door_rotating", dict_switch, true );

            if( self.pev.SpawnFlagBitSet( 1 ) )
            {
                m_pDoor.Use( self, self, USE_ON, 0.0f );
            }

            dictionary dict_base;
            dict_base[ 'origin' ] = self.pev.origin.ToString();
            dict_base[ 'model' ] = model_Base;
            g_EntityFuncs.CreateEntity( "func_wall", dict_base, true );
       }
        BaseClass.PostSpawn();
    }

    void Touch( CBaseEntity@ pOther )
    {
        if( pOther !is null && pOther.IsPlayer() && pOther.IsAlive() )
        {
            mikk_Message.PrintBind( pPlayer, 'Press +use to interact.' );
            if( !m_IsMoving && pOther.pev.button & IN_USE != 0  )
            {
                m_pDoor.Use( null, null, USE_TOGGLE, 0.0f );
                m_IsMoving = true;
                
                g_Scheduler.SetTimeout( @this, "DelCooldown", 2.0f );
            }
        }
    }

    void DelCooldown()
    {
        m_IsMoving = !m_IsMoving;
    }
}