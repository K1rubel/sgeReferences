;; a function to return the upper bound for the number of expansions of each non-terminal in a given max non-terminal references list
;; To apply the rule the grammar should fist be expanded fully .. insert intermediate symbols where there is recurssion .. referal of a non-terminal by itself
;; In short no referal of a non-terminal by itself are allowed 

! (bind! &space (new-space))

(= (upperBound $space $reference)
    (if (== $reference ())
        (add-atom $space (S 1))
        (let* (
            ($h (car-atom $reference))
            ($t (cdr-atom $reference))
            ($nt (car-atom $h))
            ($rules (cleanExpr (cdr-atom $h)))
            )
            (if (== $nt S)
                (let () (addAtom $space $rules)
                    (upperBound $space $t)
                )
                (let* (
                    ($ntFactor (match $space ($nt $x) $x))
                    (() (addAtoms $space $rules $ntFactor))
                    )
                    (upperBound $space $t)
                )
            ))))

;; Removes the extra pair of () added to expressions as a result of the (cdr-atom) operation

(= (cleanExpr $expr)
    (if (== (cdr-atom $expr) ())
        (car-atom $expr)
        $expr))

;; a function to return count of a rule in space -- needed to offset issue with match that if there is no match it returns []
;; and this cannot be worked with

(= (getCount $space $nt)
    (collapse (match $space ($nt $x) $x))
)

;; adds (NT count) recursively to space when the parent terminal is S, the start symbols , i.e. no previous symbols of the grammar could have been added to the space prior to this.

(= (addAtom $space $rules)
    (if (== $rules ())
        ()
        (let* (($h (car-atom $rules))
                ($t (cdr-atom $rules))
                (() (add-atom $space $h))
                )
                (addAtom $space $t))))
;; updates the space based on presence/absence of a (NT count) in the space accounting for parent mulitiplicity and pre-exsting NT referal a given space

(= (addAtoms $space $rules $factor)
    (if (== $rules ())
        ()
        (let* (
            ($h (car-atom $rules))
            ($t (cdr-atom $rules))
            ($a (car-atom $h))
            ($c (cdr-atom $h))
            ($n (car-atom $c))
            ($m (* $factor $n))
            ($v (getCount $space $a))
            )
            (if (== $v ())
                (let* (
                    ($new (cons-atom $a ($m)))
                    (() (add-atom $space $new))
                    )
                    (addAtoms $space $t $factor)
                )
                (let* (
                    ($p (+ (car-atom $v) $m))
                    ($new (cons-atom $a ($p)))
                    (() (remove-atom $space $h))
                    (() (add-atom $space $new))
                    )
                    (addAtoms $space $t $factor)
                )))))

! (get-atoms &space) ;; returns empty query result

; ! (upperBound &space ((S ((expr 1))) (expr ((expr 2) (bop 1) (uop 1) (term 1))))) ;; this contains recursive reference so wont work with the function

! (upperBound &space ((S ((expr 2) (op 1))) (expr ((term 2) (op 1)))))

;; to see if we have added to the space defined above
! (get-atoms &space) ;; in &space we get this-> (expr 2), (op 3), (term 4), (S 1). The number represent the upper bound of expansion of the corresponding terminal