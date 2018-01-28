(use scsh-process)

(define (main)
  (let* ((status (string-chomp (run/string (dropbox-cli status) (= 2 1))))
         (status (if (> (string-length status) 20)
                     (substring status 0 20)
                     status)))
    (if (not (string= status "Up to date"))
        (printf "~a~%" status)
        (newline))))

(main)
