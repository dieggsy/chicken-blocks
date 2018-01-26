#!/usr/bin/csi -script
(use scsh-process)

(define (main)
  (let* ((args (command-line-arguments))
         (brightness (run/sexp (xbacklight -get)))
         ;; round to closest multiple of 5
         (brightness (inexact->exact (* 5 (round (/ brightness 5)))))
         (add (if (not (null? args))
                  (cond ((and (< brightness 100) (string= (car args) "+")) 5)
                        ((and (> brightness 0) (string= (car args) "-")) -5)
                        (else 0))
                  0)))
    (let ((brightness (+ brightness add)))
      (when (not (zero? add))
        (run (xbacklight -set ,brightness)))
      (display brightness)
      (newline))))

(main)
