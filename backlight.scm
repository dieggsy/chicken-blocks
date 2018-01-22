#!/usr/bin/csi -s

(define backlight-path  "/sys/class/backlight/intel_backlight/")

(define (read-backlight-file filename)
  (car (read-file (string-append backlight-path filename))))

(define (main)
  (let ((current-brightness (read-backlight-file "brightness"))
        (max-brightness (read-backlight-file "max_brightness")))
    (display
     (inexact->exact
      (round (* 100 (/ current-brightness max-brightness)))))
    (newline)))
