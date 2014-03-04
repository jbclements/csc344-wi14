#lang racket

(require rsound)


;; a program is a vector of MEMSIZE instructions

;; an instruction is 
;; (music reg)
;; (load reg num)
;; (add reg reg reg)
;; (incr reg)
;; (decr reg)
;; (branchif0 reg tgt)

;; there are REGS registers.
(define REGS 10)
(define MEMSIZE 50)
;; stop after this many steps
(define MAX-STEPS 100)

;; all registers start at 0
(define init-regs
  (for/hash ([i REGS]) (values i 0)))


(define (next-pc pc)
  (cond [(= pc (sub1 MEMSIZE)) 0]
        [else (add1 pc)]))

;; run the machine, produce a list of beats to take.
(define (interp prog pc regs steps)
  (define (recur pc regs)
    (interp prog pc regs (add1 steps)))
  (cond 
    [(= steps MAX-STEPS)
     empty]
    [else
     (match (vector-ref prog pc)
       [`(music ,src) 
        (cons (hash-ref regs src)
              (recur (next-pc pc) regs))]
       [`(load ,reg ,num)
        (recur (next-pc pc)
          (hash-set regs reg num))]
       [`(add ,src1 ,src2 ,dest)
        (recur (next-pc pc)
          (hash-set regs dest (+ (hash-ref regs src1)
                                 (hash-ref regs src2))))]
       [`(incr ,reg)
        (recur (next-pc pc)
          (hash-set regs reg (+ 1 (hash-ref regs reg))))]
       [`(decr ,reg)
        (recur (next-pc pc)
          (hash-set regs reg (- (hash-ref regs reg) 1)))]
       [`(branchif0 ,reg ,tgt)
        (cond [(= (hash-ref regs reg) 0)
               (recur tgt regs)]
              [else 
               (recur (next-pc pc) regs)])])]))


(define (rand-instr)
  (match (random 6)
    [0 `(music ,(random REGS))]
    [1 `(load ,(random REGS) ,(randint))]
    [2 `(add ,(random REGS) ,(random REGS) ,(random REGS))]
    [3 `(incr ,(random REGS))]
    [4 `(decr ,(random REGS))]
    [5 `(branchif0 ,(random REGS) ,(random MEMSIZE))]))

;; generate a random literal for a load instruction
(define (randint)
  (- (random 100) 50))


(define (rand-prog) (for/vector ([i MEMSIZE]) (rand-instr)))

(rand-prog)


(define (run p)
  (interp p 0 init-regs 0))
(define run-result (run (rand-prog)))
run-result


(define (s sec) (* 44100 sec))
(define START-OFFSET 11335)
(define snd (rs-read/clip "/tmp/live-in-this-city.wav" (+ START-OFFSET (s 0))
                          (+ START-OFFSET (s 120))))
(define beat-samples (* 2 (- 21119 11335)))
(define (b beat) (round (* beat beat-samples)))
(define MEASURE-SAMPLES (* 4 beat-samples))
(define (m measure) (* measure MEASURE-SAMPLES))




;; combine two programs
(define (combine-programs v1 v2)
  (for/vector ([i MEMSIZE])
    (cond [(= 0 (random 2)) (vector-ref v1 i)]
          [else (vector-ref v2 i)])))


;; how much music does it produce?
(define (fitness prog)
  (length (interp prog 0 init-regs 0)))

(define p1 (rand-prog))
(run p1)
(fitness p1)
(define p2 (rand-prog))
(run p2)
(fitness p2)

(random-seed 2342)

(define pool
  (for/list ([i 100])
    (define rp (rand-prog))
    (list rp (fitness rp))))

(define sorted-pool (sort pool
            >
            #:key second))

(take sorted-pool 2)

(define child
  (combine-programs 
   (first (first sorted-pool))
   (first (second sorted-pool))))



(fitness child)


(cond [(empty? run-result)
       "no sounds played!"]
      [else
       (play
        (rs-append*
         (for/list ([i (run child)])
           (define wrapped (modulo i 50))
           (clip snd (b wrapped)
                 (b (add1 wrapped))))))])