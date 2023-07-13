mixin class CDoors
{
    private dictionary dict_door;
    private CBaseEntity@ m_pDoor = null;
    private USE_TYPE m_DoorTypeTrigger = USE_OFF;

    void Spawn()
    {
        dict_door[ 'wait' ] = '-1';
        dict_door[ 'angles' ] = '90 0 0';
        dict_door[ 'lip' ] = '-1';
        dict_door[ 'origin' ] = self.pev.origin.ToString();
        dict_door[ 'targetname' ] = string( self.entindex() );
        
        g_EntityFuncs.SetOrigin( self, self.pev.origin );

        self.pev.movetype = MOVETYPE_NONE;

        if( self.pev.SpawnFlagBitSet( 1 ) )
        {
            string iszVec = self.pev.origin.ToString();

            if( self.pev.classname == 'mikk_door_fire' )
            {
                mikk_Character.VecSpawnFire = iszVec;
            }
            else
            {
                mikk_Character.VecSpawnWater = iszVec;
            }
        }
        else
        {
            self.pev.solid = SOLID_TRIGGER;
            g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, -32 ), Vector( 32, 32, 32 ) );
            SetTouch( TouchFunction( this.Touch ) );
            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.1f;
        }

        BaseClass.Spawn();
    }

    void Think()
    {
        m_pDoor.Use( null, null, m_DoorTypeTrigger, 0.0f );

        m_DoorTypeTrigger = USE_OFF;

        self.pev.nextthink = g_Engine.time + 1.0f;
    }

    void PostSpawn()
    {
        CBaseEntity@ door_water = mikk_util.FindPropModel( 'door_water' );
        CBaseEntity@ door_fire = mikk_util.FindPropModel( 'door_fire' );
        CBaseEntity@ door_frame = mikk_util.FindPropModel( 'door_frame' );

        if( door_water !is null && door_fire !is null && door_frame !is null )
        {
            string model_water = door_water.pev.model;
            string model_fire = door_fire.pev.model;
            string model_frame = door_frame.pev.model;

            if( self.pev.classname == 'mikk_door_fire' )
            {
                dict_door[ 'model' ] = model_fire;
            }
            else
            {
                dict_door[ 'model' ] = model_water;
            }

            @m_pDoor = g_EntityFuncs.CreateEntity( "func_door", dict_door, true );

            dictionary dict_frame;
            dict_frame[ 'origin' ] = self.pev.origin.ToString();
            dict_frame[ 'model' ] = model_frame;
            g_EntityFuncs.CreateEntity( "func_illusionary", dict_frame, true );
        }
        BaseClass.PostSpawn();
    }

    void Touch( CBaseEntity@ pOther )
    {
        if( pOther !is null && pOther.IsPlayer() && pOther.IsAlive() )
        {
            if(self.pev.classname == 'mikk_door_fire' && pOther.pev.targetname == 'fireboy' 
            or self.pev.classname == 'mikk_door_water' && pOther.pev.targetname == 'watergirl' )
            {
                m_DoorTypeTrigger = USE_ON;
                mikk_util.CKV( pOther, "$v_mikk_oldorigin_" + pOther.pev.targetname, self.pev.origin.ToString() );

                if( self.pev.target != '' )
                {
                    CBaseEntity@ pTarget = mikk_util.FindPropModel( self.pev.target );

                    if( pTarget !is null )
                    {
                        g_EntityFuncs.SetOrigin( pOther, pTarget.pev.origin );

                        g_EntityFuncs.FireTargets( self.pev.netname, pOther, self, USE_TOGGLE, 0.0f );
                        mikk_util.CKV( pOther, "$v_mikk_cam_overview", self.pev.message );
                    }
                }
                // m_pDoor.Use( null, null, USE_OFF, 0.0f );
            }
        }
    }
}