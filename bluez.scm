#!/usr/bin/csi -s
(use srfi-1
     srfi-13)
(include "ddbus")

(define bluez
  (dbus:make-context
   bus: dbus:system-bus
   service: 'org.bluez
   path: '/
   interface: 'org.freedesktop.DBus.ObjectManager))

(define hci0-context
  (dbus:make-context
   bus: dbus:system-bus
   service: 'org.bluez
   path: '/org/bluez/hci0
   interface: 'org.bluez.Adapter1))

(define (listify-recursively lst)
  (cond ((null? lst)
         '())
        ((not (pair? lst))
         lst)
        ((not (pair? (car lst)))
         (cons (car lst)
               (listify-recursively
                (if (vector? (cdr lst))
                    (vector->list (cdr lst))
                    (cdr lst)))))
        (else
         (cons (listify-recursively (car lst))
               (listify-recursively
                (if (vector? (cdr lst))
                    (vector->list (cdr lst))
                    (cdr lst)))))))

(define connected-devices
  (filter
   (lambda (thing)
     (let* ((props-ish (cdr thing))
            (device-info (alist-ref "org.bluez.Device1" props-ish string=)))
       (and device-info
            (alist-ref "Connected" device-info string=))))
   (listify-recursively
    (vector->list (car (dbus:call bluez "GetManagedObjects"))))))

(define (main)
  (let ((devices (let loop ((dev connected-devices))
                   (if (null? dev)
                       dev
                       (cons
                        (alist-ref
                         "Name"
                         (alist-ref "org.bluez.Device1" (cdr (car dev)) string=)
                         string=)
                        (loop (cdr dev)))))))
    (if (not (null? devices))
        (printf "~a~%" (string-join devices " "))
        (newline))))

(main)
