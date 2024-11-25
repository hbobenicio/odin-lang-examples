package elf

import "core:fmt"
import "core:bufio"
import "core:bytes"
import "core:os"
import "core:io"
import "core:strings"
import "core:mem"
import "core:log"
import "base:intrinsics"

Parser :: struct {
    input_file_path: string,
    byte_offset: uint,
    input_handle: os.Handle,
    input_reader: bufio.Reader,
    elf: Elf,
}

@require_results
parser_parse_file :: proc(self: ^Parser, input_file_path: string) -> Parsing_Error {
    self.input_file_path = input_file_path

    file_handle, err := os.open(input_file_path)
    if err != os.ERROR_NONE {
        return Parsing_Error_OS{ err }
    }
    defer os.close(file_handle)
    self.input_handle = file_handle

    defer free_all(context.temp_allocator)

    bufio.reader_init(&self.input_reader, os.stream_from_handle(file_handle))
    defer bufio.reader_destroy(&self.input_reader)

    parser_parse_header(self) or_return

    return nil
}

@private
@require_results
parser_parse_header :: proc(self: ^Parser) -> Parsing_Error {
    parser_parse_ident_magic_number(self)   or_return
    parser_parse_ident_class(self)          or_return
    parser_parse_ident_data_endianess(self) or_return
    parser_parse_ident_version(self)        or_return
    parser_parse_ident_os_abi(self)         or_return
    parser_parse_ident_abi_version(self)    or_return
    parser_padding_skip(self, 7)

    parser_parse_type(self)    or_return
    parser_parse_machine(self) or_return
    parser_parse_version(self) or_return
    parser_parse_entry(self)   or_return
    parser_parse_phoff(self)   or_return
    return nil
}

@private
@require_results
parser_parse_ident_magic_number :: proc(self: ^Parser) -> Parsing_Error {
    buffer: [4]byte
    read_count, err := bufio.reader_read(&self.input_reader, buffer[:])
    if err != .None {
        return Parsing_Error_IO{ err }
    }
    if read_count < len(buffer) {
        return Parsing_Error_IO{ io.Error.Unexpected_EOF }
    }
    
    // 0x7F followed by "ELF" (45 4c 46) in ASCII
    MAGIC_NUMBER :: []byte{ 0x7F, 'E', 'L', 'F' }

    if mem.compare(buffer[:], MAGIC_NUMBER) != 0 {
        return Parsing_Error_Bad_Field{ field_name = "magic number" }
    }

    self.byte_offset += uint(read_count) * size_of(byte)
    return nil
}

@private
@require_results
parser_parse_ident_class :: proc(self: ^Parser) -> Parsing_Error {
    class := parser_parse_generic(self, byte) or_return
    if class != 1 && class != 2 {
        return Parsing_Error_Bad_Field{ field_name = "header class" }
    }

    self.elf.header.ident.class = Header_Ident_Class(class)
    self.byte_offset += size_of(class)

    return nil
}

@private
@require_results
parser_parse_ident_data_endianess :: proc(self: ^Parser) -> Parsing_Error {
    data_endianess := parser_parse_generic(self, byte) or_return
    if data_endianess != 1 && data_endianess != 2 {
        return Parsing_Error_Bad_Field{ field_name = "header data endianess" }
    }
    self.elf.header.ident.data_endianess = Header_Ident_Data_Endianess(data_endianess)
    self.byte_offset += size_of(data_endianess)
    return nil
}

@private
@require_results
parser_parse_ident_version :: proc(self: ^Parser) -> Parsing_Error {
    version := parser_parse_generic(self, byte) or_return
    if version != 1 {
        return Parsing_Error_Bad_Field{ field_name = "header version" }
    }
    self.elf.header.ident.version = Header_Ident_Version(version)
    self.byte_offset += size_of(version)
    return nil
}

@private
@require_results
parser_parse_ident_os_abi :: proc(self: ^Parser) -> Parsing_Error {
    os_abi := parser_parse_generic(self, byte) or_return
    if os_abi == 0x05 || os_abi > 0x12 {
        return Parsing_Error_Bad_Field{ field_name = "header os abi" }
    }
    self.elf.header.ident.os_abi = Header_Ident_OS_ABI(os_abi)
    self.byte_offset += size_of(os_abi)
    return nil
}

@private
@require_results
parser_parse_ident_abi_version :: proc(self: ^Parser) -> Parsing_Error {
    abi_version := parser_parse_generic(self, byte) or_return
    self.elf.header.ident.abi_version = Header_Ident_ABI_Version(abi_version)
    self.byte_offset += size_of(abi_version)
    return nil
}

@private
parser_padding_skip :: proc(self: ^Parser, n: int) -> Parsing_Error {
    if _, err := bufio.reader_discard(&self.input_reader, n); err != .None {
        return Parsing_Error_IO{ err }
    }
    return nil
}

@private
@require_results
parser_parse_type :: proc(self: ^Parser) -> Parsing_Error {
    type := parser_parse_generic(self, u16) or_return
    self.elf.header.type = Header_Type(type)
    self.byte_offset += size_of(type)
    return nil
}

@private
@require_results
parser_parse_machine :: proc(self: ^Parser) -> Parsing_Error {
    machine := parser_parse_generic(self, u16) or_return
    self.elf.header.machine = Header_Machine(machine)
    self.byte_offset += size_of(machine)
    return nil
}

@private
@require_results
parser_parse_version :: proc(self: ^Parser) -> Parsing_Error {
    version := parser_parse_generic(self, u32) or_return
    self.elf.header.version = Header_Version(version)
    self.byte_offset += size_of(version)
    return nil
}

@private
@require_results
parser_parse_entry :: proc(self: ^Parser) -> Parsing_Error {
    switch (self.elf.header.ident.class) {
        case .Bits32:
            value := parser_parse_generic(self, u32) or_return
            self.elf.header.entry = Header_Entry_32(value)
            self.byte_offset += size_of(value)

        case .Bits64:
            value := parser_parse_generic(self, u64) or_return
            self.elf.header.entry = Header_Entry_64(value)
            self.byte_offset += size_of(value)
    }
    return nil
}

@private
@require_results
parser_parse_phoff :: proc(self: ^Parser) -> Parsing_Error {
    switch (self.elf.header.ident.class) {
        case .Bits32:
            value := parser_parse_generic(self, u32) or_return
            self.elf.header.phoff = Header_Phoff_32(value)
            self.byte_offset += size_of(value)

        case .Bits64:
            value := parser_parse_generic(self, u64) or_return
            self.elf.header.phoff = Header_Phoff_64(value)
            self.byte_offset += size_of(value)
    }
    return nil
}

@private
@require_results
parser_parse_generic :: proc(self: ^Parser, $T: typeid) -> (T, Parsing_Error)
    where intrinsics.type_is_numeric(T)
{
    buffer := make([]byte, size_of(T), allocator = context.temp_allocator)
    read_count, err := bufio.reader_read(&self.input_reader, buffer[:])
    if err != .None {
        return 0, Parsing_Error_IO{ err }
    }
    if read_count != len(buffer) {
        return 0, Parsing_Error_IO{ io.Error.Unexpected_EOF }
    }
    value_ptr := transmute(^T) bytes.ptr_from_bytes(buffer[:])
    return value_ptr^, nil
}
