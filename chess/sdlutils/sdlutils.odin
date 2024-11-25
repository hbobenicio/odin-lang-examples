package sdlutils

import "core:log"

import sdl "vendor:sdl2"
import img "vendor:sdl2/image"

import "chess:app"

log_versions :: proc() {
    log.debugf("SDL API version=\"%d.%d.%d\"", sdl.MAJOR_VERSION, sdl.MINOR_VERSION, sdl.PATCHLEVEL)

    sdl_img_linked_version: ^sdl.version = img.Linked_Version()
    log.debugf("SDL_IMG linked version=\"%d.%d.%d\"", sdl_img_linked_version.major, sdl_img_linked_version.minor, sdl_img_linked_version.patch)
}

log_error :: proc(reason: string) {
    log.errorf("sdl: %s: %s", reason, sdl.GetError())
}

// texture_from_png_bytes creates a sdl.Texture from png encoded bytes.
// Caller should defer sdl.DestroyTexture(texture)
texture_from_png_bytes :: proc(bytes: []u8) -> (texture: ^sdl.Texture, width, height: i32) {
    ctx := cast(^app.Context) context.user_ptr

    rw: ^sdl.RWops = sdl.RWFromMem(raw_data(bytes), i32(len(bytes)))
    if rw == nil {
        log_error("failed creating sdl.Surface")
        return nil, 0, 0
    }
    // defer sdl.RWclose(rw)

    surface := img.LoadPNG_RW(rw)
    if surface == nil {
        log_error("failed creating sdl.Surface")
        return nil, 0, 0
    }
    // defer sdl.FreeSurface(surface)

    texture = sdl.CreateTextureFromSurface(ctx.renderer, surface)
    if texture == nil {
        log_error("failed creating sdl.Texture from sdl.Surface")
        return nil, 0, 0
    }
    
    format: u32
    access: i32
    if rc := sdl.QueryTexture(texture, &format, &access, &width, &height); rc != 0 {
        log_error("failed querying sdl.Texture")
        return nil, 0, 0
    }

    return texture, width, height
}
