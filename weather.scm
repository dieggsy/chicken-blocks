#!/usr/bin/csi -script
(use (prefix medea medea:)
     (prefix http-client hc:)
     uri-common
     matchable)

(define api-key "***REMOVED***")

(define city-id 0000000)

(define units "imperial")

(define weather-url
  (format
   "http://api.openweathermap.org/data/2.5/weather?id=~a&appid=~a&units=~a"
   city-id
   api-key
   units))

(define weather-info (hc:with-input-from-request weather-url #f medea:read-json))

(define (alist-ref* alist . keys)
  (let loop ((klst (reverse keys)))
    (if (null? klst)
        alist
        (alist-ref (car klst) (loop (cdr klst))))))

(let ((weather-main (alist-ref
                     'main
                     (vector-ref
                      (alist-ref 'weather weather-info)
                      0)))
      (weather-temp (alist-ref* weather-info 'main 'temp)))
  (format #t "~a ~a~%"
          (match weather-main
            ("Clear" "")
            ("Cloud" "")
            ((or "Rain" "Drizzle") "")
            ("Storm" "")
            ("Snow" "")
            ((or "Fog" "Mist") ""))
          (inexact->exact
           (round weather-temp))))
