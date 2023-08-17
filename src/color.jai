// Everett
// Color Palette
// Alex Hartford
// June 2023

// This is simply a list of all the colors we will use in the game.
// My plan is just to keep this as the end-all-be-all mapping, and always draw in these colors.
// This will require a bit of doing on our part, but not much, and will be
// great for easily tweaking the final result.

// @NOTE: Just leave the alphas in here as 1... We want to set the alpha we want at the use point.
// The only reason these aren't Vector3's is because it's nicer to pass vector4's around later.

white  :: Vector4.{.97, 1, .97, 1};
black  :: Vector4.{.16, .18, .21, 1};
red    :: Vector4.{0.9, .2, .2, 1};
green  :: Vector4.{0, .98, .61, 1};
blue   :: Vector4.{.31, .80, .77, 1};

orange :: Vector4.{1, .3, .2,  1};
yellow :: Vector4.{1, .9, .43, 1};
