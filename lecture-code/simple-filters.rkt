#lang racket
(require rsound
         rsound/reverb-typed)

(define speaking
  (rs-read "/Users/clements/rsound/rsound/examples/speaking.wav"))

(define speaking-sig (rsound->signal/left speaking))

(signal-play
 (network ()
          [i (speaking-sig)]
          [out (+ i (* 0.2 (prev delayed1 0.0))
                  (* 0.15 (prev delayed2 0.0))
                  (* 0.3 (prev delayed3 0.0)))]
          [delayed1 ((tap 10000 0.0) out)]
          [delayed2 ((tap 6291 0.0) out)]
          [delayed3 ((tap 5784 0.0) out)]
          [real-out out]
          ))


