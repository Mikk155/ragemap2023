final class GMap
{
    float corner;

    void GetCorner()
    {
        CBaseEntity@ pCorner = g_EntityFuncs.FindEntityByTargetname( null, 'mikk_corner_barrier' );

        if( pCorner !is null )
        {
            mikk_Map.corner = pCorner.pev.origin.y;
        }
    }

    void CheckCorner( CBasePlayer@ pPlayer )
    {
        if( pPlayer.pev.origin.y <= mikk_Map.corner )
        {
            pPlayer.pev.velocity.y = 10000;
        }
    }
}