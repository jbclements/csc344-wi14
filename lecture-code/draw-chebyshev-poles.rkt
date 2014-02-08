#lang racket

(require rsound 
         rsound/filter-typed
         plot)

(plot (points (for/list ([p chebyshev-s-poles])
                (list (real-part p) (imag-part p))))
      #:x-min -1
      #:x-max 1
      #:y-min -1
      #:y-max 1)

(define i (sqrt -1))

(plot (list 
       (points (for/list ([p (chebyshev-z-poles (/ pi 8))])
                 (list (real-part p) (imag-part p))))
       (parametric (lambda (x) 
                     (define v (exp (* i x)))
                     (list (real-part v)
                           (imag-part v)))
                   0 (* 2 pi)))
      #:x-min -1
      #:x-max 1
      #:y-min -1
      #:y-max 1)