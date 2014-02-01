#lang racket
(require rsound
         rsound/reverb-typed)

(define speaking
  (rs-read "/Users/clements/rsound/rsound/examples/speaking.wav"))

(define speaking-sig (rsound->signal/left speaking))

(signal-play
 (network ()
          [i (speaking-sig)]
          [delayed ((tap 200 0.0) i)]
          [out (+ i delayed)]
          ))


