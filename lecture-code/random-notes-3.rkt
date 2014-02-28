#lang racket

(require rsound
         rsound/piano-tones
         math/distributions)

(struct note (pitch time duration))
(define (s sec) (round (* 44100 sec)))
(define tempo 128)
(define qtr (s (/ 60 tempo)))
(define eighth (round (/ qtr 2)))
(define sixteenth (round (/ eighth 2)))

(define len-dis
  (discrete-dist (list qtr eighth sixteenth)
                 (list 1 1 10)))
(define bass-len-dis
  (discrete-dist (list qtr eighth)))
(define note-dis 
  (discrete-dist (for/list ([i 24]) (+ 50 i))
                 '(0 0 0 0 0 0 0 0 0 0 0 0
                   9 0 1 0 1 1 0 9 0 0 0 0
                   )))
(define bass-note-dis 
  (discrete-dist (for/list ([i 24]) (+ 26 i))
                 '(1 0 0 0 0 0 0 1 0 0 0 0
                   1 0 0 0 0 0 0 1 0 0 0 0
                   )))

(define notes
  (sort
   (append
    (let loop ([cur-time (s 2)])
      (cond [(< (s 30) cur-time) empty]
            [else (define dur (sample len-dis))
                  (cons (note (sample note-dis) cur-time dur)
                        (loop (+ cur-time dur)))]))
    (let loop ([cur-time (s 2)])
      (cond [(< (s 30) cur-time) empty]
            [else (define dur (sample bass-len-dis))
                  (cons (note (sample bass-note-dis) cur-time dur)
                        (loop (+ cur-time dur)))])))
   <
   #:key note-time))

(define ps (make-pstream))

;; play the notes in a list
;; list-of-notes -> pstream
(define (play-notes lon)
  (cond [(empty? lon) ps]
        [else
         (play-note (first lon)) 
         (play-notes (rest lon))]))


;; play a single note
;; note -> pstream
(define (play-note n)
  (pstream-queue
   ps
   (let ([snd (piano-tone (note-pitch n))])
   (clip snd
         0 (min (rs-frames snd) (note-duration n))))
   (note-time n)))

(play-notes notes)
(sleep 30)