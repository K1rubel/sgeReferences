;; counts the number of expansion options for each non-terminal 
;; this is necessary for picking random integers which fill up the gene list
! (register-module! ../SGE)
! (import! &self SGE:expression-helpers)

;; input 1. space variable 2. grammar name


(= (cN $space $g)
    (let $grammar (match $space ($g $x) $x)
        (collapse
            (let $el (superpose $grammar)
                (++n (cdr-atom $el))
            ))))

;; (++n) -- returns the length of an expression

! (bind! &space (new-space))

! (add-atom &space
     (grammar 
         (
             (S (bop expr expr) expr)
             (expr (bop term term))
             (bop AND OR)
             (term x 0.5)
         )
     ))

; ! (let $g (match &space (grammar $x) $x)
;     (superpose $g)
; )
! (cN &space grammar) ;; (2 1 2 2) can be verified against the above grammar 
                      ;; S has two expansiion options
                      ;; expr one
                      ;; bop 2
                      ;; term 2
                      ;; the gene list will be filled taking an integer in the range 0 to N-1, N being the number options for each symbol as calculated above
                      ;; the length of the list is determined by the upper bounds function
                      ;; Example 
                      ;; S -- it is the start symbol and appears only once but it has two options for expansion
                      ;; gene for S -- could be one of these --chosing randomly from the range 0--[2-1] == 0--1 
                      ;; [0 0], [0 1], [1 0], [1 1]