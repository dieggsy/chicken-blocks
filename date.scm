#!/usr/bin/csi -script
(use srfi-19
     s)

(define (main)
  (format #t
          " ~a~%"
          (format-date "~a ~Y-~m-~d ~H:~M"
                       (time->date (current-time)))))

(main)
