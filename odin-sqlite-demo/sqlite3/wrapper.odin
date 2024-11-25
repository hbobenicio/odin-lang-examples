package sqlite3

import "core:c"
foreign import sqlite "system:sqlite3"

sqlite3      :: distinct struct{}
sqlite3_stmt :: distinct struct{}

// int (*callback)(void*,int,char**,char**)
// callback :: proc"c"(data: rawptr, a: c.int, b: [^]cstring, c: [^]cstring) -> ResultCode
Exec_Callback :: proc "c"(rawptr, c.int, ^cstring, ^cstring) -> c.int
Bind_Callback :: proc "c"(rawptr) -> rawptr

// @(link_prefix="sqlite3_")
foreign sqlite {

    // int sqlite3_open(const char *filename, sqlite3 **ppDb);
    sqlite3_open :: proc(filename: cstring,  pp_db: ^^sqlite3) -> c.int ---

    // int sqlite3_close(sqlite3*);
    sqlite3_close :: proc(db: ^sqlite3) -> c.int ---

    // int sqlite3_close_v2(sqlite3*);
    sqlite3_close_v2 :: proc(db: ^sqlite3) -> c.int ---

    // int sqlite3_errcode(sqlite3 *db);
    sqlite3_errcode :: proc(db: ^sqlite3) -> c.int ---

    // int sqlite3_extended_errcode(sqlite3 *db);
    sqlite3_extended_errcode :: proc(db: ^sqlite3) -> c.int ---

    // const char *sqlite3_errmsg(sqlite3*);
    sqlite3_errmsg :: proc(db: ^sqlite3) -> cstring ---

    // const void *sqlite3_errmsg16(sqlite3*);
    sqlite3_errmsg16 :: proc(db: ^sqlite3) -> rawptr ---

    // const char *sqlite3_errstr(int);
    sqlite3_errstr :: proc(code: c.int) -> cstring ---

    // int sqlite3_error_offset(sqlite3 *db);
    sqlite3_error_offset :: proc(db: ^sqlite3) -> c.int ---
    
    // int sqlite3_exec(
    //     sqlite3*,                                  /* An open database */
    //     const char *sql,                           /* SQL to be evaluated */
    //     int (*callback)(void*,int,char**,char**),  /* Callback function */
    //     void *,                                    /* 1st argument to callback */
    //     char **errmsg                              /* Error msg written here */
    // );
    sqlite3_exec :: proc(db: ^sqlite3, sql: cstring, callback: Exec_Callback, arg: rawptr, errmsg: ^cstring) -> c.int ---

    //void sqlite3_free(void*);
    sqlite3_free :: proc(rawptr) ---

    // int sqlite3_prepare_v2(
    //     sqlite3 *db,            /* Database handle */
    //     const char *zSql,       /* SQL statement, UTF-8 encoded */
    //     int nByte,              /* Maximum length of zSql in bytes. */
    //     sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
    //     const char **pzTail     /* OUT: Pointer to unused portion of zSql */
    // );
    sqlite3_prepare_v2 :: proc(db: ^sqlite3, zSql: cstring, nByte: c.int, ppStmt: ^^sqlite3_stmt, pzTail: ^cstring) -> c.int ---

    // int sqlite3_bind_text(sqlite3_stmt*,int,const char*,int,void(*)(void*));
    sqlite3_bind_text :: proc(^sqlite3_stmt, c.int, cstring, c.int, Bind_Callback) -> c.int ---
    // int sqlite3_bind_int(sqlite3_stmt*, int, int);
    // int sqlite3_bind_double(sqlite3_stmt*, int, double);
}
