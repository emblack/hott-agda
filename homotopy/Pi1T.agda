{-# OPTIONS --type-in-type --without-K #-}

open import lib.Prelude 
open Paths
open T
open Int

module homotopy.Pi1T where

  U = Set

  C : T -> U
  C = T-rec (Int × Int) (ap (λ x → x × Int) (ua succEquiv)) (ap (λ y → Int × y) (ua succEquiv)) {!!}

{-
  subst-C-loop : subst C loop ≃ succ
  subst-C-loop = 
    subst C loop                  ≃〈 subst-resp C loop 〉
    subst (λ x → x) (resp C loop) ≃〈 resp (subst (λ x → x)) (βloop/rec Int succ≃) 〉 
    subst (λ x → x) succ≃         ≃〈 subst-univ _ 〉 
    succ ∎

  subst-C-!loop : subst C (! loop) ≃ pred
  subst-C-!loop = 
    subst C (! loop)                  ≃〈 subst-resp C (! loop) 〉
    subst (λ x → x) (resp C (! loop)) ≃〈 resp (subst (λ x → x)) (resp-! C loop)〉
    subst (λ x → x) (! (resp C loop)) ≃〈 resp (λ y → subst (λ x → x) (! y)) (βloop/rec Int succ≃) 〉
    subst (λ x → x) (! succ≃)         ≃〈 resp (subst (λ x → x)) succ≃-! 〉
    subst (λ x → x) pred≃             ≃〈 subst-univ _ 〉 
    pred ∎
-}

  _^_ : (base ≃ base) -> Int -> base ≃ base
  α ^ Zero = id
  α ^ (Pos One) = α
  α ^ (Pos (S n)) = α ∘ (α ^ (Pos n))
  α ^ (Neg One) = ! α
  α ^ (Neg (S n)) = ! α ∘ (α ^ (Neg n))

  decode' : (Int × Int) -> base ≃ base
  decode' (m , n) = (loop₁ ^ m) ∘ (loop₂ ^ n)

  encode : {x : T} ->  base ≃ x  ->  C x
  encode p = transport C p (Zero , Zero)

  encode-loop^ : (p : Int × Int) -> encode (decode' p) ≃ p
  encode-loop^ (m , n) = {!!} ∘ ap≃ (transport-∘ C (loop₁ ^ m) (loop₂ ^ n)) {Zero , Zero}

  -- stuck : {p : base ≃ base} -> p ≃ loop^ (encode p)
  -- stuck = {!!} -- no way to use J directly; need to generalize

{-
  shift : (n : Int) -> (loop ∘ (loop^ (pred n))) ≃ loop^ n
  shift (Pos Z) = Refl
  shift (Pos (S y)) = Refl
  shift Zero = !-inv-r loop
  shift (Neg Z) = 
    ∘-unit-l _ ∘
    resp (\ x → x ∘ ! loop) (!-inv-r loop) 
    ∘ ∘-assoc loop (! loop) (! loop) 
  shift (Neg (S y)) = 
    loop ∘ ! loop ∘ ! loop ∘ loop^ (Neg y)    ≃〈 ∘-assoc loop (! loop) (! loop ∘ loop^ (Neg y)) 〉
    (loop ∘ ! loop) ∘ ! loop ∘ loop^ (Neg y)  ≃〈 resp (λ x → x ∘ ! loop ∘ loop^ (Neg y)) (!-inv-r loop) 〉
    Refl ∘ ! loop ∘ loop^ (Neg y)             ≃〈 ∘-unit-l _ 〉
    (! loop ∘ loop^ (Neg y) ∎) 
-}

  decode : {x : T} -> C x -> base ≃ x
  decode {a} = 
    T-elim {\ x -> C x -> base ≃ x} 
            decode'
            c1
            c2
            {!!}
            a where 
    postulate 
      c1 : _
      c2 : _

  decode-encode : ∀ {a} -> (p : base ≃ a) -> decode (encode p) ≃ p
  decode-encode {a} p = 
    path-induction (λ a' (p' : base ≃ a') → decode (encode p') ≃ p') id p

{-
  theorem : Id base base ≃ Int
  theorem = ua (isoToAdj (encode , isiso decode encode-loop^ decode-encode))
-}



