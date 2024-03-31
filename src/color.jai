// Everett
// Color Palette
// Alex Hartford
// June 2023

Color :: Vector4;

// Assumes a hex number in the form 0xRRGGBB (no Alpha)
color_from_hex :: ($h: u32) -> Color {
    color : Color;
    color.x = ((h >> 16) & 0xff) / 255.0;
    color.y = ((h >>  8) & 0xff) / 255.0;
    color.z = ((h >>  0) & 0xff) / 255.0;
    color.w = 1.0;

    return color;
}

// The Palette
////////////////////////////////////////////////////////////////////////////////

color_none :: Color.{};
white   :: #run color_from_hex(0xffffff);
black   :: #run color_from_hex(0x060608);
gray    :: #run color_from_hex(0x7c7c7c);

purple  :: #run color_from_hex(0x2f256b);
red     :: #run color_from_hex(0xd14444);
green   :: #run color_from_hex(0x67ab7a);
yellow  :: #run color_from_hex(0xECA72C);
blue    :: #run color_from_hex(0x067ab7);
pink    :: #run color_from_hex(0xb869d3);

// Rainbow color below!
////////////////////////////////////////////////////////////////////////////////

rainbow : Color;

rainbow_time : float;
RAINBOW_OSCILLATION_SPEED :: 5.0;

update_rainbow_color :: (dt: float) -> Color {
    rainbow_time += dt * RAINBOW_OSCILLATION_SPEED;

    if rainbow_time >= 6.0 then rainbow_time = rainbow_time - 6.0;
    
    if      rainbow_time > 5.0 then return pink;
    else if rainbow_time > 4.0 then return red;
    else if rainbow_time > 3.0 then return yellow;
    else if rainbow_time > 2.0 then return green;
    else if rainbow_time > 1.0 then return blue;
    else                            return purple;
}
