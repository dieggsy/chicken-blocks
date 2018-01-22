#!/usr/bin/csi -script
(use (prefix dbus dbus:)
     srfi-13)

(dbus:auto-unbox-object-paths #t)
(dbus:auto-unbox-variants #t)

(define nm-props
  (dbus:make-context
   bus: dbus:system-bus
   service: 'org.freedesktop.NetworkManager
   path: '/org/freedesktop/NetworkManager
   interface: 'org.freedesktop.DBus.Properties))

;; connecion object paths
(define active-connections
  (vector->list
   (car
    (dbus:call nm-props "Get" "org.freedesktop.NetworkManager" "ActiveConnections"))))

(define (make-connection-string path)
  (let* ((context (dbus:make-context
                   bus: dbus:system-bus
                   service: 'org.freedesktop.NetworkManager
                   path: path
                   interface: 'org.freedesktop.DBus.Properties))
         (type (car (dbus:call
                     context
                     "Get"
                     "org.freedesktop.NetworkManager.Connection.Active" "Type")))
         (icon (cond ((string-suffix? "wireless" type)
                      "")
                     ((string-suffix? "ethernet" type)
                      "<>")
                     (else "?"))))
    (let* ((id (car (dbus:call
                     context
                     "Get"
                     "org.freedesktop.NetworkManager.Connection.Active"
                     "Id"))))
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
