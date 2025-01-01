
;; get the set of non-terminals form the grammar in a given space

(= (getNtSet $space)
    (let $grammar (match $space (grammar $x) $x)
        (collapse (let $rule (superpose $grammar)
                    (car-atom $rule))
        )))

;; count occurrences of non-terminals in production choices

(= (countNtOccurrences $choice $nt)
    (if (== (get-metatype $choice) Symbol)
        (if (== $choice $nt)
            1
            0
        )
        (if (== $choice ())
        0
        (let* (
            ($first (car-atom $choice))
            ($tail (cdr-atom $choice))
            )
            (if (== $nt $first)
                (+ 1 (countNtOccurrences $tail $nt))
                (countNtOccurrences $tail $nt)
            )))))

;; get production rule of a non-terminal

(= (getProductionRule $grammar $nt)
    (let $production (superpose $grammar)
        (if (== (car-atom $production) $nt)
            (cdr-atom $production)
            (empty)
        )))


;; get elements of $sub that are also members of $main
;; required for filtering of non-terminals that do not contain reference of non-terminals in their production choices

(= (membersOnly $main $sub)
    (collapse (intersection (superpose $main) (superpose $sub)))
)

;; count non-terminal mentions in the each option of the production rule and the non-terminal with the max reference count

(= (countReferences $nt $production)
    (let $ref (collapse 
                    (let $p (superpose $production)
                        (countNtOccurrences $p $nt)
                    )
                )
            ($nt (foldright max $ref))))


;; foldright 

(= (foldright $func $expr) 
    (if (== $expr ())
        ()
        (let* (
            ($head (car-atom $expr))
            ($tail (cdr-atom $expr))
            )
            (if (== $tail ())
                $head
                ($func $head (foldright $func $tail))
            ))))

;; max value return

(= (max $x $y)
    (if (> $x $y)
        $x
        $y))

;; gets multiplicity factor associated with a non-terminal

(= (ntFactor $space $nt )
    (match $space ($nt $x) $x)
    )

;; removes redundant brackets from expressions

(= (cleanExpr $expr)
    (if (== (cdr-atom $expr) ())
        (let $inner (car-atom $expr)
            (cleanExpr $inner)
        )
        $expr))

;; get unique items in the prodcution rule
;; first flattening is necessary to avoid going through nested structures
;; (A B C) -> (A B C), (A (B C)) -> (A B C), (A (B C) (D E)) -> (A B C D E)

(= (flatten $expr $acc) 
    (if (== $expr ())
        $acc
        (let* (
            ($first (car-atom $expr))
            ($tail (cdr-atom $expr))
            )
            (if (== (get-metatype $first) Symbol)
                (let $carry (collapse (union (superpose $acc) $first))
                    (flatten $tail $carry)
                )    
                (let* (
                    ($carry (collapse (union (superpose $acc) (superpose $first))))
                    )
                    (flatten $tail $carry)
                )))))

;; non-deterministic option for flatten 

(= (flatten $expr)
    (collapse (let $el (superpose $expr)
        (if (== (get-metatype $el) Symbol)
            $el
            (superpose $el)
        ))))

;; Return only unique members:-> metta has a perfectly functional unique function to do the same thing

(= (unyque $expr $acc)
    (if (== $expr ())
        $acc
        (let* (
            ($head (car-atom $expr))
            ($tail (cdr-atom $expr))
            ($carry (collapse (union (superpose $acc) $head)))
            )
            (if (== $tail ())
                $carry
                (let $tailWithoutHead (collapse 
                        (let $x (superpose $tail)
                                (if (== $head $x)
                                    ;(superpose ())
                                    (empty)
                                    $x
                                )
                        ))
                    (unyque $tailWithoutHead $carry )
                )))))

(= (unikue $expr)
    (unyque $expr ())
)


;; appends a an element/expression to a parent expression

(= (append $acc $el)
        (collapse (union (superpose $acc) (superpose ($el))))
)

;; counts the number of atoms in an expression

(= (++n $atom)
    (if (== $atom ())
        0
        (+ 1 (++n (cdr-atom $atom)))
    )
)