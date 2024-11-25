package main

import "core:fmt"
import "core:os"
import "core:log"
import "core:mem"
import "core:c"
import "sqlite3"

main :: proc() {
    when ODIN_DEBUG {
    	track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, backing_allocator = context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("\n=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("\n=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
    }

    root_logger := log.create_console_logger(log.Level.Info)
    defer log.destroy_console_logger(root_logger)
    context.logger = root_logger

    if ok := run(); !ok {
        os.exit(1)
    }
}

SCHEMA :: #load("schema.sql", string)

run :: proc() -> bool {
    log.info("db: opening connection...")

    db: ^sqlite3.sqlite3
    if rc := sqlite3.sqlite3_open("o.db", &db); rc != sqlite3.OK {
        defer sqlite3.sqlite3_close(db)
        reason := sqlite3.sqlite3_errmsg(db)
        log.error("failed to open database:", reason)
        return false
    }
    defer sqlite3.sqlite3_close(db)
    // defer fmt.println("ok")

    log.info("db: connection is open")

    err_msg: cstring
    if rc := sqlite3.sqlite3_exec(db, cstring(SCHEMA), nil, nil, &err_msg); rc != sqlite3.OK {
        log.error("failed to exec sql:", err_msg)
        sqlite3.sqlite3_free(cast(rawptr) err_msg)
        return false
    }

    contas_create(db, "fulano@gmail.com") or_return

    fmt.println("It Works!")
    return true
}
