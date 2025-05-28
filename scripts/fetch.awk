#!/usr/bin/awk -f

# skip comments and empty lines
/^\s*#/ || NF < 3 { next }

$2 == out {
    url = $1
    md5 = $3

    printf("Fetching %s...\n", url)
    system("curl -L -o \"sources/" out "\" \"" url "\"")

    cmd = "md5sum \"sources/" out "\" | cut -d' ' -f1"
    cmd | getline checksum
    close(cmd)

    if (checksum != md5) {
        printf("MD5 mismatch: expected %s, got %s\n", md5, checksum) > "/dev/stderr"
        exit 2
    }

    print "Downloaded and verified:", out
    found = 1
    exit
}

END {
    if (!found) {
        print "Not found:", out > "/dev/stderr"
        exit 1
    }
}
