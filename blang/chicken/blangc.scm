;;(load "blangc.scm")
(require-extension lalr-driver)
(require-extension fmt)
(require-extension srfi-69)

(require-extension chili)

(cond-expand
 (compiling (declare (uses grammar-out)))
 (else (load "grammar-out.scm")))


(define (my-make-token sym val)
  (make-lexical-token sym 0 val))
(define (simple-token sym)
  (my-make-token sym sym))


(cond-expand
 (compiling (declare (uses lex-out)))
 (else (include "lex-out.scm")))


(define variables (make-hash-table))
(define (get-var varname)
  (hash-table-ref/default variables varname 0))
(define (set-var varname value)
  (hash-table-set! variables varname value))
  
(define (prlist x)
  (do-list i x (fmt #t i))  
  (newline))
;; (prlist '(10 11))

(define (just x)
  (prlist x))


(define (go)
  (lexer-init 'port (open-input-file "assign.txt"))
  ;;(lexer-init 'string "JUST 14+12+5;")
  (define syntax-tree (blang-parser lexer print))
  (displayln "Made it this far")
  (pretty-print syntax-tree)
  (eval syntax-tree)
  #t)
(go)


