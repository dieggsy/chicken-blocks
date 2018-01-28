#!/usr/bin/csi -s
(use scsh-process
     irregex
     srfi-13)

(define args (command-line-arguments))

(define (main)
  (when (not (null? args))
    (let (($1 (car args)))
      (cond ((string= $1 "toggle")
             (run (amixer -D pulse sset Master toggle)
                  (> 1 /dev/null)
                  (= 2 1)))
            ((string= $1 "+")
             (run (amixer -D pulse sset Master 5%+)
                  (> 1 /dev/null)
                  (= 2 1)))
            ((string= $1 "-")
             (run (amixer -D pulse sset Master 5%-)
                  (> 1 /dev/null)
                  (= 2 1))))))
  (let* ((amixer-info (run/strings (amixer sget Master)))
         (last-line (last amixer-info))
         (regex (irregex '(: (submatch (+ numeric)) "%")))
         (mute (string-suffix? "[off]" last-line))
         (level (string->number
                 (irregex-match-substring (irregex-search regex last-line) 1)))
         (icon (cond ((or (= level 0) mute)
                      "")
                     ((< level 50)
                      "")
                     (else  ""))))
    (printf "~a ~a~%" icon level)
    (unless (and (not (null? args))
                 (string= (car args) "-display"))
      (with-output-to-file "/tmp/ipc-polybar-simple"
        (lambda () (display "hook:module/volume1"))))))

(main)
