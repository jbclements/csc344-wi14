#lang racket

(require rsound
         rsound/piano-tones)

;; make a pstream for playing
(define ps (make-pstream))

;; queue the given sound on pstream ps at the given time:
(define (psq snd time) (pstream-queue ps snd time))

;; convert seconds to frames:
(define (s sec) (* 44100 sec))

;; make a tone:
(define (tone-maker pitch)
  #;(make-tone pitch 0.2 (s 4))
  (piano-tone (pitch->midi-note-num pitch)))


(define now (pstream-current-frame ps))
(psq (tone-maker 124) now)
(psq (tone-maker (* 2 124)) (+ (s 1/2) now))
(psq (tone-maker (* 124 4)) (+ (s 1) now))
(psq (tone-maker (* 124 8)) (+ (s 3/2) now))

;(psq (tone-maker 440) (+ (s 4) now))
;(psq (tone-maker (* (expt 2 3/12) 440)) (+ (s 4) (s 1/2) now))

