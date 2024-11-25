package main

import "core:io"
import "core:os"
import "core:fmt"
import "core:log"
import "core:mem"

import "elf"

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

    run()
}

run :: proc() {
	for input_file_path in os.args[1:] {
		process_file(input_file_path)
	}
}

process_file :: proc(input_file_path: string) {
	log.infof("processing file... path=\"%s\"", input_file_path)

	elf_parser: elf.Parser
	if err := elf.parser_parse_file(&elf_parser, input_file_path); err != nil {
		elf.parser_error_log(&elf_parser, err)
		log.errorf("processing failed: path=\"%s\"", input_file_path)
		os.exit(1)
	}

	log.infof("processing succeeded. elf=%v", elf_parser.elf)
	
	elf.println(&elf_parser.elf)
}
