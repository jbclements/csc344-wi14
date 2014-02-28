#lang racket

(require rsound
         rsound/piano-tones)

(struct note (pitch time duration))
(define (s sec) (* 44100 sec))

(define notes-list)
(define notes
  (let loop ([cur-time (s 2)])
    (cond [(< (s 30) cur-time) empty]
          [else (define dur (random 44100))
                (cons (note (random 128) cur-time dur)
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