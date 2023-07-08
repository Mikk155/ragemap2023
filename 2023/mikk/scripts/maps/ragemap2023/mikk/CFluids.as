enum FluidType
{
    FLUID_ACID = 0,
    FLUID_WATER = 1,
    FLUID_LAVA = 2
}

enum FluidSize
{
    FLUID_VERYSMALL = 0,
    FLUID_SMALL = 1,
    FLUID_MEDIUM = 2,
    FLUID_BIG = 3,
    FLUID_EXTRABIG = 4
}

mixin class CFluids
{
    dictionary dict_water =
    {
        { 'rendermode', '5' },
        { 'renderamt', '255' }
    };

    void Spawn()
    {
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        dict_water[ 'origin' ] = self.pev.origin.ToString();
        BaseClass.Spawn();
    }

    void PostSpawn()
    {
        string size = string( atoi( self.pev.message ) );
        string iszModel;

        if( int( self.pev.frags ) == FLUID_ACID )
        {
            iszModel = mikk_util.FindPropModel( 'fluid_acid_' + size ).pev.model;
        }
        else if( int( self.pev.frags ) == FLUID_WATER )
        {
            iszModel = mikk_util.FindPropModel( 'fluid_water_' + size ).pev.model;
        }
        else if( int( self.pev.frags ) == FLUID_LAVA )
        {
            iszModel = mikk_util.FindPropModel( 'fluid_fire_' + size ).pev.model;
        }
        dict_water[ 'model' ] = iszModel;

        self.pev.model = iszModel;
        g_EntityFuncs.SetModel( self, iszModel );
        g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        SetTouch( TouchFunction( this.Touch ) );

        g_EntityFuncs.CreateEntity( "func_illusionary", dict_water, true );
        BaseClass.PostSpawn();
    }

    void Touch( CBaseEntity@ pOther )
    {
        if( pOther !is null && pOther.IsPlayer() )
        {
            g_Game.AlertMessage( at_console, 'Touchfunc' );
            if( int( self.pev.frags ) == FLUID_ACID )
            {
                mikk_Character.CharacterDie( cast<CBasePlayer@>( pOther ) );
            }
            else if( int( self.pev.frags ) == FLUID_WATER && pOther.pev.targetname != 'watergirl' )
            {
                mikk_Character.CharacterDie( cast<CBasePlayer@>( pOther ) );
            }
            else if( int( self.pev.frags ) == FLUID_LAVA && pOther.pev.targetname != 'fireboy' )
            {
                mikk_Character.CharacterDie( cast<CBasePlayer@>( pOther ) );
            }
        }
    }
}