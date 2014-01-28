#lang racket

(require rsound
         rsound/draw)

(define (s sec) (* 44100 sec))

(define itsnotright (rs-read/clip "/tmp/itsnotright.wav" 0 (s 10)))
(define clipsig (rsound->signal/left itsnotright))
;(play itsnotright)

(define (make-snd frames)
  (signal->rsound
   frames
   (network ()
            #;[w (clipsig)]
            [modumodulator (sine-wave 1/4)]
            [modulator (square-wave (+ 123 (* modumodulator 50)))]
            [w (sine-wave (+ 400 (* 198 modulator)) #;344.53125)]
            [out (* 0.5 w)])))

(define snd (make-snd (s 5)))
(play snd)
(rs-draw snd)
(rsound/left-1-fft-draw (make-snd 8192))


