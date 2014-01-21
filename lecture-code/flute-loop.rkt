#lang racket

(require rsound
         rsound/draw
         #;2htdp/image
         #;2htdp/universe
         math/array)

(define flute-tone (rs-read "/tmp/e4v.wav"))

(define shortened (resample/interp (/ 9000 8192) flute-tone))



;(play shortened)
;(play flute-tone)

(rs-draw shortened)

(define (wrapped-clip snd from to overlap)
  (define half-overlap (round (/ overlap 2)))
  (define intro (clip snd (- from half-overlap) (+ from half-overlap)))
  (define body (clip snd (+ from half-overlap) (- to half-overlap)))
  (define outro (clip snd (- to half-overlap) (+ to half-overlap)))
  (define mixy (signals->rsound
                overlap
                (indexed-signal
                 (lambda (f) (+ (* (rs-ith/left intro f) (/ f overlap))
                                (* (rs-ith/left outro f) (- 1 (/ f overlap))))))
                (indexed-signal
                 (lambda (f) (+ (* (rs-ith/right intro f) (/ f overlap))
                                (* (rs-ith/right outro f) (- 1 (/ f overlap))))))))
  (rs-append mixy body)
  )

(define loop-start 45000 #;(round (* 50000 8192/9000)))

(define loopy (wrapped-clip shortened loop-start (+ loop-start 8192) 3000))

#;(play (times 50 loopy))

(rs-draw (times 4 loopy))

(define picture-tone loopy)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(rsound/left-1-fft-draw picture-tone)

(define vec-as-array (build-array (vector (rs-frames picture-tone))
                                  (lambda (i) (rs-ith/left/s16 picture-tone (vector-ref i 0)))))
(define the-fft (array-fft vec-as-array))

(define the-inverse (array-inverse-fft the-fft))

(define with-indexes
  (for/list ([val (in-array the-fft)]
             [i (in-naturals)])
    (list i val)))
(define sorted-with-indexes
  (sort with-indexes
        #:key (lambda (x) (magnitude (second x)))
        >))

;; convert an array of numbers in -32767<v<32767 to a sound
(define (array->rsound array)
  (unless (= 1 (array-dims array))
    (error 'freak-out))
  (signal->rsound
   (array-size array)
  (indexed-signal (lambda (t)
                    (define samp (array-ref array (vector t)))
                    (unless (< (imag-part samp) 1e-4)
                      (error 'too-imaginary!))
                    (/ (truncate (real-part samp)) 32767.0)))))

(define (sound-with-first-n n)
  (define chosen-indexes (take sorted-with-indexes 
                               n))
  
  
  (array->rsound
   (array-inverse-fft
    (build-array (vector (rs-frames picture-tone))
                 (lambda (idxs)
                   (match (dict-ref chosen-indexes (vector-ref idxs 0) #f)
                     [#f 0.0]
                     [(list v) v]))))))

#;(equal? picture-tone 
        (array->rsound
         (array-inverse-fft
          (build-array (vector (rs-frames picture-tone))
                       (lambda (idxs)
                         (match (dict-ref chosen-indexes (vector-ref idxs 0) #f)
                           [#f 0.0]
                           [(list v) v]))))))

(define resynthesized-tone #f)

(define (draw-and-reset-sound n)
  (define snd (sound-with-first-n n))
  (rs-draw snd)
  (set! resynthesized-tone snd)
  (set! tone2 (times 10 snd))
  n)

(draw-and-reset-sound 2048)

(define (world-draw w)
  (overlay
   (text (~a w) 30 "black")
   (rectangle 400 200 "solid" "lightgray")))



;; world key-event -> world
(define (handle-key w e)
  (match e
    ["'" (begin (psn tone1) w)]
    ["," (begin (psn tone2) w)]
    ["1" (draw-and-reset-sound 2)]
    ["2" (draw-and-reset-sound 4)]
    ["3" (draw-and-reset-sound 6)]
    ["4" (draw-and-reset-sound 8)]
    ["5" (draw-and-reset-sound 10)]
    ["6" (draw-and-reset-sound 12)]
    ["7" (draw-and-reset-sound 14)]
    ["8" (draw-and-reset-sound 16)]
    ["9" (draw-and-reset-sound 2048)]))

#;(big-bang (draw-and-reset-sound 2)
          [to-draw world-draw]
          [on-key handle-key])

