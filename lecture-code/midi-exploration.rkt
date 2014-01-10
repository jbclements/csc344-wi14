#lang racket

;; midi-example

(require midi-readwrite)

(with-output-to-file "/tmp/get-lucky-expanded.txt"
  (lambda ()
    (pretty-print 
     (midi-file-parse "/tmp/get-lucky.mid"))))