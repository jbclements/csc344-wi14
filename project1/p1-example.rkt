#lang racket

(require rsound)
(define (s sec) (* 44100 sec))


(define snd (rs-read/clip "/tmp/art-for-arts-sake.wav" (s 0) (s 20)))
(define s-len (rs-frames snd))

(random-seed 27278)


(define song 
 (rs-append*
  (for/list ([i 30])
    (define d (add1 (random 10)))
    (define rs (random (- s-len (s 1))))
    (times d (clip snd rs (round (+ rs (/ (s 1) d))))))))

(rs-write song "/tmp/my-awesome-song.wav")

(play song)