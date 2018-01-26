#!/usr/bin/csi -script
(include "ddbus")

(define battery-context
  (dbus:make-context
   bus: dbus:system-bus
   service: 'org.freedesktop.UPower
   path: '/org/freedesktop/UPower/devices/battery_BAT0
   interface: 'org.freedesktop.UPower.Device))

(define adapter-context
  (dbus:make-context
   bus: dbus:system-bus
   service: 'org.freedesktop.UPower
   path: '/org/freedesktop/UPower/devices/line_power_ADP1
   interface: 'org.freedesktop.UPower.Device))

(define (main)
  (let ((percent
         (inexact->exact
          (round
           (* 100
              (/ (dbus:get-property battery-context "Energy")
                 (dbus:get-property battery-context "EnergyFull"))))))
        (connected (dbus:get-property adapter-context "Online")))
    ;; Warn
    (when (and (<= percent 10) (not connected))
      (let ((warn "Battery critically low, consider charging."))
        (system (format "espeak -vf4 '~a' &" warn))
        (system (format "notify-send '~a' &" warn))))
    ;; Print
    (format
     #t
     "~a ~a~%"
     (cond (connected
            "")
           ((> percent 95)
            "")
           ((> percent 75)
            "")
           ((> percent 50)
            "")
           ((> percent 25)
            "")
           ((<= percent 25)
            ""))
     percent)))

(main)
