(use (prefix medea medea:)
     (only (prefix http-client hc:) hc:with-input-from-request)
     utils)

(define access-token
  (string-chomp
   (read-all (format "~a/.polybar-ghub-token"
                     (get-environment-variable "HOME")))))

(define notifications-url
  (format "https://api.github.com/notifications?access_token=~a"
          access-token))

(define (main)
  (let ((data (hc:with-input-from-request
               notifications-url
               #f
               medea:read-json)))
    (if (zero? (vector-length data))
        (printf "~%")
        (printf "~a~%" (vector-length data)))))

(main)
