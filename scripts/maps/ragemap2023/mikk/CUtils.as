final class CUtils
{
    CBaseEntity@ FindPropModel( string m_iszPropName )
    {
        return g_EntityFuncs.FindEntityByTargetname( null, 'mikk_prefab_' + m_iszPropName );
    }

    string CKV( CBaseEntity@ pPlayer, string szKey, string iszValue = String::INVALID_INDEX )
    {
        string sget = String::INVALID_INDEX;

        if( iszValue != String::INVALID_INDEX )
        {
            g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), szKey, iszValue );
            //g_Game.AlertMessage( at_console, 'Set key "' + szKey + '" to "' + iszValue + '"' + '\n' );
        }
        else
        {
            sget = pPlayer.GetCustomKeyvalues().GetKeyvalue( szKey ).GetString();
            //g_Game.AlertMessage( at_console, 'Get key "' + szKey + '" at "' + sget + '"' + '\n' );
        }
        return sget;
    }

    Vector atov( string VectIn )
    {
        Vector VectOut;
        g_Utility.StringToVector( VectOut, VectIn );
        return VectOut;
    }

    string SteamID( CBaseEntity@ pPlayer )
    {
        return g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
    }

    void ClientExe( CBasePlayer@ pPlayer, string_t iszCommand )
    {
        NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
            msg.WriteString( ';' + iszCommand + ';' );
        msg.End();
    }
}
