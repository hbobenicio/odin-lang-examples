package main

import "core:fmt"
import "core:log"
import "core:os"

import sdl "vendor:sdl2"
import img "vendor:sdl2/image"

import "app"
import "sdlutils"
import "board"
import "pieces"

WINDOW_TITLE :: "Chess"

main :: proc() {
    // Initialize the global (console) logger
    logger := log.create_console_logger()
    defer log.destroy_console_logger(logger)
    context.logger = logger

    // Initialize the global application context
    log.debug("app: ctx: initializing...")
    ctx: app.Context
    app.init(&ctx, 1200, 900)
    context.user_ptr = &ctx

    // Initializa SDL and friends
    ctx.window, ctx.renderer = sdl_init()
    if ctx.window == nil || ctx.renderer == nil {
        log.error("sdl: initialization failed")
        os.exit(1)
    }
    defer sdl_quit()

    log.debug("pieces: initializing...")
    pieces.init()
    defer pieces.destroy()

    // Main Loop
    main_loop: for {

        // Polling Events
        event: sdl.Event
        for sdl.PollEvent(&event) {
            #partial switch event.type {
                case .QUIT:
                break main_loop

                case .KEYDOWN:
                if event.key.keysym.sym == .ESCAPE {
                    break main_loop
                }
            }
        }

        // Update
        //TODO

        // Render
        background_render()
        board.render()
        pieces.render()

        sdl.RenderPresent(ctx.renderer)
    }

    log.debug("application exiting normally...")
}

//sdl_init initializes SDL and all of its libraries (including window and renderer creation).
// Caller must defer sdl_quit()
sdl_init :: proc() -> (^sdl.Window, ^sdl.Renderer) {
    ctx := cast(^app.Context) context.user_ptr

    sdlutils.log_versions()

    log.debug("sdl: initializing...")
    if sdl.Init(sdl.INIT_VIDEO) < 0 {
        sdlutils.log_error("init failed")
        return nil, nil
    }

    log.debug("sdl: img: initializing...")
    img_init_flags := img.InitFlags{ .PNG, .TIF }
    if rc := img.Init(img_init_flags); rc != img_init_flags {
        sdlutils.log_error("img: init failed")
        sdl.Quit()
        return nil, nil
    }

    log.debug("sdl: creating window...")
    window := sdl.CreateWindow(
        WINDOW_TITLE,
        sdl.WINDOWPOS_CENTERED,
        sdl.WINDOWPOS_CENTERED,
        i32(ctx.screen_width_px),
        i32(ctx.screen_height_px),
        sdl.WINDOW_SHOWN
        //        sdl.WINDOW_FULLSCREEN
    )
    if window == nil {
        sdlutils.log_error("failed to create window")
        img.Quit()
        sdl.Quit()
        return nil, nil
    }
    
    log.debug("sdl: creating renderer...")
    renderer := sdl.CreateRenderer(window, -1, sdl.RENDERER_ACCELERATED | sdl.RENDERER_PRESENTVSYNC)
    if (renderer == nil) {
        sdlutils.log_error("failed to create renderer")
        sdl.DestroyWindow(window)
        img.Quit()
        sdl.Quit()
        return nil, nil
    }
    
    return window, renderer
}

sdl_quit :: proc() {
    ctx := cast(^app.Context) context.user_ptr
    
    defer sdl.Quit()
    defer img.Quit()
    defer sdl.DestroyWindow(ctx.window)
    defer sdl.DestroyRenderer(ctx.renderer)
}

background_render :: proc() {
    ctx := cast(^app.Context) context.user_ptr

    COLOR :: [4]u8 { 42, 42, 42, 255 }
    sdl.SetRenderDrawColor(ctx.renderer, COLOR.r, COLOR.g, COLOR.b, COLOR.a)
    sdl.RenderClear(ctx.renderer)
}
