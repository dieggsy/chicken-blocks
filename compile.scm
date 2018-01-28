#!/usr/bin/csi -s
(use getopt-long
     files
     posix
     scsh-process)

(define options
  '((prefix
     "Specify install directory"
     (value #t))
    (file-prefix
     "Specify prefix to prepend to executables"
     (value #t))))

(define (files-to-compile)
  (remove
   (cut member
     <>
     '("scroll.scm"
       "notify.scm"
       "ddbus.scm"
       "compile.scm"))
   (directory)))

(define (main)
  (let* ((opts (getopt-long (command-line-arguments) options))
         (prefix (or (alist-ref 'prefix opts)
                     (format "~a/bin/blocks" (get-environment-variable "HOME"))))
         (file-prefix (or (alist-ref 'file-prefix opts) "")))
    (create-directory prefix #t)
    (print prefix)
    (print file-prefix)
    (let loop ((files (files-to-compile)))
      (if (null? files)
          #f
          (let* ((file (string-append file-prefix (car files)))
                 (out-file (make-pathname
                            prefix
                            (pathname-file file))))
            (printf "Compiling ~a to ~a~%" file out-file)
            (run (csc ,file -o ,out-file))
            ;; (compile ,file -o ,out-file)
            (loop (cdr files)))))))

(main)
