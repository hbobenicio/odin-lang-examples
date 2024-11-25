package board

import sdl "vendor:sdl2"

import "chess:app"
import "chess:pieces"

render :: proc() {
    squares_render()
}

@(private="file")
squares_render :: proc() {
    for i in 0..<8 {
        for j in 0..<8 {
            // it's a light square if i's and j's parities are equal
            square_color: pieces.Color = .White if (i % 2) == (j % 2) else .Black
            square_render(square_color, i, j)
        }
    }
}

@(private="file")
square_render :: proc(color: pieces.Color, i, j: int) {
    ctx := cast(^app.Context) context.user_ptr

    square_white_render_color :: [4]u8{ 255, 255, 255, 255 }
    square_black_render_color :: [4]u8{   0,   0  , 0, 255 }

    switch color {
    case .White:
        sdl.SetRenderDrawColor(
            ctx.renderer,
            square_white_render_color.r,
            square_white_render_color.g,
            square_white_render_color.b,
            square_white_render_color.a
        )

    case .Black:
        sdl.SetRenderDrawColor(
            ctx.renderer,
            square_black_render_color.r,
            square_black_render_color.g,
            square_black_render_color.b,
            square_black_render_color.a
        )
    }

    square := sdl.Rect {
        x = i32(ctx.margin_left_px + i * ctx.square_width_px),
        y = i32(j * ctx.square_height_px),
        w = i32(ctx.square_width_px),
        h = i32(ctx.square_height_px)
    }

    sdl.RenderFillRect(ctx.renderer, &square)
}

// rect_from_position(row, col)