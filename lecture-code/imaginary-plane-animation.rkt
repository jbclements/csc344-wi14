#lang racket

(require 2htdp/image
         2htdp/universe)

;; a world is a natural number

(define WIDTH 400)
(define HEIGHT 400)
(define RADIUS 60)
(define CENTERX (/ WIDTH 2))
(define CENTERY (/ HEIGHT 2))


(define (make-oscillator freq)
  (lambda (t)
    (exp (* 2 pi freq t i 1/20))))

(define (my-sig t)
  (+ (* 0.2 (sin (* 2 pi t 1/20)))
     (* 0.1 (cos (* 2 pi (+ 4 (* 3 t)) 1/20)))
     ))

(define (overlay-signal scene signal-val pen)
  (scene+line
   scene
   CENTERX CENTERY 
   (+ CENTERX (* RADIUS (real-part signal-val)))
   (- CENTERY (* RADIUS (imag-part signal-val)))
   pen))

(define pens
  (list 
   (make-pen "green" 10 "solid" "round" "round")
   (make-pen "blue" 10 "solid" "round" "round")
   (make-pen "gray" 10 "solid" "round" "round")))

(define BASE-SCENE 
  (overlay (circle RADIUS "outline" "red")
             (empty-scene WIDTH HEIGHT)))

(define f1 (make-oscillator 2))
(define f2 (make-oscillator -2))
(define (f3 t) 
  (for/sum ([i t])
    (* (f1 i) (f2 i))))

(define (time->scene t)
  (define a (f1 t))
  (define b (f2 t))
  (define sum-of-products (f3 t))
  #;(define product (* a b))
  (define signals (list a b sum-of-products))
  (for/fold ([scene BASE-SCENE])
    ([sig signals] [pen pens])
    (overlay-signal
     scene
     sig
     pen)))

(define i (sqrt -1))

(big-bang 0
 [on-tick add1 1/2]
 [to-draw time->scene])
