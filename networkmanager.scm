#!/usr/bin/csi -script
(use srfi-13)

(include "ddbus")

(define nm-context
  (dbus:make-context
   bus: dbus:system-bus
   service: 'org.freedesktop.NetworkManager
   path: '/org/freedesktop/NetworkManager
   interface: 'org.freedesktop.NetworkManager))

;; connecion object paths
(define active-connections
  (vector->list (dbus:get-property nm-context "ActiveConnections")))

(define (make-connection-string path)
  (let* ((context (dbus:make-context
                   bus: dbus:system-bus
                   service: 'org.freedesktop.NetworkManager
                   path: path
                   interface: 'org.freedesktop.NetworkManager.Connection.Active))
         (type (dbus:get-property context "Type"))
         (icon (cond ((string-suffix? "wireless" type)
                      "")
                     ((string-suffix? "ethernet" type)
                      "<>")
                     (else "?"))))
    (let* ((id (dbus:get-property context "Id")))
      (string-append icon " " id))))

(define (main)
  (let* ((connections (let loop ((conn active-connections))
                        (if (null? conn)
                            conn
                            (cons
                             (make-connection-string (car conn))
                             (loop (cdr conn)))))))
    (if  (null? connections)
         (format #t "  No Connection~%")
         (format #t "~a~%" (string-join connections " ")))))

(main)
