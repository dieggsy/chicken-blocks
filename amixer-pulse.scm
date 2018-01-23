#!/usr/bin/csi -s
(use scsh-process
     irregex)

(define args (command-line-arguments))

(define (main)
  (when (not (null? args))
    (let (($1 (car args)))
      (cond ((string= $1 "toggle")
             (run (amixer -D pulse sset Master toggle)
                  (> 1 /dev/null)
                  (> 2 1)))
            ((string= $1 "+")
             (run (amixer -D pulse sset Master 5%+)
                  (> 1 /dev/null)
                  (> 2 1)))
            ((string= $1 "-")
             (run (amixer -D pulse sset Master 5%-)
                  (> 1 /dev/null)
                  (> 2 1))))))
  (let* ((amixer-info (run/strings (amixer sget Master)))
         (last-line (last amixer-info))
         (regex (irregex '(: (submatch (+ numeric)) "%")))
         (level (irregex-match-substring (irregex-search regex last-line) 1)))
    (display level)
    (newline)
    (with-output-to-file "/tmp/ipc-polybar-simple"
      (lambda () (display "hook:module/volume1")))))

(main)
