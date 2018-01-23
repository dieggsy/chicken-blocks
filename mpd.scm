#!/usr/bin/csi -s
(use (prefix mpd-client mpd:)
     posix
     srfi-18
     s)

(include "scroll")

(set-buffering-mode! (current-output-port) line:)

(define mpd (mpd:connect))

(define (mpd-info)
  (let* ((status (alist-ref 'state (mpd:get-status mpd)))
         (metadata (mpd:get-current-song mpd))
         (artist (alist-ref 'Artist metadata))
         (song (alist-ref 'Title metadata)))
    (print status)
    (values
     (case status
       ((pause) "|")
       ((play) ">")
       ((stop) "■")
       (else #f))
     (if (member status '(play pause stop))
         (format "~a - ~a" song artist)
         #f))))

(define (main)
  (scroll mpd-info))

(main)
