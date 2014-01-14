#lang racket

(require rsound
         rsound/piano-tones)

;; make a pstream for playing
(define ps (make-pstream))

;; queue the given sound on pstream ps at the given time:
(define (psq snd time) (pstream-queue ps snd time))

;; convert seconds to frames:
(define (s sec) (* 44100 sec))

;; make a tone:
(define (tone-maker pitch)
  (make-tone pitch 0.2 (s 4))
  #;(piano-tone (pitch->midi-note-num pitch)))



(define now (+ (s 1) (pstream-current-frame ps)))
(define base-note 330)
#;(
(psq (tone-maker base-note) now)
(psq (tone-maker (* base-note (expt 2 4/12))) now)
(psq (tone-maker (* base-note (expt 2 7/12))) now)
(psq (tone-maker (* base-note 2)) now)

(psq (tone-maker base-note) (+ (s 4) now))
(psq (tone-maker (* base-note 5/4)) (+ (s 4)now))
(psq (tone-maker (* base-note 3/2)) (+ (s 4)now))
(psq (tone-maker (* base-note 2)) (+ (s 4) now)))



#;(define equal-intervals 7)
#;(for ([i (add1 equal-intervals)])
  (psq (tone-maker (* 440 (expt 2 (/ i equal-intervals)))) (+ now (s (* i 1/2)))))



#;(argmin (lambda (n) (abs (- n ))))

(define equal-tempered-notes
  (for/list ([i 30])
    (* base-note (expt 2 (/ i 12)))))

(define just-tuning-1-octave
  (list 1 16/15 9/8 (* 9/8 16/15) 5/4 4/3 (* 4/3 16/15)
        3/2 (* 3/2 16/15) 5/3 (* 5/3 16/15) 15/8 2))
(define just-tuning-notes
  (map
   (lambda (x) (* x base-note))
   (append just-tuning-1-octave
           (rest (map (lambda (x) (* x 2)) just-tuning-1-octave))
           (rest (map (lambda (x) (* x 4)) just-tuning-1-octave)))))

just-tuning-notes

(define diatonic-scale-notes (list 0 2 4 5 7 9 11 12))
(define major-chord-notes (list 0 4 7 11 14))

(define (showcase scale-notes)
  (rs-append*
   (list
    (assemble
     (for/list ([i (in-naturals)]
                [n diatonic-scale-notes])
       (list (piano-tone (pitch->midi-note-num 
                          (list-ref scale-notes n))) 
             (s (* 1/2 i)))))
    (assemble
     (for/list ([i (in-naturals)]
                [n (reverse diatonic-scale-notes)])
       (list (piano-tone (pitch->midi-note-num 
                          (list-ref scale-notes n))) 
             (s (* 1/2 i)))))
    (assemble
     (for/list ([i (in-naturals)]
                [n major-chord-notes])
       (list (piano-tone (pitch->midi-note-num 
                          (list-ref scale-notes n))) 
             (s (* 1/2 i)))))
    (assemble
     (for/list ([i (in-naturals)]
                [n major-chord-notes])
       (list (piano-tone (pitch->midi-note-num 
                          (list-ref scale-notes n))) 
             (s 0))))
    (silence (s 2))
    )))


(define snd (showcase (drop #;equal-tempered-notes just-tuning-notes 0)))

(play snd)



