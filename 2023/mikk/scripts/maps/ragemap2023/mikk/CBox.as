mixin class CBox : ScriptBaseEntity
{
    dictionary dict_box =
    {
        { 'buoyancy', '20' },
        { 'friction', '50' },
        { 'targetname', string( self.pev.targetname ) }
    };

    void Spawn()
    {
        dict_box[ 'origin' ] = self.pev.origin.ToString();
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        self.pev.movetype = MOVETYPE_NONE;
        BaseClass.Spawn();
    }

    void PostSpawn()
    {
        CBaseEntity@ box = mikk_util.FindPropModel( 'box' );

        if( box !is null )
        {
            dict_box[ 'model' ] = string( box.pev.model );
            g_EntityFuncs.CreateEntity( "func_pushable", dict_box );
            g_EntityFuncs.Remove( self );
        }
        BaseClass.PostSpawn();
    }
}