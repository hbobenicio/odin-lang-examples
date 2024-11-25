package elf

import "core:os"
import "core:io"
import "core:log"

Parsing_Error :: union {
    Parsing_Error_IO,
    Parsing_Error_OS,
    Parsing_Error_Bad_Field,
}

Parsing_Error_IO :: struct {
    io.Error,
}

Parsing_Error_OS :: struct {
    os.Errno,
}

Parsing_Error_Bad_Field :: struct {
    field_name: string,
}

parser_error_log :: proc(self: ^Parser, err: Parsing_Error) {
    log.errorf("%s:%v: %v", self.input_file_path, self.byte_offset, err)
}
