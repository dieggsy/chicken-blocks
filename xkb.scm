#!/usr/bin/csi -s
(use scsh-process)

(define (current-map)
  (last
   (string-split
    (caddr
     (run/strings (setxkbmap -query))))))

(define args (command-line-arguments))

(define (main)
  (when (and (not (null? args))
             (equal? (car args) "-toggle"))
    (if (equal? (current-map) "dvorak")
        (run (setxkbmap us))
        (run (setxkbmap dvorak))))
  (when (not (equal? (current-map) "dvorak"))
    (display (current-map)))
  (newline)
  (unless (and (not (null? args))
               (equal? (car args) "-display"))
    (with-output-to-file "/tmp/ipc-polybar-simple"
      (lambda () (display "hook:module/xkb1")))))

(main)
