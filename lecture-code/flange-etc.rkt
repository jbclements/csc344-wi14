#lang racket

(require rsound
         rsound/piano-tones
         rsound/draw)

(define input-sound
  #;(piano-tone 50)
  (rs-read "/tmp/chet-atkins.wav"
   #;"/Users/clements/rsound/rsound/piano-tones/"
   #;"/Users/clements/rsound/rsound/examples/speaking.wav"
   #;"/tmp/simple-singing.wav"))

#;(play input-sound)

;; flange:
(define output-snd 
(signal->rsound
 (- (rs-frames input-sound) 2000)
 (network ()
          [ctr ((simple-ctr 0 1))]
          [offset (sine-wave 1/3)]
          [o1 (+ (rs-ith/left input-sound ctr)
                 (rs-ith/left input-sound
                              (inexact->exact
                               (round (+ ctr (* 2000 offset))))))])))


#;(rs-draw input-sound)

;; hard distortion
#;(define output-snd 
(signal->rsound
 (- (rs-frames input-sound) 80)
 (network ()
          [ctr ((simple-ctr 0 1))]
          [o1 (* 6 (min 0.01 (max -0.01 (rs-ith/left input-sound ctr))))
              ])))

;; bitcrush
#;(define output-snd
  (signal->rsound
 (- (rs-frames input-sound) 80)
 (network ()
          [ctr ((simple-ctr 0 1))]
          [o1 (+ (cond [(< 0.00 (rs-ith/left input-sound ctr)) 0.1]
                       [else 0.0]))
              ])))

(play output-snd)

(rs-draw output-snd)




