#!/usr/bin/csi -script
(use (prefix dbus dbus:)
     srfi-13)

(dbus:auto-unbox-variants #t)
(dbus:auto-unbox-structs #t)

(define battery-props
  (dbus:make-context
   bus: dbus:system-bus
   service: 'org.freedesktop.UPower
   path: '/org/freedesktop/UPower/devices/battery_BAT0
   interface: 'org.freedesktop.DBus.Properties))

(define adapter-props
  (dbus:make-context
   bus: dbus:system-bus
   service: 'org.freedesktop.UPower
   path: '/org/freedesktop/UPower/devices/line_power_ADP1
   interface: 'org.freedesktop.DBus.Properties))

(define (get-battery-prop prop)
  (car (dbus:call battery-props "Get" "org.freedesktop.UPower.Device" prop)))

(define (get-adapter-prop prop)
  (car (dbus:call adapter-props "Get" "org.freedesktop.UPower.Device" prop)))

(define (main)
  (let ((percent (inexact->exact
                  (round
                   (* 100
                      (/ (get-battery-prop "Energy")
                         (get-battery-prop "EnergyFull"))))))
        (connected (get-adapter-prop "Online")))
    ;; click
    (let ((click (get-environment-variable "BLOCK_BUTTON")))
      (when (and click (string= click "1"))
        (string= (get-environment-variable "BLOCK_BUTTON") "1")
        (system "notify-send \"$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)\"")))
    ;; Warn
    (when (and (<= 10 percent) (not connected))
      (let ((warn "Battery critically low, consider charging."))
        (system (format "espeak -vf4 '~a' &" warn))
        (system (format "notify-send '~a' &" warn))))
    ;; Print
    (format
     #t
     "  ~a  ~a ~%"
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
