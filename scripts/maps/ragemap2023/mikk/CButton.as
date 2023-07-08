mixin class CButton
{
    dictionary dict_door =
    {
        { 'wait', '-1' },
        { 'angles', '0 0 -90' },
        { 'targetname', string( self.entindex() ) }
    };

    private CBaseEntity@ m_pDoor = null;

    void Spawn()
    {
        dict_door[ 'origin' ] = self.pev.origin.ToString();
        g_EntityFuncs.SetOrigin( self, self.pev.origin );

        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_TRIGGER;

        g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, -32 ), Vector( 32, 32, 32 ) );
        SetTouch( TouchFunction( this.Touch ) );
        BaseClass.Spawn();
    }

    void PostSpawn()
    {
        CBaseEntity@ button = mikk_util.FindPropModel( 'button' );

        if( button !is null )
        {
            dict_door[ 'model' ] = string( button.pev.model );
            @m_pDoor = g_EntityFuncs.CreateEntity( "func_door", dict_door );
        }
        BaseClass.PostSpawn();
    }

    void Touch( CBaseEntity@ pOther )
    {
        if( pOther !is null )
        {
            m_pDoor.Use( null, null, USE_ON, 0.0f );
        }
    }
}