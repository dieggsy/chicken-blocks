#!/usr/bin/csi -script
(use (prefix medea medea:)
     (prefix http-client hc:)
     matchable
     uri-common)

(form-urlencoded-separator "&")

(define api-key
  "00000000000000000000000000000000")

(define lat-long
  "00.0000,00.0000")

(define units
  ;; auto, ca, uk2, us, or si
  ;; see https://darksky.net/dev/docs
  "us")

(define weather-url
  (make-uri scheme: 'https
            host: "api.darksky.net"
            path: `(/ "forecast" ,api-key ,lat-long)
            query: `((units . ,units))))

(define (weather-info)
  (hc:with-input-from-request weather-url #f medea:read-json))

(define (get-icon icon)
  (match icon
    ("clear-day" "")
    ("clear-night" "")
    ("rain" "")
    ("snow" "")
    ("sleet" "")
    ("wind" "")
    ("fog" "")
    ("cloudy" "")
    ("partly-cloudy-day" "")
    ("partly-cloudy-night" "")
    ("hail" "")
    ("thunderstorm" "")
    ("tornado" "")
    (_ "")))

(define (main)
  (let* ((info (weather-info))
         (current (alist-ref 'currently info))
         (temp (inexact->exact
                (round (alist-ref 'temperature current))))
         (icon (alist-ref 'icon current)))
    (printf "~a ~a~%" (get-icon icon) temp)))

(main)
