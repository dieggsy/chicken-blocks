#!/usr/bin/csi -script
(use (prefix medea medea:)
     (only (prefix http-client hc:) hc:with-input-from-request))

(define unread-url
  (string-append
   "https://www.reddit.com/message/unread/.json?"
   "feed=5228a3d32cdc6f87e4c4afcbf4137b4444a6349f&user=dieggsy"))

(define (main)
  (let* ((info (hc:with-input-from-request unread-url #f medea:read-json))
         (children (alist-ref 'children (alist-ref 'data info)))
         (unread (vector-length children)))
    (if (zero? unread)
        (printf "")
        (printf "~a~%" unread))))

(main)
