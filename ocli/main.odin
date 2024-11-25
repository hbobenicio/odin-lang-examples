package main

import "core:io"
import "core:os"
import "core:fmt"
import "core:log"
import "core:mem"

import "ocli"

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

    ocli.run()
}
