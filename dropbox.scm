#!/usr/bin/csi -s
(use scsh-process)

(define (main)
  (let* ((status (string-chomp (run/string (dropbox-cli status) (= 2 1)))))
    (cond ((string= status "Dropbox isn't running!")
           (printf "~%"))
          ((substring-index-ci "sync" status)
           (printf "~%"))
          (else (newline)))))

(main)
