! (register-module! ../SGE)
! (import! &self SGE:expression-helpers)

;; the main function -- retrieves the maximum number of non-terminal references in each non-terminals production choices

(: getReferences (-> hyperon::space::DynSpace Expression))
(= (getReferences $space)
     (collapse (let* (
            
                ($ntSet (getNtSet $space))
                ($nt (superpose $ntSet))
                ($grammar (match $space (grammar $x) $x))
                ($production (getProductionRule $grammar $nt))
                ($flat (flatten $production)) 
                )
        ;; non-terminals that do not contain non-terminals in their prodcution rule are not cosidered. Why would they?
        (if (== (membersOnly $ntSet $flat) ()) 
            (empty)
            (let* (
                ;; return unique symbols from the priduction options
                ($uniq (unique $flat))

                ;; remove symbols which are not member of the non-terminal set
                ($ntMembers (membersOnly $ntSet $uniq)) 
                )
                ($nt (collapse (let $el (superpose $ntMembers)
                        (countReferences $el $production))
            )))))))
            

;; example grammar max-reference count ((S ((expr 2) (op 1))) (expr ((term 2) (op 1))))

! (bind! &space_ (new-space))
! (bind! &space__ (new-space))

; add grammar to &space

! (add-atom &space_ (grammar
        (
            (S expr)
            (expr (bop expr expr) (uop expr) term)
            (bop AND OR)
            (uop NOT)
            (term A B C D)
        )))
! (add-atom &space__
     (grammar 
         (
             (S (bop expr expr) expr)
             (expr (bop term term))
             (bop AND OR)
             (term x 0.5)
         )
     ))
! (getReferences &space_) ;; ((S ((expr 1))) (expr ((expr 2) (bop 1) (uop 1) (term 1)))) ;; this contains recursive references to non-terminals, wouldn't work well with the reference upper bound calculator
! (getReferences &space__) ;; ((S ((expr 2) (bop 1))) (expr ((bop 1) (term 2))))