#lang racket

(require rsound 
         rsound/draw
         rackunit)

;; output contains deflection and duration

;; a simple markov model : a hash from states to (listof (list probability (list (list deflection duration) next-state)))
(define simple-model
  (hash 'a (list (list 0.2 (list (list 0 1) 'b))
                 (list 0.2 (list (list 0 1/2) 'hb1))
                 (list 0.1 (list (list 4/5 1/5) 'rev2))
                 (list 0.1 (list (list 'reverse 1) 'a))
                (list 0.4 (list (list 0 1) 'a)))
        'b (list (list 1.0 (list (list -1 1) 'a)))
        'hb1 (list (list 1.0 (list (list -1/2 1/2) 'a)))
        'rev2 (list (list 1.0 (list (list 2/5 1/5) 'rev3)))
        'rev3 (list (list 1.0 (list (list 0/5 1/5) 'rev4)))
        'rev4 (list (list 1.0 (list (list -2/5 1/5) 'rev5)))
        'rev5 (list (list 1.0 (list (list -4/5 1/5) 'a)))))

;; choose the next state of the model, return the new state & output
(define (run-model m state)
  (define next-state-info (hash-ref m state))
  (define choice (random))
  (let loop ([remaining next-state-info] [choice choice])
    (cond [(empty? remaining)
           (error 'run-model "internal error 1")]
          [else
           (cond [(< choice (first (first remaining)))
                  (second (first remaining))]
                 [else (loop (rest remaining)
                             (- choice (first (first remaining))))])])))


;; MUSIC PART
(define (s sec) (* 44100 sec))
;; the point at which the first beat of this song starts:
(define START-OFFSET 11335)
;; the clip of the sound:
(define snd (rs-read/clip "/tmp/live-in-this-city.wav" (+ START-OFFSET (s 0))
                          (+ START-OFFSET (s 120))))
;; the (observed) length of one beat
(define beat-samples (* 2 (- 21119 11335)))
;; convenience function for beat points
(define (b beat) (round (* beat beat-samples)))

;; overlaying a ding to see if we got the beat right (commented out)
#;(define quiet-ding (rs-scale 0.5 ding))
#;(play
 (rs-overlay
  (assemble
   (for/list ([i 28])
     (list quiet-ding (+ 11335 (* beat-samples i)))))
  (rs-scale 0.5 snd)))
#;(rs-draw snd)

;; How many beats of music to generate?
(define LIMIT 250)

;; construct a piece of music, using the model.
;; the input and output playhead are the same; they're locked in sync
;; produce a list of (list sound frame-offset)
(define (construct-music)
  (let loop ([i 0][state 'a][playhead 0])
    (cond [(= i LIMIT) empty]
          [else (match (run-model simple-model state)
                  [(list (list deflection duration) next-state)
                   (cons (list (output->sample playhead deflection duration)
                               (b i))
                         (loop (+ i duration)
                               next-state
                               (+ playhead duration)))])])))

;; given playhead, deflection, and duration *in beats*, produce sound
(define (output->sample playhead deflection duration)
  (cond [(eq? deflection 'reverse)
         (rearrange (b duration)
                    (lambda (t) (round (- (b duration) (/ t 2))))
                    (clip snd 
                          (b playhead)
                          (b (+ playhead duration))))]
        [else
         (clip snd 
               (b (+ playhead deflection))
               (b (+ playhead deflection duration)))]))


(define output (assemble (construct-music)))
(rs-write output "/tmp/live-in-this-city-2.wav")
(play output)
