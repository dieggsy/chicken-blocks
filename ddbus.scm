(use (prefix dbus dbus:))

(dbus:auto-unbox-object-paths #t)
(dbus:auto-unbox-structs #t)
(dbus:auto-unbox-variants #t)

(define (dbus:get-property context prop)
  (let* ((prop (->string prop))
         (bus (vector-ref context 1))
         (service (vector-ref context 2))
         (path (vector-ref context 3))
         (old-interface (vector-ref context 4))
         (context
          (dbus:make-context
           bus: bus
           service: service
           path: path
           interface: 'org.freedesktop.DBus.Properties))
         (raw
          (handle-exceptions err #f
            (dbus:call context "Get" (symbol->string old-interface) prop))))
    (and raw (car raw))))

