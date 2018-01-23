#!/usr/bin/csi -script
(use srfi-26
     srfi-13
     srfi-1
     posix
     s
     utf8)

(include "ddbus")
(include "scroll")

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

(define player-name (car (command-line-arguments)))


(define player-context
  (dbus:make-context
   service: (string->symbol (format "org.mpris.MediaPlayer2.~a" player-name))
   path: '/org/mpris/MediaPlayer2
   interface: 'org.mpris.MediaPlayer2.Player))

(define (mpris-info)
  (let* ((status (dbus:get-property player-context "PlaybackStatus"))
         (metadata (vector->list (dbus:get-property player-context "Metadata")))
         (artist (vector-ref (alist-ref "xesam:artist" metadata equal?) 0))
         (song (alist-ref "xesam:title" metadata equal?)))
    (values
     (cond ((string= status "Paused")
            "|")
           ((string= status "Playing")
            ">")
           ((string= status "Stopped")
            "■")
           (else #f))
     (if (member status '("Playing" "Paused" "Stopped"))
         (format "~a - ~a" song artist)
         #f))))

(define (main)
  (scroll mpris-info))

(main)
