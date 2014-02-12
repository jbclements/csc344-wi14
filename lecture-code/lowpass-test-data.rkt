#lang racket

(require rsound
         rsound/filter
         rsound/filter-typed
         racket/flonum
         math/flonum
         rsound/draw)

(define cutoff-freq 800)
(define test-freq 1600)
(define theta (* pi (/ cutoff-freq 22050)))

(for/list ([i 20])
  (list (exact->inexact (* 22050 (/ i 20))) 
        (- (apply + (cons -1 (flvector->list
                              (vector-ref (lpf-tap-vectors (* pi (/ i 20)))
                                          1)))))))
(match-define (vector fir-terms iir-terms ignoring-this-gain)
  (lpf-tap-vectors theta))

(define gain (- (apply + (cons -1 (flvector->list
                                   iir-terms)))))

gain

(define (simple-param-signal)
  (values (flvector 0.0 0.0 0.0 0.0)#;fir-terms
          iir-terms
          gain))

#;(define processed
  (signal->rsound
   441000
   (network ()
            [a ((simple-ctr 0 1))]
            [s (sine-wave (* 10000 (/ a 441000)))]
            [(f i g) (simple-param-signal)]
            [out ((dynamic-lti-signal 4) f i g (* 0.1 s))])))

(define input-ramp
  (signal->rsound
   120
   (indexed-signal
    (lambda (t) (/ (modulo t 30) 30)))))

(rs-draw input-ramp)

(define processed 
  (signal->rsound
   120
   (network ()
            [a ((simple-ctr 0 1))]
            [s (rs-ith/left input-ramp a)]
            [(f i g) (simple-param-signal)]
            [out ((dynamic-lti-signal 4) f i g s)])))

(for/list ([i 120])
  (list i (rs-ith/left/s16 input-ramp i)
        (rs-ith/left/s16 processed i)))

(rs-draw processed)
(play processed)

(* gain 1/30)
