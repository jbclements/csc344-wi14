#lang racket

(require rsound
         rsound/piano-tones
         math/distributions)

(struct note (pitch time duration))
(define (s sec) (round (* 44100 sec)))
(define tempo 128)
(define qtr (s (/ 60 tempo)))
(define eighth (round (/ qtr 2)))

(define len-dis
  (discrete-dist (list qtr eighth)))
(define note-dis 
  (discrete-dist (for/list ([i 24]) (+ 50 i))))

(define notes
  (let loop ([cur-time (s 2)])
    (cond [(< (s 30) cur-time) empty]
          [else (define dur (sample len-dis))
                (cons (note (sample note-dis) cur-time dur)
                      (loop (+ cur-time dur)))])))

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