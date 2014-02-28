#lang racket

(require rsound 
         rsound/draw
         rackunit)

(define simple-model
  (hash 1 (list (list 1.0 (list 1 2)))
        2 (list (list 1.0 (list 2 1)))))

(define (run-model m state)
  (define next-state-info (hash-ref m state))
  (define choice (random))
  (let loop ([remaining next-state-info])
    (cond [(empty? remaining)
           (error 'run-model "internal error 1")]
          [else
           (cond [(< choice (first (first remaining)))
                  (second (first remaining))]
                 [else (loop (rest remaining))])])))

(check-equal? (run-model simple-model 1) '(1 2))
(check-equal? (run-model simple-model 2) '(2 1))
#|
(define (s sec) (* 44100 sec))
(define snd (rs-read/clip "/tmp/live-in-this-city.wav" (s 0) (s 20)))
(define beat-samples (* 2 (- 21119 11335)))
(define MEASURE-SAMPLES (* 4 beat-samples))
(define START-OFFSET 11335)
(define (m measure) (+ START-OFFSET (* measure MEASURE-SAMPLES)))
(define quiet-ding (rs-scale 0.5 ding))
#;(play
 (rs-overlay
  (assemble
   (for/list ([i 28])
     (list quiet-ding (+ 11335 (* beat-samples i)))))
  (rs-scale 0.5 snd)))
(rs-draw snd)

(/ 60 (/ (* 2 (- 21119 11335)) 44100))

(define LIMIT 100)

(define (output->sample output)
  (clip snd 
        (m output)
        (m (add1 output))))


(define (construct-music)
  (let loop ([i 0][state 1])
    (cond [(= i LIMIT) empty]
          [else (match (run-model simple-model state)
                  [(list output next-state)
                   (cons (list (output->sample output) (m i))
                         (loop (add1 i) next-state))])])))

(play (assemble (construct-music)))
|#