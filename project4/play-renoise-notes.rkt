#lang racket

;; Copyright 2014 John Clements (clements@racket-lang.org)
;; released under Mozilla Public License 2.0

;; before running this, you'll need to install osc, using
;; raco pkg install osc


(require racket/udp
         racket/runtime-path
         osc/osc-to-bytes
         osc/osc-defns)

(define-runtime-path here ".")

;; this assumes you've started the renoise OSC server, 
;; listening on UDP port 8790
(define renoise-socket 8790)

;; create a socket
(define the-socket (udp-open-socket))

;; send a command to renoise
(define (send-command message)
  (udp-send-to the-socket "127.0.0.1" renoise-socket 
               (osc-element->bytes message)))


(let loop ()
  (printf "hit return to start.\n")
  
  ;; a list of random midi notes in the range 20-74
  (define r (for/list ([i 20])(+ 50 (random 24))))
  (read-line)
  
  ;; event loop. Every three seconds, start and stop notes. Each
  ;; note is stopped three cycles after it starts.
  (for/list ([start-pitch (append r (list #f #f))]
             [stop-pitch (append (list #f #f) r)])
    ;; maybe start a pitch
    (when start-pitch
      (send-command (osc-message #"/renoise/trigger/note_on" `(1 2 ,start-pitch 127))))
    (sleep 3)
    ;; maybe stop a pitch
    (when stop-pitch
      (send-command (osc-message #"/renoise/trigger/note_off" `(1 2 ,stop-pitch))))
    )
  
  (loop))







