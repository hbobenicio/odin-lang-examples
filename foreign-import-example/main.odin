package main

import "core:c"
import "core:fmt"
foreign import "system:sqlite3"

@(link_prefix="sqlite3_")
foreign sqlite3 {
    close :: proc()
}

main :: proc() {
    fmt.println("Hello, World!")
    sqlite3.close(nil)
}
