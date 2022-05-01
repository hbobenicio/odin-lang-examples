package main

import "core:fmt"
import "core:os"
import sdl "vendor:sdl2"

Screen :: struct {
    width: i32,
    height: i32,
}

Game :: struct {
    screen: Screen,
    win: ^sdl.Window,
    renderer: ^sdl.Renderer,
}

main :: proc() {
    if sdl.Init(sdl.INIT_VIDEO) < 0 {
        fmt.eprintln("error: sdl2: failed to init library");
        os.exit(1);
    }
    defer sdl.Quit();

    game: Game;
    game.screen = Screen{400, 300};

    game.win = sdl.CreateWindow(
        "Hey Odin!",
        sdl.WINDOWPOS_CENTERED,
        sdl.WINDOWPOS_CENTERED,
        game.screen.width,
        game.screen.height,
        sdl.WINDOW_SHOWN
    );
    if game.win == nil {
        fmt.eprintln("error: sdl2: failed to create window:", sdl.GetError());
        os.exit(1);
    }
    defer sdl.DestroyWindow(game.win);

    game.renderer = sdl.CreateRenderer(game.win, -1, sdl.RENDERER_ACCELERATED | sdl.RENDERER_PRESENTVSYNC);
    if game.renderer == nil {
        fmt.eprintln("error: sdl2: failed to create renderer:", sdl.GetError());
        os.exit(1);
    }
    defer sdl.DestroyRenderer(game.renderer);

    // for {
    //     event: sdl.Event;
    //     sdl.PollEvent(&event);
    //     sdl.Delay(3000);
    // }
    sdl.Delay(2000);
}
