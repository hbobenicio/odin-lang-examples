package app

import "core:log"
import sdl "vendor:sdl2"

Context :: struct {
    window: ^sdl.Window,
    renderer: ^sdl.Renderer,

    // screen, margin, board and square dimensions are dynamic values that depend on the window's viewport size

    screen_width_px: int,
    screen_height_px: int,

    margin_left_px: int,
    margin_right_px: int,

    board_width_px: int,
    board_height_px: int,

    square_width_px: int,
    square_height_px: int,
}

init :: proc(app: ^Context, screen_width_px, screen_height_px: int) {
    app.screen_width_px = screen_width_px
    app.screen_height_px = screen_height_px
    log.debugf("screen=[%d, %d]", app.screen_width_px, app.screen_height_px)

    app.margin_left_px = (app.screen_width_px - app.screen_height_px) / 2
    app.margin_right_px = app.margin_left_px
    log.debugf("margin=[%d, %d]", app.margin_left_px, app.margin_right_px)

    app.board_width_px = app.screen_width_px - app.margin_left_px - app.margin_right_px
    app.board_height_px = app.screen_height_px
    log.debugf("board=[%d, %d]", app.board_width_px, app.board_height_px)

    app.square_width_px = app.board_width_px / 8
    app.square_height_px = app.square_width_px
    log.debugf("square=[%d, %d]", app.square_width_px, app.square_height_px)
}
