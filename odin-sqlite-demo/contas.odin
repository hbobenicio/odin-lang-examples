package main

import "core:log"
import "sqlite3"

contas_create :: proc(db: ^sqlite3.sqlite3, email: string) -> bool {
    sql: cstring = "INSERT INTO conta_corrente (email) VALUES (?1)"
    err_msg: cstring
    if err := sqlite3.sqlite3_exec(db, sql, nil, nil, &err_msg); err != sqlite3.OK {
        defer sqlite3.sqlite3_free(cast(rawptr) err_msg)
        log.error("failed to exec sql:", err_msg)
        return false
    }
    return true
}
