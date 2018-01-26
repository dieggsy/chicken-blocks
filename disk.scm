#!/usr/bin/csi -s
(use scsh-process)

(define (main)
  (let ((disk-space
         (string-chomp
          (run/string
           (pipe (df -h /) (grep -v "^[A-Z]") (awk "{print $4}"))))))
    (display disk-space)
    (newline)))

(main)
