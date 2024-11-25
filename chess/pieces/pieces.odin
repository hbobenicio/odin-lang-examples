package pieces

import "core:os"
import "core:fmt"
import "core:log"
import sdl "vendor:sdl2"
import img "vendor:sdl2/image"

import "chess:app"
import "chess:sdlutils"
import "chess:position"

TOTAL_PIECES :: 32
TOTAL_BLACK_PIECES :: TOTAL_PIECES / 2
TOTAL_WHITE_PIECES :: TOTAL_PIECES / 2

Piece :: struct {
    name: string,
    kind: Kind,
    color: Color,
    init_square_color: SquareColor,

    texture: ^sdl.Texture,
    texture_width: i32,
    texture_height: i32,
}

black_bishop := Piece{ name = "Bishop", kind = .Bishop, color = .Black }
black_king   := Piece{ name = "King",   kind = .King,   color = .Black }
black_knight := Piece{ name = "Knight", kind = .Knight, color = .Black }
black_pawn   := Piece{ name = "Pawn",   kind = .Pawn,   color = .Black }
black_queen  := Piece{ name = "Queen",  kind = .Queen,  color = .Black }
black_rook   := Piece{ name = "Rook",   kind = .Rook,   color = .Black }

white_bishop := Piece{ name = "Bishop", kind = .Bishop, color = .White }
white_king   := Piece{ name = "King",   kind = .King,   color = .White }
white_knight := Piece{ name = "Knight", kind = .Knight, color = .White }
white_pawn   := Piece{ name = "Pawn",   kind = .Pawn,   color = .White }
white_queen  := Piece{ name = "Queen",  kind = .Queen,  color = .White }
white_rook   := Piece{ name = "Rook",   kind = .Rook,   color = .White }

pieces := map[Kind]map[Color]^Piece{
    .Bishop = { .Black = &black_bishop, .White = &white_bishop },
    .King   = { .Black = &black_king,   .White = &white_king   },
    .Knight = { .Black = &black_knight, .White = &white_knight },
    .Pawn   = { .Black = &black_pawn,   .White = &white_pawn   },
    .Queen  = { .Black = &black_queen,  .White = &white_queen  },
    .Rook   = { .Black = &black_rook,   .White = &white_rook   }
}

png_data := map[^Piece][]u8{
    &black_bishop  = #load("piece_bishop_black.png"),
    &black_king    = #load("piece_king_black.png"),
    &black_knight  = #load("piece_knight_black.png"),
    &black_pawn    = #load("piece_pawn_black.png"),
    &black_queen   = #load("piece_queen_black.png"),
    &black_rook    = #load("piece_rook_black.png"),

    &white_bishop  = #load("piece_bishop_white.png"),
    &white_king    = #load("piece_king_white.png"),
    &white_knight  = #load("piece_knight_white.png"),
    &white_pawn    = #load("piece_pawn_white.png"),
    &white_queen   = #load("piece_queen_white.png"),
    &white_rook    = #load("piece_rook_white.png"),
}

init :: proc() {
    for kind in Kind.Bishop..=Kind.Rook {
        for color in Color.White..=Color.Black {
            p := pieces[kind][color]
            log.debugf("pieces: initializing %s %s", color, kind)

            p.texture, p.texture_width, p.texture_height = sdlutils.texture_from_png_bytes(png_data[p])
            if p.texture == nil {
                log.errorf("pieces: failed initializing texture for %s %s", color, kind)
                os.exit(1)
            }
        }
    }
}

destroy :: proc() {
    for kind in Kind.Bishop..=Kind.Rook {
        for color in Color.White..=Color.Black {
            p := pieces[kind][color]

            sdl.DestroyTexture(p.texture)
            p.texture = nil
        }
    }
}

render :: proc() {
    ctx := cast(^app.Context) context.user_ptr

    for kind in Kind.Bishop..=Kind.Rook {
        for color in Color.White..=Color.Black {
            p := pieces[kind][color]

            srcrect := sdl.Rect{ x=0, y=0,  w=p.texture_width, h=p.texture_height }
            dstrect := srcrect
            sdl.RenderCopy(ctx.renderer, p.texture, &srcrect, &dstrect)
        }
    }
}
