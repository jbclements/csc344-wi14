#lang racket

(require plot)

(define i (sqrt -1))

(define (mag->db m)
  (* 10 (/ (log (max 1e-10 m)) (log 10))))


(define (fun z)
  (* (- z -1/2) (+ (* z z) (* -2 (cos (/ pi 4)) z) 1))
  
  #;(* (- z (exp (* i (/ pi 4))))
     (- z (exp (- (* i (/ pi 4)))))
     #;(- z -3/4)
     (- z (* 3/4 (exp (* i (/ (* 3 pi) 4)))))
     (- z (* 3/4 (exp (- (* i (/ (* 3 pi) 4))))))))

(plot3d (list (surface3d (λ (x y) (magnitude (fun (+ x (* y i))))) -1 1 -1 1
                           #:label "magnitude")
              (parametric3d (lambda (theta)
                              (list (cos theta)
                                    (sin theta)
                                    (magnitude (fun (exp (* i theta))))))
                            0 
                            (* 2 pi))))

(plot (function (lambda (theta) (mag->db (magnitude (fun (exp (* i theta)))))))
      #:x-min 0
      #:x-max (* 2 pi))

(define (fun2 z)
  (* (- z (exp (* i (/ pi 8))))
     (- z (exp (- (* i (/ pi 8)))))))

(plot (function (lambda (theta) (mag->db (magnitude (fun2 (exp (* i theta)))))))
      #:x-min 0
      #:x-max (* 2 pi))

