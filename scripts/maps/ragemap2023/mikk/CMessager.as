final class CMessager
{
    void PrintBind( CBasePlayer@ pPlayer, string iszmsg )
    {
        g_PlayerFuncs.PrintKeyBindingString( pPlayer, iszmsg + "\n"  );
    }

    void Timer( CBasePlayer@ pPlayer )
    {
        HUDSpriteParams params;
        params.y = -1.0f;
        params.x = 0.0f;
        params.holdTime = 1.0;
        params.fadeinTime = 0.0;
        params.flags = HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_SCR_CENTER_X;
        params.color1 = RGBA( 255, 255, 255, 255 );
        params.spritename = 'ragemap2023/mikk/timer.spr';
        g_PlayerFuncs.HudCustomSprite( pPlayer, params );
    }

    void CharacterDelay( CBasePlayer@ pPlayer )
    {
        mikk_util.CKV( pPlayer, "$i_mikk_chardelay", '0' );
    }
}