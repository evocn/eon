// Everett
// UI
// Alex Hartford
// June 2023

// This will be a getrect - type solution to UI problems.
// General idea: Be able to draw rectangles on the screen.
//               Be able to draw text on the screen.
//               Have a nice way to put text on those rectangles so it's easy to write UI code.
// Interaction with the rectangles will be very simple though:
// We will define state machines for each, and let you move around with the normal inputs
// (Left/Right/Up/Down/A/B)
//
// This will make things much easier than getrect, so we won't have to worry too much.
// Roadmap:
// 1. Get the rects working where you define them with a spot on the screen and a size (and maybe a color).
// 2. Load and render bitmap fonts.
// 3. Font-rendering is tight and terse. Don't need to focus on caching system, etc.
// 4. Integrate text into the rectangles. Maybe do some work on wrapping, maybe don't bother.
// 5. Input
// 6. Integrate into a nice API
// 7. Stretch Goals: TTF Rendering, Real-Time UI editing, cool styles, etc.

// That's the plan. Let's knock it out fast!
