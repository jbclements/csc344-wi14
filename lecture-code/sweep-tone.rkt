#lang racket

(require rsound
         rsound/draw)

(define (s sec) (* 44100 sec))

(define SWEEP-TIME (s 10))
(define MAX-FREQ 22050)

(define coeff (* -2 (cos (/ pi 8))))

(signal-play
 (network ()
          [freq ((simple-ctr 0.0 (/ MAX-FREQ SWEEP-TIME)))]
          [osc (sine-wave freq)]
          [tap1 ((tap 1 0.0) osc)]
          [tap2 ((tap 2 0.0) osc)]
          [filtered (+ tap2 (* coeff tap1) osc)]
         [out (* 0.05 filtered)]))
#|(define n (rs-scale 0.2 #;(make-tone 440 1.0 44100) (noise (s 5))))

(time (rsound/left-1-fft-draw (clip n 30 (+ 30 16384))))

(play n)|#