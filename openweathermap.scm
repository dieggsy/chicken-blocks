#!/usr/bin/csi -script
(use (prefix medea medea:)
     (prefix http-client hc:)
     matchable)

(define api-key
  ;; Create an account on openweathermap.org and aftert signing in get an API
  ;; key from: https://home.openweathermap.org/api_keys
  "00000000000000000000000000000000")

(define city-id
  ;; City id can be found here: http://openweathermap.org/find
  ;; Should be an integer
  0000000)

(define units
  ;; "imperial" or "metric"
  "imperial")

(define weather-url
  (format
   "http://api.openweathermap.org/data/2.5/weather?id=~a&appid=~a&units=~a"
   city-id
   api-key
   units))

(define (weather-info)
  (hc:with-input-from-request weather-url #f medea:read-json))

(define (get-icon icon)
  ;; Get icon from weather-icons ttf according to definitions in
  ;; https://openweathermap.org/weather-conditions
  (match icon
    ;; Clear
    ("01d" "") ("01n" "")
    ;; Few clouds
    ("02d" "") ("02n" "")
    ;; Scattered clouds
    ((or "03n" "03d") "")
    ;; Broken clouds
    ((or "04n" "04d") "")
    ;; Showers
    ("09d" "") ("09n" "")
    ;; Rain
    ("10d" "") ("10n" "")
    ;; Thunderstorm
    ("11d" "") ("11n" "")
    ;; Snow or freezing rain
    ("13d" "") ("13n" "")
    ;; Fog or mist
    ("50d" "") ("50n" "")
    ;; Unknown
    (_ "")))

(define (main)
  (let* ((info (weather-info))
         (temp (inexact->exact
                (round (alist-ref 'temp (alist-ref 'main info)))))
         (icon (alist-ref 'icon (vector-ref (alist-ref 'weather info) 0))))
    (format #t "~a ~a~%" (get-icon icon) temp)))

(main)
