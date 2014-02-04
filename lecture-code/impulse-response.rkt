#lang racket

(require rsound
         rsound/draw)

(define speaking 
  (rs-read/clip "/Users/clements/rsound/rsound/examples/speaking.wav"
                (* 44100 4) (+ (* 44100 4) 160000)))
(define IMPULSE-RESPONSE-CUTOFF 15000)
(define impulse-response (rs-read/clip "/tmp/binaural-1.wav" 
                                  0 IMPULSE-RESPONSE-CUTOFF))

(rs-draw impulse-response)

(rs-frames impulse-response)
(define (convolve a b)
  (define a-len (rs-frames a))
  (define b-len (rs-frames b))
  (define len (+ a-len b-len))
  (signals->rsound
   len
   (indexed-signal
    (lambda (t)
      (when (= 0 (modulo t 200))
        (printf "t = ~v\n" t))
      (define min-i (max 0 (- t (sub1 b-len))))
      (define max-i (min (sub1 a-len) t))
      (for*/sum ([i (in-range min-i max-i)])
        (define j (- t i))
        (* (rs-ith/left a i) (rs-ith/left b j)))))
   (indexed-signal
    (lambda (t)
      (define min-i (max 0 (- t (sub1 b-len))))
      (define max-i (min (sub1 a-len) t))
      (for*/sum ([i (in-range min-i max-i)])
        (define j (- t i))
        (* (rs-ith/left a i) (rs-ith/left b j)))))))

(define convolved 
  (time (convolve speaking impulse-response)))

(rs-draw convolved)

(rs-write convolved "/tmp/convolved-longer.wav")

;; slower than real time by 1103x
;; took 66.7 minutes to generate 4 seconds of sound.