#lang racket

;; Copyright 2014 John Clements (clements@racket-lang.org)
;; released under Mozilla Public License 2.0

;; before running this, you'll need to install osc, using
;; raco pkg install osc


(require racket/udp
         racket/runtime-path
         osc/osc-to-bytes
         osc/osc-defns
         )

(define-runtime-path here ".")

;; this assumes you've started the renoise OSC server, listening on UDP port 8790
(define renoise-socket 8790)
(define receive-socket 13699)

;; create a socket
(define the-socket (udp-open-socket))

;; bind it (probably unnecessary, since we're not planning on receiving)
(udp-bind! the-socket "127.0.0.1" receive-socket)

;; also, we're assuming we won't get any messages longer than 10K
(define receive-buffer (make-bytes 10000 0))

(thread
 (lambda ()
   (let loop ()
     (printf "waiting for incoming messages.\n")
     (define-values (len hostname src-port)
       (udp-receive! the-socket receive-buffer))
     (printf "current seconds: ~v\n" (current-seconds))
     (printf "len: ~v\nhostname: ~v\nsrc-port: ~v\n" len hostname src-port)
     (define received (subbytes receive-buffer 0 len))
     (printf "received buffer: ~v\n" received)
     (loop))))

(define (send-command message)
  (udp-send-to the-socket "127.0.0.1" renoise-socket 
               (osc-element->bytes message)))


(let loop ()
  (printf "hit return to start\n")
  (define r (for/list ([i 20])(+ 50 (random 24))))
  (read-line)
  
  
  ;; start the sine wave:
  (for/list ([start-pitch (append r (list #f #f))]
             [stop-pitch (append (list #f #f) r)])
    (when start-pitch
      (send-command (osc-message #"/renoise/trigger/note_on" `(1 2 ,start-pitch 127))))
    (sleep 3)
    (when stop-pitch
      (send-command (osc-message #"/renoise/trigger/note_off" `(1 2 ,stop-pitch))))
    )
  
  ;; wait, so that the printf winds up below all of the other printout:
  (sleep 0.5)
  (printf "hit return to stop.\n")
  (read-line)

  (loop))






