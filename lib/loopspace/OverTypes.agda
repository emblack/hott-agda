
{-# OPTIONS --type-in-type --without-K #-}

open import lib.First
open import lib.Paths
open Paths
open import lib.Functions
open import lib.Int
open Int
open import lib.AdjointEquiv
open import lib.Univalence
open import lib.Truncations
open Truncation
open import lib.WrappedPath
open import lib.TypeEquivalence

open import lib.loopspace.Basics
open import lib.loopspace.Groupoid
open import lib.loopspace.Types
open import lib.loopspace.Truncation

module lib.loopspace.OverTypes where

{- not needed right now but possibly good stuff; don't delete

  module LoopOver-idloop where

   mutual
    deover : (n : Positive) {A : Type} {a : A} {B : A → Type} {b : B a}
           ->  LoopOver n (id^ n) B b → Loop n (B a) b
    deover One lo = lo
    deover (S n) {B = B} {b = b} lo = adjust (deover-id n B b) (ap (deover n) lo)

    deover-id : (n : Positive) {A : Type} {a : A} (B : A → Type) (b : B a)
              -> deover n (idOver n B b) ≃ id^ n
    deover-id One B b = id
    deover-id (S n) B b = !-inv-with-middle-r (deover-id n B b) id

   mutual
    over : (n : Positive) {A : Type} {a : A} {B : A → Type} {b : B a}
           -> Loop n (B a) b → LoopOver n (id^ n) B b 
    over One lo = lo
    over (S n) {B = B} {b = b} lo = adjust (over-id n B b) (ap (over n) lo)

    over-id : (n : Positive) {A : Type} {a : A} (B : A → Type) (b : B a)
              -> over n (id^ n) ≃ idOver n B b
    over-id One B b = id
    over-id (S n) B b = !-inv-with-middle-r (over-id n B b) id

   path : (n : Positive) {A : Type} {a : A} (B : A → Type) (b : B a) 
                  ->  Loop n (B a) b ≃ LoopOver n (id^ n) B b 
   path n B b = ua (improve (hequiv (over n) (deover n) {!!} {!!}))

  open LoopOver-idloop using (deover; over) 



  mutual
    -- more computational version of transport at LoopOver n - B b
    rebaseOver : (n : Positive) {A : Type} {a : A} {α α' : Loop n A a}
               → (B : A -> Type) (b : B a)
               → (p : Path α α') -> LoopOver n α B b -> LoopOver n α' B b
    rebaseOver One B b p l = l ∘ ! (ap (λ x → transport B x b) p)
    rebaseOver (S n) {α = α} {α' = α'} B b p l = 
       l
     ∘ ! (transport-LoopOver n α (idOver n B b))
     ∘ (! (ap (\ x -> rebaseOver n B b x (idOver n B b)) p))
     ∘ transport-LoopOver n α' (idOver n B b) 
      {- so you can see what's going on:
      transport (λ x → LoopOver n x B b) α' (idOver n B b) ≃〈 transport-LoopOver n α' (idOver n B b) 〉
      rebaseOver n α' (idOver n B b) ≃〈 (! (ap (\ x -> rebaseOver n x (idOver n B b)) p)) 〉
      rebaseOver n α  (idOver n B b) ≃〈 ! (transport-LoopOver n α (idOver n B b)) 〉
      transport (\ x -> LoopOver n x B b) α  (idOver n B b) ≃〈 l 〉
      (idOver n B b ∎)
      -}

    rebaseOver-idpath : (n : Positive) {A : Type} {a : A} {α : Loop n A a}
               → {B : A -> Type} {b : B a} (l : LoopOver n α B b)
               -> rebaseOver n B b id l ≃ l
    rebaseOver-idpath One l = id
    rebaseOver-idpath (S n) {α = α} {B = B} {b = b} l = 
      ap (λ x → l ∘ x) (!-inv-with-middle-l (transport-LoopOver n α (idOver n B b)) id)

    transport-LoopOver : (n : Positive) {A : Type} {a : A} {α α' : Loop n A a}
               {B : A -> Type} {b : B a} 
               (p : Path α α') (l : LoopOver n α B b)
               → transport (\ x -> LoopOver n x B b) p l ≃ rebaseOver n B b p l
    transport-LoopOver n id l = ! (rebaseOver-idpath n l)

-}


  LoopOverS :  (n : Positive) {A : Type} {a : A} (α : Loop (S n) A a) 
             → (B : A -> Type) (b : B a) → Type
  LoopOverS n {A}{a} α B b = 
    Path{Loop n (B a) b} 
        (apt n (ap^ (S n) B α) b)
        (id^ n)

  LoopOver-is-S : (n : Positive) {A : Type} {a : A} (α : Loop (S n) A a) → (B : A -> Type) (b : B a) 
                 → LoopOver (S n) α B b ≃ LoopOverS n α B b 
  LoopOver-is-S One α B b = (move-!≃ (apt One (id ∘ ap (λ l → ap B l) α) b) id)
                                  ∘ ap (λ x → Id x id) 
                                       (transport (λ x → Id (transport B x b) b) α id ≃〈 transport-Path (λ x → transport B x b) (λ _ → b) α id 〉
                                        ap (\_ -> b) α ∘ id ∘ ! (ap (\ x -> transport B x b) α) ≃〈 ap (λ x → x ∘ id ∘ ! (ap (λ x' → transport B x' b) α)) (ap-constant b _) 〉 
                                        id ∘ id ∘ ! (ap (\ x -> transport B x b) α) ≃〈 ∘-unit-l (id ∘ ! (ap (\ x -> transport B x b) α)) 〉 
                                        id ∘ ! (ap (\ x -> transport B x b) α) ≃〈 ∘-unit-l (! (ap (λ x → transport B x b) α)) 〉 
                                        ! (ap (\ x -> transport B x b) α) ≃〈 ap !
                                                                                (ap-by-equals {f = λ x → transport B x b}
                                                                                 {g = (λ f → f b) o coe o ap B} (λ x → ap≃ (transport-ap-assoc B x)) α) 〉
                                        ! (id ∘ ap ((\ f -> f b) o coe o (ap B)) α ) ≃〈 ap ! (∘-unit-l (ap ((λ f → f b) o coe o ap B) α)) 〉
                                        ! (ap ((\ f -> f b) o coe o (ap B)) α ) ≃〈 ap ! (ap-o3 (λ f → f b) coe (ap B) α) 〉
                                        ! (ap (\ f -> f b) (ap coe ((ap (ap B)) α))) ≃〈 id 〉
                                        ! ((apt One (ap (ap B) α) b)) ≃〈 ap (λ x → ! (apt One x b)) (! (∘-unit-l (ap (ap B) α))) 〉
                                        (! (apt One (id ∘ ap (ap B) α) b) ∎))

  LoopOver-is-S (S n){A}{a} α B b = 
    transport (λ x → LoopOver (S n) x B b) α id 
    ≃ id                                              ≃〈 ap (λ x → x ≃ id) (ap≃ (transport-ap-assoc (λ x → LoopOver (S n) x B b) α)) 〉 

    coe (ap (λ x → LoopOver (S n) x B b) α) id 
    ≃ id                                              ≃〈 ap (λ x → coe x id ≃ id) (ap-loop-by-equals {f = λ x → LoopOver (S n) x B b} {g = λ x → LoopOverS n x B b} (λ x → ! (LoopOver-is-S n x B b)) α) 〉 

    coe (adj _ (ap (λ x → LoopOverS n x B b) α)) id 
    ≃ id                                               ≃〈 id 〉 

    coe (adj _ (ap (λ x → Path{Loop n (B _) b} 
                               (apt n (ap^ (S n) B x) b)
                               (id^ n))
                    α)) id ≃ id                        ≃〈 ap (λ x → coe x id ≃ id) (ap (adj _) (ap-o (\ x -> Id x (id^ n)) (λ x → apt n (ap^ (S n) B x) b) α)) 〉 

    coe (adj _ (ap (\ x -> Path x (id^ n))
                   (ap (\ x -> (apt n (ap^ (S n) B x) b)) α))) id 
    ≃ id                                                ≃〈 id 〉 

    coe (adj (! (LoopOver-is-S n id B b))
             (ap (\ x -> Path x (id^ n))
                 (ap (\ x -> (apt n (ap^ (S n) B x) b))
                     α)))
        id
    ≃ id                                                ≃〈 ap (λ x → coe x id ≃ id) (adj-def _ _) 〉 

    coe (adjust (! (LoopOver-is-S n id B b)) 
                (ap (\ x -> Path x (id^ n)) 
                    (ap (\ x -> (apt n (ap^ (S n) B x) b))
                        α)))
         id
    ≃ id                                                ≃〈 ap (λ x → x ≃ id) (ap≃ (transport-∘3 (λ x → x) (! (LoopOver-is-S n id B b)) (ap (λ x → Path x (id^ n)) (ap (λ x → apt n (ap^ (S n) B x) b) α)) (! (! (LoopOver-is-S n id B b))))) 〉 

    coe (! (LoopOver-is-S n id B b))
        (coe (ap (\ x -> Path x (id^ n))
                 (ap (\ x -> (apt n (ap^ (S n) B x) b)) α)) 
             (coe (! (! (LoopOver-is-S n id B b))) id))
    ≃ id                                                ≃〈 move-transport-right-!≃ (λ x → x) (LoopOver-is-S n id B b)〉 

    coe ((ap (\ x -> Path x (id^ n)) (ap (\ x -> (apt n (ap^ (S n) B x) b)) α))) 
         (coe (! (! (LoopOver-is-S n id B b))) id)
    ≃ coe (LoopOver-is-S n id B b) id                  ≃〈 ap (λ x → coe (ap (λ x' → Path x' (id^ n)) (ap (λ x' → apt n (ap^ (S n) B x') b) α)) (coe x id) ≃ coe (LoopOver-is-S n id B b) id) (!-invol (LoopOver-is-S n id B b)) 〉 

    coe ((ap (\ x -> Path x (id^ n)) (ap (\ x -> (apt n (ap^ (S n) B x) b)) α))) 
          (coe (LoopOver-is-S n id B b) id)
    ≃ coe (LoopOver-is-S n id B b) id                   ≃〈 ap (λ x → x ≃ (coe (LoopOver-is-S n id B b) id)) (ap≃ (! (transport-ap-assoc' (λ x → x) (λ x → Path x (id^ n)) (ap (λ x → apt n (ap^ (S n) B x) b) α)))) 〉

    transport (\ x -> Path x (id^ n)) (ap (\ x -> (apt n (ap^ (S n) B x) b)) α) 
          (coe (LoopOver-is-S n id B b) id)
    ≃ coe (LoopOver-is-S n id B b) id                  ≃〈 ap (λ x → x ≃ coe (LoopOver-is-S n id B b) id) (transport-Path-pre (ap (λ x → apt n (ap^ (S n) B x) b) α) (coe (LoopOver-is-S n id B b) id)) 〉
 
    (coe (LoopOver-is-S n id B b) id) ∘ ! (ap (\ x -> (apt n (ap^ (S n) B x) b)) α)
    ≃ coe (LoopOver-is-S n id B b) id                  ≃〈 cancel-left≃ (coe (LoopOver-is-S n id B b) id) (! (ap (λ x → apt n (ap^ (S n) B x) b) α)) 〉 

    ! (ap (\ x -> (apt n (ap^ (S n) B x) b)) α)
    ≃ id                                                ≃〈 move-!≃ (ap (λ x → apt n (ap^ (S n) B x) b) α) id 〉 

    (ap (\ x -> (apt n (ap^ (S n) B x) b)) α) 
    ≃ id                                                ≃〈 id 〉 

    (ap (\ x -> (ap^ n (\f -> f b) (ap^ n coe (loopSN1 n (ap^ (S n) B x))))) α)
    ≃ id                                                ≃〈 ap (\ x -> x ≃ id) (ap-o4 (ap^ n (\f -> f b)) (ap^ n coe) (loopSN1 n) (ap^ (S n) B) α) 〉 

    (ap (ap^ n (λ f → f b)) (ap (ap^ n coe) (ap (loopSN1 n) (ap (ap^ (S n) B) α))))
    ≃ id                                                ≃〈 adj-middle-id _ (ap (ap^ n (λ f → f b)) (ap (ap^ n coe) (ap (loopSN1 n) (ap (ap^ (S n) B) α)))) 〉 
    adj _
     (ap (ap^ n (λ f → f b)) (ap (ap^ n coe) (ap (loopSN1 n) (ap (ap^ (S n) B) α))))
    ≃ id                                                ≃〈 ap (\ x -> x ≃ id) (! lemma) 〉 

    apt (S n) (ap^ (S (S n)) B α) b ≃ id ∎

    where lemma : apt (S n) (ap^ (S (S n)) B α) b ≃ adj
                                                      _
                                                      (ap (ap^ n (λ f → f b))
                                                       (ap (ap^ n coe) (ap (loopSN1 n) (ap (ap^ (S n) B) α)))) 
          lemma = apt (S n) (ap^ (S (S n)) B α) b                                                       ≃〈 id 〉 
                  ap^ (S n) (\ f -> f b) (ap^ (S n) coe (loopSN1 (S n) (ap^ (S (S n)) B α)))            ≃〈 ! (adj-def (ap^-id n (λ f → f b) {coe id}) (ap (ap^ n (\ f -> f b)) (ap^ (S n) coe (loopSN1 (S n) (ap^ (S (S n)) B α))))) 〉 
                  (adj _ (ap (ap^ n (\ f -> f b)) (ap^ (S n) coe (loopSN1 (S n) (ap^ (S (S n)) B α))))) ≃〈 ap (adj _ o ap (ap^ n (λ f → f b))) (! (adj-def (ap^-id n coe {id}) (ap (ap^ n coe) (loopSN1 (S n) (ap^ (S (S n)) B α))))) 〉 
                  (adj _ (ap (ap^ n (\ f -> f b)) (adj _ (ap (ap^ n coe) (loopSN1 (S n) (ap^ (S (S n)) B α)))))) ≃〈 adj-bind (ap-adj (ap^ n (λ f → f b)) (ap (ap^ n coe) (loopSN1 (S n) (ap^ (S (S n)) B α))) _) 〉 
                  (adj _ (ap (ap^ n (\ f -> f b)) (ap (ap^ n coe) (loopSN1 (S n) (ap^ (S (S n)) B α))))) ≃〈 ap (adj _  o (ap (ap^ n (\ f -> f b))) o ap (ap^ n coe)) (! (adj-def (LoopPath.loopSN1-id n) (ap (loopSN1 n) (ap^ (S (S n)) B α)))) 〉
                  (adj _ (ap (ap^ n (\ f -> f b)) (ap (ap^ n coe) (adj _ (ap (loopSN1 n) (ap^ (S (S n)) B α)))))) ≃〈 ap (adj _ o (ap (ap^ n (\ f -> f b)))) (ap-adj (ap^ n coe) (ap (loopSN1 n) (ap^ (S (S n)) B α)) _)  〉
                  (adj _ (ap (ap^ n (\ f -> f b)) (adj _ (ap (ap^ n coe) (ap (loopSN1 n) (ap^ (S (S n)) B α)))))) ≃〈 adj-bind (ap-adj (ap^ n (λ f → f b)) (ap (ap^ n coe) (ap (loopSN1 n) (ap^ (S (S n)) B α))) _) 〉
                  (adj _ (ap (ap^ n (\ f -> f b)) (ap (ap^ n coe) (ap (loopSN1 n) (ap^ (S (S n)) B α))))) ≃〈 ap (adj _) (ap (λ x → ap (ap^ n (λ f → f b)) (ap (ap^ n coe) (ap (loopSN1 n) x))) (! (adj-def (ap^-id (S n) B {a}) (ap (ap^ (S n) B) α)))) 〉
                  (adj _ (ap (ap^ n (\ f -> f b)) (ap (ap^ n coe) (ap (loopSN1 n) (adj _ (ap (ap^ (S n) B) α)))))) ≃〈 ap (adj _) (ap (\ x -> (ap (ap^ n (\ f -> f b)) (ap (ap^ n coe) x))) (ap-adj (loopSN1 n) (ap (ap^ (S n) B) α) _)) 〉
                  (adj _ (ap (ap^ n (\ f -> f b)) (ap (ap^ n coe) (adj _ (ap (loopSN1 n) (ap (ap^ (S n) B) α)))))) ≃〈 ap (adj _) (ap (ap (ap^ n (λ f → f b))) (ap-adj (ap^ n coe) (ap (loopSN1 n) (ap (ap^ (S n) B) α)) _)) 〉
                  (adj _ (ap (ap^ n (\ f -> f b)) (adj _ (ap (ap^ n coe) (ap (loopSN1 n) (ap (ap^ (S n) B) α)))))) ≃〈 adj-bind (ap-adj (ap^ n (λ f → f b)) (ap (ap^ n coe) (ap (loopSN1 n) (ap (ap^ (S n) B) α))) _) 〉
                  (adj _ (ap (ap^ n (\ f -> f b)) (ap (ap^ n coe) (ap (loopSN1 n) (ap (ap^ (S n) B) α))))) ∎





  LoopType→ : ∀ n {A B} → (Loop (S n) Type A) -> Loop (S n) Type B -> Loop (S n) Type (A → B)
  LoopType→ n {A} {B} lA lB = λt n (λ (f : A → B) →
                                      λl n (λ (x : A) →
                                              ∘^ n (apt n lB (f x)) 
                                                   (ap^ n f (apt n (!^ (S n) lA) x))))
  postulate
   ap^→ : ∀ {A} → (n : _) → (C D : A → Type) → {base : A} {α : Loop (S n) A base} →
           ap^ (S n) (\ x -> C x → D x) α 
         ≃ LoopType→ n (ap^ (S n) C α) (ap^ (S n) D α)
  {-
  ap^→ One C D = {!!}
  ap^→ (S n) C D = {!!}
  -}

  Loop→OverS : (n : Positive) {A : Type} {a : A} (α : Loop (S n) A a) 
              → {B C : A → Type} (f : B a → C a)
              →   Path {Loop n (B a → C a) f}
                    (λl n
                     (λ x →
                        ∘^ n (apt n (ap^ (S n) C α) (f x))
                             (ap^ n f (apt n (!^ (S n) (ap^ (S n) B α)) x))))
                    (λl n (λ x → id^ n))
                ≃ (LoopOver (S n) α (\ x -> B x → C x) f)
  Loop→OverS n α{B}{C} f = ! (LoopOver-is-S n α (λ x → B x → C x) f) 
                          ∘ ap (λ x → Id (apt n x f) (id^ n)) (! (ap^→ n B C {_} {α})) 
                          ∘ ap (λ x → Id x (id^ n)) (! (LoopSType.β n _ _))
                          ∘ ap (Id _) (LoopΠ.η n (id^ n) ∘ ap (λl n) (λ≃ (λ x → ! (ap^-id n (λ f' → f' x)))))
 
  -- postulate
  --   ap^Loop : ∀ n k {A} {a : A} (α : Loop (S n) A a) → ap^ (S n) (λ x → Loop k A x) α ≃ λt n (λ x → rebase n (ap≃ (rebase-idpath k)) (ap^ n (λ p → rebase k p x) (coe (LoopPath {n}) α)))
--  ap^Loop n k α = {!!}
  {-
  Loop→OverS n {A} {a} α {B}{C} f = 
    ! ((LoopOver (S n) α (\ x -> B x → C x) f) ≃〈 {!!} 〉 
       LoopOverS n α (\ x -> B x → C x) f ≃〈 id 〉 
       Path{Loop n (B a → C a) f} 
           (apt n (ap^ (S n) (\ x → B x → C x) α) f)
           (id^ n) ≃〈 {!!} 〉 
       Path{Loop n (B a → C a) f} 
           (apt n (LoopType→ n (ap^ (S n) B α) (ap^ (S n) C α)) f)
           (id^ n) ≃〈 {!!} 〉 
       Path{Loop n (B a → C a) f} 
           (λl n (λ x → ∘^ n (apt n (ap^ (S n) C α) (f x)) 
                            (ap^ n f (apt n (!^ (S n) (ap^ (S n) B α)) x))))
           (id^ n) ≃〈 eta 〉 
       Path{Loop n (B a → C a) f} 
           (λl n (λ x → ∘^ n (apt n (ap^ (S n) C α) (f x)) 
                            (ap^ n f (apt n (!^ (S n) (ap^ (S n) B α)) x))))
           (λl (\ _ -> id^ n))
    ∎)
  -}

  -- note: non-dependent 
  postulate
   LoopPathOver : (n : Positive) {A : Type} {a : A} (α : Loop n A a) 
                → {B : Type} (f g : A → B) (β : Path {B} (f a) (g a))
                →   (Path {Loop n B (g a)} (rebase n β (ap^ n f α)) (ap^ n g α))
                  ≃ (LoopOver n α (\ x -> f x ≃ g x) β) 
  {-
  LoopPathOver n {A}{a} α B f g β = ua (improve (hequiv (i n α) {!!} {!!} {!!})) where
   mutual
    i : ∀ n (α : Loop n A a) 
          → (Path {Loop n B (g a)} (rebase n β (ap^ n f α)) (ap^ n g α))
          → (LoopOver n α (\ x -> f x ≃ g x) β) 
    i One α p = {!!}
    i (S n) α p = transport (λ x → LoopOver n x (λ x' → Id (f x') (g x')) β) α (idOver n (λ x → Id (f x) (g x)) β) ≃〈 {!!} 〉 
                  (i n _
                   (transport (\ x -> (Path {Loop n B (g a)} (rebase n β (ap^ n f x)) (ap^ n g x)))
                            α 
                            (e n _ (idOver n (λ x → Id (f x) (g x)) β)))) ≃〈 {!transport-by (i n)!} 〉 
                  (i n _
                   (ap (ap^ n g) α ∘
                    (e n _ (idOver n (λ x → Id (f x) (g x)) β)) ∘ 
                    ! (ap (\ x -> rebase n β (ap^ n f x)) α))) ≃〈 {!p!} 〉 
                  (i n _
                   (ap (ap^ n g) α ∘
                    (e n _ (idOver n (λ x → Id (f x) (g x)) β)) ∘ 
                    ! (ap (\ x -> rebase n β (ap^ n f x)) α))) ≃〈 {!e-id!} 〉 
                  (idOver n (λ x → Id (f x) (g x)) β ∎) where
     p' :  ap ((rebase n β) o (ap^ n f)) α 
         ≃ ! (rebase-id n β ∘ ap (rebase n β) (ap^-id n f)) 
         ∘ (ap^-id n g ∘ ap (ap^ n g) α ∘ ! (ap^-id n g) 
         ∘ ((rebase-id n β) ∘ (ap (rebase n β) (ap^-id n f))))
     p' = {!rearrange p!}

    e : ∀ n (α : Loop n A a) 
          → (LoopOver n α (\ x -> f x ≃ g x) β) 
          → (Path {Loop n B (g a)} (rebase n β (ap^ n f α)) (ap^ n g α))
    e = {!!}
  -}


  -- FIXME: should be able to derive these compositionally from a rule for 
  -- truncation and a rule for Path in general

  -- intended to to be "α ∘ β"
  LoopTypeTruncPathPost : ∀ n {A} {a : A} (α : Loop (S n) A a) (a0 : A) 
                   → Loop (S n) Type (Trunc (tlp n)(Path{A} a0 a))
  LoopTypeTruncPathPost n α a0 = λt n (Trunc-elim (λ tβ → Loop n (Trunc (tlp n) (Path a0 _)) tβ) 
                                                  (λ _ → IsNTrunc-Loop n Trunc-is) 
                                                  (λ β → ap^ n [_]
                                                        (rebase n (∘-unit-l β)
                                                           (ap^ n (λ x → x ∘ β) (loopSN1 n α)))))

  postulate
    ap^TruncPathPost : ∀ n {A} {a : A} (α : Loop (S n) A a) (a0 : A)
                → 
                Path{Loop (S n) Type (Trunc (tlp n) (Path{A} a0 a))}
                    (ap^ (S n) (\ x -> Trunc (tlp n) (Path a0 x)) α)
                    (LoopTypeTruncPathPost n α a0)


