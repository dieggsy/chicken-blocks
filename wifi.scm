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
  (let ((click (get-environment-variable "BLOCK_BUTTON")))
    (when (and click (string= click "1"))
      (system "networkmanager_dmenu &")))
  (let* ((connections (let loop ((conn active-connections)
                                 (count 0))
                        (if (null? conn)
                            conn
                            (cons
                             (make-connection-string (car conn))
                             (loop (cdr conn) (+ 1 count))))))
         (connections (string-join connections " ")))
    (if  (string-null? connections)
         (format #t "  No Connection~%")
         (format #t "~a~%" connections))))

(main)
