CMessager g_Message;
final class CMessager
{
    void PrintBind( CBasePlayer@ pPlayer, string iszmsg )
    {
        g_PlayerFuncs.PrintKeyBindingString( pPlayer, iszmsg + "\n"  );
    }

    void ShowTimer( CBasePlayer@ pPlayer )
    {
        HUDSpriteParams params;

        params.y = 0.05;
        params.x = 0.45;
        params.holdTime = 1.0;
        params.fadeinTime = 0.0;
        params.color1 = RGBA( 255, 255, 255, 255 );
        params.spritename = 'ragemap2023/mikk/timer.spr';

        g_PlayerFuncs.HudCustomSprite( pPlayer, params );
    }
}