#!/usr/bin/csi -s
(use (prefix dbus dbus:)
     srfi-13
     posix)

(define args (command-line-arguments))

(define $1 (and (not (null? args)) (car args)))

(define (main)
  (let* ((kb-light (dbus:make-context
                    #:bus dbus:system-bus
                    #:service 'org.freedesktop.UPower
                    #:interface 'org.freedesktop.UPower.KbdBacklight
                    #:path '/org/freedesktop/UPower/KbdBacklight))
         (delta (cond ((string= $1 "+") 17)
                      ((string= $1 "-") -17)
                      (else 0)))
         (current (car (dbus:call kb-light "GetBrightness")))
         (maximum (car (dbus:call kb-light "GetMaxBrightness")))
         (new (max 0 (+ current delta))))
    (when (<= 0 new maximum)
      (dbus:call kb-light "SetBrightness" new))
    (display (inexact->exact
              (round (* 100 (/ new maximum)))))
    (newline)))

(main)
