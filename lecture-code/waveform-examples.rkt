#lang racket

(require rsound
         rsound/draw
         2htdp/image
         2htdp/universe
         math/array)

(define ps (make-pstream))
(define (psn snd) (pstream-play ps snd))

;; the state of the world is a number

;(define world-box (box #f))
(define (s sec) (* 44100 sec))

(define tones
  (for/list ([i (in-range 69 (+ 69 12))])
    (define pitch (midi-note-num->pitch i))
    (signal->rsound (s 0.5) 
                    (network ()
                             [a (square-wave pitch)]
                             [out (* 0.1 a)]))))

(define picture-square-tone
  (signal->rsound
   2048
   (indexed-signal 
    (lambda (f)
      (cond [(< 64 (modulo f 128)) 0.1]
            [else -0.1])))))

(define picture-triangular-tone
  (signal->rsound
   2048
   (indexed-signal 
    (lambda (f)
      (define a (modulo (- f 64) 128))
      (* 1/128 (- (cond [(< a 64) a]
                        [else (- 128 a)])
                  32))))))

(define picture-sawtooth-tone
  (signal->rsound
   2048
   (indexed-signal 
    (lambda (f)
      (define a (modulo f 128))
      (* 1/2 (* 1/128 (- a 64)))))))

(define picture-tone picture-sawtooth-tone)


(define tone1 (times 10 picture-tone))
(define tone2 (times 10 picture-triangular-tone))

(rs-draw picture-tone)

(define (diff-stats s1 s2)
  (define diffs
    (for/list ([i 2048])
      (abs (- (rs-ith/left s1 i)
              (rs-ith/left s2 i)))))
  (display (take 
            (sort
             diffs
             >)
            10))
  (newline)
  (display
   (~a "number of nonzero diffs: "
       (length (filter (lambda (d) (not (= d 0.0))) diffs))
       " / 2048\n")))


(define round-trip-tone
  (signal->rsound 
   (rs-frames picture-tone)
   (indexed-signal (lambda (t) (rs-ith/left picture-tone t)))))

(diff-stats picture-tone round-trip-tone)

(rsound/left-1-fft-draw picture-tone)

(define vec-as-array (build-array (vector (rs-frames picture-tone))
                                  (lambda (i) (rs-ith/left picture-tone (vector-ref i 0)))))
(define the-fft (array-fft vec-as-array))

(define the-inverse (array-inverse-fft the-fft))

(array-ref vec-as-array '#(14))
(array-ref the-inverse '#(14))
(equal? vec-as-array the-inverse)

(define with-indexes
  (for/list ([val (in-array the-fft)]
             [i (in-naturals)])
    (list i val)))
(define sorted-with-indexes
  (sort with-indexes
        #:key (lambda (x) (magnitude (second x)))
        >))

;; convert an array of numbers in -1<v<1 to a sound
(define (array->rsound array)
  (unless (= 1 (array-dims array))
    (error 'freak-out))
  (signal->rsound
   (array-size array)
  (indexed-signal (lambda (t)
                    (define samp (array-ref array (vector t)))
                    (unless (< (imag-part samp) 1e-4)
                      (error 'too-imaginary!))
                    (real-part samp)))))

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
    ["9" (draw-and-reset-sound 2048)]
    [";" (begin (psn (times 10 picture-square-tone)) w)]
    ["q" (begin (psn (times 10 picture-triangular-tone)) w)]
    ["j" (begin (psn (times 10 picture-sawtooth-tone)) w)]))

(big-bang (draw-and-reset-sound 2)
          [to-draw world-draw]
          [on-key handle-key])