#!/usr/bin/csi -script
(use (prefix shell shell:))

(define (main)
  (let* ((args (command-line-arguments))
         (brightness (string->number
                      (string-chomp (shell:capture "xbacklight -get"))))
         ;; round to closest multiple of 5
         (brightness (inexact->exact (* 5 (round (/ brightness 5)))))
         (add (if (not (null? args))
                  (cond ((and (< brightness 100) (string= (car args) "+")) 5)
                        ((and (> brightness 0) (string= (car args) "-")) -5)
                        (else 0))
                  0)))
    (let ((brightness (+ brightness add)))
      (when (not (zero? add))
        (system (format "xbacklight -set ~a > /dev/null 2>&1" brightness)))
      (format #t "    ~a~%" brightness))))

(main)
