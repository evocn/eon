// Everett
// Debug
// Alex Hartford
// August 2023

debug : struct {
    lines : [..] string;
}

screen_print :: (text: string) {
    array_add(*debug.lines, text);
}
