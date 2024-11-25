package ocli

import "core:bufio"
import "core:io"
import "core:os"
import "core:fmt"
import "core:strings"

prompt_string :: proc(msg: string, max_size: int) -> (string, io.Error) {
    buffered_reader: bufio.Reader
    bufio.reader_init(&buffered_reader, os.stream_from_handle(os.stdin), size = max_size)
    defer bufio.reader_destroy(&buffered_reader)
 
    fmt.printf("%s: ", msg)
    value, err := bufio.reader_read_string(&buffered_reader, '\n')
    if err != .None {
        fmt.println()
        return "", err
    }

    value = strings.trim_space(value)
    return value, nil
}
