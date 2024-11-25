package ocli

import "core:os"
import "core:fmt"
import "core:log"

run :: proc() {
    cmd_root(os.args[1:])
}

cmd_root :: proc(args: []string) {
    if len(args) == 0 {
        usage_print()
        return
    }
    switch args[0] {
        case "issues":
            cmd_issues(args[1:])

        case "-h", "--help":
            usage_print()
            return

        case:
            log.error("bad args: invalid command/args/flags")
            usage_print()
            os.exit(1)
    }
}

cmd_issues :: proc(args: []string) {
    if len(args) == 0 {
        cmd_issues_usage_print()
        os.exit(1)
    }
    switch args[0] {
        case "create":
            cmd_issues_create()

        case "-h", "--help":
            cmd_issues_usage_print()
            return

        case:
            fmt.eprintln("error: bad args: invalid issues action")
            cmd_issues_usage_print()
            os.exit(1)
    }
}

usage_print :: proc() {
    fmt.printf("usage: %v <CMD>\n", os.args[0])
    fmt.println()
    fmt.println("CMD:")
    fmt.println("  issues - Manage issues")
    fmt.println()
}

cmd_issues_usage_print :: proc() {
    fmt.printf("usage: %v issues <ACTION>\n", os.args[0])
    fmt.println()
    fmt.println("ACTION:")
    fmt.println("  create - Creates a new issue")
    fmt.println()
}

cmd_issues_create :: proc() {
    log.info("creating issue...")

    gitlab_site, err := prompt_string("Select the gitlab site (git.serpro / gitlab.com)", max_size = 64)
    if err != .None {
        log.errorf("failed to read gitlab_size: %v", err)
        os.exit(1)
    }
    defer delete(gitlab_site)

    fmt.println("Selected gitlab site:", gitlab_site)
}
