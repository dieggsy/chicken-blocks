#!/usr/bin/csi -script
(use (prefix dbus dbus:)
     srfi-26
     srfi-13
     srfi-1
     posix
     s
     utf8)

(set-buffering-mode! (current-output-port) line:)

;; builtin xsubstring has a bug
(define (x-substring str from #!optional to start end)
  (let (( len (string-length str)))
    (when (or (and start (not (<= 0 start)))
              (and end (not (<  start end)) (not (<= end len)))
              (and to (not (<= from to)))
              (and start end (= start end) to (not (= from to))))
      (error "xsubstring: argument out of range"))
    (if (and to (= from to))
        ""
        (let* ((str (substring str (or start 0) (or end len)))
               (len (string-length str))
               (to (or to (+ from (- (or start 0)) (or end len))))
               (q1 (quotient from len))
               (r1 (modulo   from len))
               (q2 (quotient to   len))
               (r2 (modulo   to   len)))
          (if (and (= q1 q2) (<= r1 r2))
              (substring str r1 r2)
              (string-join
               `(,(substring str (modulo from len) len)
                 ,@(make-list (- q2 q1 1) str)
                 ,(substring str 0 (modulo to len)))
               ""))))))

(dbus:auto-unbox-object-paths #t)
(dbus:auto-unbox-variants #t)
(dbus:auto-unbox-structs #t)

(define args (command-line-arguments))

(define spotify (and (not (null? args)) (string= (car args) "spotify")))

(define prop-context
  (dbus:make-context
   service: (if spotify
                'org.mpris.MediaPlayer2.spotify
                'org.mpris.MediaPlayer2.cmus)
   path: '/org/mpris/MediaPlayer2
   interface: 'org.freedesktop.DBus.Properties))

;; (define player-context
;;   (dbus:make-context
;;    service: 'org.mpris.MediaPlayer2.cmus
;;    path: '/org/mpris/MediaPlayer2
;;    interface: 'org.mpris.MediaPlayer2.Player))

;; (define (player action . args)
;;   (if (null? args)
;;       (dbus:call player-context action)
;;       (apply
;;        (cut dbus:call
;;          player-context
;;          action
;;          <>)
;;        args)))

(define (get-prop prop)
  (car (dbus:call prop-context "Get" "org.mpris.MediaPlayer2.Player" prop)))

(define (get-info)
  (let* ((status (get-prop "PlaybackStatus"))
         (metadata (vector->list (get-prop "Metadata")))
         (artist (vector-ref (alist-ref "xesam:artist" metadata equal?) 0))
         (song (alist-ref "xesam:title" metadata equal?)))
    (list
     status
     (format "~a - ~a" song artist))))

(define (main)
  (define (make-start)
    (define count 0)
    (define start 0)
    (lambda (#!optional reset)
      (if reset
          (begin
            (set! count 1)
            (set! start 0))
          (begin
            (set! count (+ count 1))
            (when (> count 12)
              (set! start (+ start 1)))))
      start))
  (define get-start (make-start))
  ;; (print (string-append icon (substring str 0 width)))
  (let loop ((start (get-start))
             (oldstr ""))
    (handle-exceptions err (format #t "~%")
      (let* ((info (get-info))
             (status (car info))
             (icon (cond ((string= status "Paused")
                          "|")
                         ((string= status "Playing")
                          ">")
                         (else "■")))
             (str (cadr info))
             (len (string-length str))
             (width (or (and (> len 20) 20) len))
             (start (if (or (not (string= oldstr str))
                            (= start (+ len 3)))
                        (get-start 'reset)
                        (get-start)))
             (printstr (if (> len width)
                           (x-substring (format "~a   " str)
                                        start
                                        (+ start width))
                           str)))
        (if (member status '("Playing" "Paused"))
            (format
             #t
             " ~a ~%"
             (string-append  (if spotify
                                 " "
                                 "")
                             icon
                             " "
                             printstr))
            (format #t "~%"))
        ;; (when (string-prefix? printstr str)
        ;;   (thread-sleep! 2.5))
        (thread-sleep! .2)
        (loop (+ 1 start) str)))
    (thread-sleep! .2)
    (loop (+ 1 start) "")))

(main)
