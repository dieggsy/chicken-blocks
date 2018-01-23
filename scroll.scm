(use s
     utf8)

;; Bulitin is broken
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

;; Counter delayed by n counts
(define (make-start n)
  (define count 0)
  (define start 0)
  (lambda (#!optional reset)
    ;; (print "COUNT: " count)
    (if reset
        (begin
          (set! count 1)
          (set! start 0))
        (begin
          (set! count (+ count 1))
          (when (> count n)
            (set! start (+ start 1)))))
    start))

(define (scroll fn
                #!key
                (sleep .2)
                (delay 12)
                (end-pad 3)
                (max-width 20)
                (fixed-width #f))
  (define get-start (make-start delay))
  (let loop ((start (get-start))
             (oldstr ""))
    (let-values (((icon str) (handle-exceptions err (values #f #f) (fn))))
      (when str
        (let* ((len (string-length str))
               (start (if (or (not (string= oldstr str))
                              (= start (+ len end-pad)))
                          (get-start 'reset)
                          start))
               (printstr (if (> len max-width)
                             (x-substring
                              (format "~a~a"
                                      str
                                      (make-string end-pad #\space))
                              start
                              (+ start max-width))
                             (if fixed-width
                                 (s-center max-width str)
                                 str))))
          (if (and icon str)
              (printf "~a ~a~%" icon printstr)
              (printf "~a~%" printstr))))
      (when (not str)
        (newline))
      (thread-sleep! sleep)
      (loop (get-start) (or str "")))))

