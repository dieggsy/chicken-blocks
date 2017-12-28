#!/usr/bin/csi -script
(use srfi-19
     s)

(define time-now (current-time))

(define date-now (time->date time-now))

(define datestr-now (format-date "~Y-~m-~d ~H:~M" date-now))

(define (make-current-month)
  (string-append
   "Su Mo Tu We Th Fr Sa\n"
   (let* ((month (date-month date-now))
          (year (date-year date-now))
          (date-first (make-date 0 0 0 0 1 month year))
          (weekday (date-week-day date-first))
          (pref (make-string (+ (* 2 weekday) weekday) #\space)))
     (string-append
      pref
      (let loop ((start 0))
        (let ((new-date (date-add-duration
                         date-first
                         (make-time time-duration 0 (* start 86400)))))
          (if (not (= (date-month new-date) month))
              "\n"
              (string-append
               (string-pad
                (number->string
                 (date-day new-date))
                2)
               (if (= (date-week-day new-date) 6)
                   "\n"
                   " ")
               (loop (+ start 1))))))))))


(define (main)
  (let ((click (get-environment-variable "BLOCK_BUTTON")))
    (when (and click (string= click "1"))
      (system (format "notify-send '~a' '~a' &"
                      (s-center
                       19
                       (format "~a ~a"
                               (format-date "~B" date-now)
                               (date-year date-now)))
                      (make-current-month)))))
  (format #t "~a ~%" datestr-now))

(main)
